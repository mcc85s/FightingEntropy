<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName : Write-Resume.ps1
          Solution : FightingEntropy Write-Resume
          Purpose  : To make a pretty deep impression on anybody who looks at your resume...
          Author   : Michael C. Cook Sr.
          Contact  : @mcc85s
          Primary  : @mcc85s
          Created  : 2022-08-11
          Modified : 2022-08-19
          Demo     : https://youtu.be/QSuge7p5_I8
          Version  : 0.0.0 - () - Finalized functional version 1
          TODO     : 
.Example
#>


Function Write-Resume
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Name,
        [Parameter(Mandatory,Position=1)][String]$Title)

    # // Default Mask Class
    Class Mask
    {
        Static [UInt32] $Count = 57
        Static [Byte[]] Tray([UInt32]$Index)
        {
            Return @(Switch ($Index)
            {
                00 {    "32 32 32 32"} 01 {    "95 95 95 95"} 02 {"175 175 175 175"} 03 {    "45 45 45 45"} 
                04 {    "32 32 32 47"} 05 {    "92 32 32 32"} 06 {    "32 32 32 92"} 07 {    "47 32 32 32"} 
                08 {    "92 95 95 47"} 09 {  "47 175 175 92"} 10 { "47 175 175 175"} 11 { "175 175 175 92"} 
                12 {    "92 95 95 95"} 13 {    "95 95 95 47"} 14 {    "91 32 95 95"} 15 {    "95 95 32 93"} 
                16 {    "42 32 32 32"} 17 {    "32 32 42 32"} 18 {    "32 32 32 42"} 19 {    "32 42 32 32"} 
                20 {    "91 61 61 93"} 21 {    "91 45 45 93"} 22 { "175 175 175 93"} 23 { "91 175 175 175"} 
                24 {    "32 32 32 93"} 25 {    "91 95 95 95"} 26 {    "95 95 95 93"} 27 {    "92 95 95 91"} 
                28 {    "32 95 95 95"} 29 {    "95 95 95 32"} 30 {    "93 95 95 47"} 31 {  "47 175 175 91"}
                32 {    "93 32 32 32"} 33 {   "32 32 32 124"} 34 {    "95 95 32 32"} 35 {    "32 32 95 95"}
                36 {   "124 32 32 32"} 37 {  "175 175 92 95"} 38 {  "95 47 175 175"} 39 {   "92 95 95 124"} 
                40 {  "47 175 175 32"} 41 {   "32 32 32 175"} 42 {   "175 32 32 32"} 43 {  "32 175 175 32"} 
                44 {  "32 175 175 92"} 45 {"175 175 175 124"} 46 {    "32 32 32 91"} 47 {    "61 61 61 61"}
                48 {    "92 95 95 32"} 49 {    "32 32 32 95"} 50 {    "95 32 32 32"} 51 {    "32 95 95 32"}
                52 {   "95 95 47 175"} 53 {   "175 92 95 95"} 54 {  "175 175 32 32"} 55 {  "32 32 175 175"}
                56 {  "124 61 61 124"}
            }) -Split " "
        }
    }

    # // Creates a guide for the function and debugging/editing
    Class ThemeMask       
    {
        [UInt32]         $Index
        [String]          $Face
        Hidden [Byte[]]   $Byte
        Hidden [UInt32[]]  $Int
        [Char[]]          $Char
        ThemeMask([UInt32]$Index,[Byte[]]$Byte)
        {
            $This.Index = $Index
            $This.Byte  = $Byte
            $This.Int   = [UInt32[]]($Byte)
            $This.Char  = [Char[]]($This.Int)
            $This.Face  = $This.Char -join ''
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    # // Container object for blocks that represent a desired theme/mask 
    Class ThemeFace
    {
        [Object[]]      $Guide
        [Object[]]      $Output
        ThemeFace()
        {
            $This.Guide = ForEach ($X in 0..([Mask]::Count-1))
            { 
                [ThemeMask]::New($X,[Mask]::Tray($X))
            }
            $This.Output = $This.Guide.Face
        }
    }

    # // This is a 1x[track] x 4[char] chunk of information for Write-Host
    Class ThemeBlock      
    {
        [Int32]              $Index
        [Object]            $Object
        [Int32]    $ForegroundColor
        [Int32]    $BackgroundColor
        [Int32]          $NoNewLine = 1
        ThemeBlock([Int32]$Index,[String]$Object,[Int32]$ForegroundColor,[Int32]$BackgroundColor)
        {
            $This.Index             = $Index
            $This.Object            = $Object
            $This.ForegroundColor   = $ForegroundColor
            $This.BackgroundColor   = $BackgroundColor
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    # // Represents a 1x[track] in a stack of tracks
    Class ThemeTrack      
    {
        [UInt32]        $Index
        [String[]]     $Object
        [UInt32[]] $Foreground
        [UInt32[]] $Background
        [Object]         $Mask
        ThemeTrack([UInt32]$Index)
        {
            $This.Index                = $Index
            $This.Object               = [ThemeFace]::New().Output[@(0)*30]
            $This.Foreground           = @(0)*30
            $This.Background           = @(0)*30
            $This.GetMask()
        }
        ThemeTrack([UInt32]$Index,[String]$Mask,[String]$Foreground,[String]$Background)
        {
            $This.Index                = $Index
            $This.Object               = [ThemeFace]::New().Output[(Invoke-Expression $Mask)]
            $This.Foreground           = Invoke-Expression $Foreground
            $This.Background           = Invoke-Expression $Background
            $This.GetMask()
        }
        GetMask()
        {
            $This.Mask                 = @( )
            0..( $This.Object.Count - 1 ) | % { 
                
                $This.Mask += [ThemeBlock]::New($_,$This.Object[$_],$This.Foreground[$_],$This.Background[$_])
            }
            $This.Mask[-1].NoNewLine = 0
        }
        [String] ToString()
        {
            Return $This.Index
        }
        Draw([UInt32[]]$Palette=@(10,12,15,0))
        {
            ForEach ($X in 0..($This.Mask.Count-1))
            {
                $Splat              = @{

                    Object          = $This.Object[$X]
                    ForegroundColor = @($Palette)[$This.Mask[$X].ForegroundColor]
                    BackgroundColor = $This.Mask[$X].BackgroundColor
                    NoNewLine       = $X -ne ($This.Mask.Count - 1)
                }

                Write-Host @Splat
            }
        }
    }
    
    # // Generates a range of templates based on InputObject types/mixtures
    Class ThemeTemplate   
    {
        Hidden [Hashtable] $StringStr = @{

            00 = "@(0,1;@(0)*25;1,0,0)"
            01 = "@(4,9,12;@(1)*23;13,9,12,0)"
            02 = "@(6,8,10;@(2)*23;11,8,9,5)"
            03 = "@(33,9,27,28;@(1)*21;29,30,9,8,7)"
            04 = "@(33,8,10;@(2)*24;33,56,36)"
            05 = "@(33,9,12;@(1)*24;13,9,36)"
            06 = "@(33;@(8,37,38)*9;8,36)"
            07 = "@(33,10;@(2)*26;11,36)"
            08 = "@(33;@(0)*28;36)"
            09 = "@(33,5;@(0)*26;4,36)"
            10 = "@(33,7;@(0)*26;6,36)"
            11 = "@(6,12;@(1)*26;13,7)"
            12 = "@(46;@(47)*28;32)"
            13 = "@(4;@(2)*28;5)"
            14 = "@(6;@(0)*28;7)"
            15 = "@(4;@(0)*28;5)"
            16 = "@(6;@(1)*28;7)"
            17 = "@(4,10;@(2)*26;11,5)"
            18 = "@(33,36;@(0)*26;33,36)"
            19 = "@(6,12;@(1)*26;13,7)"
            20 = "@(0;@(2)*28;0)"
        }
        Hidden [Hashtable] $ForeStr = @{
            
            00 = "@(@(0)*30)"
            01 = "@(0,1;@(0)*25;1,0,0)"
            02 = "@(0,1;@(0)*25;1,1,0)"
            03 = "@(0,1,0;@(2)*23;0,0,1,0)"
            04 = "@(0,1;@(0)*26;1,0)"
            05 = "@(0,1;@(0)*26;1,0)"
            06 = "@(0;@(1)*28;0)"
            07 = "@(0;@(0)*28;0)"
            08 = "@(0,1;@(2)*26;1,0)"
            09 = "@(0,1;@(2)*26;1,0)"
            10 = "@(0,1;@(2)*26;1,0)"
            11 = "@(0;@(1)*28;0)"
            12 = "@(0;@(2)*28;0)"
            13 = "@(@(0)*30)"
            14 = "@(0,0;@(2)*26;0,0)"
            15 = "@(0,0;@(2)*26;0,0)"
            16 = "@(@(0)*30)"
            17 = "@(0;@(1)*28;0)"
            18 = "@(0,1;@(2)*26;1,0)"
            19 = "@(0;@(1)*28;0)"
            20 = "@(@(0)*30)"
        }
        Hidden [String[]] $BackStr = ( 0..20 | % { "@({0})" -f ( @(0)*30 -join ',' ) } )
        [String]        $Name
        [Int32]       $Header
        [Int32]         $Body
        [Int32]       $Footer
        [String[]]    $String
        [String[]]      $Fore
        [String[]]      $Back
        [Object[]]     $Track
        ThemeTemplate()
        {
            $This.Name   = "Table"
            $Span        = 0..20
            $This.Header = 3
            $This.Body   = 8
            $This.Footer = -1
            $This.String = @($Span | % { $This.StringStr[$_] })
            $This.Fore   = @($Span | % { $This.ForeStr[$_] })
            $This.Back   = @($Span | % { $This.BackStr[$_] })
            $This.Track  = @( )
            ForEach ($X in 0..($This.String.Count - 1))
            {
                $This.Track += [ThemeTrack]::New($X,$This.String[$X],$This.Fore[$X],$This.Back[$X])
            }
        }
        [Object] Guide()
        {
            Return @(
            # Guide
            "[Guide]{0}" -f ("_"*149 -join '');

            # Ruler
            "|  --|",(@(0..29 | % {"  {0:d2}" -f $_}) -join "|"),"| __[Mask] __" -join '';

            # Section
            ForEach ($X in 0..($This.Track.Count-1)){ "|  {0:d2}|{1}| {2}" -f $X,($This.Track[$X].Mask.Object -join "|"),$This.String[$X]};

            # End
            [Char]175 * 156 -join '')
        }
        Display()
        {
            Write-Host ("[Theme]{0}" -f ("_" * 113 -join ''))
            $This.Draw(@(10,12,15,0))
            Write-Host ([Char]175 * 120 -join '')
        }
        Draw([UInt32[]]$Palette)
        {
            ForEach ($Track in $This.Track)
            {
                $Track.Draw($Palette)
            }
        }
        Draw()
        {
            ForEach ($Track in $This.Track)
            {
                $Track.Draw(@(10,12,15,0))
            }
        }
    }

    # // Meant to provide IMPLICIT dimensions for tracks and lengths
    Class Guide
    {
        [String] $Name
        [UInt32] $Start
        [UInt32] $End
        [UInt32] $Length
        Static [String[]] Types()
        {
            Return "Mask Header Qualification Employer Section Education Skill" -Split " "
        }
        Guide([String]$Name)
        {
            If ($Name -notin [Guide]::Types())
            {
                Throw "Invalid type"
            }

            $This.Name  = $Name
            $X          = Switch ($Name)
            {
                Mask { 0,0 } Header { 13,103 } Default { 8,112 }
            }
            $This.Start  = $X[0]
            $This.End    = $X[1]
            $This.Length = $X[1] - $X[0]
        }
    }

    # // Class for collecting individual qualifications
    Class Qualification
    {
        [UInt32]           $Index
        [UInt32]          $Length
        [String]     $Description
        Qualification([UInt32]$Index,[String]$Description)
        {
            $This.Index       = $Index
            $This.Length      = $Description.Length
            $This.Description = $Description
        }
        [String] ToString()
        {
            Return $This.Description
        }
    }

    # // Class for collecting a SINGLE STRING or MULTIPLE STRINGS for each ACCOMPLISHMENT/STUDY/DESCRIPTION
    Class Detail
    {
        [UInt32]         $Index
        [String[]] $Description
        Detail([UInt32]$Index,[String]$Description)
        {
            $This.Index       = $Index
            $This.Description = $Description -Split "`n"
        }
        [String] Center([Object]$Length,[String]$String)
        {
            If ($String.Length -lt $Length)
            {
                $Buffer       = $Length - $String.Length
                $Split        = [Math]::Round($Buffer / 2,[MidpointRounding]::ToZero)
                If ($Split -eq 0)
                {
                    Return $String
                }
                Else
                {
                    $String   = "{0}{1}{0}" -f (@(" ") * $Split -join ''), $String
                    If ($String.Length -lt $Length)
                    {
                        $String += " "
                    }
                    Return $String
                }
            }
            Else 
            {
                Return $String
            }
        }
        [String] ToString()
        {
            Return "<Detail[$($This.Index)]>"
        }
        [String[]] Output()
        {
            $Out = @()
            If ($This.Description.Count -eq 1)
            {
                $Out += "[+] {0}" -f $This.Description
            }
            If ($This.Description.Count -gt 1)
            {
                $F               = 0
                $X               = 0
                $Out            += "[+] {0}" -f $This.Description[$X]
                $X              ++
                Do
                {
                    If ($This.Description[$X] -match "_{4,}")
                    {
                        $F       = 1
                        $Line    = $This.Center(104,$This.Description[$X])
                    }
                    ElseIf ($F -eq 1)
                    {
                        $Line    = $This.Center(104,$This.Description[$X])
                        If ($This.Description[$X] -match "¯{4,}")
                        {
                            $F   = 0
                        }
                    }
                    Else
                    {
                        $Line    = "    {0}" -f $This.Description[$X]
                    }
                    $Out        += $Line
                    $X          ++
                }
                Until ($X -eq $This.Description.Count)
            }
            Return $Out
        }
    }

    # // Employer object, meant to collect 1) Name, 2) Location, 3) Dates, 4) Title, and 5) Details
    Class Employer
    {
        Hidden [Object] $Guide
        [UInt32]        $Index
        [String]         $Name
        [String]     $Location
        [String]         $Date
        [String]        $Title
        [Object[]]     $Detail
        Employer([UInt32]$Index,[String]$Name,[String]$Location,[String]$Date,[String]$Title)
        {
            $This.Guide    = [Guide]::New("Employer")
            If ($Date -notmatch [Employer]::DateFormat())
            {
                Throw "Date must be in 'MO/YEAR - MO/YEAR' format"
            }
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Location = $Location
            $This.Date     = [Regex]::Matches($Date,[Employer]::DateFormat()).Value
            $This.Title    = $Title
            $This.Detail   = @( )
        }
        Static [String] DateFormat()
        {
            Return "(\d{2}\/\d{4}\s{1}\-\s{1}\d{2}\/\d{4})"
        }
        AddDetail([String[]]$Detail)
        {
            If ($Detail -in $This.Detail)
            {
                Throw "<Detail> already specified"
            }

            $This.Detail += [Detail]::New($This.Detail.Count,$Detail)
        }
        RemoveDetail([UInt32]$Index)
        {
            If (!$This.Detail[$Index])
            {
                Throw "Invalid <Detail>"
            }

            $This.Detail = $This.Detail | ? Description -ne $This.Detail[$Index].Description
            $This.Rerank()
        }
        Rerank()
        {
            Switch ($This.Detail.Count)
            {
                Default {}
                {$_ -eq 1}
                {
                    $This.Detail[0].Index = 0
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($This.Detail.Count-1))
                    {
                        $This.Detail[$X].Index = $X
                    }
                }
            }
        }
        [String[]] Details([Hashtable]$Hash)
        {
            $This.Detail.Output() | % { $Hash.Add($Hash.Count,$_) }

            Return @($Hash[0..($Hash.Count-1)])
        }
        [String[]] Output()
        {
            $Length           = $This.Guide.Length
            If ($This.Index -eq 0)
            {
                $SkimBuff     = $Length - 4
                $DateLength   = $Length - 24
                $Hash         = @{0="";1="";2="";3="";4="";5=""}
                $Hash[1]      = "| {0} - {1} |" -f $This.Name, $This.Location
                If ($Hash[1].Length -ge $DateLength)
                {
                    Throw "Employer name and location too long (80 chars max)"
                }

                $Hash[0]      = @("_") * $Hash[1].Length -join ""
                $Hash[2]      = @([char]175) * $Hash[1].Length -join ""
                Do
                {
                    0..2      | % { $Hash[$_] += " " }
                }
                Until ($Hash[1].Length -eq 83)
                $Hash[0]     += @("_") * 21 -join ""
                $Hash[1]     += "| {0} |" -f $This.Date
                $Hash[2]     += @([char]175) * 21 -join ""
                $Hash[4]      = $This.Title
                If ($Hash[4].Length -ge $SkimBuff)
                {
                    Throw "Employment title too long ($SkimBuff char max)"
                }
                If ($Hash[4].Length -lt 100)
                {
                    $Hash[4]  = "| {0} |" -f $Hash[4]
                    $Hash[3]  = @("_") * $Hash[4].Length -join ''
                    $Hash[5]  = @([Char]175) * $Hash[4].Length -join ''
                    $Buffer   = $Length - $Hash[4].Length
                    $Split    = [Math]::Round($Buffer / 2,[MidpointRounding]::ToZero)
                    $Hash[3]  = "{0}{1}{0}" -f (@(" ") * $Split -join ''), $Hash[3]
                    $Hash[4]  = "{0}{1}{0}" -f (@(" ") * $Split -join ''), $Hash[4]
                    $Hash[5]  = "{0}{1}{0}" -f (@(" ") * $Split -join ''), $Hash[5]
                    If ($Hash[4].Length -le $Length)
                    {
                        3..5  | % { $Hash[$_] += " " }
                    }
                }
                Return $This.Details($Hash)
            }

            ElseIf ($This.Index -gt 0)
            {
                $DateLength   = $Length - 18
                $Hash         = @{0="";1="";2="";3="";4=""}
                $Hash[1]      = "{0} - {1}" -f $This.Name, $This.Location
                If ($Hash[1].Length -ge $DateLength)
                {
                    Throw "Employer name and location too long (86 chars max)"
                }
                Do
                {
                    $Hash[1] += " "
                }
                Until ($Hash[1].Length -eq $DateLength)
                $Hash[1]     += $This.Date
                $Hash[2]     += $This.Title
                Do
                {
                    $Hash[2] += " "
                }
                Until ($Hash[2].Length -eq $Length)
                Do
                {
                    $Hash[0] += [char]175
                    $Hash[3] += [char]95
                    $Hash[4] += [char]175
                }
                Until ($Hash[0].Length -eq $Length)
                $Hash[0] += [char]175
                $Hash[3] += [char]95
                $Hash[4] += [char]175

                Return $This.Details($Hash)
            }

            Else
            {
                Return $Null
            }
        }
    }

    # // Education object, meant to collect 1) Name, 2) Location, 3) Dates, 4) Focus, and 5) Details                  
    Class Education
    {
        Hidden [Object] $Guide
        [UInt32]        $Index
        [String]         $Name
        [String]     $Location
        [String]         $Date
        [String]        $Focus
        [Object[]]     $Detail
        Education([UInt32]$Index,[String]$Name,[String]$Location,[String]$Date,[String]$Focus)
        {
            $This.Guide          = [Guide]::New("Education")
            $This.Index          = $Index
            $This.Name           = $Name
            $This.Location       = $Location
            $This.Focus          = $Focus
            $This.Date           = $Date
            $This.Detail         = @( )
        }
        AddDetail([String]$Detail)
        {
            If ($Detail -in $This.Detail)
            {
                Throw "<Detail> already specified"
            }

            $This.Detail += [Detail]::New($This.Detail.Count,$Detail)
        }
        RemoveDetail([UInt32]$Index)
        {
            If (!$This.Detail[$Index])
            {
                Throw "Invalid <Detail>"
            }

            $This.Detail = $This.Detail | ? Description -ne $This.Detail[$Index].Description
        }
        Rerank()
        {
            Switch ($This.Detail.Count)
            {
                Default {}
                {$_ -eq 1}
                {
                    $This.Detail[0].Index = 0
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($This.Detail.Count-1))
                    {
                        $This.Detail[$X].Index = $X
                    }
                }
            }
        }
        [String[]] Details([Hashtable]$Hash)
        {
            $This.Detail.Output() | % { $Hash.Add($Hash.Count,$_) }

            Return @($Hash[0..($Hash.Count-1)])
        }
        [String[]] Output()
        {
            $Length           = $This.Guide.Length
            $DateLength       = $Length - 18
            $Hash             = @{0="";1="";2="";3="";4=""}
            $Hash[1]          = "{0} - {1}" -f $This.Name, $This.Location
            If ($Hash[1].Length -ge $DateLength)
            {
                Throw "Employer name and location too long ($DateLength chars max)"
            }
            Do
            {
                $Hash[1]     += " "
            }
            Until ($Hash[1].Length -eq $DateLength)
            $Hash[1]         += $This.Date
            $Hash[2]         += $This.Focus
            Do
            {
                $Hash[2]     += " "
            }
            Until ($Hash[2].Length -eq $Length)
            Do
            {
                $Hash[0] += [char]175
                $Hash[3] += [char]95
                $Hash[4] += [char]175
            }
            Until ($Hash[0].Length -eq $Length)
            $Hash[0] += [char]175
            $Hash[3] += [char]95
            $Hash[4] += [char]175

            Return $This.Details($Hash)
        }
    }

    # // To be expanded, provides a type name and value
    Class SkillDetail
    {
        [String] $Name
        [String] $Value
        SkillDetail([String]$Name,[String]$Value)
        {
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return $This.Value
        }
    }

    # // Skill object (basically URLs to portfolio items/objects)
    Class Skill
    {
        Hidden [Object]  $Guide 
        [UInt32]         $Index
        [String]          $Name
        [String]          $Date
        [Object]        $Detail
        [String[]] $Description
        Skill([UInt32]$Index,[String]$Name,[String]$Date,[String]$Detail,[String]$Description)
        {
            $This.Guide       = [Guide]::New("Skill")
            $This.Index       = $Index
            $This.Name        = $Name
            $This.Date        = $Date
            $DetailName       = @("Unspecified","Hyperlink")[$Detail -match "^http(s*):\/\/"]
            $This.Detail      = [SkillDetail]::New($DetailName,$Detail)
            $This.Description = $Description -Split "`n"
        }
        [String] ToString()
        {
            Return $This.Name
        }
        [String[]] Details([Hashtable]$Hash)
        {
            $This.Description | % { $_.ToString() } | % { $Hash.Add($Hash.Count,$_) }

            Return $Hash[0..($Hash.Count-1)]
        }
        [String[]] Output()
        {
            $Length           = $This.Guide.Length
            $DateLength       = $Length - 7
            $Hash             = @{0="";1="";2="";3="";4=""}
            $Hash[1]          = $This.Name
            If ($Hash[1].Length -ge $DateLength)
            {
                Throw "Skill name too long ($DateLength chars max)"
            }
            Do
            {
                $Hash[1]     += " "
            }
            Until ($Hash[1].Length -eq $DateLength)
            $Hash[1]         += $This.Date
            $Hash[2]          = $This.Detail.Value
            Do
            {
                $Hash[2]     += " "
            }
            Until ($Hash[2].Length -eq $Length)
            Do
            {
                $Hash[0]     += [char]175
                $Hash[3]     += [char]95
                $Hash[4]     += [char]175
            }
            Until ($Hash[0].Length -eq $Length)
            $Hash[0] += [char]175
            $Hash[3] += [char]95
            $Hash[4] += [char]175

            Return $This.Details($Hash)
        }
    }

    # // The person who the resume object will reflect
    Class Person
    {
        [String]            $Name
        [String]           $Title
        [Object[]] $Qualification
        [Object[]]      $Employer
        [Object[]]     $Education
        [Object[]]         $Skill
        Person([String]$Name,[String]$Title)
        {
            $This.Name          = $Name
            $This.Title         = $Title
            $This.Qualification = @( )
            $This.Employer      = @( )
            $This.Education     = @( )
            $This.Skill         = @( )
        }
        AddQualification([String]$Description)
        {
            If ($Description -in $This.Qualification.Description)
            {
                Throw "<Qualification> already specified"
            }

            $This.Qualification += [Qualification]::New($This.Qualification.Count,$Description)
        }
        RemoveQualification([UInt32]$Index)
        {
            If (!$This.Qualification[$Index])
            {
                Throw "Invalid <Qualification>"
            }

            $This.Qualification = $This.Qualification | ? Description -ne $This.Qualification[$Index].Description
            $This.Rerank("Qualification")
        }
        AddEmployer([String]$Name,[String]$Location,[String]$Date,[String]$Title)
        {
            If ($Name -in $This.Employer.Name)
            {
                Throw "<Employer> already specified"
            }

            $This.Employer += [Employer]::New($This.Employer.Count,$Name,$Location,$Date,$Title)
        }
        RemoveEmployer([UInt32]$Index)
        {
            If (!$This.Employer[$Index])
            {
                Throw "Invalid <Employer>"
            }

            $This.Employer = $This.Employer | ? Name -ne $This.Employer[$Index].Name
            $This.Rerank("Employer")
        }
        AddEducation([String]$Name,[String]$Location,[String]$Date,[String]$Focus)
        {
            If ($Name -in $This.Education.Name)
            {
                Throw "<Education> already specified"
            }

            $This.Education += [Education]::New($This.Education.Count,$Name,$Location,$Date,$Focus)
        }
        RemoveEducation([UInt32]$Index)
        {
            If (!$This.Education[$Index])
            {
                Throw "Invalid <Education>"
            }

            $This.Education = $This.Education | ? Name -ne $This.Education[$Index].Name
            $This.Rerank("Education")
        }
        AddSkill([String]$Name,[String]$Date,[String]$Detail,[String[]]$Description)
        {
            If ($Name -in $This.Skill.Name)
            {
                "<Skill> already specified"
            }
            If ($Date -notmatch "\d{2}\/\d{4}")
            {
                Throw "Invalid date, use MO/YEAR format"
            }
            
            $This.Skill += [Skill]::New($This.Skill.Count,$Name,$Date,$Detail,$Description)
        }
        RemoveSkill([UInt32]$Index)
        {
            If (!$This.Skill[$Index])
            {
                Throw "Invalid <Skill>"
            }

            $This.Skill = $This.Skill | ? Name -ne $This.Skill[$Index].Name
            $This.Rerank("Skill")
        }
        Rerank([String]$Type)
        {
            $Item = $This.$Type

            Switch ($Item.Count)
            {
                Default {}
                {$_ -eq 1}
                {
                    $Item[0].Index = 0
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($Item.Count-1))
                    {
                        $Item[$X].Index = $X
                    }
                }
            }
        }
    }

    # // Body object templte to manipulate and orchestrate each BODY SECTION
    Class Body
    {
        [UInt32]  $Index
        [Int32]    $Slot
        [String]   $Type
        [Object] $Object
        Body([UInt32]$Index,[String]$Type,[Object]$Object)
        {
            $This.Index  = $Index
            $This.Type   = $Type
            $This.Slot   = Switch ($Type)
            {
                 Employer  { 2 }
                 Education { 4 }
                 Skill     { 5 }
            }
            $This.Object = $Object
        }
    }

    # // Provides altering types for data insertion
    Class Insertion
    {
        [Int32]   $Slot
        [String]  $Type
        [Object] $Guide
        [UInt32] $Index
        [Object] $Track
        Insertion([Int32]$Slot,[UInt32]$Index,[Object]$Track)
        {
            $This.Slot    = -1
            $This.Type    = "Mask"
            $This.Guide   = [Guide]::New("Mask")
            $This.Index   = $Index
            $This.Track   = $Track
        }
        Insertion([Int32]$Slot,[UInt32]$Index,[Object]$Track,[String]$String)
        { 
            $This.Slot    = $Slot
            $This.Type    = Switch ($Slot)
            {
                 0 {        "Header" }
                 1 { "Qualification" }
                 2 {      "Employer" }
                 3 {       "Section" }
                 4 {     "Education" }
                 5 {         "Skill" }
            }
            $This.Guide   = [Guide]::New($This.Type)
            $This.Index   = $Index
            If ($String.Length -le $This.Guide.Length)
            {
                Do
                {
                    $String += " "
                }
                Until ($String.Length -ge $This.Guide.Length)
                $String += " "
            }

            # // Grabs default mask/track
            $This.Track                    = [ThemeTrack]::New($Slot)
            ForEach ($X in 0..($Track.Object.Count-1))
            {
                $This.Track.Object[$X]     = $Track.Object[$X]
                $This.Track.Mask[$X].ForegroundColor = $Track.Mask[$X].ForegroundColor
                $This.Track.Mask[$X].BackgroundColor = $Track.Mask[$X].BackgroundColor
            }

            $This.Apply($String)
        }
        Apply([String]$String)
        {
            $Line      = $This.Track.Object -join ''
            $Array0    = [Char[]]$Line
            $Array1    = [Char[]]$String
            $C         = 0
            $Tray      = @( )

            # // Swaps the mask characters with input characters
            ForEach ($X in 0..($Array0.Count-1))
            {
                If ($X -notin ($This.Guide.Start)..($This.Guide.End))
                {
                    $Tray += $Array0[$X]
                }
                Else
                {
                    $Tray += $Array1[$C]
                    $C ++
                }
            }

            # // Separates each line into 1x4 blocks
            $Out   = @( )
            $Block = ""
            ForEach ($X in 0..($Tray.Count-1))
            {
                If ($X -ne 0 -and $X % 4 -eq 0)
                {
                    $Out  += $Block
                    $Block = ""
                }
                $Block    += $Tray[$X]
            }
            $Out          += $Block

            # // Swaps the default mask/track blocks with the new input
            ForEach ($X in 0..($Out.Count-1))
            {
                $This.Track.Object[$X] = $Out[$X]
            }
        }
    }
    
    # // Controller class
    Class Resume
    {
        [Object] $Person
        [Object] $Theme
        Hidden [Object[]] $Guide
        [Object] $Body
        [Object] $Swap
        [Object] $Output
        Resume([String]$Name,[String]$Title)
        {
            $This.Person = [Person]::New($Name,$Title)
            $This.Theme  = [ThemeTemplate]::new()
            $This.Guide  = [Guide]::Types() | % { [Guide]::New($_) }
            $This.Body   = @( )
            $This.Swap   = @{ }
            $This.Output = @( )
        }
        [String] Header()
        {
            $Header      = $This.Person.Name, $This.Person.Title -join " | "
            $Length      = $This.Guide | ? Name -eq Header | % Length

            # // Scope out + modify the header input
            If ($Header.Length -lt ($Length-2) -and $Header.Length -gt ($Length-3))
            {
                $Header   = $Header.Substring(0,($Length-3)) + "..."
            }
            Else
            {
                $Header   = "{0}{1}" -f $Header, (@(" ") * ($Length - $Header.Length) -join '')
            }

            Return "$Header  "
        }
        [String[]] Qualification()
        {
            $Length        = $This.Guide | ? Name -eq Qualification | % Length

            # // Combine
            $Line          = $This.Person.Qualification.Description -join " | "
            
            # // CharArray
            $Array         = [Char[]]$Line
            $Hash          = @{ 0 = "" }
            $Out           = @( )
            ForEach ($X in 0..($Array.Count-1))
            {
                $Hash[$Hash.Count-1] += $Array[$X]

                If ($Hash[$Hash.Count-1].Length -gt $Length)
                {
                    $Hash.Add($Hash.Count,$Hash[$Hash.Count-1].Split(" | ")[-1])
                    $Hash[$Hash.Count-2] = $Hash[$Hash.Count-2] -Replace $Hash[$Hash.Count-1],''
                }
            }

            # // Clean & Center each line
            Switch ($Hash.Count)
            {
                {$_ -eq 0}
                {
                    Throw "No qualifications found"
                }
                {$_ -eq 1}
                {
                    $Out += $This.Center($Length,$Hash[0].TrimEnd(" | "))
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($Hash.Count-1))
                    {
                        $Out += $This.Center($Length,$Hash[$X].TrimEnd(" | "))
                    }
                }
            }

            $Out = $This.Prepare($Length,$Out)

            Return $Out
        }
        [String[]] Employer([UInt32]$Index)
        {
            $Length = $This.Guide | ? Name -eq Employer | % Length
            If ($Index -gt $This.Person.Employer.Count)
            {
                Throw "Invalid <Employer> index"
            }

            $Out = $This.Person.Employer[$Index].Output()

            Return $This.Prepare($Length,$Out)
        }
        [String[]] Education([UInt32]$Index)
        {
            $Length = $This.Guide | ? Name -eq Education | % Length
            If ($Index -gt $This.Person.Education.Count)
            {
                Throw "Invalid <Education> index"
            }

            $Out = $This.Person.Education[$Index].Output()

            Return $This.Prepare($Length,$Out)
        }
        [String[]] Skill([UInt32]$Index)
        {
            $Length = $This.Guide | ? Name -eq Skill | % Length
            If ($Index -gt $This.Person.Skill.Count)
            {
                Throw "Invalid <Skill> index"
            }

            $Out = $This.Person.Skill[$Index].Output()

            Return $This.Prepare($Length,$Out)
        }
        [String] Padding([UInt32]$Length,[String]$Line)
        {
            If ($Line.Length -lt $Length)
            {
                Do
                {
                    $Line += " "
                }
                Until ($Line.Length -eq $Length)
            }
            Return $Line
        }
        [String[]] Prepare([UInt32]$Length,[String[]]$Object)
        {
            Switch ($Object.Count)
            {
                0
                {
                    Throw "Cannot prepare (0) input objects"
                }
                1
                {
                    $Object[0] = $This.Padding($Length,$Object[0])
                }
                Default
                {
                    ForEach ($X in 0..($Object.Count-1))
                    {
                        $Object[$X] = $This.Padding($Length,$Object[$X])
                    }
                }
            }
            Return $Object
        }
        Populate()
        {
            $This.Body = @( )
            ForEach ($Section in "Employer","Education","Skill")
            {
                Switch ($Section)
                {
                    Employer  
                    { 
                        If ($This.Person.Employer.Count -eq 1)
                        {
                            $This.Body += [Body]::New($This.Body.Count,$Section,$This.Employer(0))
                        }
                        ElseIf ($This.Person.Employer.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Person.Employer.Count-1))
                            {
                                $This.Body += [Body]::New($This.Body.Count,$Section,$This.Employer($X))
                            }
                        }
                    }
                    Education 
                    { 
                        If ($This.Person.Education.Count -eq 1)
                        {
                            $This.Body += [Body]::New($This.Body.Count,$Section,$This.Education(0))
                        }
                        ElseIf ($This.Person.Education.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Person.Education.Count-1))
                            {
                                $This.Body += [Body]::New($This.Body.Count,$Section,$This.Education($X))
                            }
                        }
                    }
                    Skill     
                    { 
                        If ($This.Person.Skill.Count -eq 1)
                        {
                            $This.Body += [Body]::New($This.Body.Count,$Section,$This.Skill(0))
                        }
                        ElseIf ($This.Person.Skill.Count -gt 1)
                        {
                            ForEach ($X in 0..($This.Person.Skill.Count-1))
                            {
                                $This.Body += [Body]::New($This.Body.Count,$Section,$This.Skill($X))
                            }
                        }   
                    }
                }
            }
        }
        Illustrate()
        {
            $This.Populate()
            $This.Swap = @{ }
            $Flag  = 0
            $Index = 0
            Do
            {
                Switch ($Index)
                {
                    {$_ -in 0..2+4..7+11} # // Guide
                    {
                        Write-Host "Guide"
                        $This.Swap.Add($This.Swap.Count,[Insertion]::New(-1,$Index,$This.Theme.Track[$Index]))
                        ##$This.Swap.Add($This.Swap.Count,[Insertion]::New(-1,$Index,$Theme.Track[$Index]))
                        $Index ++
                    }
                    
                    {$_ -eq 3} # // Header
                    {
                        Write-Host "Header"
                        $Header = $This.Header()
                        $This.Swap.Add($This.Swap.Count,[Insertion]::New(0,0,$This.Theme.Track[$Index],$Header))
                        ## $Header    = $Resume.Header()
                        ## $This.Swap.Add($This.Swap.Count,[Insertion]::New(0,0,$Theme.Track[$Index],$Header))
                        $Index ++
                    }
                    
                    {$_ -eq 8} # // Qualification
                    {
                        $Qualification = $This.Qualification()
                        ## $Qualification = $Resume.Qualification()

                        # [Insertion]::new([Int]$Slot,[UInt32]$Index,[Object]$Track,[String[]]$String)
                        If ($Qualification.Count -eq 1)
                        {                        
                            Write-Host "Qualification"
                            $This.Swap.Add($This.Swap.Count,[Insertion]::New(1,0,$This.Theme.Track[$Index],$Qualification))
                            ## $This.Swap.Add($This.Swap.Count,[Insertion]::New(1,0,$Theme.Track[$Index],$Qualification))
                        }
                        ElseIf ($Qualification.Count -gt 1)
                        {
                            ForEach ($X in 0..($Qualification.Count-1))
                            {
                                Write-Host "Qualification"
                                $This.Swap.Add($This.Swap.Count,[Insertion]::New(1,$X,$This.Theme.Track[$Index],$Qualification[$X]))
                                ## $This.Swap.Add($This.Swap.Count,[Insertion]::New(1,$X,$Theme.Track[$Index],$Qualification[$X]))
                            }
                        }
                        $Index ++
                    }
                    {$_ -eq 9} # // Employer0
                    {
                        $Employer       = $This.Body[0].Object
                        ## $Employer    = $Resume.Body[0].Object

                        ForEach ($X in 0..($Employer.Count-1))
                        {
                            Write-Host "Employer0"
                            $This.Swap.Add($This.Swap.Count,[Insertion]::New(2,$X,$This.Theme.Track[@($Index;($Index+1))[$X % 2]],$Employer[$X]))
                            ## $This.Swap.Add($This.Swap.Count,[Insertion]::New(1,$X,$Theme.Track[@($Index;($Index+1))[$X % 2]],$Employer[$X]))
                            If ($X -eq $Employer.Count - 1)
                            {
                                $Index ++ 
                                $X     ++
                                If ($X % 2 -eq 1)
                                {
                                    $This.Swap.Add($This.Swap.Count,[Insertion]::New(2,$X,$This.Theme.Track[$Index]))
                                }
                            }
                        }
                        $Index         ++
                    }
                    {$_ -eq 12} # // Remaining
                    {
                        $Last = ""
                        ForEach ($X in 1..($This.Body.Count-1))
                        {
                            $Item      = $This.Body[$X]
                            If ($Item.Type -eq $Last)
                            {
                                $Index = 13
                            }
                            If ($Item.Type -ne $Last)
                            {
                                $Index = 12
                                $Last  = $Item.Type
                                $Label = "( $Last )"
                                If ($Label.Length -le 104)
                                {
                                    Do
                                    {
                                        $Label += "="
                                    }
                                    Until ($Label.Length -ge 104)
                                    $Label += "="
                                }
                                $This.Swap.Add($This.Swap.Count,[Insertion]::New(3,$This.Swap.Count,$This.Theme.Track[$Index],$Label))
                                $Index ++
                            }

                            Write-Host ("{0} ({1}/{2})" -f $Last, $Item.Index, $This.Body.Count)
                            $I = 0
                            Do
                            {
                                If ($Index -ne 18)
                                {
                                    $This.Swap.Add($This.Swap.Count,[Insertion]::New($Item.Slot,$I,$This.Theme.Track[$Index],$Item.Object[$I]))
                                    $I     ++
                                    $Index ++
                                }
                                If ($Index -eq 18)
                                {
                                    If ($I -ne $Item.Object.Count)
                                    {
                                        $This.Swap.Add($This.Swap.Count,[Insertion]::New($Item.Slot,$I,$This.Theme.Track[$Index],$Item.Object[$I]))
                                        $I ++
                                    }
                                    If ($I -ne $Item.Object.Count)
                                    {
                                        Do
                                        {
                                            $This.Swap.Add($This.Swap.Count,[Insertion]::New($Item.Slot,$I,$This.Theme.Track[$Index],$Item.Object[$I]))
                                            $I ++
                                        }
                                        Until ($I -ge $Item.Object.Count)
                                    }
                                    $Index ++
                                }
                            }
                            Until ($I -eq $Item.Object.Count)
                            $This.Swap.Add($This.Swap.Count,[Insertion]::New($Item.Slot,$I,$This.Theme.Track[$Index]))

                            If ($X -eq $This.Body.Count-1)
                            {
                                $Flag = 1
                                $Index ++
                                $This.Swap.Add($This.Swap.Count,[Insertion]::New(-1,$Index,$This.Theme.Track[$Index]))
                            }
                        }
                    }
                }
            } 
            Until ($Flag -eq 1)
            ForEach ($X in 0..($This.Swap.Count-1))
            {
                $This.Swap[$X].Index  = $X
                $This.Output    += $This.Swap[$X]
            }
        }
        [Void] Draw()
        {
            $This.Output.Track.Draw(@(10,12,15,0))
        }
        [Void] Draw([UInt32[]]$Palette)
        {
            $This.Output.Track.Draw($Palette)
        }
        [String] Center([UInt32]$Length,[String]$Line)
        {
            $Buffer = $Length - $Line.Length
            $Split  = [Math]::Round($Buffer / 2,[MidpointRounding]::ToZero)
            Return "{0}{1}{0}" -f (@(" ")*$Split -join ''), $Line
        }
        [String[]] ToString()
        {
            If ($This.Output.Count -gt 0)
            {
                Return @( $This.Output | % { $_.Track.Object -join '' } )
            }
            Else
            {
                Return $Null
            }
        }
    }

    [Resume]::New($Name,$Title)
}




<# [Drafting Mask/Blueprint]
       _____________________________________________________________
       | Legends of the (Hidden Temple/Drafting Blueprint)         |
       |-----------------------------------------------------------|
       |     Symbol | Section(s)                                   |
       |-----------------------------------------------------------|
       |        [A] | Header (Name, Title)                         |
       |        [B] | Qualifications                               |
       |        [C] | Employer0 (Current)                          |
       |        [D] | Section Label (Employer1+, Education, Skill) |
       |        [E] | Body (Employer1+, Education, Skill)          |
       | ---------- | Solid sections, IS NOT for data insertion    |
_______| - - - - -  | Maleable sections,  IS for data insertion    |__________________________________________________________________________________________
| Line | 0123456789 | For indexing X/Y coordinates to insert data (not a KING, QUEEN or PRESIDENT type of ruler...)             | Notes / Information        |
|______|________________________________________________________________________________________________________________________|____________________________|
       |          0         0         0         0         0         0         0         0         0         1         1         |
       |          1         2         3         4         5         6         7         8         9         0         1         |
       |012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|
_______|________________________________________________________________________________________________________________________|_____________________________
| [00] |    ____                                                                                                    ____        | <begin table>              |
| [01] |   //¯¯\\__________________________________________________________________________________________________//¯¯\\___    |                            |
| [02] |   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   |                            |
¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_____________________________
| [03] |   |/¯¯\\__[ __________________________________________________________________________________________ ]__//¯¯\\__//   | [A]         013..102 (090) | 
¯¯¯¯¯¯¯|¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|________________________________________________________________________________________________________________________|_____________________________
| [04] |   |\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ||==||   |                            |
| [05] |   |/¯¯\\______________________________________________________________________________________________________//¯¯\|   |                            |
| [06] |   |\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/|   |                            |
| [07] |   |/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|   |                            |
¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_____________________________
| [08] |   |    [                                                                                                      ]    |   | [B]         008..112 (104) |
| ---- |   |    [                                                                                                      ]    |   | <as needed> 008..112 (104) |
| [09] |   |\   [                                                                                                      ]   /|   | [C]         008..112 (104) |
| [10] |   |/   [                                                                                                      ]   \|   |             008..112 (104) |
| ---- |   |    [                                                                                                      ]    |   | <as needed> 008..112 (104) |
| [11] |   \\______________________________________________________________________________________________________________//   | <endcap>                   |
¯¯¯¯¯¯¯|¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_____________________________
| [12] |   [====[                                                                                                      ]====]   | [D]         008..112 (100) |
¯¯¯¯¯¯¯|¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |_____________________________
| [13] |   /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\   | <startcap>                 |
| [14] |   \    [                                                                                                      ]    /   | [E]         008..112 (104) |
| [15] |   /    [                                                                                                      ]    \   |             008..112 (104) |
| [16] |   \________________________________________________________________________________________________________________/   | <endcap>                   |
| [17] |   //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\   | <startcap>                 |
| [18] |   ||   [                                                                                                      ]   ||   |             008..112 (104) | 
| ---- |   ||   [                                                                                                      ]   ||   | <as needed> 008..112 (104) | 
| [19] |   \\______________________________________________________________________________________________________________//   | <endcap>                   |
¯¯¯¯¯¯¯|¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_______|________________________________________________________________________________________________________________________|_____________________________
| [20] |    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    | <end table>                |
¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#>

<#
[XXX]     ____                                                                                                    ____     
[XXX]    //¯¯\\__________________________________________________________________________________________________//¯¯\\___ 
[XXX]    \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\
[XXX]    |/¯¯\\__[ Michael C. Cook Sr. | Network Information System Security Professional | DevOPS Engineer ]____//¯¯\\__//
[XXX]    |\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ||==||
[XXX]    |/¯¯\\______________________________________________________________________________________________________//¯¯\|
[XXX]    |\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/|
[XXX]    |/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#>

$Resume = Write-Resume -Name "Michael C. Cook Sr." -Title "Network Information System Security Professional | DevOPS Engineer"

<# [Add Qualifications]
[XXX]    |     CompTIA A+/Network+/Security+ | Cisco CCNA/CNAP | Microsoft Certified Professional/MCDST/MCSA/MCSE         |
[XXX]    |     Associate Degree in Information Technology (Drafting & Design/Multimedia) | Portfolio Award/CRCATS         |
#>

"CompTIA A+/Network+/Security+",
"Cisco CCNA/CNAP",
"Microsoft Certified Professional/MCDST/MCSA/MCSE",
"Associate Degree in Information Technology (Drafting & Design/Multimedia)",
"Portfolio Award/CRCATS" | % { $Resume.Person.AddQualification($_) }

<# [Add Employer[0] (Current)]
     |          0         0         0         0         0         0         0         0         0         1         1         |
     |          1         2         3         4         5         6         7         8         9         0         1         |
     |012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|
[XXX]|   |\   _________________________________________________                                  _____________________   /|   |
[XXX]|   |/   | Secure Digits Plus LLC (π) – Clifton Park, NY |                                  | 10/2018 - 08/2022 |   \|   |
[XXX]|   |\   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   /|   |
[XXX]|   |/                     _____________________________________________________________________                    \|   |
[XXX]|   |\                     | Security Engineer, also CEO/NISSP/DevOPS/Investigative Journalist |                    /|   |
[XXX]|   |/                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                    \|   |
[XXX]|   |\   [+] Portfolio Development for Applications, as well as Investigative Journalism                            /|   |
[XXX]|   |/   ________________________________________________________________________________________________________   \|   |
[XXX]|   |\   | 08/02/22 | Top Deck Awareness - Not News | drive.google.com/file/d/1NoqGcpDVYnCF6zWx-7HPQBV3-MgeCzsT |   /|   |
[XXX]|   |/   | 06/23/22 | Archimedes (CIA+Zuckerberg)   | https://youtu.be/QP25FbNhakQ                              |   \|   |
[XXX]|   |\   | 02/15/22 | A Matter of National Security | https://youtu.be/e4VnZObiez8 (Links in video description) |   /|   |
[XXX]|   |/   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   \|   |
[XXX]|   |\   [+] Main development focus: (C/PowerShell/.NET) module development, codename [FightingEntropy(π)]          /|   |
[XXX]|   |/   [+] [FightingEntropy(π)] is a MODULE for PowerShell which automatically installs itself, as well as...     \|   |
[XXX]|   |\       (installing/configuring) Windows Server 2016/2019, Windows 10 Home/Education/Pro, RHEL/CentOS, and     /|   |
[XXX]|   |/       FreeBSD/OPNsense/pfSense via the [(Microsoft Deployment Toolkit – by Michael T. Niehaus)]              \|   |
[XXX]|   |\   [+] [FightingEntropy(π)] ALSO configures and establishes a network baseline for:                           /|   |
[XXX]|   |/      __________________________________________________________________________________________________      \|   |
[XXX]|   |\      | Active Directory Domain Services | Windows Deployment Services | Hyper-V/Veridian | DNS | DHCP |      /|   |
[XXX]|   |/      | Demonstration of [FightingEntropy (π)][FEInfrastructure]: https://youtu.be/6yQr06_rA4I         |      \|   |
[XXX]|   |\      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      /|   |
[XXX]|   |/   [+] Other areas of development include:                                                                    \|   |
[XXX]|   |\      _________________________________________________________________________________________________       /|   |
[XXX]|   |/      | Extensible Application Markup Language | Graphical User Interface design | Linux/Unix/FreeBSD |       \|   |
[XXX]|   |\      | IIS/Internet Information Services | Razor/Blazor/ASP.Net Core | Conceptualizing R&D projects  |       /|   |
[XXX]|   |/      | Investigating: IDENTITY THEFT | CYBERCRIMINAL ACTIVITIES | GOVERNMENT CORRUPTION | ESPIONAGE  |       \|   |
[XXX]|   |\      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯       /|   |
[XXX]|   |/   [+] [FightingEntropy(π)] is completely written in (C/PowerShell/.Net), and is split between:               \|   |
[XXX]|   |\       - Development: https://www.github.com/mcc85s/FightingEntropy                                           /|   |
[XXX]|   |/       - Production: https://www.github.com/mcc85sx/FightingEntropy                                           \|   |
[XXX]|   \\______________________________________________________________________________________________________________//   |
#>

$Resume.Person.AddEmployer("Secure Digits Plus LLC (π)",
    "Clifton Park, NY",
    "10/2018 - 08/2022",
    "Security Engineer, also CEO/NISSP/DevOPS/Investigative Journalist")
$Hash = @{ }
$Hash.Add(0, @"
Portfolio Development for Applications, as well as Investigative Journalism:
________________________________________________________________________________________________________
| 08/02/22 | Top Deck Awareness - Not News | drive.google.com/file/d/1NoqGcpDVYnCF6zWx-7HPQBV3-MgeCzsT |
| 06/23/22 | Archimedes (CIA+Zuckerberg)   | https://youtu.be/QP25FbNhakQ                              |
| 02/15/22 | A Matter of National Security | https://youtu.be/e4VnZObiez8 (Links in video description) |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)
$Hash.Add(1, "Main development focus: (C/PowerShell/.NET) module development, codename [FightingEntropy(π)]")
$Hash.Add(2, @"
[FightingEntropy(π)] is a MODULE for PowerShell which automatically installs itself, as well as...
(installing/configuring) Windows Server 2016/2019, Windows 10 Home/Education/Pro, RHEL/CentOS, and
FreeBSD/OPNsense/pfSense via the [(Microsoft Deployment Toolkit – by Michael T. Niehaus)]
"@)
$Hash.Add(3, @"
[FightingEntropy(π)] ALSO configures and establishes a network baseline for:
__________________________________________________________________________________________________
| Active Directory Domain Services | Windows Deployment Services | Hyper-V/Veridian | DNS | DHCP |
| Demonstration of [FightingEntropy (π)][FEInfrastructure]: https://youtu.be/6yQr06_rA4I         |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)
$Hash.Add(4, @"
Other areas of development include:
_________________________________________________________________________________________________
| Extensible Application Markup Language | Graphical User Interface design | Linux/Unix/FreeBSD |
| IIS/Internet Information Services | Razor/Blazor/ASP.Net Core | Conceptualizing R&D projects  |
| Investigating: IDENTITY THEFT | CYBERCRIMINAL ACTIVITIES | GOVERNMENT CORRUPTION | ESPIONAGE  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)
$Hash.Add(5, @"
[FightingEntropy(π)] is completely written in (C/PowerShell/.Net), and is split between:
- Development: https://www.github.com/mcc85s/FightingEntropy
- Production: https://www.github.com/mcc85sx/FightingEntropy
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[1] (Former)]
[XXX]    [====( Former Employers )========================================================================================]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Computer Answers - Clifton Park, NY                                                   10/2015 - 07/2019     /
[XXX]    /    Chief Technology Officer & Business Solutions Expert                                                        \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Developed scripts and protocol, overseeing productivity/training of all employees                      ||
[XXX]    ||   [+] Complaining about the development team that took forever to do anything                                ||
[XXX]    ||   [+] Featured on WTEN Alert Desk via Andrew Banas regarding SmartTV’s at https://youtu.be/-jkDPv9H6BQ       ||
[XXX]    ||   [+] Set highest sales record in the company to date, in August 2017                                        ||
[XXX]    ||   [+] Rebuilt all of the networking equipment, point of sale equipment, server/router/access point           ||
[XXX]    ||       configuration, surveillance system/cameras, and DHCP configuration/deployment, for ALL 7 stores        ||
[XXX]    ||   [+] Deploying and configuring Clients/Servers/Routers/Switches/Access Points/receipt printers/SmartTV’s…   ||
[XXX]    ||       …led to the founding of [Secure Digits Plus LLC], successor to [Mike’s PC Repair], in order to build   ||
[XXX]    ||       a program that does all of this configuration, in a similar manner to:                                 ||
[XXX]    ||        _____________________________________________________________________________________________         ||
[XXX]    ||        | Google Kubernetes | Microsoft Azure | Amazon Web Services | VmWare vSphere | Cisco SD-WAN |         ||
[XXX]    ||        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯         ||
[XXX]    ||   [+] Upgraded each store network to gigabit Ethernet internally, as well as installation of:                ||
[XXX]    ||                   ________________________________________________________________________                   ||
[XXX]    ||                   | Security Gateways using | pfSense | OPNSense | HardenedBSD | FreeBSD |                   ||
[XXX]    ||                   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                   ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddEmployer("Computer Answers",
    "Clifton Park, NY",
    "10/2015 - 07/2019",
    "Chief Technology Officer & Business Solutions Expert")
$Hash = @{ } 
$Hash.Add(0, "Developed scripts and protocol, overseeing productivity/training of all employees")
$Hash.Add(1, "Complaining about the development team that took forever to do anything")
$Hash.Add(2, "Featured on WTEN Alert Desk via Andrew Banas regarding SmartTV’s at https://youtu.be/-jkDPv9H6BQ")
$Hash.Add(3, "Set highest sales record in the company to date, in August 2017")
$Hash.Add(4, @"
Rebuilt all of the networking equipment, point of sale equipment, server/router/access point
configuration, surveillance system/cameras, and DHCP configuration/deployment, for ALL 7 stores
"@)
$Hash.Add(5, @"
Deploying and configuring Clients/Servers/Routers/Switches/Access Points/receipt printers/SmartTV’s…
…led to the founding of [Secure Digits Plus LLC], successor to [Mike’s PC Repair], in order to build
a program that does all of this configuration, in a similar manner to:
_____________________________________________________________________________________________
| Google Kubernetes | Microsoft Azure | Amazon Web Services | VmWare vSphere | Cisco SD-WAN |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)
$Hash.Add(6, @"
Upgraded each store network to gigabit Ethernet internally, as well as installation of:
________________________________________________________________________
| Security Gateways using | pfSense | OPNSense | HardenedBSD | FreeBSD |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[2] (Former)]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    KeyCorp - Albany, NY                                                                  03/2016 - 12/2016     /
[XXX]    /    Help Desk Level (I & II) Support Engineer                                                                   \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Provided support to (KeyCorp/KeyBank) employees over the phone and over Key's Inter IM client,         ||
[XXX]    ||       Cisco Jabber, for various first and second level help desk support tickets                             ||
[XXX]    ||   [+] First experience with System Center Configuration Manager, which utilizes core aspects of the          ||
[XXX]    ||       Microsoft Deployment Toolkit and other Microsoft-centric programs/applications                         ||
[XXX]    ||   [+] Exposure to Active Directory Administration was rather limited in this position (typically used for    ||
[XXX]    ||       password resets), brief contact with Organizational Units, Site Links, Lotus Notes, Exchange,          ||
[XXX]    ||       vSphere/eSXI, Group Policy Objects, RSA Encryption/Software tokens, KeyCounselor/HOGAN                 ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


# Add Employer [Former] #2
$Resume.Person.AddEmployer("KeyCorp",
    "Albany, NY",
    "03/2016 - 12/2016",
    "Help Desk Level (I & II) Support Engineer")
$Hash = @{ }
$Hash.Add(0, @"
Provided support to (KeyCorp/KeyBank) employees over the phone and over Key's Inter IM client,
Cisco Jabber, for various first and second level help desk support tickets
"@)

$Hash.Add(1, @"
First experience with System Center Configuration Manager, which utilizes core aspects of the
Microsoft Deployment Toolkit and other Microsoft-centric programs/applications
"@)

$Hash.Add(2, @"
Exposure to Active Directory Administration was rather limited in this position (typically used for
password resets), brief contact with Organizational Units, Site Links, Lotus Notes, Exchange,
vSphere/eSXI, Group Policy Objects, RSA Encryption/Software tokens, KeyCounselor/HOGAN
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[3] (Former)]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Metroland/Lou Communications - Albany, NY                                             01/2007 - 01/2014     /
[XXX]    /    Distribution Contractor & IT Consultant                                                                     \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Distributed the newspaper Metroland for several years throughout the Greater Capital Region            ||
[XXX]    ||   [+] Eventually they were in need of IT services from 'Mike’s PC Repair' in September 2012                  ||
[XXX]    ||   [+] Documented & moved their network from 420 Madison Ave, Albany NY - 523 Western Ave, Albany NY while    ||
[XXX]    ||       upgrading old Dell based Win NT 4.0 server to 1U blade server w/ (2x AMD CPUs, Windows Server 2008)    ||
[XXX]    ||   [+] Migrated ALL data from an older system that publishers used for archiving (weekly/legacy) content      ||
[XXX]    ||   [+] Assisted John Bracchi with (printers/network storage for PUBLISHERS via Adobe (PS & Illustrator):      ||
[XXX]    ||         ____________________________________________________________________________________________         ||
[XXX]    ||         | mapping printers | domain logins | emails/Outlook | making sure that Ted Etoll was happy |         ||
[XXX]    ||         ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯         ||
[XXX]    ||   [+] Limited use of domain resources, otherwise most services were DISTRIBUTION of the newspaper            ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


# Add Employer [Former] #3
$Resume.Person.AddEmployer("Metroland/Lou Communications",
    "Albany, NY",
    "01/2007 - 01/2014",
    "Distribution Contractor & IT Consultant")
$Hash = @{ }

$Hash.Add(0, "Distributed the newspaper Metroland for several years throughout the Greater Capital Region")
$Hash.Add(1, "Eventually they were in need of IT services from 'Mike’s PC Repair' in September 2012")
$Hash.Add(2, @"
Documented & moved their network from 420 Madison Ave, Albany NY - 523 Western Ave, Albany NY while
upgrading old Dell based Win NT 4.0 server to 1U blade server w/ (2x AMD CPUs, Windows Server 2008)
"@)
$Hash.Add(3, "Migrated ALL data from an older system that publishers used for archiving (weekly/legacy) content")
$Hash.Add(4, @"
Assisted John Bracchi with (printers/network storage for PUBLISHERS via Adobe (PS & Illustrator):
____________________________________________________________________________________________
| mapping printers | domain logins | emails/Outlook | making sure that Ted Etoll was happy |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)
$Hash.Add(5, "Limited use of domain resources, otherwise most services were DISTRIBUTION of the newspaper")

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[4] (Former)]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Nfrastructure - Clifton Park, NY                                                      09/2010 - 01/2011     /
[XXX]    /    Computer (Hardware/Printer/Network) Technician                                                              \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Staged machines to be used for Point-Of-Sale systems for the Adidas-Reebok of North America, as well   ||
[XXX]    ||       as testing, repairing, and maintaining a rolling inventory of computers, monitors, receipt printers,   ||
[XXX]    ||       handheld devices, barcode scanners, & label/form printers (Epson)                                      ||
[XXX]    ||   [+] Made DAILY warranty calls to HP for Elite 8100/8200's, AND Dell for various (laptops/workstations)     ||
[XXX]    ||   [+] Told people how real I kept it, AND provided desktop support for internal company users                ||
[XXX]    ||   [+] Repaired, inspected, and maintained full-size (Lexmark/HP) stack printers for various NYS agencies     ||
[XXX]    ||   [+] Imaged THOUSANDS of computers to be used for various New York State companies and  gov't agencies:     ||
[XXX]    ||      __________________________________________________________________________________________________      ||
[XXX]    ||      | Dept. of Transportation | CSMIN | Golub Corporation | Office of People with Disabilities Dept. |      ||
[XXX]    ||      | Dept. Of Correctional Services | Adidas-Reebok of NA | Testcomm of New York and Massachusetts  |      ||
[XXX]    ||      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


# Add Employer [Former] #4
$Resume.Person.AddEmployer("Nfrastructure",
    "Clifton Park, NY",
    "09/2010 - 01/2011",
    "Computer (Hardware/Printer/Network) Technician")
$Hash = @{ }
$Hash.Add(0, @"
Staged machines to be used for Point-Of-Sale systems for the Adidas-Reebok of North America, as well
as testing, repairing, and maintaining a rolling inventory of computers, monitors, receipt printers,
handheld devices, barcode scanners, & label/form printers (Epson)
"@)
$Hash.Add(1, "Made DAILY warranty calls to HP for Elite 8100/8200's, AND Dell for various (laptops/workstations)")
$Hash.Add(2, "Told people how real I kept it, AND provided desktop support for internal company users ")
$Hash.Add(3, "Repaired, inspected, and maintained full-size (Lexmark/HP) stack printers for various NYS agencies")
$Hash.Add(4, @"
Imaged THOUSANDS of computers to be used for various New York State companies and  gov't agencies:
__________________________________________________________________________________________________
| Dept. of Transportation | CSMIN | Golub Corporation | Office of People with Disabilities Dept. |
| Dept. Of Correctional Services | Adidas-Reebok of NA | Testcomm of New York and Massachusetts  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[5] (Former)]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    TEKsystems - Albany, NY                                                               06/2006 - 05/2019     /
[XXX]    /    Various (Computer/Network) related roles                                                                    \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Completed Pittsfield MA Census Bureau deployment (2009-2010) | KeyCorp (2016) | Patroon Creek (2017)   ||
[XXX]    ||   [+] Trinity Health/St. Peters Hospital 02/2019 [Interview] - Potential client was seeking to build an      ||
[XXX]    ||       entirely new domain physically as well as ASP.Net overhaul, already developing [FightingEntropy(π)]    ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


# Add Employer [Former] #5
$Resume.Person.AddEmployer("TEKsystems",
    "Albany, NY",
    "06/2006 - 05/2019",
    "Various (Computer/Network) related roles")
$Hash = @{ }
$Hash.Add(0, "Completed Pittsfield MA Census Bureau deployment (2009-2010) | KeyCorp (2016) | Patroon Creek (2017)")
$Hash.Add(1, @"
Trinity Health/St. Peters Hospital 02/2019 [Interview] - Potential client was seeking to build an
entirely new domain physically as well as ASP.Net overhaul, already developing [FightingEntropy(π)]
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Employer[6] (Former)]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Hearst Corporation – Albany, NY                                                       04/2006 - 04/2009     /
[XXX]    /    Distribution Contractor & Accounts Receivable Collector                                                     \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Provided distribution throughout lower Saratoga County, as well as the Greater Capital Region          ||
[XXX]    ||   [+] Daily paper drops were required in early morning hours after they are printed (2AM-4AM), and stores    ||
[XXX]    ||       would either be open or closed - some stops needed priority treatment (primarily Stewarts Corp)        ||
[XXX]    ||   [+] Drifted in the snow a lot, found new ways to drop off newspapers, drove a minimum of 90 miles/night    ||
[XXX]    ||   [+] Collected and calculated return payment amounts, deposited into bank account with Bank of America      ||
[XXX]    ||   [+] Worked under (Kenny/Patrick Bernard) for Q122, Q107, Q121, & Chris Jones for daytime return routes     ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

# Add Employer [Former] #6
$Resume.Person.AddEmployer("Hearst Corporation",
    "Albany, NY",
    "04/2006 - 04/2009",
    "Distribution Contractor & Accounts Receivable Collector")
$Hash = @{ }
$Hash.Add(0, "Provided distribution throughout lower Saratoga County, as well as the Greater Capital Region")
$Hash.Add(1, @"
Daily paper drops were required in early morning hours after they are printed (2AM-4AM), and stores
would either be open or closed - some stops needed priority treatment (primarily Stewarts Corp)
"@)
$hash.Add(2, "Drifted in the snow a lot, found new ways to drop off newspapers, drove a minimum of 90 miles/night")
$Hash.Add(3, "Collected and calculated return payment amounts, deposited into bank account with Bank of America")
$Hash.Add(4, "Worked under (Kenny/Patrick Bernard) for Q122, Q107, Q121, & Chris Jones for daytime return routes")

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Employer[$Resume.Person.Employer.Count - 1].AddDetail($Hash[$X])
}

<# [Add Education[0]]
[XXX]    [====( Education )===============================================================================================]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    New Horizons Learning Center - Albany, NY                                             01/2008 - 01/2009     /
[XXX]    /    CompTIA & Microsoft Certifications Track                                                                    \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Completed certifications from CompTIA A+/Network+, MCP/MCDST                                           ||
[XXX]    ||   [+] Hands on support with hardware, and operating systems Windows (XP Pro/Home/Server 2003)                ||
[XXX]    ||   [+] Studied server technologies and services: FTP, File Server, WINS/DNS/DHCP, RSAT/WSUS, Certificates,    ||
[XXX]    ||       Active Directory, Group Policy, Drivers, Wireless, IIS 6.0, VPN Encryption, & Virtual Server           ||
[XXX]    \\______________________________________________________________________________________________________________//
#> 

# Add Education #1
$Resume.Person.AddEducation("New Horizons Learning Center",
    "Albany, NY",
    "01/2008 - 01/2009",
    "CompTIA & Microsoft Certifications Track")
$Hash = @{ }
$Hash.Add(0, "Completed certifications from CompTIA A+/Network+, MCP/MCDST")
$Hash.Add(1, "Hands on support with hardware, and operating systems Windows (XP Pro/Home/Server 2003)")
$Hash.Add(2, @"
Studied server technologies and services: FTP, File Server, WINS/DNS/DHCP, RSAT/WSUS, Certificates,
Active Directory, Group Policy, Drivers, Wireless, IIS 6.0, VPN Encryption, & Virtual Server
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Education[$Resume.Person.Education.Count - 1].AddDetail($Hash[$X])
}

<# [Add Education[1]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    ITT Technical Institute - Albany, NY                                                  06/2004 - 06/2006     /
[XXX]    /    Information Technology: Drafting & Design, Multimedia                                                       \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] Received Associate degree in (IT/Drafting and Design-Multimedia)                                       ||
[XXX]    ||   [+] Course studies included:                                                                               ||
[XXX]    ||       _________________________________________________________________________________________________      ||
[XXX]    ||       | 2D/3D graphic, print AND web design AND publishing | Portfolio Development |  Problem-Solving |      ||
[XXX]    ||       |  Instructional Design | Micro Economics | CompTIA (A+/Network+) | Intro to Visual Basic .Net  |      ||
[XXX]    ||       |-----------------------------------------------------------------------------------------------|      ||
[XXX]    ||       |   Macromedia | [Flash/Director/Dreamweaver] HTML/CSS and flash animation                      |      ||
[XXX]    ||       |-----------------------------------------------------------------------------------------------|      ||
[XXX]    ||       |        Adobe | [Premiere/After Effects] video/scene | [Photoshop/Illustrator] photo | editing |      ||
[XXX]    ||       |-----------------------------------------------------------------------------------------------|      ||
[XXX]    ||       | AutoDesk 3DS | scene/character modeling | lighting | texturing | rigging | animation          |      ||
[XXX]    ||       ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


# Add Education #2
$Resume.Person.AddEducation("ITT Technical Institute",
    "Albany, NY",
    "06/2004 - 06/2006",
    "Information Technology: Drafting & Design, Multimedia")
$Hash = @{ }
$Hash.Add(0, "Received Associate degree in (IT/Drafting and Design-Multimedia)")
$Hash.Add(1, @"
Course studies included:
_________________________________________________________________________________________________
| 2D/3D graphic, print AND web design AND publishing | Portfolio Development |  Problem-Solving |
|  Instructional Design | Micro Economics | CompTIA (A+/Network+) | Intro to Visual Basic .Net  |
|-----------------------------------------------------------------------------------------------|
|   Macromedia | [Flash/Director/Dreamweaver] HTML/CSS and flash animation                      |
|-----------------------------------------------------------------------------------------------|
|        Adobe | [Premiere/After Effects] video/scene | [Photoshop/Illustrator] photo | editing |
|-----------------------------------------------------------------------------------------------|
| AutoDesk 3DS | scene/character modeling | lighting | texturing | rigging | animation          |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Education[$Resume.Person.Education.Count - 1].AddDetail($Hash[$X])
}

<# [Add Education[2]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Capital Region Career and Technical School – Albany, NY                               09/2001 - 06/2003     /
[XXX]    /    Microsoft System Administration, CompTIA A+/Network+, & Cisco Certified Network Academy                     \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   [+] While attending Shenendehowa High School, this 2-year vocational program consisted of hands-on lab     ||
[XXX]    ||       environment experience, and studies related to the above curriculum                                    ||
[XXX]    ||   [+] Briefly acted as (Student Network Administrator), using (MMC/Microsoft Management Console) snap-ins,   ||
[XXX]    ||       HyperTerminal, Novell Netware IPX/SPX, Windows XP/Server 2000 Workgroup, and some Red Hat Linux        ||
[XXX]    ||   [+] Received an in-depth year with Cisco (routers/switches) via RS232                                      ||
[XXX]    ||   [+] Participated in NYS competition at (SCCC/Schenectady County Community College), & ITT Tech             ||
[XXX]    ||   [+] Received an award from the school for Portfolio Development at final graduation ceremony               ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

# Add Education #3
$Resume.Person.AddEducation("Capital Region Career and Technical School",
    "Albany, NY",
    "09/2001 - 06/2003",
    "Microsoft System Administration, CompTIA A+/Network+, & Cisco Certified Network Academy")
$Hash = @{ }
$Hash.Add(0, @"
While attending Shenendehowa High School, this 2-year vocational program consisted of hands-on lab
environment experience, and studies related to the above curriculum
"@)
$Hash.Add(1, @"
Briefly acted as (Student Network Administrator), using (MMC/Microsoft Management Console) snap-ins,
HyperTerminal, Novell Netware IPX/SPX, Windows XP/Server 2000 Workgroup, and some Red Hat Linux
"@)
$Hash.Add(2, "Received an in-depth year with Cisco (routers/switches) via RS232")
$Hash.Add(3, "Participated in NYS competition at (SCCC/Schenectady County Community College), & ITT Tech")
$Hash.Add(4, "Received an award from the school for Portfolio Development at final graduation ceremony")

ForEach ($X in 0..($Hash.Count - 1)) {
    $Resume.Person.Education[$Resume.Person.Education.Count - 1].AddDetail($Hash[$X])
}

# // ________________________________________________________________________________________________________________________
# // | Section: [Application Development + Network/Hardware Magistration + Virtualization + Graphic Design]                 |
# // |----------------------------------------------------------------------------------------------------------------------|
# // | Date    | Name                                 | Detail                                                              |
# // |---------|--------------------------------------|---------------------------------------------------------------------|
# // | 12/2021 | FightingEntropy FEInfrastructure     | https://youtu.be/6yQr06_rA4I                                        |
# // | 10/2021 | Advanced Domain Controller Promotion | https://youtu.be/O8A2PDfQOBs                                        |
# // | 03/2021 | A Deep Dive: PowerShell and XAML     | https://youtu.be/NK4NuQrraCI                                        |
# // | 05/2022 | Wireless Network Scanning Utility    | https://youtu.be/35EabWfh8dQ                                        |
# // | 09/2021 | PowerShell Deployment FE Wizard      | https://youtu.be/lZX5fAgczz0                                        |
# // | 01/2019 | 2019_0125-(Computer Answers - MDT)   | https://youtu.be/5Cyp3pqIMRs                                        |
# // | 06/2021 | Install-pfSense                      | https://youtu.be/E_uFbzS0blQ                                        |
# // | 06/2021 | Advanced System Administration Lab   | https://youtu.be/xgffIccX1eg                                        |
# // | 06/2021 | Windows Image Extraction             | https://youtu.be/G10EuwlNAyo                                        |
# // | 08/2021 | Flight Test Part 1                   | https://drive.google.com/file/d/1qdS_UVcLTsxHFCpuwK16NQs0xJL7fv0W   |
# // | 08/2021 | Flight Test Part 2                   | https://youtu.be/vg359UlYVp8                                        |
# // | 05/2019 | Hybrid | Desired State Controller    | https://youtu.be/C8NYaaqJAlI                                        |
# // | 11/2019 | Methodologies                        | https://youtu.be/bZuSgBK36CE                                        |
# // | 08/2019 | Education/Exhibition Program Design  | https://youtu.be/v6RrrzR5v2E                                        |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

<# [Add Skill[00]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    FightingEntropy FEInfrastructure                                                                12/2021     /
[XXX]    /    https://youtu.be/6yQr06_rA4I                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I PROVE that BY MYSELF, I know ALL OF THE ASPECTS of:                                ||
[XXX]    ||    ___________________________________________________________________________________________________       ||
[XXX]    ||    | APP DEVELOPMENT | VIRTUALIZATION | HARDWARE/NETWORK MAGISTRATION | MICROSOFT DEPLOYMENT TOOLKIT |       ||
[XXX]    ||    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯       ||
[XXX]    ||   As in, I AM MORE EXPERIENCED THAN 95% of the people in the field of INFORMATION TECHNOLOGY.                ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("FightingEntropy FEInfrastructure",
    "12/2021",
    "https://youtu.be/6yQr06_rA4I",
    @"
This is a video where I PROVE that BY MYSELF, I know ALL OF THE ASPECTS of:
___________________________________________________________________________________________________
| APP DEVELOPMENT | VIRTUALIZATION | HARDWARE/NETWORK MAGISTRATION | MICROSOFT DEPLOYMENT TOOLKIT |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
As in, I AM MORE EXPERIENCED THAN 95% of the people in the field of INFORMATION TECHNOLOGY.
"@)

<# [Add Skill[01]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Advanced Domain Controller Promotion                                                             10/2021    /
[XXX]    /    https://youtu.be/O8A2PDfQOBs                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   Basically, promoting a server to a domain controller via the GUI. This GUI can also be controlled          ||
[XXX]    ||   via the process in Flight Test, which means that uh, I'm doing stuff that hasn't been developed yet.       ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("Advanced Domain Controller Promotion",
    "10/2021",
    "https://youtu.be/O8A2PDfQOBs",
    @'
Basically, promoting a server to a domain controller via the GUI. This GUI can also be controlled    
via the process in Flight Test, which means that uh, I'm doing stuff that hasn't been developed yet.
'@)


<# [Add Skill[02]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    A Deep Dive: PowerShell and XAML                                                                01/2021     /
[XXX]    /    https://youtu.be/NK4NuQrraCI                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   In this video, I EDUCATE PEOPLE on: BUILDING A GRAPHICAL USER INTERFACE using XAML & POWERSHELL            ||
[XXX]    ||   This video should, single-handedly, prove that I'm an EXPERT.                                              ||
[XXX]    ||   I can EASILY adjust my LANGUAGE so that PEOPLE can LEARN from an EXPERT such as MYSELF.                    ||
[XXX]    ||   Like an ACTUAL EXPERT that gets PAID a LOT OF MONEY to TEACH PEOPLE...                                     ||
[XXX]    ||   Like, a PROFESSOR. Sorta like KEVLIN HENNEY, ROBERT SOPOLSKY, or JEREMY RIFKIN. Even TIM COREY.            ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("A Deep Dive: PowerShell and XAML",
    "03/2021",
    "https://youtu.be/NK4NuQrraCI",
    @"
In this video, I EDUCATE PEOPLE on: BUILDING A GRAPHICAL USER INTERFACE using XAML & POWERSHELL
This video should, single-handedly, prove that I am an EXPERT. 
I can EASILY adjust my LANGUAGE so that PEOPLE CAN LEARN FROM AN *EXPERT* SUCH AS MYSELF.
Like an ACTUAL EXPERT that gets PAID a LOT OF MONEY to TEACH PEOPLE...
Like, a PROFESSOR. Sorta like KEVLIN HENNEY, ROBERT SOPOLSKY, or JEREMY RIFKIN. Even TIM COREY.
"@)

<# [Add Skill[03]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Wireless Network Scanning Utility                                                               05/2022     /
[XXX]    /    https://youtu.be/35EabWfh8dQ                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I show off HOW TO PROGRAM & MANIPULATE WIRELESS RADIOS using POWERSHELL, and         ||
[XXX]    ||   CREATE GRAPHICAL USER INTERFACES using XAML/POWERSHELL.                                                    ||
[XXX]    ||   It should hands down, single handedly prove that I am MORE EXPERIENCED than 95% of people in the field     ||
[XXX]    ||   of information technology.                                                                                 ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   So, for ANY USELESS DOUCHEBAG that wants to try and tell me that I “don't have enough experience”...       ||
[XXX]    ||   WELL, dipshit... this video will show ya, I've got more experience than anyone you probably know.          ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Wireless Network Scanning Utility",
    "05/2022",
    "https://youtu.be/35EabWfh8dQ",
    @"
This is a video where I show off HOW TO PROGRAM & MANIPULATE WIRELESS RADIOS using POWERSHELL, and
CREATE GRAPHICAL USER INTERFACES using XAML/POWERSHELL.
It should hands down, single handedly prove that I am MORE EXPERIENCED than 95% of people in the field
of information technology.

So, for ANY USELESS DOUCHEBAG that wants to try and tell me that I “don't have enough experience”...
WELL, dipshit... this video will show ya, I've got more experience than anyone you probably know.
"@)

<# [Add Skill[04]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    PowerShell Deployment FE Wizard                                                                 09/2021     /
[XXX]    /    https://youtu.be/lZX5fAgczz0                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I've decided to EXTEND the CAPABILITIES & FUNCTIONS of the POWERSHELL DEPLOYMENT   ||
[XXX]    ||   project written by:                                                                                        ||
[XXX]    ||                _____________________________________________________________________________                 ||
[XXX]    ||                | DEPLOYMENT BUNNY/JOHAN ARWIDMARK & MYKAEL NYSTROM (Both former Microsoft) |                 ||
[XXX]    ||                ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                 ||
[XXX]    ||   ...as well as:                                                                                             ||
[XXX]    ||                        ______________________________________________________________                        ||
[XXX]    ||                        | MICROSOFT/MICHAEL T. NIEHAUS – Vice President of Marketing |                        ||
[XXX]    ||                        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                        ||
[XXX]    ||   The original PSD Wizard GRAPHICAL USER INTERFACE that I modified, was created by:                          ||
[XXX]    ||                                    ______________________________________                                    ||
[XXX]    ||                                    | SYST AND DEPLOY/DAMIEN VAN ROBAEYS |                                    ||
[XXX]    ||                                    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                    ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("PowerShell Deployment FE Wizard",
    "09/2021",
    "https://youtu.be/lZX5fAgczz0",
    @"
This is a video where I've decided to EXTEND the CAPABILITIES & FUNCTIONS of the POWERSHELL DEPLOYMENT
project written by:
_____________________________________________________________________________
| DEPLOYMENT BUNNY/JOHAN ARWIDMARK & MYKAEL NYSTROM (Both former Microsoft) |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
...as well as:
______________________________________________________________________________
| MICROSOFT/MICHAEL T. "Smart bastard" NIEHAUS – Vice President of Marketing |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
The original PSD Wizard GRAPHICAL USER INTERFACE that I modified, was created by:
______________________________________
| SYST AND DEPLOY/DAMIEN VAN ROBAEYS |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[05]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    2019_0125-(Computer Answers - MDT)                                                              01/2019     /
[XXX]    /    https://youtu.be/5Cyp3pqIMRs                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is when I was using VIRTUALBOX developed by ORACLE...                                                 ||
[XXX]    ||   ...to create a CUSTOM MODIFICATION that became HYBRID-DSC.                                                 ||
[XXX]    ||   I believe that Microsoft was PISSED about this video because I wasn't using HYPER-V...                     ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   Which is what I use basically all the time now...                                                          ||
[XXX]    ||   And Microsoft agrees, HYPER-V is the way to go.                                                            ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   What's COOL about HYPER-V is that it is 100% CONTROLLABLE from POWERSHELL.                                 ||
[XXX]    ||   So, you get cool features and kick ass performance that you just can't get from VIRTUALBOX...              ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("2019_0125-(Computer Answers - MDT)",
    "01/2019",
    "https://youtu.be/5Cyp3pqIMRs",
    @"
This is when I was using VIRTUALBOX developed by ORACLE...
...to create a CUSTOM MODIFICATION that became HYBRID-DSC.
I believe that Microsoft was PISSED about this video because I wasn't using HYPER-V...

Which is what I use basically all the time now...
And Microsoft agrees, HYPER-V is the way to go.

What's COOL about HYPER-V is that it is 100% CONTROLLABLE from POWERSHELL.
So, you get cool features and kick ass performance that you just can't get from VIRTUALBOX...
"@)


<# [Add Skill[06]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Install-pfSense                                                                                 06/2021     /
[XXX]    /    https://youtu.be/E_uFbzS0blQ                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I use VISUAL STUDIO CODE to access POWERSHELL DIRECT to manage HYPER-V over a        ||
[XXX]    ||   REMOTE DESKTOP CONNECTION to AUTOMATE THE INSTALLATION of pfSense onto VIRTUAL GATEWAYS/ROUTERS            ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("Install-pfSense",
    "06/2021",
    "https://youtu.be/E_uFbzS0blQ",
    @'
This is a video where I use VISUAL STUDIO CODE to access POWERSHELL DIRECT to manage HYPER-V over a
REMOTE DESKTOP CONNECTION to AUTOMATE THE INSTALLATION of pfSense onto VIRTUAL GATEWAYS/ROUTERS
'@)

<# [Add Skill[07]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Advanced System Administration Lab                                                               06/2021    /
[XXX]    /    https://youtu.be/xgffIccX1eg                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    || Same sort of idea as above, except a lot more EXTENSIVE and COMPREHENSIVE.                                   ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("Advanced System Administration Lab",
    "06/2021",
    "https://youtu.be/xgffIccX1eg",
    "Same sort of idea as above, except a lot more EXTENSIVE and COMPREHENSIVE.")
<# [Add Skill[08]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Windows Image Extraction                                                                         06/2021    /
[XXX]    /    https://youtu.be/G10EuwlNAyo                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This extracts Windows Images from the ISO directly from Microsoft's website, to be injected as             || 
[XXX]    ||   TASK SEQUENCES for the MICROSOFT DEPLOYMENT TOOLKIT.                                                       ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>
$Resume.Person.AddSkill("Windows Image Extraction",
    "06/2021",
    "https://youtu.be/G10EuwlNAyo",
    @'                                    
This extracts Windows Images from the ISO directly from Microsoft's website, to be injected as       
TASK SEQUENCES for the MICROSOFT DEPLOYMENT TOOLKIT. 
'@)

<# [Add Skill[09]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Flight Test Part 1                                                                               08/2021    /
[XXX]    /    https://drive.google.com/file/d/1qdS_UVcLTsxHFCpuwK16NQs0xJL7fv0W                                           \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||    This video has to be DOWNLOADED because of the MUSIC in a 6 hour video demonstration.                     ||
[XXX]    ||   I don't expect EVERYBODY to watch the entire 6 hours worth of content here, but somebody will want         ||
[XXX]    ||   to see HOW STRONGLY I CAN PROGRAM SOMETHING THAT ORCHESTRATES THE ENTIRE DEPLOYMENT PROCESS FOR AN         ||
[XXX]    ||   ADVANCED NETWORK of GATEWAYS/ROUTERS, DHCP/DNS/ADDS SERVERS, DOMAIN CONTROLLERS, and WORKSTATIONS.         ||
[XXX]    ||   There WILL be a few people who hire contractors at a STARTING RATE of over $250K/year, to do what I        ||
[XXX]    ||   demonstrate in this particular video. That's because I'm fulfilling the role of SOLUTIONS ARCHITECT.       ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>
$Resume.Person.AddSkill("Flight Test Part 1",
    "08/2021",
    "https://drive.google.com/file/d/1qdS_UVcLTsxHFCpuwK16NQs0xJL7fv0W",
    @'
This video has to be DOWNLOADED because of the MUSIC in a 6 hour video demonstration.                
I don't expect EVERYBODY to watch the entire 6 hours worth of content here, but somebody will want   
to see HOW STRONGLY I CAN PROGRAM SOMETHING THAT ORCHESTRATES THE ENTIRE DEPLOYMENT PROCESS FOR AN   
ADVANCED NETWORK of GATEWAYS/ROUTERS, DHCP/DNS/ADDS SERVERS, DOMAIN CONTROLLERS, and WORKSTATIONS.   
There WILL be a few people who hire contractors at a STARTING RATE of over $250K/year, to do what I  
demonstrate in this particular video. That's because I'm fulfilling the role of SOLUTIONS ARCHITECT. 
'@)

<# [Add Skill[10]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Flight Test Part 2                                                                               08/2021    /
[XXX]    /    https://youtu.be/vg359UlYVp8                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   Continuing on from the last video, covering some stuff I forgot to fix or implement.                       ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("Flight Test Part 2",
    "08/2021",
    "https://youtu.be/vg359UlYVp8",
    "Continuing on from the last video, covering some stuff I forgot to fix or implement.")

<# [Add Skill[11]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Advanced Domain Controller Promotion                                                             10/2021    /
[XXX]    /    https://youtu.be/O8A2PDfQOBs                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   Basically, promoting a server to a domain controller via the GUI. This GUI can also be controlled          ||
[XXX]    ||   via the process in Flight Test, which means that uh, I'm doing stuff that hasn't been developed yet.       ||
[XXX]    \\______________________________________________________________________________________________________________//
[XXX]     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#>

$Resume.Person.AddSkill("Advanced Domain Controller Promotion",
    "10/2021",
    "https://youtu.be/O8A2PDfQOBs",
    @'
Basically, promoting a server to a domain controller via the GUI. This GUI can also be controlled    
via the process in Flight Test, which means that uh, I'm doing stuff that hasn't been developed yet.
'@)


<# [Add Skill[12]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Hybrid | Desired State Controller                                                               05/2019     /
[XXX]    /    https://youtu.be/C8NYaaqJAlI                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a DEMONSTRATION of the MICROSOFT DEPLOYMENT TOOLKIT MODIFICATION that I spent like...              ||
[XXX]    ||   (4) months working on, WHILE learning how to use PowerShell.                                               ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   I became rather INTRIGUED with the IDEA of DEPLOYING WINDOWS 10 TO THE CUSTOMERS COMPUTERS at:             ||
[XXX]    ||         ____________________________________________________________________________________________         ||
[XXX]    ||         | COMPUTER ANSWERS | 1602 US-9, Clifton Park, NY 12065 | 514 MAIN ST., BENNINGTON VT 05201 |         ||
[XXX]    ||         ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯         ||
[XXX]    ||   That's why I WAS ATTACKED on 01/15/2019, left address, I was ATTACKED AGAIN on 03/07/2019, right side.     ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   I ASKED MY OLD INSTRUCTOR (BRUCE CHENEY/CYBERSTONE SECURITY) FOR SOME HELP...?                             ||
[XXX]    ||   BUT HE'S SORT OF A DIPSHIT THAT HAS TO HIDE HIS TAIL BETWEEN HIS LEGS AND GETS OFFENDED VERY EASILY.       ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Hybrid | Desired State Controller",
    "05/2019",
    "https://youtu.be/C8NYaaqJAlI",
    @"
This is a DEMONSTRATION of the MICROSOFT DEPLOYMENT TOOLKIT MODIFICATION that I spent like...
(4) months working on, WHILE learning how to use PowerShell.

I became rather INTRIGUED with the IDEA of DEPLOYING WINDOWS 10 TO THE CUSTOMERS COMPUTERS at:
___________________________________________________________________________________________
| COMPUTER ANSWERS | 1602 US-9, Clifton Park, NY 12065 | 514 MAIN ST. BENNINGTON VT 05201 |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 That's why I WAS ATTACKED on 01/15/2019, left address, I was ATTACKED AGAIN on 03/07/2019, right side.

I ASKED MY OLD INSTRUCTOR (BRUCE CHENEY/CYBERSTONE SECURITY) FOR SOME HELP...?
BUT HE'S SORT OF A DIPSHIT THAT HAS TO HIDE HIS TAIL BETWEEN HIS LEGS AND GETS OFFENDED VERY EASILY.
"@)


<# [Add Skill[13]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Methodologies                                                                                   11/2019     /
[XXX]    /    https://youtu.be/bZuSgBK36CE                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I was about LESS THAN (1) year into PROGRAMMING/APP DEVELOPMENT w/ POWERSHELL.       ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Methodologies",
    "11/2019",
    "https://youtu.be/bZuSgBK36CE",
    "This is a video where I was about LESS THAN (1) year into PROGRAMMING/APP DEVELOPMENT w/ POWERSHELL.")

<# [Add Skill[14]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Education/Exhibition Program Design                                                             08/2019     /
[XXX]    /    https://youtu.be/v6RrrzR5v2E                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I was in the MIDDLE of being ATTACKED by some HACKERS, so I decided to tell em:      ||
[XXX]    ||          __________________________________________________________________________________________          ||
[XXX]    ||          | Me : You know what...?                                                                 |          ||
[XXX]    ||          |      Fuck you guys.                                                                    |          ||
[XXX]    ||          |      I'm just gonna start RECORDING VIDEOS of ME, TEACHING OTHER PEOPLE...             |          ||
[XXX]    ||          |      ...that way you queers have 2x fewer legs to stand on when you keep ATTACKING ME. |          ||
[XXX]    ||          ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯          ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Education/Exhibition Program Design",
    "08/2019",
    "https://youtu.be/v6RrrzR5v2E",
    @"
This is a video where I was in the MIDDLE of being ATTACKED by some HACKERS, so I decided to tell em:
___________________________________________________________________________________________
| Me : You know what...?                                                                  |
|      Fuck you guys.                                                                     |
|      I'm just gonna start RECORDING VIDEOS of ME, TEACHING OTHER PEOPLE...              |
|      ...that way you queers have 2x fewer legs to stand on when you keep ATTACKING ME.  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

# // ________________________________________________________________________________________________________________________
# // | Section: [Network/Hardware Magistration]                                                                             |
# // |----------------------------------------------------------------------------------------------------------------------|
# // | Date    | Name                                  | Detail                                                             |
# // |---------|---------------------------------------|--------------------------------------------------------------------|
# // | 07/2017 | Spectrum Cable Modem Reset            | https://youtu.be/LfZW-s0BMow                                       |
# // | 04/2018 | How to repair an iPhone 7+            | https://youtu.be/i3qn1CZ-5WM                                       |
# // | 03/2018 | Troubleshooting Network Equipment 101 | https://youtu.be/0nEiGijjOEY                                       |
# // | 11/2017 | Troubleshooting a poorly made CRM     | https://youtu.be/xs-FVZgjnkI                                       |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

<# [Add Skill[15]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \   [06] 07/2017 - Spectrum Cable Modem Reset                                                                    /
[XXX]    /   https://youtu.be/LfZW-s0BMow                                                                                 \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video that showcases just how gay PAVEL ZAICHENKO/CEO of COMPUTER ANSWERS, actually is.          ||
[XXX]    ||   If people wanna argue with me “I don't see anything that indicates this dude is gay...”                    ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   OH- well, I was able to EDUCATE A LOT OF PEOPLE by BEING MORE TALENTED at RUNNING COMPUTER ANSWERS,        ||
[XXX]    ||   the COMPANY, than the OWNER/CEO... and EVEN the Vice President, DWAYNE O. COONRADT, the ol' PC-DOC         ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Spectrum Cable Modem Reset",
    "07/2017",
    "https://youtu.be/LfZW-s0BMow",
    @"
This is a video that showcases just how gay PAVEL ZAICHENKO/CEO of COMPUTER ANSWERS, actually is.
If people wanna argue with me “I don't see anything that indicates this dude is gay...”
    
OH- well, I was able to EDUCATE A LOT OF PEOPLE by BEING MORE TALENTED at RUNNING COMPUTER ANSWERS,
the COMPANY, than the OWNER/CEO... and EVEN the Vice President, DWAYNE O. COONRADT, the ol' PC-DOC
"@)

<# [Add Skill[16]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \   How to repair an iPhone 7+                                                                       04/2018     /
[XXX]    /   https://youtu.be/i3qn1CZ-5WM                                                                                 \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video that showcases how gay TIM COOK/CEO of APPLE CORPORATION, actually is.                     ||
[XXX]    ||   APPLE DISABLED MY IPHONE 8+ AFTER I SHOWED NYS TROOPER SHAEMUS LEAVEY A VIDEO OF 2 GUYS USING PEGASUS,     ||
[XXX]    ||   AS THEY WERE ATTEMPTING TO MURDER ME OUTSIDE OF (1597-1602) US-9, CLIFTON PARK NY 12065 on 05/26/2020.     ||    
[XXX]    ||                                                                                                              ||
[XXX]    ||   RESULTANT, I HAVE WITNESSED TIM COOK BEING PRIMARILY RESPONSIBLE FOR COMMITTING OBSTRUCTION OF JUSTICE.    ||
[XXX]    ||   TIM COOK will CONTINUALLY be CALLED OUT for being a FLAMING HOMOSEXUAL for ALLOWING THIS. I KNOW THAT IS   ||
[XXX]    ||   EXACTLY WHAT HAPPENED, but the COMMUNITY and the POLICE have been TOO BUSY BEING MORONS, to watch this.    ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   Sorta know what I'm doing more than most people in the COMMUNITY or the POLICE. (<- FACT, not an OPINION)  ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   As for TIM COOK (CEO OF APPLE), the man has received a LOT of awards from the town, for being the GAYEST   ||
[XXX]    ||   GUY IN CUPERTINO, CA each year. Nobody in CUPERTINO has a shot at outdoing this man, at being gay.         ||
[XXX]    ||   Outside of CUPERTINO, CA...? VLADIMIR PUTIN, APT29 & CERBERUS most definitely win, hands down.             ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   By the way, TIM COOK and I are NOT RELATED, but that man is DEFINITELY ALMOST as gay, as APT29.            ||
[XXX]    ||   I have MORE EXPERIENCE than:                                                                               ||
[XXX]    ||   ____________________________________________________________________________________________________       ||
[XXX]    ||   | the people who work at ANY APPLE STORE | MOST of the people at APPLE HQ in CUPERTINO, CALIFORNIA |       ||
[XXX]    ||   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯       ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("How to repair an iPhone 7+",
    "04/2018",
    "https://youtu.be/i3qn1CZ-5WM",
    @"
This is a video that showcases how gay TIM COOK/CEO of APPLE CORPORATION, actually is.
APPLE DISABLED MY IPHONE 8+ AFTER I SHOWED NYS TROOPER SHAEMUS LEAVEY A VIDEO OF 2 GUYS USING PEGASUS,
AS THEY WERE ATTEMPTING TO MURDER ME OUTSIDE OF (1597-1602) US-9, CLIFTON PARK NY 12065 on 05/26/2020.

RESULTANT, I HAVE WITNESSED TIM COOK BEING PRIMARILY RESPONSIBLE FOR COMMITTING OBSTRUCTION OF JUSTICE.
TIM COOK will CONTINUALLY be CALLED OUT for being a FLAMING HOMOSEXUAL for ALLOWING THIS. I KNOW THAT IS
EXACTLY WHAT HAPPENED, but the COMMUNITY and the POLICE have been TOO BUSY BEING MORONS, to watch this.

Sorta know what I'm doing more than most people in the COMMUNITY or the POLICE. (FACT, not an OPINION)

As for TIM COOK (CEO OF APPLE), the man has received a LOT of awards from the town, for being the GAYEST
GUY IN CUPERTINO, CA each year. Nobody in CUPERTINO has a shot at outdoing this man, at being gay.
Outside of CUPERTINO, CA...? VLADIMIR PUTIN, APT29 & CERBERUS most definitely win, hands down.

By the way, TIM COOK and I are NOT RELATED, but that man is DEFINITELY ALMOST as gay, as APT29.
I have MORE EXPERIENCE than:
____________________________________________________________________________________________________
| the people who work at ANY APPLE STORE | MOST of the people at APPLE HQ in CUPERTINO, CALIFORNIA |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[17]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Troubleshooting Network Equipment 101                                                           03/2018     /
[XXX]    /    https://youtu.be/0nEiGijjOEY                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video that showcases how gay DWAYNE COONRADT/VP of COMPUTER ANSWERS, APPEARS to be when he       ||
[XXX]    ||   refuses to tell people that I outperformed him for the 3+ years I (worked at/MANAGED the COMPANY)...       ||
[XXX]    ||   COMPUTER ANSWERS.                                                                                          ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Troubleshooting Network Equipment 101",
    "03/2018",
    "https://youtu.be/0nEiGijjOEY",
    @"
This is a video that showcases how gay DWAYNE COONRADT/VP of COMPUTER ANSWERS, APPEARS to be when he
refuses to tell people that I outperformed him 100% of the 3+ years I (worked at/MANAGED) the COMPANY
COMPUTER ANSWERS.
"@)

<# [Add Skill[18]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Troubleshooting a poorly made CRM                                                               11/2017     /
[XXX]    /    https://youtu.be/xs-FVZgjnkI                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I am attempting to educate the lazy moron who owns COMPUTER ANSWERS, what was        ||
[XXX]    ||   ALWAYS PROBLEMATIC about the PIECE OF SHIT SOFTWARE that he was attempting to build, without having the    ||
[XXX]    ||   experience necessary to do so. He actually STOLE THIS SOFTWARE from SOHRAB GHAIRAT who is an ACTUAL        ||
[XXX]    ||   EXPERT at DEVELOPING APPLICATIONS/PROGRAMMING.                                                             ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Troubleshooting a poorly made CRM",
    "11/2017",
    "https://youtu.be/xs-FVZgjnkI",
    @"
This is a video where I am attempting to educate the lazy moron who owns COMPUTER ANSWERS, what was
ALWAYS PROBLEMATIC about the PIECE OF SHIT SOFTWARE that he was attempting to build without having the 
experience necessary to do so. He actually STOLE THIS SOFTWARE from SOHRAB GHAIRAT who is an ACTUAL 
EXPERT at DEVELOPING APPLICATIONS/PROGRAMMING.
"@)

# // _________________________________________________________________________________________________________________________________________
# // | Section: [Graphic Design]                                                                                                             |
# // |---------------------------------------------------------------------------------------------------------------------------------------|
# // | Date    | Subject               | Name                            | Detail                                                            |
# // |---------|-----------------------|---------------------------------|-------------------------------------------------------------------|
# // | 08/2021 | Game Design 101 (1/4) | 20KDM1: Return to Castle: Quake | https://youtu.be/xN53K9oGCME                                      |
# // | 08/2021 | Game Design 101 (2/4) | 20KDM1: Tempered Graveyard      | https://youtu.be/dyHwm9AdkQs                                      |
# // | 08/2021 | Game Design 101 (3/4) | 20KCTF1: Out of my head         | https://youtu.be/rwyHCNnwlkM                                      |
# // | 08/2021 | Game Design 101 (4/4) | 20KDM3: Insane Products         | https://youtu.be/EG8UyJSMK3Y                                      |
# // | 05/2001 | Website Design 101    | BFG20K's Shopping Maul          | http://web.archive.org/web/20220000000000*/planetquake.com/bfg20k |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

<# [Add Skill[19]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Game Design 101 Part I - 20KDM2 - Return to Castle: Quake                                       08/2021     /
[XXX]    /    https://youtu.be/xN53K9oGCME                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAY back in (2001/2002) for    ||
[XXX]    ||   QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2001.                            ||
[XXX]    ||                     _________________________________________________________________                        ||
[XXX]    ||                     | This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |                        ||
[XXX]    ||                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                        ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Game Design 101 Part I - 20KDM2 - Return to Castle: Quake",
    "08/2021",
    "https://youtu.be/xN53K9oGCME",
    @"
This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAY back in (2001/2002) for
QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2001.
_________________________________________________________________
| This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[20]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Game Design 101 Part II - 20KDM1 - Tempered Graveyard                                           08/2021     /
[XXX]    /    https://youtu.be/dyHwm9AdkQs                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAY back in (2001) for         ||
[XXX]    ||   QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2001.                            ||
[XXX]    ||                     _________________________________________________________________                        ||
[XXX]    ||                     | This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |                        ||
[XXX]    ||                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                        ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Game Design 101 Part II - 20KDM1 - Tempered Graveyard",
    "08/2021",
    "https://youtu.be/dyHwm9AdkQs",
    @"
This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAY back in (2001) for
QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2001.
_________________________________________________________________
| This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[21]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Game Design 101 Part III - 20KCTF1 - Out of my head                                             08/2021     /
[XXX]    /    https://youtu.be/rwyHCNnwlkM                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAAY back in (2002) for        ||
[XXX]    ||   QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2002.                            ||
[XXX]    ||                     ___________________________________________________________________                      ||
[XXX]    ||                     | This particular map is OLDER THAN FACEBOOK, or COMPUTER ANSWERS |                      ||
[XXX]    ||                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                      ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Game Design 101 Part III - 20KCTF1 - Out of my head",
    "08/2021",
    "https://youtu.be/rwyHCNnwlkM",
    @"
This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAAY back in (2002) for
QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2002.
_________________________________________________________________
| This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[22]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Game Design 101 Part IV - 20KDM3 - Insane Products                                              08/2021     /
[XXX]    /    https://youtu.be/EG8UyJSMK3Y                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAAY back in (2006) for        ||
[XXX]    ||   QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2006.                            ||
[XXX]    ||                     _________________________________________________________________                        ||
[XXX]    ||                     | This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |                        ||
[XXX]    ||                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                        ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Game Design 101 Part IV - 20KDM3 - Insane Products",
    "08/2021",
    "https://youtu.be/EG8UyJSMK3Y",
    @"
This is a LEVEL that I CREATED for my WEBSITE on PLANETQUAKE.COM/BFG20K, WAAAAAY back in (2006) for
QUAKE III ARENA, which showcases that I knew how to DESIGN VIDEO GAMES in 2006.
_________________________________________________________________
| This particular map is OLDER THAN FACEBOOK & COMPUTER ANSWERS |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[23]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Website Design 101 - <|3FG20K>'s Shopping Maul                                                  05/2001     /
[XXX]    /    http://web.archive.org/web/20220000000000*/planetquake.com/bfg20k                                           \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a link to the WAYBACK MACHINE, featuring a WEBSITE that I CREATED when I was 15 years old.         ||
[XXX]    ||   This particular website is OLDER THAN FACEBOOK. AND YOUTUBE. AND REDDIT. AND TWITTER. AND MYSPACE...       ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   So, when I hear people tell me that “I don't have enough experience”, that means they probably could use   ||
[XXX]    ||   a nice, fresh smack across the fuckin' face. Dead serious.                                                 ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   The WEBSITE BFG20K's Shopping Maul EXISTED in 1999, but then PLANETQUAKE.COM was like:                     ||
[XXX]    ||                         ___________________________________________________________                          ||
[XXX]    ||                         | PlanetQuake : DUDE, YOU CAN TOTALLY HAVE A HOSTED SITE. |                          ||
[XXX]    ||                         |               YOU'RE ONLY 15...?                        |                          ||
[XXX]    ||                         |               THIS SHIT IS COOL AS FUCK.                |                          ||
[XXX]    ||                         ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                          ||
[XXX]    ||   Thus, PLANETQUAKE.COM/BFG20K was born, WAAAAAAY back in 2001~!                                             ||
[XXX]    ||   Like, BEFORE THE TWIN TOWERS WERE ATTACKED~!                                                               ||
[XXX]    ||   But, I'm gonna get some cocksucker that will TRY to say that “I don't have enough experience.” Sure.       ||
[XXX]    ||   To anyone who wants to say that...?                                                                        ||
[XXX]    ||   Make yourself useful, and go suck a fuckin' dick like MARK ZUCKERBERG does.                                ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Website Design 101 - BFG20K's Shopping Maul",
    "05/2001",
    "http://web.archive.org/web/20220000000000*/planetquake.com/bfg20k", @"
This is a link to the WAYBACK MACHINE, featuring a WEBSITE that I CREATED when I was 15 years old.
This particular website is OLDER THAN FACEBOOK. AND YOUTUBE. AND REDDIT. AND TWITTER. AND MYSPACE...

So, when I hear people tell me that “I don't have enough experience”, that means they probably could use
a nice, fresh smack across the fuckin' face. Dead serious.

The WEBSITE BFG20K's Shopping Maul EXISTED in 1999, but then PLANETQUAKE.COM was like:
___________________________________________________________
| PlanetQuake : DUDE, YOU CAN TOTALLY HAVE A HOSTED SITE. |
|               YOU'RE ONLY 15...?                        |
|               THIS SHIT IS COOL AS FUCK.                |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Thus, PLANETQUAKE.COM/BFG20K was born, WAAAAAAY back in 2001~!
Like, BEFORE THE TWIN TOWERS WERE ATTACKED~!
But, I'm gonna get some cocksucker that will TRY to say that “I don't have enough experience.” Sure.
To anyone who wants to say that...?
Make yourself useful, and go suck a fuckin' dick like MARK ZUCKERBERG does.
"@)

# // ________________________________________________________________________________________________________________________
# // | Section: [Security Engineering & Journalism]                                                                         |
# // |----------------------------------------------------------------------------------------------------------------------|
# // | Date    | Name                                 | Detail                                                              |
# // |---------|--------------------------------------|---------------------------------------------------------------------|
# // | 08/2022 | Top Deck Awareness - Not News        | https://drive.google.com/file/d/1XWGSsZ-rGQHfB8eY2Xm6uu51wuj1MqFW   |
# // | 03/2018 | News 10, Andrew Banas, WEEPING ANGEL | https://youtu.be/bPdWt7kcd3M                                        |
# // | 02/2022 | CIA/VAULT 7/Archimedes               | https://youtu.be/QP25FbNhakQ                                        |
# // | 02/2022 | CIA/VAULT 7/After Midnight (#1)      | https://youtu.be/LYVUMLpofWg                                        |
# // | 02/2022 | CIA/VAULT 7/After Midnight (#2)      | https://youtu.be/oShPs6_uXIk                                        |
# // | 02/2022 | Facebook BSOD                        | https://youtu.be/40sQXpVh_8Y                                        |
# // | 02/2022 | Facebook Censorship                  | https://youtu.be/Jmq4yBqGhTs                                        |
# // | 09/2019 | Hardware Security                    | https://youtu.be/-jkDPv9H6BQ                                        |
# // | 03/2019 | NFRASTRUCTURE – RICO                 | https://youtu.be/vmDVKwTF2Zc                                        |
# // | 02/2022 | A Matter of National Security        | https://youtu.be/e4VnZObiez8                                        |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

<# [Add Skill[24]]
[XXX]|   /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]|   \    Top Deck Awareness - Not News                                                                   08/2022     /
[XXX]|   /    https://drive.google.com/file/d/1XWGSsZ-rGQHfB8eY2Xm6uu51wuj1MqFW                                           \
[XXX]|   \________________________________________________________________________________________________________________/
[XXX]|   //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]|   ||   My master thesis about the following subjects:                                                             ||
[XXX]|   ||   ________________________________________________________________________________________________________   ||
[XXX]|   ||   | U.S. CONSTITUTION | PSYCHOLOGICAL MANIPULATION | PRIVATE INVESTIGATION   |     COOL/SMART RICH DUDES |   ||
[XXX]|   ||   | HIDDEN GOVERNMENT | USA-PATRIOT ACT of 2001    | SURVEILLANCE CAPITALISM | LAME/DOUCHEBAG RICH DUDES |   ||
[XXX]|   ||   | NEWS VS PROPAGANDA | EXPERT PROGRAMMING | INJUSTICE | JULIEN ASSANGE | EDWARD SNOWDEN | U.S. HISTORY |   ||
[XXX]|   ||   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ||
[XXX]|   \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Top Deck Awareness - Not News",
    "08/2022",
    "https://drive.google.com/file/d/1XWGSsZ-rGQHfB8eY2Xm6uu51wuj1MqFW",
    @"
My master thesis about the following subjects:                                                              
________________________________________________________________________________________________________
| U.S. CONSTITUTION | PSYCHOLOGICAL MANIPULATION | PRIVATE INVESTIGATION   |     COOL/SMART RICH DUDES |
| HIDDEN GOVERNMENT | USA-PATRIOT ACT of 2001    | SURVEILLANCE CAPITALISM | LAME/DOUCHEBAG RICH DUDES |
| NEWS VS PROPAGANDA | EXPERT PROGRAMMING | INJUSTICE | JULIEN ASSANGE | EDWARD SNOWDEN | U.S. HISTORY |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[25]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    News 10 - Interview with Andrew Banas regarding WEEPING ANGEL                                   03/2018     /
[XXX]    /    https://youtu.be/bPdWt7kcd3M                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is an INTERVIEW that I had with an actual NEWS REPORTER named ANDREW BANAS, WAAAAY back in 03/2018    ||
[XXX]    ||   when I MANAGED COMPUTER ANSWERS at 1602 Route 9, CLIFTON PARK, NY 12065.                                   ||
[XXX]    ||   This was BEFORE (HOMOSEXUALS/HACKERS from APT29) STARTED TO ATTACK ME and my work.                         ||
[XXX]    ||   Still, I must NOT have enough EXPERIENCE to run CIRCLES around people that make over $250K/year, right?    ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("News 10 - Interview with Andrew Banas regarding WEEPING ANGEL",
    "03/2018",
    "https://youtu.be/bPdWt7kcd3M",
    @"
This is an INTERVIEW that I had with an actual NEWS REPORTER named ANDREW BANAS, WAAAAY back in 03/2018
when I MANAGED COMPUTER ANSWERS at 1602 Route 9, CLIFTON PARK, NY 12065.
This was BEFORE (HOMOSEXUALS/HACKERS from APT29) STARTED TO ATTACK ME and my work.
Still, I must NOT have enough EXPERIENCE to run CIRCLES around people that make over `$250K/year, right?
"@)

<# [Add Skill[26]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Central Intelligence Agency/VAULT 7/Archimedes                                                  02/2022     /
[XXX]    /    https://youtu.be/QP25FbNhakQ                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   MARK ZUCKERBERG, owner of FACEBOOK using a TOOL developed by the CENTRAL INTELLIGENCE AGENCY from          ||
[XXX]    ||   VAULT 7, to CAUSE INTERFERENCE to my LAPTOP, the CONTEXT of the VIDEO should SHOWCASE the REASONS WHY.     ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Central Intelligence Agency/VAULT 7/Archimedes",
    "02/2022",
    "https://youtu.be/QP25FbNhakQ",
    @"
MARK ZUCKERBERG, owner of FACEBOOK using a TOOL developed by the CENTRAL INTELLIGENCE AGENCY from
VAULT 7, to CAUSE INTERFERENCE to my LAPTOP, the CONTEXT of the VIDEO should SHOWCASE the REASONS WHY.
"@)

<# [Add Skill[27]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    [02] 02/2022 - Central Intelligence Agency/VAULT 7/After Midnight (Laptop angle)                            /
[XXX]    /    https://youtu.be/LYVUMLpofWg                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   From the CYBERATTACK on 02/26/22, featuring AFTERMIDNIGHT, another CENTRAL INTELLIGENCE AGENCY tool from   ||
[XXX]    ||   VAULT 7, being used against me to DISTRIBUTE MALICIOUS PAYLOADS and SCRIPTS to my device to CORRUPT the    ||
[XXX]    ||   DATA on my SYSTEM, because of the CENSORSHIP VIDEO I posted below. (It failed)                             ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Central Intelligence Agency/VAULT 7/After Midnight (Laptop angle)",
    "02/2022",
    "https://youtu.be/LYVUMLpofWg",
    @"
From the CYBERATTACK on 02/26/22, featuring AFTERMIDNIGHT, another CENTRAL INTELLIGENCE AGENCY tool from
VAULT 7, being used against me to DISTRIBUTE MALICIOUS PAYLOADS and SCRIPTS to my device to CORRUPT the
DATA on my SYSTEM, because of the CENSORSHIP VIDEO I posted below. (It failed)
"@)

<# [Add Skill[28]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    [03] 02/2022 - Central Intelligence Agency/VAULT 7/After Midnight (Smartphone angle)                        /
[XXX]    /    https://youtu.be/oShPs6_uXIk                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   From the CYBERATTACK on 2/26/22, featuring AFTERMIDNIGHT, another CENTRAL INTELLIGENCE AGENCY tool from    ||
[XXX]    ||   VAULT 7, being used against mme to DISTRIBUTE MALICIOUS PAYLOADS and SCRIPTS to my device to CORRUPT the   ||
[XXX]    ||   DATA on my SYSTEM, because of the CENSORSHIP VIDEO I posted below.                                         ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Central Intelligence Agency/VAULT 7/After Midnight (Smartphone angle)",
    "02/2022",
    "https://youtu.be/oShPs6_uXIk",
    @"
From the CYBERATTACK on 2/26/22, featuring AFTERMIDNIGHT, another CENTRAL INTELLIGENCE AGENCY tool from
VAULT 7, being used against mme to DISTRIBUTE MALICIOUS PAYLOADS and SCRIPTS to my device to CORRUPT the
DATA on my SYSTEM, because of the CENSORSHIP VIDEO I posted below.
"@)

<# [Add Skill[29]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    [04] 02/2022 - Facebook BSOD                                                                                /
[XXX]    /    https://youtu.be/40sQXpVh_8Y                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a BLUE SCREEN OF DEATH that was CAUSED by FACEBOOK AFFILIATES that are HACKERS and they're known   ||
[XXX]    ||   as (APT29/ADVANCED PERSISTENT THREAT 29), and they COMMIT CYBERATTACKS/IDENTITY THEFT and are VERY GAY,    ||
[XXX]    ||   and every single one of them has sucked at QUAKE III ARENA over the last 20+ years.                        ||
[XXX]    ||                  __________________________________________________________________________                  ||
[XXX]    ||                  | APT29 : Yeah, we're the most raging homosexuals on the fuckin' planet. |                  ||
[XXX]    ||                  |         AND, we suck at QUAKE III ARENA. So what...?                   |                  ||
[XXX]    ||                  |         Who's gonna stop us...? Hm...?                                 |                  ||
[XXX]    ||                  |         NOBODY... that's who.                                          |                  ||
[XXX]    ||                  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                  ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Facebook BSOD",
    "02/2022",
    "https://youtu.be/40sQXpVh_8Y",
    @"
This is a BLUE SCREEN OF DEATH that was CAUSED by FACEBOOK AFFILIATES that are HACKERS and they're known
as (APT29/ADVANCED PERSISTENT THREAT 29), and they COMMIT CYBERATTACKS/IDENTITY THEFT and are VERY GAY,
and every single one of them has sucked at QUAKE III ARENA over the last 20+ years.
__________________________________________________________________________
| APT29 : Yeah, we're the most raging homosexuals on the fuckin' planet. |
|         AND, we suck at QUAKE III ARENA. So what...?                   |
|         Who's gonna stop us...? Hm...?                                 |
|         NOBODY... that's who.                                          |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

<# [Add Skill[30]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    [05] 02/2022 - Facebook Censorship                                                                          /
[XXX]    /    https://youtu.be/Jmq4yBqGhTs                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video that showcases how gay MARK ZUCKERBERG/CEO OF FACEBOOK, actually is. I posted a comment,   ||
[XXX]    ||   and then like magic, my COMMENT is REMOVED from the system before my very eyes. This showcases a living    ||
[XXX]    ||   example of JUST HOW GAY, MARK ZUCKERBERG truly is. Doesn't matter if he's a COOL, HIGHLY RESPECTED         ||
[XXX]    ||   BILLIONAIRE, because this is what this GAY BASTARD HAS BEEN DOING TO ME ever since I wrote a RESPONSE      ||
[XXX]    ||   to an AD REJECTION in 02/2019. They felt that my AD was VIOLATING PEOPLE'S PRIVACY. What I told him, was   ||
[XXX]    ||   that he's fucking lucky that I wasn't a member of Congress during the CAMBRIDGE ANALYTICA scandal.         ||
[XXX]    \\______________________________________________________________________________________________________________//
#>


$Resume.Person.AddSkill("Facebook Censorship",
    "02/2022",
    "https://youtu.be/Jmq4yBqGhTs",
    @"
This is a video that showcases how gay MARK ZUCKERBERG/CEO OF FACEBOOK, actually is. I posted a comment,
and then like magic, my COMMENT is REMOVED from the system before my very eyes. This showcases a living 
example of JUST HOW GAY, MARK ZUCKERBERG truly is. Doesn't matter if he's a COOL, HIGHLY RESPECTED
BILLIONAIRE, because this is what this GAY BASTARD HAS BEEN DOING TO ME ever since I wrote a RESPONSE
to an AD REJECTION in 02/2019. They felt that my AD was VIOLATING PEOPLE'S PRIVACY. What I told him, was
that he's fucking lucky that I wasn't a member of Congress during the CAMBRIDGE ANALYTICA scandal.
"@)

<# [Add Skill[31]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    Hardware Security                                                                               09/2019     /
[XXX]    /    https://youtu.be/-jkDPv9H6BQ                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video where I discuss the INTERVIEW with ANDREW BANAS, as well as WEEPING ANGEL being REVERSE    ||
[XXX]    ||   ENGINEERED, and EXPANDING UPON HIS REPORT.                                                                 ||
[XXX]    ||   I also explain to people how I'm more EXPERIENCED than LINUS SEBASTIAN from LINUS MEDIA GROUP.             ||
[XXX]    ||   And, that NFRASTRUCTURE was involved in ATTACKING MY EQUIPMENT.                                            ||
[XXX]    ||   I also caught the attention of APT29 with this particular video.                                           ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("Hardware Security",
    "09/2019",
    "https://youtu.be/-jkDPv9H6BQ",
    @"
This is a video where I discuss the INTERVIEW with ANDREW BANAS, as well as WEEPING ANGEL being REVERSE
ENGINEERED, and EXPANDING UPON HIS REPORT.
I also explain to people how I'm more EXPERIENCED than LINUS SEBASTIAN from LINUS MEDIA GROUP.
And, that NFRASTRUCTURE was involved in ATTACKING MY EQUIPMENT.
I also caught the attention of APT29 with this particular video.
"@)

<# [Add Skill[32]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    NFRASTRUCTURE – RICO                                                                            03/2019     /
[XXX]    /    https://youtu.be/vmDVKwTF2Zc                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a VIDEO that I sent to some woman at MICROSOFT regarding the CYBERATTACKS that I kept facing       ||
[XXX]    ||   that I described up above in the PREVIOUS ENTRY. I actually ASSUMED that MICHAEL T. NIEHAUS had some       ||
[XXX]    ||   HAND in ATTACKING ME.                                                                                      ||
[XXX]    ||                                                                                                              ||
[XXX]    ||   I don't think that he had ANYTHING to do with the attack.                                                  ||
[XXX]    ||   I BELIEVE that MR. NIEHAUS has been HELPING ME ever since I recorded this video.                           ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("NFRASTRUCTURE – RICO",
    "03/2019",
    "https://youtu.be/vmDVKwTF2Zc",
    @"
This is a VIDEO that I sent to some woman at MICROSOFT regarding the CYBERATTACKS that I kept facing
that I described up above in the PREVIOUS ENTRY. I actually ASSUMED that MICHAEL T. NIEHAUS had SOME
hand in ATTACKING ME...

However, I don't think that he had ANYTHING to do with the attack.
The attack consisted of 1) PEGASUS/PHANTOM 2) DENIAL OF SERVICE, 3) CVE-2019-8936, 4) WANNACRY.
Basically, SOMEONE WITH A LOT OF TECHNICAL EXPERTISE (like, the queers in APT29 that PAVEL knows)
performed the ATTACK that CAUSED ME TO THINK that my FORMER EMPLOYER had ATTACKED ME.
2 former employers, by the way, not just (1). (2) former employers. 
I BELIEVE that MR. NIEHAUS has been HELPING ME ever since I recorded this video.
"@)

<# [Add Skill[33]]
[XXX]    /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
[XXX]    \    A Matter of National Security                                                                   02/2022     /
[XXX]    /    https://youtu.be/e4VnZObiez8                                                                                \
[XXX]    \________________________________________________________________________________________________________________/
[XXX]    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
[XXX]    ||   This is a video that showcases someone in the CENTRAL INTELLIGENCE AGENCY that has been INTERACTING WITH   ||
[XXX]    ||   ME for over 3+ years (must not have enough experience or something...) by using SCRIBBLES (VAULT 7) to     ||
[XXX]    ||   ADD A LINE OF PIXELS to PARTICULAR LINES OF TEXT in ANY MICROSOFT WORD-LIKE EDITOR, and I TALK ABOUT       ||
[XXX]    ||   PEGASUS/PHANTOM and JULIEN ASSANGE, and EDWARD SNOWDEN.                                                    ||
[XXX]    \\______________________________________________________________________________________________________________//
#>

$Resume.Person.AddSkill("A Matter of National Security",
    "02/2022",
    "https://youtu.be/e4VnZObiez8",
    @"
This is a video that showcases someone in the CENTRAL INTELLIGENCE AGENCY that has been INTERACTING WITH
ME for over 3+ years by using SCRIBBLES (VAULT 7) to ADD A LINE OF PIXELS to PARTICULAR LINES OF TEXT in 
ANY MICROSOFT WORD-LIKE EDITOR, and I TALK ABOUT PEGASUS/PHANTOM and JULIEN ASSANGE, and EDWARD SNOWDEN. 
Still, with all of these INDICATIONS that I have PLENTY of EXPERIENCE...?
I know that someone will come right out and say that I must not have enough, yet.
"@)

$Resume.Illustrate()

# // _______________________________________________
# // | To RENDER the COLORS and stuff, you can use |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# $Resume.Draw() # // DEFAULT COLORS (10/Green), (12/Red), (15/White), (0/Black)

# // _________
# // | OR... |
# // ¯¯¯¯¯¯¯¯¯

# $Resume.Draw(@(10,14,15,0) # // Green, Yellow, White, Black

# // ______________________________________________________
# // | OR... whatever colors you want, knock yourself out |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# // _________________________________________________________________________________________________
# // | To get the STRING OUTPUT...? Run the Illustrate method above, and then use $Resume.ToString() |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Resume.ToString()
