Function Write-Theme
{
    [CmdletBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=0,Mandatory,Position=0)][Object]$InputObject,
        [Parameter(ParameterSetName=0)][String] $Title,
        [Parameter(ParameterSetName=0)][String] $Prompt,
        [Parameter(ParameterSetName=0,Position=1)][UInt32[]] $Palette = @(10,12,15,0),
        [Parameter(ParameterSetName=0)][Switch] $Text,
        [Parameter(ParameterSetName=1,Mandatory)][Switch] $Banner,
        [Parameter(ParameterSetName=2,Mandatory)][Switch] $Flag
    )
    
    Class ThemeMask       # Creates a guide for the function and debugging/editing
    {
        [UInt32] $Index
        [String] $Face
        [UInt32[]] $Char
        ThemeMask([UInt32]$Index,[UInt32[]]$Char)
        {
            $This.Index = $Index
            $This.Char  = $Char
            $This.Face  = [Char[]]$Char -join ''
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    Class ThemeFace       # This is an array of character codes that create the desired blocks for the theme/mask
    {
        Static [Object] $Mask = @{  0  =  32, 32, 32, 32; 1  =  95, 95, 95, 95; 2  = 175,175,175,175; 3  =  45, 45, 45, 45;
                                    4  =  32, 32, 32, 47; 5  =  92, 32, 32, 32; 6  =  32, 32, 32, 92; 7  =  47, 32, 32, 32;
                                    8  =  92, 95, 95, 47; 9  =  47,175,175, 92; 10 =  47,175,175,175; 11 = 175,175,175, 92; 
                                    12 =  92, 95, 95, 95; 13 =  95, 95, 95, 47; 14 =  91, 32, 95, 95; 15 =  95, 95, 32, 93; 
                                    16 =  42, 32, 32, 32; 17 =  32, 32, 42, 32; 18 =  32, 32, 32, 42; 19 =  32, 42, 32, 32; 
                                    20 =  91, 61, 61, 93; 21 =  91, 45, 45, 93; 22 = 175,175,175, 93; 23 =  91,175,175,175;
                                    24 =  32, 32, 32, 93; 25 =  91, 95, 95, 95; 26 =  95, 95, 95, 93; 27 =  92, 95, 95, 91; 
                                    28 =  32, 95, 95, 95; 29 =  95, 95, 95, 32; 30 =  93, 95, 95, 47; 31 =  47,175,175, 91;
                                    32 =  93, 32, 32, 32; }
        [Object[]]      $Guide
        [Object[]]      $Output
        ThemeFace()
        {
            $This.Guide = ForEach ( $X in 0..([ThemeFace]::Mask.Count - 1) )
            { 
                [ThemeMask]::New($X,[ThemeFace]::Mask[$X])
            }
            $This.Output = $This.Guide.Face
        }
    }

    Class ThemeBlock      # This is a 1x[track] x 4[char] chunk of information for Write-Host
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

    Class ThemeTrack      # Represents a 1x[track] in a stack of tracks
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
        [String[]] Guide()
        {
            Return @( 
                "[Guide]{0}" -f ("_" * 147 -join ''); 
                @("  00";0..($This.Mask.Count-1) | % { "  {0:d2}" -f $_ } ) -join "|";
                @("  01";0..($This.Mask.Count-1) | % { $This.Mask[$_].Object }) -join "|";
                "¯" * 154 -join '';
            )
        }
        Display()
        {
            Write-Host ("[Track]{0}" -f ("_" * 113 -join ''))
            $This.Draw(@(10,12,15,0))
            Write-Host ("¯" * 120 -join '')
        }
        Draw([UInt32[]]$Palette)
        {
            ForEach ( $X in 0..($This.Mask.Count-1))
            {
                $Splat              = @{

                    Object          = $This.Mask[$X].Object
                    ForegroundColor = @($Palette)[$This.Mask[$X].ForegroundColor]
                    BackgroundColor = $This.Mask[$X].BackgroundColor
                    NoNewLine       = $X -ne ($This.Mask.Count - 1)
                }

                Write-Host @Splat
            }
        }
    }

    Class ThemeTemplate   # Generates a range of templates based on InputObject types/mixtures # @(4;9;27;14;@(1)*21;29;30;9;8;7)
    {
        Hidden [String[]] $StringStr = (("0;1;@(0)*25;1;1;0 4;9;12;@(1)*23;13;9;8;7 6;8;10;@(2)*23;11;8;10;0 0;11;27;28;@(1)*21;29;30;10;0;0" +
        " 0;0;@(2)*25;0;0;0 0;1;0;@(1)*25;0;0 4;9;8;10;@(2)*23;11;12;0 6;8;10;28;@(0)*23;13;9;5 0;11;12;@(1)*23;13;9;8;7 0;0;@(2)*25;0" + 
        ";2;0 6;8;10;@(2)*23;11;8;9;5 4;9;27;28;@(1)*21;29;30;9;8;7 6;8;10;@(2)*24;0;11;5 4;10;@(0)*26;4;7 6;5;@(0)*26;6;5 6;12;@(0)*25;13;9" + 
        ";5 4;9;12;@(1)*23;13;10;13;7").Split(" ") | % { "@($_)" })
        Hidden [String[]] $ForeStr = (( "@(0)*30 0;1;@(0)*25;1;1;0 0;1;@(1)*25;1;0;0 0;0;1;@(2)*23;1;0;0;0 @(0)*30 @(0)*30 0;1;0;@(1)*25;0;0" +
        " 0;1;1;@(2)*24;1;1;0 0;0;@(1)*25;0;1;0 @(0)*30 0;@(1)*28;0 0;1;1;@(2)*23;1;0;1;0 0;1;@(0)*26;0;0 @(0)*30 @(0)*30 @(0)*28;1;0 0;1;" + 
        "@(0)*25;1;1;0").Split(" ") | % { "@($_)" })
        Hidden [String[]] $BackStr = ( 0..16 | % { "@({0})" -f ( @(0)*30 -join ',' ) } )
        [String]        $Name
        [Int32]      $Header
        [Int32]        $Body
        [Int32]      $Footer
        [String[]]    $String
        [String[]]      $Fore
        [String[]]      $Back
        [Object[]]     $Track
        ThemeTemplate([UInt32]$Slot)
        {
            $This.Name   = ("Function Action Section Table Test" -Split " ")[$Slot]
            $Span        = Switch($Slot) { 0 { 0..4 } 1 { 5..9 } 2 { 0..1+10..16+2..4 } 3 { -1 } 4 { -1 } }
            $This.Header = @(3,2,3,3,3)[$Slot]
            $This.Body   = @(-1, 6)[$Slot -eq 2]
            $This.Footer = @(-1,10)[$Slot -eq 2]
            $This.String = @($Span | % { $This.StringStr[$_] })
            $This.Fore   = @($Span | % { $This.ForeStr[$_] })
            $This.Back   = @($Span | % { $This.BackStr[$_] })
            $This.Track  = @( )
            
            0..( $This.String.Count - 1 ) | % {

                $This.Track += [ThemeTrack]::New($_,$This.String[$_],$This.Fore[$_],$This.Back[$_])
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
            "¯" * 156 -join '')
        }
        Display()
        {
            Write-Host ("[Theme]{0}" -f ("_" * 113 -join ''))
            $This.Draw(@(10,12,15,0))
            Write-Host ("¯" * 120 -join '')
        }
        Draw([UInt32[]]$Palette)
        {
            ForEach ($Track in $This.Track)
            {
                $Track.Draw($Palette)
            }
        }
    }

    Class ThemeInput      # Manhandles a range of inputs
    {
        [String] $Type
        Hidden [String] $Buffer
        Hidden [String] $Key
        [Object] $Output
        ThemeInput([String]$Type,[String]$Line)
        {
            $This.Type                        = $Type
            $This.Output                      = @( )
            $This.Buffer                      = $Null
            $This.Key                         = $Null
            If ($Line.Length -gt 86)
            {
                Do
                {
                    $This.Output             += $Line.Substring(0,86)
                    $Line                     = $Line.Substring(86) 
                }
                Until ($Line.Length -le 86)
                $This.Output                 += $Line
            }
            Else
            {
                $This.Output                 += $Line
            }
        }
        ThemeInput([String]$Type,[UInt32]$Buffer,[String]$Name,[Object]$Value)
        {
            $This.Type                        = $Type
            $This.Output                      = @( )
            If ($Buffer -gt $Name.Length)
            {
                $This.Key                     = "{0}{1}" -f $Name,((@(" ") * ($Buffer-$Name.Length) -join ''))
                $This.Buffer                  = " " * $Buffer -join ''
            }
            Else
            {
                $This.Key                     = $Name
                $This.Buffer                  = " " * $Name.Length -join ''
            }
            If ($Value.Count -eq 1)
            {
                $Line                         = "{0} : {1}" -f $This.Key, $Value
                If ($Line.Length -gt 86)
                {
                    Do
                    {
                        $This.Output         += $Line.Substring(0,86)
                        $Line                 = "{0}   {1}" -f $This.Buffer,$Line.Substring(86)
                    }
                    Until ($Line.Length -le 86)
                    $This.Output             += $Line
                }
                Else
                {
                    $This.Output             += $Line
                }
            }
            If ($Value.Count -gt 1)
            {
                ForEach ($X in 0..($Value.Count-1))
                {
                    If ($X -eq 0)
                    {
                        $Line                 = "{0} : {1}" -f $This.Key, $Value[$X]
                        If ($Line.Length -gt 86)
                        {
                            Do
                            {
                                $This.Output += $Line.Substring(0,86)
                                $Line         = "{0}   {1}" -f $This.Buffer, $Line.Substring(86)
                            }
                            Until ($Line.Length -le 86)
                            $This.Output     += $Line
                        }
                        Else
                        {
                            $This.Output     += $Line
                        }
                    }
                    Else 
                    {
                        $Line                 = "{0}   {1}" -f $This.Buffer, $Value[$X]
                        If ($Line.Length -gt 86)
                        {
                            Do 
                            {
                                $This.Output += $Line.Substring(0,86)
                                $Line         = "{0}   {1}" -f $This.Buffer, $Line.Substring(86)
                            } 
                            Until ($Line.Length -le 86)
                            $This.Output     += $Line
                            
                        }
                        Else
                        {
                            $This.Output     += $Line
                        }
                    }
                }
            }
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ThemeObject     # Prepares the entire input stack
    {
        [String] $Type
        [String] $Height
        [Object] $Stack
        [Object] $Swap
        [Object] $Output
        ThemeObject([Object]$IP)
        {
            $This.Type   = $IP.GetType().Name
            $This.Stack  = @( )
            $This.Swap   = @{ }
            $This.Output = @( )

            If ($This.Type -notmatch "\w+\[\]")
            {
                $This.GetObject($IP)
            }

            ElseIf ($This.Type -match "String")
            {
                $This.Output = $IP
            }

            Else
            {
                If ($IP.Count -eq 1)
                {
                    $This.GetObject($IP)
                }

                ElseIf ($IP.Count -gt 1)
                {
                    ForEach ($Item in $IP)
                    {
                        $This.GetObject($Item)
                    }
                }
            }

            $This.Swap = @{ }
            $X         = 0
            If (($This.Stack | ? Type -ne "").Count -eq 1)
            {
                $This.Swap.Add(0,@())
                ForEach ($Item in $This.Stack)
                {
                    $This.Swap[0] += $Item.Output
                }
            }
            Else
            {
                ForEach ($Item in $This.Stack)
                {
                    If ($Item.Type -ne "")
                    {
                        $This.Swap.Add($X,@($Item.Output))
                        $X ++
                    }

                    If ($Item.Type -eq "")
                    {
                        $This.Swap[$X-1] += $Item.Output
                    }
                }
            }

            If ($This.Swap.Count -eq 1)
            {
                ForEach ($Line in $This.Swap[$X])
                {
                    $This.Output += $Line
                }
            }

            If ($This.Swap.Count -gt 1)
            {
                ForEach ($X in 0..($This.Swap.Count-1))
                {
                    ForEach ($Line in $This.Swap[$X])
                    {
                        $This.Output += $Line
                    }
                }
            }

            $This.Height = $This.Output.Count
        }
        GetObject([Object]$Object)
        {
            Switch -Regex ($Object.GetType().Name)
            {
                "^Hashtable$"
                {
                    $This.Stack     += [ThemeInput]::New("Hashtable"," ")
                    $Buffer          = ($Object.Keys | Sort-Object Length | Select-Object -Last 1 | % Length) + 2
                    $Object.GetEnumerator() | % { 
                        
                        $This.Stack += [ThemeInput]::New($Null,$Buffer,$_.Name,$_.Value)
                    }
                    $This.Stack     += [ThemeInput]::New($Null," ")
                }
                "^(String|[u]*int\d+)$"
                {
                    $This.Stack     += [ThemeInput]::New($Object.GetType().Name,$Object)
                }
                Default
                {
                    $This.Stack     += [ThemeInput]::New($Object.GetType().Name," ")
                    $Buffer          = ($Object.PSObject.Properties.Name | Sort-Object Length | Select-Object -Last 1 | % Length) + 2
                    ForEach ($Item in $Object.PSObject.Properties.Name)
                    {
                        $This.Stack += [ThemeInput]::New($Null,$Buffer,$Item,$Object.$Item)
                    }
                    $This.Stack     += [ThemeInput]::New($Null," ")
                }
            }
        }
    }

    Class ThemeOutput     # Collects everything for output
    {
        [Object] $Type
        [Object] $Template
        [Object] $Object
        [Object] $Header
        [Object] $Body
        [Object] $Footer
        [Object] $Output
        ThemeOutput([Object]$InputObject)
        {
            $This.Object = [ThemeObject]$InputObject
            $This.Header = "Section"
            $This.Footer = "Press enter to continue"
            $This.GetTemplate()
        }
        ThemeOutput([Object]$InputObject,[String]$Header)
        {
            $This.Object = [ThemeObject]$InputObject
            $This.Header = $Header
            $This.Footer = "Press enter to continue"
            $This.GetTemplate()
        }
        ThemeOutput([Object]$InputObject,[String]$Header,[String]$Footer)
        {
            $This.Object = [ThemeObject]$InputObject
            $This.Header = $Header
            $This.Footer = $Footer
            $This.GetTemplate()
        }
        GetTemplate()
        {
            If ($This.Object.Type -eq "String")
            {
                $This.Header = $This.Object.Output

                If ($This.Object.Output -notmatch "^\w+\s\[(\+|\~|\-)\]")
                {
                    $This.Type   = 0
                }
                Else
                {
                    $This.Type = 1
                }
            }
            Else
            {
                $This.Type = 2
            }
            $This.Template = [ThemeTemplate]::New($This.Type)
            
            If ($This.Type -eq 2)
            {
                $This.Body = $This.Object.Output
            }

            $This.Output = @( )
            $This.Build()
        }
        [Hashtable] Divide([String]$String)
        {
            $String           = " $String "
            If ($String.Length % 4 -ne 0)
            {
                $SuffixLength = 4 - ($String.Length % 4) 
                $Suffix       = " " * $SuffixLength
                $String       = "$String{0}" -f $Suffix
            }
            $CharArray        = $String.ToCharArray()
            $Count            = $String.Length / 4
            $Insert           = @{ }

            If ($Count -gt 1)
            {
                ForEach ( $X in 0..($Count-1))
                {
                    $S                           = $X * 4
                    $Insert.Add($X,($CharArray[$S..($S+3)] -join ''))
                }
            }
            If ($Count -eq 1)
            {
                $Insert.Add(0,$CharArray -join '')
            }

            Return $Insert
        }
        InsertLine([Object]$Track,[String]$Subject)
        {
            $Insert = $This.Divide($Subject)

            If ($Insert.Count -eq 1)
            {
                If ($This.Type -in 0,2)
                {
                    $Track.Mask[3].Object                 = $Insert[0]
                    $Track.Mask[4].Object                 = "]___"
                    $Track.Mask[4].ForegroundColor        = 1
                    ForEach ($X in 5..25 )
                    {
                        $Track.Mask[$X].Object            = "____"
                        $Track.Mask[$X].ForegroundColor   = 1
                    }
                    $Track.Mask[26].Object                = "___/"
                }
                If ($This.Type -in 1)
                {
                    $Track.Mask[3].Object                 = $Insert[0]
                }
            }
            If ($Insert.Count -gt 1)
            {
                If ($This.Type -in 0,2)
                {
                    ForEach ($X in 0..($Insert.Count-1))
                    {
                        $Track.Mask[3+$X].Object     = $Insert[$X]
                    }

                    If ($X -le 21)
                    {
                        $X ++
                        $Track.Mask[3+$X].Object              = "]___"
                        $Track.Mask[3+$X].ForegroundColor     = 1
                        Do
                        {
                            $X ++
                            $Track.Mask[3+$X].Object          = "____"
                            $Track.Mask[3+$X].ForegroundColor = 1
                        }
                        Until ($X -eq 23)

                        $Track.Mask[3+$X].Object              = "___/"
                    }
                }
                If ($This.Type -in 1)
                {
                    ForEach ($X in 0..($Insert.Count-1))
                    {
                        $Track.Mask[3+$X].Object     = $Insert[$X]
                    }
                }
            }
        }
        [Object[]] InsertBody([Object[]]$String)
        {
            $Swap = @( )
            ForEach ($I in 0..($String.Count - 1))
            {
                $Track    = [ThemeTrack]::New($I)
                $Mode     = $I % 2
                Switch ($Mode)
                {
                    0
                    {
                        $Track.Mask[ 0].Object = "   \" 
                        $Track.Mask[ 1].Object = "\   "
                        $Track.Mask[28].Object = "   \"
                        $Track.Mask[29].Object = "\   "
                    }
                    1
                    {
                        $Track.Mask[ 0].Object = "   /"
                        $Track.Mask[ 1].Object = "/   "
                        $Track.Mask[28].Object = "   /"
                        $Track.Mask[29].Object = "/   "
                    }
                }

                $Insert   = $This.Divide($String[$I])
                If ($Insert.Count -eq 1)
                {
                    $Track.Mask[3].Object                 = $Insert[0]
                    $Track.Mask[3].ForegroundColor        = 2
                }
                If ( $Insert.Count -gt 1)
                {
                    ForEach ($I in 0..($Insert.Count-1))
                    {
                        $Track.Mask[3+$I].Object          = $Insert[$I]
                        $Track.Mask[3+$I].ForegroundColor = 2
                    }
                }
                $Swap += $Track
            }

            Switch($Swap.Count % 2)
            {
                0
                {
                    $Swap[-1].Mask[28].Object = "___/"
                }
                1
                {
                    $Track = [ThemeTrack]::New($Swap.Count+1)
                    $Track.Mask[ 0].Object = "   /"
                    $Track.Mask[ 1].Object = "/   "
                    $Track.Mask[28].Object = "___/"
                    $Track.Mask[29].Object = "/   "
                    $Swap += $Track
                }
            }

            Return $Swap
        }
        Build()
        {
            ForEach ($X in 0..($This.Template.Track.Count-1))
            {
                If ($X -eq $This.Template.Header)
                {
                    $This.InsertLine($This.Template.Track[$X],$This.Header)
                    $This.Output += $This.Template.Track[$X]
                }

                If ($X -eq $This.Template.Footer)
                {
                    $This.InsertLine($This.Template.Track[$X],$This.Footer)
                    $This.Output += $This.Template.Track[$X]
                }

                If ($X -eq $This.Template.Body)
                {
                    $Swap = $This.InsertBody($This.Body)
                    ForEach ( $Track in $Swap )
                    {
                        $This.Output += $Track
                    }
                }

                If ($X -notin $This.Template.Header,$This.Template.Body,$This.Template.Footer)
                {
                    $This.Output += $This.Template.Track[$X]
                }
            }

            ForEach ( $X in 0..($This.Output.Count-1))
            {
                $This.Output[$X].Index = $X
            }
        }
        [String[]] Text()
        {
            Return @( 0..($This.Output.Count-1) | % { "#$($This.Output[$_].Mask.Object -join '')" } )
        }
    }

    Class Banner
    {
        Hidden [String[]] $Faces   = [ThemeFace]::New().Output
        Hidden [String[]] $String_ = (( "0;1;@(0)*25;1;1;0 4;9;12;@(1)*23;13;9;8;7 6;8;10;@(2)*23;11;8;9;5 4;9;12;14;@(1)*21;15;13;9;8;7 " + 
                                        "6;8;10;@(2)*24;0;11;5 4;10;@(0)*26;4;7 6;5;0;0;@(1)*22;0;0;6;5 4;7;0;13;@(9;8)*5;10;11;@(8;9)*5;" + 
                                        "12;0;4;7 6;5;4;9;8;9;8;10;@(2)*14;11;8;9;8;9;5;6;5 4;7;6;8;9;8;10;@(0)*16;11;8;9;8;7;4;7 6;5;4;9" + 
                                        ";8;10;@(0)*18;11;8;9;5;6;5 4;7;6;8;9;5;@(0)*18;4;9;8;7;4;7 6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5 4;7;6" + 
                                        ";8;9;5;@(0)*18;4;9;8;7;4;7 6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5 4;7;6;8;9;12;@(0)*18;13;9;8;7;4;7 6;5" + 
                                        ";4;9;8;9;12;@(0)*16;13;9;8;9;5;6;5 4;7;6;8;9;8;9;12;@(1)*14;13;9;8;9;8;7;4;7 6;5;0;11;@(8;9)*5;1" + 
                                        "2;13;@(9;8)*5;10;0;6;5 4;7;0;0;@(2)*22;0;0;13;7 6;12;@(0)*25;13;9;5 4;9;12;@(1)*23;13;9;8;7 6;8;" +
                                        "10;@(2)*23;11;8;10;0 0;11;12;14;@(1)*21;15;13;10;0;0 0;0;@(2)*25;0;0;0" ) -Split " " | % { "@($_)" })
        Hidden [String[]] $Fore_   = ((("{0} 10;12;@(10)*25;12;12;10 10;@(12)*28;10 10;12;12;@(15)*23;12;10;12;10 10;12;@(10)*28 {0} {0} " +
                                        "@(10)*4;@(12)*22;@(10)*4 @(10)*3;@(12)*4;@(10)*16;@(12)*4;@(10)*3 {1} {2} {2} {2} {2} {2} {2} {1" +
                                        "} @(10)*3;@(12)*4;@(10)*16;@(12)*4;@(10)*3 @(10)*4;@(12)*22;@(10)*4 {0} @(10)*28;12;10 10;12;@(10" +
                                        ")*25;12;12;10 10;@(12)*27;10;10 10;10;12;@(15)*23;12;10;10;10 {0}") -f "@(10)*30", ("@(10)*3;@(1" + 
                                        "2)*3;10;@(15)*16;10;@(12)*3;@(10)*3"), "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3").Split(" ") | % { 
                                        "@($_)" })
        Hidden [String[]] $Back_   = @("@(0)*30") * 25
        [Object] $Track
        Banner()
        {
            $This.Track            = @( )

            ForEach ( $I in 0..24 )
            {
                $This.Track += [ThemeTrack]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
                $This.Track[$I].Mask[-1].NoNewLine = 0
            }

            ForEach ( $I in 0..7 )
            {
                $This.Track[ 9].Mask[11+$I].Object = "   S;ecur;e Di;gits; Plu;s LL;C ($([char]960);)   ".Split(";")[$I]
                $This.Track[10].Mask[11+$I].Object = "   -;----;----;----;----;----;----;-   ".Split(";")[$I]
                $This.Track[15].Mask[11+$I].Object = "Netw;ork ;& Ha;rdwa;re M;agis;trat;ion ".Split(";")[$I]
                $This.Track[16].Mask[11+$I].Object = "----;----;----;----;----;----;----;--- ".Split(";")[$I]
            }

            ForEach ( $I in 0..9 )
            {
                $This.Track[11].Mask[10+$I].Object = "Dyna;mica;lly ;Engi;neer;ed D;igit;al S;ecur;ity ".Split(";")[$I]
                $This.Track[12].Mask[10+$I].Object = "----;----;----;----;----;----;----;----;----;--- ".Split(";")[$I]
                $This.Track[13].Mask[10+$I].Object = "Appl;icat;ion ;Deve;lopm;ent ;- Vi;rtua;liza;tion".Split(";")[$I]
                $This.Track[14].Mask[10+$I].Object = "----;----;----;----;----;----;----;----;----;----".Split(";")[$I]
            }
        }
        Draw()
        {
            ForEach ( $I in 0..( $This.Track.Count - 1 ) )
            { 
                ForEach ( $X in 0..( $This.Track[$I].Mask.Count - 1 ) )
                {
                    $Item               = $This.Track[$I].Mask[$X]

                    @{  Object          = $Item.Object 
                        ForegroundColor = $Item.ForegroundColor 
                        BackgroundColor = $Item.BackgroundColor
                        NoNewLine       = $Item.NoNewLine
        
                    }                   | % { Write-Host @_ }
                }
            }
        }
    }

    Class Flag
    {
        Hidden [String[]] $Faces   = [ThemeFace]::New().Output
        Hidden [String[]] $String_ = (( "0;1;@(0)*25;1;1;0 4;9;12;@(1)*23;13;9;8;7 6;8;10;@(2)*23;11;8;9;5 4;9;12;14;@(1)*21;15;13;9;8;7 " +
                                        "6;8;10;@(2)*24;0;11;5 4;10;@(0)*26;4;7 6,5,0,0;@(1)*22;0,0,6,5 4,7,0,4,10;@(2)*8;22,23;@(2)*10;1" + 
                                        "1,5,0,4,7 6,5,0,6,5,16,17,0,16,17,0,16,17,24,25;@(1)*10;13,7,0,6,5 4,7,0,4,7,18,0,19,18,0,19,18," + 
                                        "0,24,23;@(2)*10;11,5,0,4,7 6,5,0,6,5;@(0)*8;24,25;@(1)*10;13,7,0,6,5 4,7,0,4,7,16,17,0,16,17,0,1" +
                                        "6,17,24,23;@(2)*10;11,5,0,4,7 6,5,0,6,5,18,0,19,18,0,19,18,0,24,25;@(1)*10;13,7,0,6,5 4,7,0,4,7;" + 
                                        "@(0)*8;24,23;@(2)*10;11,5,0,4,7 6,5,0,6,5,16,17,0,16,17,0,16,17,24,25;@(1)*10;13,7,0,6,5 4,7,0,4" +
                                        ",7,18,0,19,18,0,19,18,0,24,23;@(2)*10;11,5,0,4,7 6,5,0,6,5;@(0)*8;24,25;@(1)*10;13,7,0,6,5 4,7,0" + 
                                        ",4,7,16,17,0,16,17,0,16,17,24,23;@(2)*10;11,5,0,4,7 6,5,0,6,5,18,0,19,18,0,19,18,0,24,25;@(1)*10" + 
                                        ";13,7,0,6,5 4,7,0,4,7,16,17,0,16,17,0,16,17,24,23;@(2)*10;11,5,0,4,7 6,5,0,6,12;@(1)*8;26,25;@(1" + 
                                        ")*10;13,7,0,6,5 4,7,0,4,10;;@(2)*20;;11,5,0,4,7 6,5,0,6,12;@(1)*7;20,8,20,20,8,20;@(1)*7;13,7,0," + 
                                        "6,5 4,7,0,4,10;@(2)*7;20;@(2)*4;20;@(2)*7;11,5,0,4,7 6,5,0,6,12;@(1)*7;20,0,0,0,0,20;@(1)*7;13,7" + 
                                        ",0,6,5 4,7,0,4,10;@(2)*7;20,0,0,0,0,20;@(2)*7;11,5,0,4,7 6,5,0,6,12,1,1,1,21,20,8,20,20,0,0,0,0," + 
                                        "20,20,8,20,21,1,1,1,13,7,0,6,5 4,7,0,4,10,2,2,2,21,2,2,2,2,0,0,0,0,2,2,2,2,21,2,2,2,11,5,0,4,7 6" + 
                                        ",5,0,6,12,1,1,1,21;@(1)*12;21,1,1,1,13,7,0,6,5 4,7,0,4,10,2,2,2,21;@(2)*12;21,2,2,2,11,5,0,4,7 6" + 
                                        ",5,0,6,12,1,1,20,21,20,8,20,20,8,20,20,8,20,20,8,20,21,20,1,1,13,7,0,6,5 4,7,0,4,10,2,2,20;@(2)*" + 
                                        "14;20,2,2,11,5,0,4,7 6,5,0,6,12,1,1,20;@(1)*14;20,1,1,13,7,0,6,5 4,7,0,0;@(2)*22;0,0,13,7 6;12;@" + 
                                        "(0)*25;13;9;5 4;9;12;@(1)*23;13;9;8;7 6;8;10;@(2)*23;11;8;10;0 0;11;12;14;@(1)*21;15;13;10;0;0 0" + 
                                        ";0;@(2)*25;0;0;0" ) -Split " " | % { "@($_)" })
        Hidden [String[]] $Fore_   = ((("{0} 10;12;@(10)*25;12;12;10 10;@(12)*28;10 10;12;12;@(15)*23;12;10;12;10 10;12;@(10)*28 {0} {1}" +
                                        " {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {1} {2} {2} {2} {2} {3} {3} {3} {3} {4" + 
                                        "} {4} {4} @(10)*3;@(15)*24;@(10)*3 @(10)*28;12;10 10;12;@(10)*25;12;12;10 10;@(12)*27;10;10 10;" + 
                                        "10;12;@(15)*23;12;10;10;10 {0}") -f "@(10)*30","@(10)*3;@(15)*24;@(10)*3",("@(10)*3;@(15)*9;@(1" + 
                                        "0)*6;@(15)*9;@(10)*3"),"@(10)*3;@(15)*5;@(10)*14;@(15)*5;@(10)*3",("@(10)*3;@(15)*4;@(10)*16;@(" + 
                                        "15)*4;@(10)*3")) -Split " " | % { "@($_)" })
        Hidden [String[]] $Back_   = ((("{0} {0} {0} {0} {0} {0} {0} {1} {1} {2} {2} {1} {1} {2} {2} {1} {1} {2} {2} {1} {1} @(0)*4;@(15" + 
                                        ")*22;@(0)*4 {3} @(0)*4;@(12)*8;@(0)*6;@(12)*8;@(0)*4 @(0)*4;@(12)*8;@(0)*6;@(12)*8;@(0)*4 {3} @(" + 
                                        "0)*4;@(15)*4;@(0)*14;@(15)*4;@(0)*4 @(0)*4;@(12)*4;@(0)*14;@(12)*4;@(0)*4 @(0)*4;@(12)*4;@(0)*14" + 
                                        ";@(12)*4;@(0)*4 @(0)*4;@(15)*4;@(0)*14;@(15)*4;@(0)*4 @(0)*4;@(15)*3;@(0)*16;@(15)*3;@(0)*4 @(0)" + 
                                        "*4;@(12)*3;@(0)*16;@(12)*3;@(0)*4 @(0)*4;@(12)*3;@(0)*16;@(12)*3;@(0)*4 {0} {0} {0} {0} {0} {0}") -f 
                                        "@(0)*30","@(0)*4;@(9)*10;@(12)*12;@(0)*4","@(0)*4;@(9)*10;@(15)*12;@(0)*4",("@(0)*4;@(15)*8;@(0)" + 
                                        "*6;@(15)*8;@(0)*4")) -Split " " | % { "@($_)" })
        Hidden [String[]] $Date_    = (Get-Date -UFormat "_[ %m/%d/%Y ]_").ToCharArray()
        Hidden [String[]] $Date
        [Object] $Track
        Flag()
        {
            $This.Track            = @( )
            $This.Date             = @( ForEach ( $I in 0..( $This.Date_.count - 1 ) )
            {
                $This.Date_[$I]
                If ( $I % 4 -eq 3 ) 
                {
                    ";"
                }
            }) -join ''

            ForEach ( $I in 0..38 )
            {
                $This.Track += [ThemeTrack]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
                $This.Track[$I].Mask[-1].NoNewLine = 0
            }

            ForEach ( $I in 0..11 )
            {
                $This.Track[10].Mask[14+$I].Object = "[__[; Dyn;amic;ally; Eng;inee;red ;Digi;tal ;Secu;rity; ]_/".Split(";")[$I]
                $This.Track[10].Mask[14+$I].ForegroundColor = 0
                $This.Track[14].Mask[14+$I].Object = "[_[ ;Appl;icat;ion ;Deve;lopm;ent ;- Vi;rtua;liza;tion; ]_/".Split(";")[$I]
                $This.Track[14].Mask[14+$I].ForegroundColor = 0
                $This.Track[18].Mask[14+$I].Object = "[___;__[ ;Netw;ork ;& Ha;rdwa;re M;agis;trat;ion ;]___;___/".Split(";")[$I]
                $This.Track[18].Mask[14+$I].ForegroundColor = 0
            }

            ForEach ( $I in 0..3 )
            {
                $This.Track[24].Mask[13+$I].Object = "----;----;----;----".Split(";")[$I]
                $This.Track[25].Mask[13+$I].Object = "  Fi;ghti;ng (;$([char]960))  ".Split(";")[$I]
                $This.Track[26].Mask[13+$I].Object = "    ; Ent;ropy;    ".Split(";")[$I]
                $This.Track[27].Mask[13+$I].Object = "----;----;----;----".Split(";")[$I]
                $This.Track[32].Mask[13+$I].Object = $This.Date.Split(";")[$I]
            }

            ForEach ( $I in 0..7 )
            {
                $This.Track[28].Mask[11+$I].Object = "___[; Sec;ure ;Digi;ts P;lus ;LLC ;]___".Split(";")[$I]
            }
        }
        Draw()
        {
            ForEach ( $I in 0..( $This.Track.Count - 1 ) )
            { 
                ForEach ( $X in 0..( $This.Track[$I].Mask.Count - 1 ) )
                {
                    $Item               = $This.Track[$I].Mask[$X]

                    @{  Object          = $Item.Object 
                        ForegroundColor = $Item.ForegroundColor 
                        BackgroundColor = $Item.BackgroundColor
                        NoNewLine       = $Item.NoNewLine
        
                    }                   | % { Write-Host @_ }
                }
            }
        }
    }

    Switch($PSCmdlet.ParameterSetName)
    {
        0
        {
            If ($Title -and $Prompt)
            {
                $Theme = [ThemeOutput]::New($InputObject,$Title,$Prompt)
            }
            ElseIf ($Title)
            {
                $Theme = [ThemeOutput]::New($InputObject,$Title)
            }
            Else
            {
                $Theme = [ThemeOutput]::New($InputObject)
            }
        
            If ($Text)
            {
                $Theme.Text()
            }
            If (!$Text)
            {
                $Theme.Output.Draw(@($Palette))
            }
        }

        1
        {
            [Banner]::New().Draw()
        }

        2
        {
            [Flag]::New().Draw()
        }
    }
}
