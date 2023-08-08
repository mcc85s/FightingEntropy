<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                       \\
\\  Date       : 2023-04-05 10:16:12                                                                  //
 \\==================================================================================================// 

    FileName   : New-MarkdownFile
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For categorizing information to create a new markdown file
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function New-MarkdownFile
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Name,
        [Parameter(Mandatory,Position=1)][String]$Date
    )

    Enum MarkdownSlotType
    {
        Video
        Audio
        Transcription
        Document
        Script
        Picture
        Link
        Annotation
    }
    
    Class MarkdownSlotItem
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        MarkdownSlotItem([String]$Type)
        {
            $This.Index = [UInt32][MarkdownSlotType]::$Type
            $This.Type  = [MarkdownSlotType]::$Type
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }
    
    Class MarkdownSlotList
    {
        [Object] $Output
        MarkdownSlotList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()
    
            ForEach ($Type in [System.Enum]::GetNames([MarkdownSlotType]))
            {
                $This.Add($Type)
            }
        }
        [Object] MarkdownSlotItem([String]$Type)
        {
            Return [MarkdownSlotItem]::New($Type)
        }
        Add([String]$Type)
        {
            $Item             = $This.MarkdownSlotItem($Type)
            $Item.Description = Switch ($Item.Index)
            {
                0 { "Link to a video or YouTube"                                                    }
                1 { "Audio file"                                                                    }
                2 { "Audio file that has been translated to text"                                   }
                3 { "Document that pertains to the related (post/item)"                             }
                4 { "Programming to reproduce a document, transcription, or annotation"             }
                5 { "A screenshot or graphic"                                                       }
                6 { "External link to research, video, content, audio, annotation, document, etc."  }
                7 { "Extended description or note for a particular markdown/document/transcription" }
            }
    
            $This.Output += $Item
        }
    }
    
    Class MarkdownOutputEntry
    {
        [String] $Name
        [String] $Value
        [UInt32] $Length
        MarkdownOutputEntry([String]$Name,[String]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
            If ($Name.Length -ge $Value.Length)
            {
                $This.Length = $Name.Length
            }
            If ($Value.Length -ge $Name.Length)
            {
                $This.Length = $Value.Length
            }
        }
        [String] ToString()
        {
            Return $This.Value
        }
    }
    
    Class MarkdownTypeList
    {
        [UInt32]  $Index
        [String]   $Name
        [Object] $Output
        MarkdownTypeList([UInt32]$Index,[String]$Name)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] MarkdownOutputEntry([String]$Name,[String]$Value)
        {
            Return [MarkdownOutputEntry]::New($Name,$Value)
        }
        [String[]] GetOutput()
        {
            $Hash             = @{ }
            $Grid             = @{ }
            $Swap             = @{ }
            $Max              = @{ }
            $Slot             = @{
                
                Video         = "Index","Date","NameLink","Duration"
                Audio         = "Index","Date","NameLink","Start","End","Duration"
                Transcription = "Index","Date","Name","NameDoc","NamePdf"
                Document      = "Index","Date","NameLink"
                Script        = "Index","Date","NameLink"
                Picture       = "Index","Image"
                Link          = "Index","Date","NameLink"
                Annotation    = "Index","Time","Name"
            }
    
            ForEach ($Property in $Slot[$This.Name])
            {
                $Grid.Add($Grid.Count,$Property)
                $Swap.Add($Property,@( ))
                $Header     = $Property
    
                If ($Property -match "Link")
                {
                    $Header = "Name/$($Matches[0])"
                }
    
                If ($Property -match "Doc")
                {
                    $Header = "Doc"
                }
    
                If ($Property -match "Pdf")
                {
                    $Header = "Pdf"
                }
    
                $Swap[$Property] += $This.MarkdownOutputEntry("Name",$Header)
                $Swap[$Property] += $This.MarkdownOutputEntry("Line",":")
                ForEach ($Item in $This.Output | % $Property)
                {
                    If ($Property -match "Duration")
                    {
                        $S    = $Item -Split "\:"
                        $Item = "{0}h {1}m {2}s" -f $S[0],$S[1],$S[2]
                    }
    
                    If ($This.Name -eq "Annotation" -and $Property -eq "Name")
                    {
                        $Item = "[{0}](#{1})" -f $Item, $Item.ToLower().Replace(" ","-")
                    }
    
                    If ($Property -in "Date","Start","End","Duration","Time")
                    {
                        $Item = "``" + $Item + "``"
                    }
    
                    If ($Property -match "Name")
                    {
                        $Item = "**$Item**"
                    }
    
                    $Swap[$Property] += $This.MarkdownOutputEntry("Value",$Item)
                }
    
                $Max.Add($Property,(($Swap[$Property] | Sort-Object Length)[-1].Length))
    
                ForEach ($Item in $Swap[$Property])
                {
                    $Item.Value  = $Item.Value.PadRight($Max[$Property],@(" ","-")[$Item.Name -eq "Line"])
                    $Item.Length = $Max[$Property]
                }
            }
    
            $Span = $Swap[$Grid[0]].Count
    
            ForEach ($X in 0..($Span-1))
            {
                $Line = @( )
                ForEach ($Property in $Slot[$This.Name])
                {
                    $Line += $Swap[$Property][$X].Value
                }
    
                $Line = $Line -join " | "
                $Hash.Add($Hash.Count,"| $Line |")
            }
    
            $Hash[1] = $Hash[1] -Replace "\| \:","|:-" -Replace "\- \|","--|"
    
            Return $Hash[0..($Hash.Count-1)]
        }
    }
    
    Class MarkdownVideoEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        [Timespan]      $Duration
        MarkdownVideoEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link,[String]$Duration)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[{0}]({1})" -f $This.Name, $This.Link
            $This.Duration = $Duration
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownVideoList : MarkdownTypeList
    {
        MarkdownVideoList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownVideoEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link,[String]$Duration)
        {
            Return [MarkdownVideoEntry]::New($Index,$Date,$Name,$Link,$Duration)
        }
        Add([String]$Date,[String]$Name,[String]$Link,[String]$Duration)
        {
            $This.Output += $This.MarkdownVideoEntry($This.Output.Count,$Date,$Name,$Link,$Duration)
    
            [Console]::WriteLine("Added [+] [Video: $Name]")
        }
    }
    
    Class MarkdownAudioEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        [String]           $Start
        [String]             $End
        [Timespan]      $Duration
        MarkdownAudioEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link,[String]$Start,[String]$End,[String]$Duration)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[{0}]({1})" -f $This.Name, $This.Link
            $This.Start    = $Start
            $This.End      = $End
            $This.Duration = $Duration
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownAudioList : MarkdownTypeList
    {
        MarkdownAudioList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownAudioEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link,[String]$Start,[String]$End,[String]$Duration)
        {
            Return [MarkdownAudioEntry]::New($Index,$Date,$Name,$Link,$Start,$End,$Duration)
        }
        Add([String]$Date,[String]$Name,[String]$Link,[String]$Start,[String]$End,[String]$Duration)
        {
            $This.Output += $This.MarkdownAudioEntry($This.Output.Count,$Date,$Name,$Link,$Start,$End,$Duration)
    
            [Console]::WriteLine("Added [+] [Audio: $Name]")
        }
    }
    
    Class MarkdownTranscriptionEntry
    {
        [UInt32]          $Index
        [String]           $Date
        [String]           $Name
        [String]            $Doc
        Hidden [String] $NameDoc
        [String]            $Pdf
        Hidden [String] $NamePdf
        MarkdownTranscriptionEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Doc,[String]$Pdf)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Doc      = $Doc
            $This.NameDoc  = "[Doc]({0})" -f $This.Doc
            $This.Pdf      = $Pdf
            $This.NamePdf  = "[Pdf]({0})" -f $This.Pdf
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownTranscriptionList : MarkdownTypeList
    {
        MarkdownTranscriptionList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownTranscriptionEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Doc,[String]$Pdf)
        {
            Return [MarkdownTranscriptionEntry]::New($Index,$Date,$Name,$Doc,$Pdf)
        }
        Add([String]$Date,[String]$Name,[String]$Doc,[String]$Pdf)
        {
            $This.Output += $This.MarkdownTranscriptionEntry($This.Output.Count,$Date,$Name,$Doc,$Pdf)
    
            [Console]::WriteLine("Added [+] [Transcription: $Name]")
        }
    }
    
    Class MarkdownDocumentEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        MarkdownDocumentEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[{0}]({1})" -f $This.Name, $This.Link
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownDocumentList : MarkdownTypeList
    {
        MarkdownDocumentList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownDocumentEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            Return [MarkdowndocumentEntry]::New($Index,$Date,$Name,$Link)
        }
        Add([String]$Date,[String]$Name,[String]$Link)
        {
            $This.Output += $This.MarkdownDocumentEntry($This.Output.Count,$Date,$Name,$Link)
    
            [Console]::WriteLine("Added [+] [Document: $Name]")
        }
    }
    
    Class MarkdownScriptEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        MarkdownScriptEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[{0}]({1})" -f $This.Name, $This.Link
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownScriptList : MarkdownTypeList
    {
        MarkdownScriptList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownScriptEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            Return [MarkdownScriptEntry]::New($Index,$Date,$Name,$Link)
        }
        Add([String]$Date,[String]$Name,[String]$Link)
        {
            $This.Output += $This.MarkdownScriptEntry($This.Output.Count,$Date,$Name,$Link)
    
            [Console]::WriteLine("Added [+] [Script: $Name]")
        }
    }
    
    Class MarkdownLinkEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        MarkdownLinkEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[{0}]({1})" -f $This.Name, $This.Link
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }
    
    Class MarkdownLinkList : MarkdownTypeList
    {
        MarkdownLinkList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownLinkEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            Return [MarkdownLinkEntry]::New($Index,$Date,$Name,$Link)
        }
        Add([String]$Date,[String]$Name,[String]$Link)
        {
            $This.Output += $This.MarkdownLinkEntry($This.Output.Count,$Date,$Name,$Link)
    
            [Console]::WriteLine("Added [+] [Link: $Name]")
        }
    }

    Class MarkdownPictureEntry
    {
        [UInt32]           $Index
        [String]            $Date
        [String]            $Name
        [String]            $Link
        [String]           $Image
        MarkdownPictureEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            $This.Index    = $Index
            $This.Date     = $Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.Image    = "![{0}]({1})" -f $Link.Split("/")[-1], $Link
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.Date, $This.Name
        }
    }

    Class MarkdownPictureList : MarkdownTypeList
    {
        MarkdownPictureList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownPictureEntry([UInt32]$Index,[String]$Date,[String]$Name,[String]$Link)
        {
            Return [MarkdownPictureEntry]::New($Index,$Date,$Name,$Link)
        }
        Add([String]$Date,[String]$Name,[String]$Link)
        {
            $This.Output += $This.MarkdownPictureEntry($This.Output.Count,$Date,$Name,$Link)
    
            [Console]::WriteLine("Added [+] [Picture: $Name]")
        }
    }
    
    Class MarkdownAnnotationEntryLine
    {
        [UInt32]   $Index
        [String] $Content
        MarkdownAnnotationEntryLine([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }
    
    Class MarkdownAnnotationEntry
    {
        [UInt32]  $Index
        [Timespan] $Time
        [String]   $Name
        [Object]   $Note
        MarkdownAnnotationEntry([UInt32]$Index,[String]$Time,[String]$Name,[String]$Note)
        {
            $This.Main($Index,$Time,$Name)
            $This.SetNote($Note)
        }
        MarkdownAnnotationEntry([UInt32]$Index,[String]$Time,[String]$Name)
        {
            $This.Main($Index,$Time,$Name)
        }
        Main([UInt32]$Index,[String]$Time,[String]$Name)
        {
            $This.Index    = $Index
            $This.Time     = $Time
            $This.Name     = $Name
        }
        SetNote([String]$Note)
        {
            $This.Clear()
    
            ForEach ($Line in $Note.Split("`n"))
            {
                $This.Add($Line)
            }
        }
        Clear()
        {
            $This.Note = @( )
        }
        [Object] MarkdownAnnotationEntryLine([Uint32]$Index,[String]$Content)
        {
            Return [MarkdownAnnotationEntryLine]::New($Index,$Content)
        }
        Add([String]$Content)
        {
            $This.Note += $This.MarkdownAnnotationEntryLine($This.Note.Count,$Content)
        }
        [String] ToString()
        {
            Return "[{0}](#{1})" -f $This.Name, $This.Name.ToLower().Replace(" ","-")
        }
    }
    
    Class MarkdownAnnotationList : MarkdownTypeList
    {
        MarkdownAnnotationList([UInt32]$Index,[String]$Name) : base($Index,$Name)
        {
    
        }
        [Object] MarkdownAnnotationEntry([UInt32]$Index,[String]$Time,[String]$Name)
        {
            Return [MarkdownAnnotationEntry]::New($Index,$Time,$Name)
        }
        [Object] MarkdownAnnotationEntry([UInt32]$Index,[String]$Time,[String]$Name,[String]$Note)
        {
            Return [MarkdownAnnotationEntry]::New($Index,$Time,$Name,$Note)
        }
        Add([String]$Time,[String]$Name)
        {
            $This.Output += $This.MarkdownAnnotationEntry($This.Output.Count,$Time,$Name)
    
            [Console]::WriteLine("Added [+] [Annotation: $Name]")
        }
        Add([String]$Time,[String]$Name,[String]$Note)
        {
            $This.Output += $This.MarkdownAnnotationEntry($This.Output.Count,$Time,$Name,$Note)
    
            [Console]::WriteLine("Added [+] [Annotation: $Name]")
        }
    }

    Class MarkdownThumbnail
    {
        [UInt32] $Enabled
        [String]    $Link
        MarkdownThumbnail()
        {

        }
        SetThumbnail([String]$Link)
        {
            $This.Enabled = 1
            $This.Link    = $Link
        }
    }
    
    Class MarkdownFile
    {
        [String]        $Name
        [String]        $Date
        [String] $Description
        [Object]   $Thumbnail
        Hidden [Object] $Slot
        [Int32]     $Selected
        [Object]      $Output
        MarkdownFile([String]$Name,[String]$Date)
        {
            $This.Name   = $Name
            $This.Date   = $Date
            $This.Slot   = $This.MarkdownSlotList()
            $This.Clear()
        }
        MarkdownFile([String]$Name,[String]$Date,[String]$Description)
        {
            $This.Name   = $Name
            $This.Date   = $Date
            $This.Slot   = $This.MarkdownSlotList()
            $This.Clear()
        }
        SetDescription([String]$Description)
        {
            $This.Description = $Description
        }
        SetThumbnail([String]$Url)
        {
            $This.Thumbnail.SetThumbnail($Url)
        }
        Clear()
        {
            $This.Thumbnail = $This.MarkdownThumbnail()
            $This.Output    = @( )
        }
        [Object] MarkdownThumbnail()
        {
            Return [MarkdownThumbnail]::New()
        }
        [Object] MarkdownSlotList()
        {
            Return [MarkdownSlotList]::New().Output
        }
        [Object] MarkdownVideoList() 
        {
            Return [MarkdownVideoList]::New($This.Output.Count,"Video")
        }
        [Object] MarkdownAudioList()
        {
            Return [MarkdownAudioList]::New($This.Output.Count,"Audio")
        }
        [Object] MarkdownTranscriptionList()
        {
            Return [MarkdownTranscriptionList]::New($This.Output.Count,"Transcription")
        }
        [Object] MarkdownDocumentList()
        {
            Return [MarkdownDocumentList]::New($This.Output.Count,"Document")
        }
        [Object] MarkdownScriptList()
        {
            Return [MarkdownScriptList]::New($This.Output.Count,"Script")
        }
        [Object] MarkdownPictureList()
        {
            Return [MarkdownPictureList]::New($This.Output.Count,"Picture")
        }
        [Object] MarkdownLinkList()
        {
            Return [MarkdownLinkList]::New($This.Output.Count,"Link")
        }
        [Object] MarkdownAnnotationList()
        {
            Return [MarkdownAnnotationList]::New($This.Output.Count,"Annotation")
        }
        AddSlotIndex([UInt32]$Slot)
        {
            If ($Slot -notin $This.Slot.Index)
            {
                Throw "Invalid slot number"
            }
    
            $Item = Switch($Slot)
            {
                0 { $This.MarkdownVideoList()         }
                1 { $This.MarkdownAudioList()         }
                2 { $This.MarkdownTranscriptionList() }
                3 { $This.MarkdownDocumentList()      }
                4 { $This.MarkdownScriptList()        }
                5 { $This.MarkdownPictureList()       }
                6 { $This.MarkdownLinkList()          }
                7 { $This.MarkdownAnnotationList()    }
            }
    
            If ($Item.Name -in $This.Output.Name)
            {
                Throw "List type already loaded"
            }
    
            $This.Output += $Item
        }
        AddSlotType([String]$Type)
        {
            If ($Type -notin $This.Slot.Type)
            {
                Throw "Invalid slot name"
            }
    
            ElseIf ($Type -in $This.Output.Name)
            {
                Throw "List type already loaded"
            }
    
            $Item = Switch ($Type)
            {
                Video         { $This.MarkdownVideoList()         }
                Audio         { $This.MarkdownAudioList()         }
                Transcription { $This.MarkdownTranscriptionList() }
                Document      { $This.MarkdownDocumentList()      }
                Script        { $This.MarkdownScriptList()        }
                Picture       { $This.MarkdownPictureList()       }
                Link          { $This.MarkdownLinkList()          }
                Annotation    { $This.MarkdownAnnotationList()    }
            }
    
            $This.Output += $Item
        }
        Add([String]$Entry)
        {
            Switch -Regex ($Entry)
            {
                "^\d$" { $This.AddSlotIndex($Entry) } Default { $This.AddSlotType($Entry) }
            }
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }
    
            $This.Selected = $Index
        }
        [Object] Current()
        {
            If ($This.Selected -lt 0)
            {
                Throw "Item not yet selected"
            }
    
            Return $This.Output[$This.Selected]
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }
    
            Return $This.Output[$Index]
        }
        [Void] Out([Hashtable]$Hash,[Object]$Object)
        {
            ForEach ($Item in $Object)
            {
                $Hash.Add($Hash.Count,$Item)
            }
        }
        [String] GetId([Object]$Item)
        {
            Return "[[{0}](#{1})]" -f $Item.Name, $Item.Name.ToLower()
        }
        [String[]] GetOutput()
        {
            $H = @{ }
            $C = $This.Output.Count

            $This.Out($H,("# {0} [{1}]" -f $This.Name, $This.Date))
            $This.Out($H,"")

            If ($This.Description)
            {
                $This.Out($H,"| Description |")
                $This.Out($H,"|:------------|")
                $This.Out($H,("| {0} |" -f $This.Description))
                $This.Out($H,"")
            }
    
            # Label Loop
            Switch ($C)
            {
                {$_ -eq 1}
                {
                    $This.Out($H,$This.GetId($This.Output[0]))
                }
                {$_ -gt 1}
                {
                    $Head = ForEach ($X in 0..($C-1))
                    {
                        $This.GetId($This.Output[$X])
                    }
        
                    $This.Out($H,($Head -join " - "))
                }
            }
            $This.Out($H,"")

            # Thumbnail
            If ($This.Thumbnail.Enabled)
            {
                $This.Out($H,'<p align="center" width="100%">')
                $This.Out($H,('    <img width="66%" src="{0}">' -f $This.Thumbnail.Link))
                $This.Out($H,'</p>')
                $This.Out($H,"")
            }
    
            # Content Loop
            ForEach ($X in 0..($C-1))
            {
                $This.Out($H,("## {0}" -f $This.Output[$X].Name))
                $This.Out($H,"")
                $This.Out($H,$This.Output[$X].GetOutput())
                $This.Out($H,"")
            }
    
            # Annotation Loop
            If ("Annotation" -in $This.Output.Name)
            {
                $Annotation = $This.Output | ? Name -eq Annotation
                ForEach ($Item in $Annotation.Output)
                {
                    # Sublabel
                    $This.Out($H,("## {0}" -f $Item.Name))
                    
                    # Time/Name
                    $Time = "``" + $Item.Time.ToString() + "``"
                    $Id   = $Item.Name.ToString()
                    $This.Out($H,("| {0} | {1} |" -f "Time".PadRight($Time.Length," "), "Name".PadRight($Id.Length," ")))
                    $This.Out($H,("|:{0}-|:{1}-|" -f "-".PadRight($Time.Length,"-"), "-".PadRight($Id.Length,"-")))
                    $This.Out($H,("| {0} | {1} |" -f $Time, $Id))
                    $This.Out($H,"")
    
                    # Note
                    If ($Item.Note -ne "")
                    {
                        $This.Out($H,"``````")
                        $This.Out($H,$Item.Note)
                        $This.Out($H,"``````")
                        $This.Out($H,"")
                    }
                }
            }
    
            Return $H[0..($H.Count-1)]
        }
    }

    [MarkdownFile]::New($Name,$Date)
}

