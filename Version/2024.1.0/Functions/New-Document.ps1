<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 18:38:13                                                                  //
 \\==================================================================================================// 

    FileName   : New-Document.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : For writing a document with the [FightingEntropy()] styling
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function New-Document
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][String]$Name,
    [ValidateScript({ Try { [DateTime]$_ } Catch { Throw "Invalid date" }})]
    [Parameter()][String]$Date=([DateTime]::Now.ToString("MM/dd/yyyy")))

    Class DocumentLine
    {
        [UInt32]   $Index
        [String] $Content
        DocumentLine([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }

    Class DocumentSection
    {
        [UInt32]   $Index
        [String]    $Name
        [UInt32]  $Height
        [Object]  $Output
        DocumentSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Clear()

            $H            = @{ }

            If ($Name -eq "Title")
            {
                $This.Add("")
                ForEach ($Line in $Content)
                {
                    $This.Add($Line)
                }
                $This.Add("")
                ForEach ($Line in $This.Top())
                {
                    $This.Add($Line)
                }
            }

            If ($Name -ne "Title")
            {
                # [Head]
                ForEach ($Line in $This.Head($Name))
                {
                    $This.Add($Line)
                }

                $This.Add("")

                # [Content]
                ForEach ($Line in $Content -Split "`n")
                {
                    If ($Line.Length -gt 112)
                    {
                        $Array         = [Char[]]$Line
                        $Block         = ""
                        $X             = 0
                        Do
                        {
                            $Block    += $Array[$X]
                            If ($Block.Length -eq 112)
                            {
                                $This.Add("    $Block")
                                $Block = ""
                            }
                            $X        ++
                        }
                        Until ($X -eq $Array.Count)
        
                        If ($Block -ne "")
                        {
                            $This.Add("    $Block")
                        }
                    }
                    Else
                    {
                        $This.Add("    $Line")
                    }
                }

                # [Foot]
                ForEach ($Line in $This.Foot($Name))
                {
                    $This.Add($Line)
                }

                # [Bottom]
                If ($Name -eq "Conclusion")
                {
                    ForEach ($Line in $This.Bottom())
                    {
                        $This.Add($Line)
                    }
                }
            }
        }
        [String] Top()
        {
            Return "\".PadRight(119,[String][Char]95) + "/"
        }
        [String] Bottom()
        {
            Return "/".PadRight(119,[String][Char]175) + "\"
        }
        [String[]] Head([String]$String)
        {
            $Out  = @( )
            $X    = [String][Char]175
            $1    = $String.Length
            $0    = 115 - $1

            $Out += "  {0} /{1}\" -f $String, $X.PadLeft($0,$X)
            $Out +=   "/{0} {1} " -f $X.PadLeft(($1+2),$X), " ".PadLeft($0," ")

            Return $Out
        }
        [String[]] Foot([String]$String)
        {
            $Out  = @( )
            $X    = [String][Char]95
            $1    = $String.Length
            $0    = 115 - $1
        
            $Out += " {0} _{1}_/" -f " ".PadLeft($0," "), $X.PadLeft($1,"_")
            $Out += "\{0}/ {1}  " -f $X.PadLeft($0,$X), $String

            Return $Out
        }
        Clear()
        {
            $This.Output = @( )
            $This.Height = 0
        }
        [Object] DocumentLine([UInt32]$Index,[String]$Line)
        {
            Return [DocumentLine]::New($Index,$Line)
        }
        Add([String]$Line)
        {
            $This.Output += $This.DocumentLine($This.Output.Count,$Line)
            $This.Height  = $This.Output.Count
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class DocumentController
    {
        [String]    $Name
        [String]    $Date
        [Object] $Section
        DocumentController([String]$Name,[String]$Date)
        {
            $This.Name    = $Name
            $This.Date    = $Date
            $This.Clear()
            $This.Add("Title",$This.GetTitle())
        }
        [Object] DocumentSection([UInt32]$Index,[String]$Name,[String]$Content)
        {
            Return [DocumentSection]::New($Index,$Name,$Content)
        }
        Out([Hashtable]$Hash,[String]$Line)
        {
            $Hash.Add($Hash.Count,$Line)
        }
        Add([String]$Name,[String]$Content)
        {
            $This.Section += $This.DocumentSection($This.Section.Count,$Name,$Content)
        }
        Clear()
        {
            $This.Section  = @( )
        }
        [String] GetTitle()
        {
            Return (Write-Theme "$($This.Name) [~] $($This.Date)" -Text) -Replace "#","" -join "`n"
        }
        [String[]] GetOutput()
        {
            Return $This.Section.Output.Content
        }
    }

    [DocumentController]::New($Name,$Date)
}
