Function Write-Theme # Cross Platform
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=0,Mandatory,Position=0)]
        [Object]$InputObject,
        [Parameter(ParameterSetName=1,Mandatory,Position=0)]
        [Switch]$Banner,
        [Parameter(ParameterSetName=2,Mandatory,Position=0)]
        [Switch]$Flag,
        [Parameter(Position=1)]
        [UInt32[]]$Palette = @(10,12,15,0),
        [Parameter()][Switch]$Text
    )

    Class Block
    {
        [String]              $Name
        [Int32]              $Index
        [Object]            $Object
        [Int32]    $ForegroundColor
        [Int32]    $BackgroundColor
        [Int32]          $NoNewLine = 1
        Block([Int32]$Index,[String]$Object,[Int32]$ForegroundColor,[Int32]$BackgroundColor)
        {
            $This.Name              = $Index
            $This.Index             = $Index
            $This.Object            = $Object
            $This.ForegroundColor   = $ForegroundColor
            $This.BackgroundColor   = $BackgroundColor
        }
    }

    Class Face
    {
        Static [Object]    $Mask = @{  0 =  32, 32, 32, 32;  1 =  95, 95, 95, 95;  2 = 175,175,175,175;  3 =  45, 45, 45, 45;
                                       4 =  32, 32, 32, 47;  5 =  92, 32, 32, 32;  6 =  32, 32, 32, 92;  7 =  47, 32, 32, 32;
                                       8 =  92, 95, 95, 47;  9 =  47,175,175, 92; 10 =  47,175,175,175; 11 = 175,175,175, 92; 
                                      12 =  92, 95, 95, 95; 13 =  95, 95, 95, 47; 14 =  91, 32, 95, 95; 15 =  95, 95, 32, 93; 
                                      16 =  42, 32, 32, 32; 17 =  32, 32, 42, 32; 18 =  32, 32, 32, 42; 19 =  32, 42, 32, 32; 
                                      20 =  91, 61, 61, 93; 21 =  91, 45, 45, 93; 22 = 175,175,175, 93; 23 =  91,175,175,175;
                                      24 =  32, 32, 32, 93; 25 =  91, 95, 95, 95; 26 =  95, 95, 95, 93 }
        [Object]           $Faces
        Face()
        {
            $This.Faces = @( ) 
            
            ForEach ( $X in 0..([Face]::Mask.Count - 1 ))
            {
                $This.Faces += ([Char[]][Face]::Mask[$X] -join '')
            }
        }
    }

    Class Track
    {
        Hidden [String[]]      $Faces = [Face]::New().Faces
        Hidden [String]         $Name
        [Int32]                $Index
        Hidden [String[]]     $Object
        Hidden [Int32[]]  $Foreground
        Hidden [Int32[]]  $Background
        [Object]                $Mask
        GetMask()
        {
            $This.Mask                 = @( )
            ForEach ( $I in 0..( $This.Object.Count - 1 ) )
            {
                $This.Mask            += [Block]::New($This.Index,$This.Object[$I],$This.Foreground[$I],$This.Background[$I])
            }
        }
        Track([Int32]$Index)
        {
            $This.Index                = $Index
            $This.Name                 = $Index
            $This.Object               = $This.Faces[@(0)*30]
            $This.Foreground           = @(0)*30
            $This.Background           = @(0)*30
            $This.GetMask()
        }
        Track([Int32]$Index,[String]$Mask,[String]$Foreground,[String]$Background)
        {
            $This.Index                = $Index
            $This.Name                 = $Index
            $This.Object               = $This.Faces[(Invoke-Expression $Mask)]
            $This.Foreground           = Invoke-Expression $Foreground
            $This.Background           = Invoke-Expression $Background
            $This.GetMask()
        }
        LoadBody([UInt32]$Even,[String]$Load)
        {
            If ( $Load.Length -eq 0 )
            {
                $Load = (@(" ") * 88 -join '' )
            }

            $Width                     = $This.Mask.Count - 6
            $Offset                    = 4-($Load.Length % 4)
            $Land                      = ($Load.Length + $Offset)/4
            $Load                      = "{0}{1}" -f $Load, (" " * $Offset)
            $Line                      = 0..( $Load.Length - 1 ) | ? { $_ % 4 -eq 0 } | % { $Load.Substring($_,4) }
            $Land..($Width-1)          | % { $Line += "    " }

            ForEach ( $X in 0..( $Line.Count - 1 ) )
            {
                $This.Mask[3+$X].Object          = $Line[$X]
                $This.Mask[3+$X].ForegroundColor = 2
            }

            $This.Mask[0].Object  = @("   \","   /")[$Even % 2]
            $This.Mask[1].Object  = @("\   ","/   ")[$Even % 2]
            $This.Mask[-2].Object = @("   \","   /")[$Even % 2]
            $This.Mask[-1].Object = @("\   ","/   ")[$Even % 2]
        }
        LoadLine([String]$Load)
        {
            If ( $Load.Length -eq 0 )
            {
                $Load = "Section"
            }

            $Load                      = " $Load"
            $Width                     = $This.Mask.Count - 6
            $Offset                    = 4-($Load.Length % 4)
            $Land                      = ($Load.Length + $Offset)/4
            $Load                      = "{0}{1}" -f $Load, (" " * $Offset)
            $Line                      = 0..( $Load.Length - 1 ) | ? { $_ % 4 -eq 0 } | % { $Load.Substring($_,4) }

            ForEach ( $X in 0..( $Line.Count - 1 ) )
            {
                $This.Mask[3+$X].Object          = $Line[$X]
                $This.Mask[3+$X].ForegroundColor = 2
            }

            $This.Mask[3+$Line.Count].Object           = "]___"
            $This.Mask[3+$Line.Count].ForegroundColor  = 1

            ForEach ( $X in ($Land+1)..($Width-1))
            {     
                $This.Mask[3+$X].Object                = "____" 
                $This.Mask[3+$X].ForegroundColor       = 1
            }
        }
        Draw([Object]$Palette)
        {
            ForEach ( $X in 0..($This.Mask.Count - 1))
            {
                $Item = $This.Mask[$X]

                If ($X -ne ($This.Mask.Count - 1))
                {
                    Write-Host $Item.Object -F @($Palette)[$Item.ForegroundColor] -B $Item.BackgroundColor -N
                }

                Else 
                {
                    Write-Host $Item.Object -F @($Palette)[$Item.ForegroundColor] -B $Item.BackgroundColor
                }
            }
        }
    }

    Class ThemeObject
    {
        [String] $Type
        [String] $Height
        [Object] $Stack
        ThemeObject([Object]$IP)
        {
            $This.Type  = $IP.GetType()
            $This.Stack = @( )

            Switch -Regex ($This.Type)
            {
                "(\[\])" 
                {
                    $This.Height = $IP.Count
                    $Z = $Null
                    ForEach ( $X in 0..($IP.Count - 1) )
                    {
                        If ( $IP[$X].ToString().Length -eq 0 )
                        {
                            $Z = (@(" ")*88 -join '')
                            $This.Stack += $Z
                        }

                        ElseIf ($IP[$X].ToString().Length -in 1..88 )
                        {
                            $Z = ("{0}{1}" -f $IP[$X],(@(" ")*(88-$IP[$X].ToString().Length) -join ''))
                            $This.Stack += $Z
                        }

                        Else
                        {
                            $Total    = $IP[$X].ToString().Length 
                            $Rem      = $Total % 88
                            $Ct       = ($Total - $Rem)/88
                            $X        = -1
                            $Temp     = @{ }

                            ForEach ( $I in 0..$Total )
                            {     
                                Switch([UInt32]($I % 88 -eq 0))
                                {
                                    0
                                    {
                                        $Temp[$X] += $Total[$I]
                                    }

                                    1
                                    {
                                        $X ++
                                        $Temp.Add($X,"")
                                        $Temp[$X] += $Total[$I]
                                    }
                                }
                            }
                        }
                    }
                }

                Hashtable
                {
                    $Z               = $Null
                    $This.Height     = $IP.Keys.Count + 1
                    $Width           = $IP.Keys | Sort-Object Length | Select-Object -Last 1 | % { $_.Length }
                    $IP.GetEnumerator() | % { 
                        
                        $Z           = ("{0}{1}: {2}" -f (@(" ")*($Width-$_.Name.Length) -join ''),$_.Name, $_.Value)
                        $This.Stack += $Z
                    }

                    $Z               = (@(" ")*88 -join '')
                    $This.Stack     += $Z
                }

                Default
                {
                    $Z              = $Null
                    $This.Height    = 1
                    If ( $IP.ToString().Length -eq 0 )
                    {
                        $Z          = (@(" ")*88 -join '')
                    }

                    ElseIf ($IP.ToString().Length -in 1,2,3)
                    {
                        $Z          = ("{0}{1}" -f $IP.ToString(),(@(" ")*(4-$IP.ToString().Length) -join ''))
                    }
                    Else
                    {
                        $Z          = $IP.ToString()
                    }

                    $This.Stack    += $Z
                }
            }

            $This.Justify()
        }
        [String] ToString()
        {
            Return $This.Type
        }
        Justify()
        {
            $Temp = @( )

            ForEach ( $Line in $This.Stack )
            {
                If ( $Line.Length -gt 88 )
                {
                    $L         = $Line.Length
                    $R         = $L % 88
                    $C         = ($L-$R) / 88
                    
                    ForEach ( $I in 0..$C )
                    {
                        $X     = 88 * $I
                        $Y     = @( $X + ( 88 - 1 ); $X + ( $R - 1 ) )[$I -eq $C]
                        $Z     = $Null

                        If ( $I -ne $C )
                        {
                            $Z = $Line[@($X..$Y)] -join ''
                        }

                        Else
                        {
                            $String = $Line.Substring($X)
                            $Z = ("{0}{1}" -f $String,(@(" ")*(88-$String.Length) -join ''))
                        }

                        $Temp += $Z
                    }
                }

                Else
                {
                    $Temp += $Line
                }
            }

            $This.Height = $Temp.Count
            $This.Stack  = @( )

            ForEach ($Line in $Temp)
            {
                $This.Stack += $Line
            }
        }
    }
    
    Class Theme
    {
        [ValidateSet(0,1,2)]
        Hidden [Int32]      $Mode
        [String]            $Name 
        [Int32[]]           $Span
        [Int32]           $Header
        [Int32]             $Body
        [Int32]           $Footer
        [Int32[]]         $Colors = @(10,12,15,0)
        Hidden [String[]]  $Faces = [Face]::New().Faces
        Hidden [String[]] $String
        Hidden [String[]]$String_ =(("0;1;@(0)*25;1;1;0 4;9;12;@(1)*23;13;9;8;7 6;8;10;@(2)*23;11;8;10;0 0;11;12;14;@(1)*21;15;13" + 
                                     ";10;0;0 0;0;@(2)*25;0;0;0 0;1;0;@(1)*25;0;0 4;9;8;10;@(2)*23;11;12;0 6;8;10;14;@(1)*21;15;0" +
                                     ";13;9;5 0;11;12;@(1)*23;13;9;8;7 0;0;@(2)*25;0;2;0 6;8;10;@(2)*23;11;8;9;5 4;9;12;14;@(1)*2" + 
                                     "1;15;13;9;8;7 6;8;10;@(2)*24;0;11;5 4;10;@(0)*26;4;7 6;5;@(0)*26;6;5 6;12;@(0)*25;13;9;5 4;" +
                                     "9;12;@(1)*23;13;10;13;7").Split(" ") | % { "@($_)" })
        Hidden [String[]]$Fore
        Hidden [String[]]$Fore_ = (( "@(0)*30 0;1;@(0)*25;1;1;0 0;1;@(1)*25;1;0;0 0;0;1;@(2)*23;1;0;0;0 @(0)*30 @(0)*30 0;1;0;@(1)" +
                                    "*25;0;0 0;1;1;@(2)*23;1;1;1;0 0;0;@(1)*25;0;1;0 @(0)*30 0;@(1)*28;0 0;1;1;@(2)*23;1;0;1;0 0;" +
                                    "1;@(0)*26;0;0 @(0)*30 @(0)*30 @(0)*28;1;0 0;1;@(0)*25;1;1;0").Split(" ") | % { "@($_)" })
        Hidden [String[]]$Back
        Hidden [String[]]$Back_ = (0..16 | % { "@({0})" -f ( @(0)*30 -join ',' ) })
        [Object[]]       $Track
        Theme([Int32]$Slot)
        {
            $This.Name   = "Function Action Section Table Test".Split(" ")[$Slot]
            $This.Span   = @{ 0 = 0..4; 1 = 5..9; 2 = @( 0..1+10..16+2..4 ); 3 = $Null; 4 = $Null }[$Slot]
            $This.Header = @(3;2;3;3;3)[$Slot]
            $This.Body   = @(-1;-1;6;-1;-1)[$Slot]
            $This.Footer = @(-1,-1,10,-1,-1)[$Slot]
                    
            $This.String = $This.Span | % { $This.String_[$_] }
            $This.Fore   = $This.Span | % { $This.Fore_[$_] }
            $This.Back   = $This.Span | % { $This.Back_[$_] }
    
            $This.Track   = @( ForEach ( $I in 0..( $This.String.Count - 1 ) )
            {
                [Track]::New($I,$This.String[$I],$This.Fore[$I],$This.Back[$I])
            })
        }
    }

    Class Stack
    {
        [Object] $Item
        [Object] $Stand
        [Object] $Type
        [Object] $Theme
        [Object] $Stack
        [Object] $Track
        Stack([Object]$Object)
        {
            $This.Item  = $Object
            $This.Stand = @( )

            Switch ($Object.Count)
            {
                Default
                {
                    ForEach ( $X in 0..($Object.Count - 1 ) )
                    {
                        $This.Stand += [ThemeObject]::New($Object[$X])
                    }
                }

                1
                {
                    $This.Stand = [ThemeObject]::New($Object)
                }
            }

            $This.Type  = @("Line","Block")[$This.Stand.Count -gt 1]
            $This.Stack = @( )

            If ( $This.Stand.Stack.Count -gt 1 )
            {
                $This.Theme = [Theme]::New(2)

                ForEach ( $X in 0..($This.Stand.Stack.Count - 1))
                {
                    $This.Stack += $This.Stand.Stack[$X]
                }
            }

            Else
            {
                $Slot = Switch -Regex ($Object)
                {
                    Default { 0 } "(\[\W\])" { 1 }
                }

                $This.Theme = [Theme]::New($Slot)
                $This.Stack = $Object
            }

            $This.Build()
            $This.Clean()
        }
        Build()
        {
            $This.Track = @{ }
            $C          = 0
            $I          = $Null

            ForEach ( $X in 0..($This.Theme.Track.Count - 1 ) )
            {
                $Track_ = $This.Theme.Track[$X]
                Switch($X)
                {
                    Default
                    {
                        $Track_.Index = $C
                        $This.Track.Add($C,$Track_)
                        $C ++
                    }

                    $This.Theme.Header
                    {
                        $Track_.Index = $C
                        $I = @("Section",$This.Stack)[$This.Type -eq "Line"]
                        $Track_.LoadLine($I)
                        $This.Track.Add($C,$Track_)
                        $C ++
                    }

                    $This.Theme.Body
                    {
                        $T = $Null
                        ForEach ( $I in 0..($This.Stack.Count - 1 ))
                        {
                            $T            = @(6,7)[$I % 2]
                            $Track_       = [Track]::New($T)
                            $Track_.LoadBody($T,$This.Stack[$I])
                            $Track_.Index = $C
                            $This.Track.Add($C,$Track_)
                            $C ++
                        }

                        If ($This.Stack.Count % 2 -eq 1 )
                        {
                            $Track_       = [Track]::New(6)
                            $Track_.LoadBody(7,"    ")
                            $Track_.Index = $C
                            $This.Track.Add($C,$Track_)
                            $C ++
                        }
                    }

                    $This.Theme.Footer
                    {
                        $Track_.LoadLine("Press enter to continue")
                        $Track_.Index     = $C
                        $This.Track.Add($C,$Track_)
                        $C ++
                    }
                }
            }
        }
        Clean()
        {
            Switch($This.Theme.Name)
            {
                Function
                {
                    $This.Track[3].Mask[     2].Object = "\__["
                    $This.Track[3].Mask[    26].Object = "___/"
                }
    
                Action
                {
                    $This.Track[2].Mask[     2].Object = ([Char[]]@(47,175,175,175) -join '')
                    ForEach ( $Mask in $This.Track[2].Mask[ 3..26] )
                    {
                        If ( $Mask.Object -match "(\]_{3}|_{4})" )
                        {
                            $Mask.Object = "    " 
                        }
                    }
                }

                Section
                {
                    $This.Track[ 3].Mask[     2].Object = "\__["
                    $This.Track[ 3].Mask[    26].Object = "___/"

                    $Total = $This.Track.Count
                    $This.Track[$Total-6].Mask[    28].Object = "___/"
                    $This.Track[$Total-2].Mask[     2].Object = "\__["
                    $This.Track[$Total-2].Mask[    26].Object = "___/"
                }
            }
        }
        Draw([Object]$Palette)
        {
            ForEach ( $X in 0..($This.Track.Count - 1 ) )
            {
                $This.Track[$X].Draw($Palette)
            }
        }
        [String[]] Out()
        {
            Return @( ForEach ( $X in 0..($This.Track.Count - 1 ) )
            {
                $This.Track[$X].Mask.Object -join ''
            } )
        }
    }

    Class Banner
                {
                    Hidden [String[]] $Faces   = [Face]::New().Faces
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
                            $This.Track += [Track]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
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
                    Hidden [String[]] $Faces   = [Face]::New().Faces
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
                            $This.Track += [Track]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
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

    $Item = Switch($PSCmdLet.ParameterSetName)
    {
        0 
        {  
            [Stack]::New($InputObject)
        }

        1 
        { 
            $Item = [Banner]::New()
        }
        
        2 
        {   
            [Flag]::New()
        }
    }

    If ($Text)
    {
        $Item.Out() | % { "#$_" }
    }

    Else
    {
        Switch([UInt32]($Item.GetType().Name -in "Flag","Banner"))
        {
            0 { $Item.Draw($Palette) } 1 { $Item.Draw() }
        }
    }
}
