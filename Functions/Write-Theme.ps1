Function Write-Theme # Cross Platform
{
    [CmdLetBinding(DefaultParameterSetName = 0 )]
    Param(
        [Parameter(ParameterSetName = 0, Position = 0, Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Object]       $InputObject ,
        [Parameter(ParameterSetName = 1 )]
        [Switch]            $Banner ,
        [Parameter(ParameterSetName = 2 )]
        [Switch]              $Flag ,
        [Parameter(ParameterSetName = 0, Position = 1 )]
        [Int32[]]          $Palette = @(10,12,15,0)
    )

    Class _Block 
    {
        [String]              $Name
        [Int32]              $Index
        [Object]            $Object
    
        [Int32]    $ForegroundColor
        [Int32]    $BackgroundColor
        [Int32]          $NoNewLine = 1
    
        _Block([Int32]$Index,[String]$Object,[Int32]$ForegroundColor,[Int32]$BackgroundColor)
        {
            $This.Name              = $Index
            $This.Index             = $Index
            $This.Object            = $Object
            $This.ForegroundColor   = $ForegroundColor
            $This.BackgroundColor   = $BackgroundColor
        }
    }

    Class _Faces
    {
        [Object]          $Faces
        [Hashtable]        $Hash = @{
    
             0 =  32, 32, 32, 32
             1 =  95, 95, 95, 95
             2 = 175,175,175,175
             3 =  45, 45, 45, 45
             4 =  32, 32, 32, 47
             5 =  92, 32, 32, 32
             6 =  32, 32, 32, 92
             7 =  47, 32, 32, 32
             8 =  92, 95, 95, 47
             9 =  47,175,175, 92
            10 =  47,175,175,175
            11 = 175,175,175, 92
            12 =  92, 95, 95, 95
            13 =  95, 95, 95, 47
            14 =  91, 32, 95, 95
            15 =  95, 95, 32, 93
            16 =  42, 32, 32, 32
            17 =  32, 32, 42, 32
            18 =  32, 32, 32, 42
            19 =  32, 42, 32, 32
            20 =  91, 61, 61, 93
            21 =  91, 45, 45, 93
            22 = 175,175,175, 93
            23 =  91,175,175,175
            24 =  32, 32, 32, 93
            25 =  91, 95, 95, 95
            26 =  95, 95, 95, 93
        }

        _Faces()
        {
            $This.Faces = @( )

            ForEach ( $I in 0..( $This.Hash.Count - 1 ) )
            {
                $This.Faces += ( [Char[]]$This.Hash[$I] -join '' )
            }
        }
    }

    Class _Track
    {
        Hidden [String[]]      $Faces = [_Faces]::New().Faces
    
        Hidden [String]         $Name
        [Int32]                $Index
        Hidden [String[]]     $Object
    
        Hidden [Int32[]]  $Foreground
        Hidden [Int32[]]  $Background
        [_Block[]]             $Mask
    
        GetMask()
        {
            $This.Mask                 = @( )
            ForEach ( $I in 0..( $This.Object.Count - 1 ) )
            {
                $This.Mask            += [_Block]::New($This.Index,$This.Object[$I],$This.Foreground[$I],$This.Background[$I])
            }
        }
    
        _Track([Int32]$Index)
        {
            $This.Index                = $Index
            $This.Name                 = $Index
            $This.Object               = $This.Faces[@(0)*30]
            $This.Foreground           = @(0)*30
            $This.Background           = @(0)*30
            $This.GetMask()
        }
    
        _Track([Int32]$Index,[String]$Mask,[String]$Foreground,[String]$Background)
        {
            $This.Index                = $Index
            $This.Name                 = $Index
            $This.Object               = $This.Faces[(Invoke-Expression $Mask)]
            $This.Foreground           = Invoke-Expression $Foreground
            $This.Background           = Invoke-Expression $Background
            $This.GetMask()
        }
    
        Load([String]$Load)
        {
            $Width                     = $This.Mask.Count - 6
            $Load                      = " $Load"
            $Offset                    = 4-($Load.Length % 4)
            $Load                      = "{0}{1}" -f $Load, (" " * $Offset)
            $Line                      = 0..( $Load.Length - 1 ) | ? { $_ % 4 -eq 0 } | % { $Load.Substring($_,4) }

            If ( $Line.Count -eq 1 )
            {
                $This.Mask[3].Object                 = $Line
                $This.Mask[3].ForegroundColor        = 2
            }
        
            If ( $Line.Count -eq $Width )
            {
                ForEach ( $X in 0..( $Line.Count - 1 ) )
                {
                    $This.Mask[3+$X].Object          = $Line[$X]
                    $This.Mask[3+$X].ForegroundColor = 2
                }
            }

            Else
            {
                ForEach ( $X in 0..( $Line.Count - 1 ) )
                {
                    $This.Mask[3+$X].Object               = $Line[$X]
                    $This.Mask[3+$X].ForegroundColor      = 2
                }

                $This.Mask[3+$Line.Count].Object          = "]___"
                $This.Mask[3+$Line.Count].Foregroundcolor = 1

                ForEach ( $X in ( $Line.Count + 1 )..( $Width - 1 ) )
                {
                    $This.Mask[3+$X].Object               = "____"
                    $This.Mask[3+$X].ForegroundColor      = 1
                }
            }
        }

        SetHead()
        {
            $This.Mask[2].Object                 = "\__["
            $This.Mask[26].Object                = "___/"
        }

        SetFoot()
        {
            $This.Mask[2].Object                 = "\__["
            $This.Mask[26].Object                = "___/"
        }
    
        SetBody([Int32]$Count)
        {
            $Count % 2                | % { 

                $This.Mask[0].Object  = @("   \","   /")[$_]
                $This.Mask[1].Object  = @("\   ","/   ")[$_]
                $This.Mask[-2].Object = @("   \","   /")[$_]
                $This.Mask[-1].Object = @("\   ","/   ")[$_]
            }

            -4..-3 | % { $This.Mask[$_].Object = "    " }
        }
    }

    Class _Theme
    {
        [ValidateSet(0,1,2)]
        Hidden [Int32]      $Mode
        [String]            $Name 
        [Int32[]]           $Span
        [Int32]           $Header
        [Int32]             $Body
        [Int32]           $Footer
        [Int32[]]         $Colors = @(10,12,15,0)
    
        Hidden [String[]]$Faces = [_Faces]::New().Faces
    
        Hidden [String[]]$String
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
    
        [_Track[]]       $Track
    
        _Theme([Int32]$Slot)
        {
            $This.Name   = "Function Action Section Table Test".Split(" ")[$Slot]
            $This.Span   = @{ 0 = 0..4; 1 = 5..9; 2 = @( 0..1+10..16+2..4 ); 3 = $Null; 4 = $Null }[$Slot]
            $This.Header = @(3;2;3;3;3)[$Slot]
            $This.Body   = @(-1;-1;6;-1;-1)[$Slot]
            $This.Footer = @(-1,-1,10,-1,-1)[$Slot]
                    
            $This.String = $This.Span | % { $This.String_[$_] }
            $This.Fore   = $This.Span | % { $This.Fore_[$_] }
            $This.Back   = $This.Span | % { $This.Back_[$_] }
    
            $This.Track   = ForEach ( $I in 0..( $This.String.Count - 1 ) )
            {
                [_Track]::New($I,$This.String[$I],$This.Fore[$I],$This.Back[$I]) 
            }
        }
    }

    Class _Object
    {
        [String]                  $Name
        [Int32]                   $Mode
        [Int32]                 $Height
        [Object]                 $Theme
        [String]                $Header
        [String[]]                $Body
        [String]                $Footer
        [Int32[]]              $Palette
        [Hashtable]             $Output
    
        [String] Line ([String]$L)
        {
            Return @{   Line  = If ( $L.Length -ge 89 ) { $L.Substring(0,88) + "..." } Else { $L + (" " * (92-$L.Length)) } } | % Line
        }
    
        [String] Pair ([String]$K,[String]$V)
        {
            Return @{   Key   = If ( $K.Length -ge 25 ) { $K.Substring(0,20) + "..." } Else { $K + (" "*(25-$K.Length)) }
                        Value = If ( $V.Length -ge 64 ) { $V.Substring(0,59) + "..." } Else { $V + (" "*(64-$V.Length)) }
                
                    }         | % { "{0} : {1}" -f $_.Key, $_.Value }
        }
        
        [String[]] Names ([Object]$N)
        {
            Return ( $N | Get-Member | ? MemberType -eq Property | Sort-Object Name | % Name )
        }

        Draw([Int32[]]$Palette)
        {   
            ForEach ( $I in 0..( $This.Output.Count - 1 ) )
            {
                ForEach ( $X in 0..( $This.Output[$I].Count - 1 ) )
                {
                    (Get-Host).UI.Write($Palette[$This.Output[$I][$X].ForegroundColor],$This.Output[$I][$X].BackgroundColor,$This.Output[$I][$X].Object.Replace("Ã‚Â¯","Â¯"))
                }

                (Get-Host).UI.Write("`n")
            }
        }
    
        Select([Object]$O)
        {
            Switch($O.GetType().Name)
            {
                OrderedDictionary { $This.Body += $This.Line(" ")
                    $O.GetEnumerator()          | % { 
                                    $This.Body += $This.Pair($_.Name,$_.Value) } }
                Hashtable         { $This.Body += $This.Line(" ")
                    $O.GetEnumerator()          | Sort-Object Name | % { 
                        $This.Body             += $This.Pair($_.Name,$_.Value) } }
                Int32             { $This.Body += $This.Line($O) }
                String            { $This.Body += $This.Line($O) }
                Default           { $This.Body += $This.Line(" ")
                
                    ForEach ( $X in $This.Names($O) )
                    { 
                        $This.Body += $This.Pair($X,$O.$($X))
                    }
                }
            }
        }

        Load([Object]$InputObject)
        {
            $This.Name             = $InputObject.GetType().Name

            Switch([Int]($InputObject.GetType().Name -match "(\[\])"))
            {
                0 { $This.Select($InputObject) }
                1 { ForEach ( $I in 0..( $InputObject.Count - 1 ) )
                    {
                        $This.Name    = $InputObject[$I].GetType().Name 
                        $This.Select($InputObject[$I])
                    }
                }
            }
        }

        Load([Object[]]$InputObject)
        {
            ForEach ( $I in 0..( $InputObject.Count - 1 ) )
            {
                $This.Name = $InputObject[$I].GetType().Name

                Switch([Int]($This.Name -match "(\[\])"))
                {
                    0 { $This.Select($InputObject[$I]) }
                    1 { ForEach ( $X in 0..( $InputObject[$I].Count - 1 ) )
                        {
                            $This.Name    = $InputObject[$I].GetType().Name 
                            $This.Select($InputObject[$I])
                        }
                    }
                }
            }
        }

        _Object([Object[]]$InputObject)
        {
            $This.Body             = @()
            $This.Load($InputObject)

            If ( $This.Body.Count -eq 1 )
            {
                If ( $This.Body -notmatch "(\[\:\])" ) 
                { 
                    $This.Name   = "Function"
                    $This.Mode   = 0 
                }

                Else                                   
                { 
                    $This.Name   = "Action"
                    $This.Mode   = 1 
                } 
            }

            Else                                       
            { 
                $This.Name      = "Section"
                $This.Mode      = 2
                $This.Header    = "Section"
                $This.Footer    = "Press Enter to Continue"
            
                Switch ($This.Body.Count % 2)
                { 
                    1 { $This.Body += $This.Line("    " )}
                }
            }

            $This.Theme     = [_Theme]::New($This.Mode)
            $This.Height    = Switch($This.Name) { Function {5} Action {5} Section { $This.Height + 10 } }
            $This.Header    = Switch($This.Mode) { 0 { $InputObject } 1 { $InputObject } 2 { "Section" } }

            $This.Output    = @{ }
            $OutputIndex    = 0

            $NameIndex      = 0
            While ( $NameIndex -lt $This.Theme.Track.Count )
            {
                $Item       = $This.Theme.Track[$NameIndex]
            
                Switch($NameIndex)
                {
                    Default 
                    {
                        $This.Output.Add($OutputIndex,$Item.Mask)
                        $OutputIndex ++
                    }

                    $This.Theme.Header  
                    {
                        $Item.Load($This.Header)
                        $Item.SetHead()
                        $This.Output.Add($OutputIndex,$Item.Mask)
                        $OutputIndex ++
                    }

                    $This.Theme.Body 
                    {    
                        Foreach ( $X in 0..( $This.Body.Count - 1 ) ) 
                        { 
                            $Item = [_Track]::New($NameIndex)
                            $Item.Load($This.Body[$X])
                            $Item.SetBody($X)

                            If ( $X -eq ( $This.Body.Count - 1 ) )
                            {
                                $Item.Mask[-2].Object = "___/"
                            }
                            $This.Output.Add($OutputIndex,$Item.Mask)
                            $OutputIndex ++
                        }
                    }

                    $This.Theme.Footer  
                    {  
                        $Item.Load(" Press Enter to Continue ")
                        $Item.SetFoot()
                        $This.Output.Add($OutputIndex,$Item.Mask)
                        $OutputIndex ++
                    }
                }

                $NameIndex ++
            }

            If ( $This.Name -eq "Action" )
            {
                $This.Output[2][ 2].Object = ([char[]]@(47,175,175,175) -join '')
                $This.Output[2][-4].Object = "    "
                $This.Output[2] | ? { $_.Object -match "]___" -or $_.Object -match "____" } | % { $_.Object = "    " }
            }
        }
    }

    Class _Flag
    {
        Hidden [String[]] $Faces   = [_Faces]::New().Faces

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

        _Flag()
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
                $This.Track += [_Track]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
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

    Class _Banner
    {
        Hidden [String[]] $Faces   = [_Faces]::New().Faces

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

        _Banner()
        {
            $This.Track            = @( )

            ForEach ( $I in 0..24 )
            {
                $This.Track += [_Track]::new($I,$This.String_[$I],$This.Fore_[$I],$This.Back_[$I])
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

    Switch ($PSCmdlet.ParameterSetName)
    {
        0 { [_Object]::New($InputObject).Draw($Palette) }
        1 { [_Banner]::New().Draw() }
        2 { [_Flag]::New().Draw() }
    }
}
