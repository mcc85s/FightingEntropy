
# // ________________________________________
# // | Single line object for string output |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeLine
{
    [UInt32] $Index
    [Object] $Value
    ThemeLine([UInt32]$Index,[Object]$Value)
    {
        $This.Index   = $Index
        $This.Value   = $Value
    }
    [String] ToString()
    {
        Return $This.Value
    }
}

# // _______________________________________________
# // | Single object to contain (index/type/value) |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeInput
{
    [UInt32]        $Index
    [String]         $Type
    [Object]        $Value
    ThemeInput([UInt32]$Index,[String]$Type,[Object]$Value)
    {
        $This.Index = $Index
        $This.Type  = $Type
        $This.Value = $Value
    }
    [Object[]] Output()
    {
        $Object   = $This.Value
        $Output   = @( )

        Switch -Regex ($This.Type)
        {
            String
            {
                If ($Object.Length -gt 86)
                {
                    Do
                    {
                        $Output   += $This.Line($Output.Count,$Object.Substring(0,86))
                        $Object    = $Object.Substring(86) 
                    }
                    Until ($Object.Length -le 86)
                    $Output       += $This.Line($Output.Count,$Object)
                }
                Else
                {
                    $Output       += $This.Line($Output.Count,$Object)
                }
            }
            Hashtable
            {
                $MaxName           = ($Object.Keys | Sort-Object Length)[-1]
                $Object.GetEnumerator() | % {

                    $Name          = $_.Name
                    If ($Name.Length -lt $MaxName.Length)
                    {
                        $Name      = "{0}{1}" -f $Name, (@(" ") * ($MaxName.Length - $Name.Length) -join '')
                    }
                    $Output       += $This.Line($Output.Count,"$Name : $($_.Value)")
                }
            }
            Default
            {
                $MaxName           = ($Object.PSObject.Properties.Name | Sort-Object Length)[-1]
                $Object.PSObject.Properties | % { 

                    $Name          = $_.Name
                    If ($Name.Length -lt $MaxName.Length)
                    {
                        $Name      = "{0}{1}" -f $Name, (@(" ") * ($MaxName.Length - $Name.Length) -join '')
                    }
                    $Output       += $This.Line($Output.Count,"$Name : $($_.Value)")
                }
            }
        }

        Return $Output
    }
    [Object] Line([UInt32]$Index,[String]$Line)
    {
        Return [ThemeLine]::New($Index,$Line)
    }
}

# // ____________________________________________________________________
# // | Process object that converts input objects into formatted output |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeFactory
{
    [UInt32] $Slot
    [String] $Type
    [UInt32] $Height
    [Object] $Input
    [Object] $Process
    ThemeFactory([Object]$Object)
    {
        $This.Input   = @( )
        $This.Process = @( )

        If ($Object.GetType().Name -match "\[\]")
        {
            ForEach ($Item in $Object)
            {
                $This.ThemeInput($Item)
            }
        }
        Else
        {
            $This.ThemeInput($Object)
        }

        $This.Export()
    }
    ThemeInput([Object]$Object)
    {
        $This.Input += [ThemeInput]::New($This.Input.Count,$Object.GetType().Name,$Object)
    }
    Export()
    {
        $This.Process  = @( )
        $Item          = $Null
        $Last          = $Null
        If ($This.Input.Count -gt 1)
        {
            ForEach ($X in 0..($This.Input.Count-1))
            {
                $Item = $This.Input[$X]
                If ($X -gt 0)
                {
                    If ($Item.Type -notmatch "String")
                    {
                        $This.Process += [ThemeLine]::New(0,"")
                    }
                    ElseIf ($Last.Type -notmatch "String" -and $Item.Type -eq "String")
                    {
                        $This.Process += [ThemeLine]::New(0,"")
                    }
                }

                $Item.Output() | % { $This.Process += $_ }
                $Last = $This.Input[$X]
            }
        }
        If ($This.Input.Count -eq 1)
        {
            $This.Input[0].Output() | % { $This.Process += $_ }
        }

        # // ____________________________________
        # // | Reindex everything in the output |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $C = 0
        ForEach ($Item in $This.Process)
        {
            $Item.Index = $C
            $C ++
        }

        If ($This.Process.Count -eq 1)
        {
            If ($This.Process[0].Value -match "^.+\[\W{1}\]")
            {
                $This.Slot = 0
            }
            Else
            {
                $This.Slot = 1
            }
        }
        If ($This.Process.Count -gt 1)
        {
            $This.Slot = 2
        }

        $This.Type   = @("Function","Action","Section")[$This.Slot]
        $This.Height = $This.Process.Count
    }
}

# // _____________________________________________________________________
# // | This is a 1x[track] x 4[char] chunk of information for Write-Host |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeBlock
{
    [UInt32]   $Index
    [Object]  $String
    [UInt32]    $Fore
    [UInt32]    $Back
    [UInt32]    $Last
    ThemeBlock([Int32]$Index,[String]$String,[Int32]$Fore,[Int32]$Back)
    {
        $This.Index  = $Index
        $This.String = $String
        $This.Fore   = $Fore
        $This.Back   = $Back
        $This.Last   = 1
    }
    Write([UInt32]$0,[UInt32]$1,[UInt32]$2,[UInt32]$3)
    {
        $Splat = @{ 

            Object          = $This.String
            ForegroundColor = @($0,$1,$2,$3)[$This.Fore]
            BackgroundColor = $This.Back
            NoNewLine       = $This.Last
        }

        Write-Host @Splat
    }
    [String] ToString()
    {
        Return "<FightingEntropy.Module.ThemeBlock>"
    }
}

# // _______________________________________________
# // | Represents a 1x[track] in a stack of tracks |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeTrack
{
    [UInt32] $Index
    [Object] $Content
    ThemeTrack([UInt32]$Index,[Object]$Track)
    {
        $This.Index   = $Index
        $This.Content = $Track
    }
    [String] ToString()
    {
        Return "<FightingEntropy.Module.ThemeTrack>"
    }
}

# // ______________________________________________________________________
# // | Effectively reproduces the strings w/ foreground+background colors |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeTemplate
{
    [UInt32] $Index
    [Object] $Content
    ThemeTemplate([UInt32]$Index,[Object]$Face,[String]$Mask,[String]$Fore,[String]$Back)
    {
        $This.Index = $Index

        # // ____________________________
        # // | Expands the mask strings |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $Object        = Invoke-Expression "@($Mask)" | % { $Face[$_] }
        $Foreground    = Invoke-Expression "@($Fore)"
        $Background    = Invoke-Expression "@($Back)"

        # // ____________________________
        # // | Generates a track object |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $Hash          = @{ }
        ForEach ($X in 0..($Object.Count-1))
        {
            $Item      = [ThemeBlock]::New($X,$Object[$X],$Foreground[$X],$Background[$X])
            If ($X -eq $Object.Count-1)
            {
                $Item.Last = 0
            }
            $Hash.Add($Hash.Count,$Item)
        }

        $This.Content = [ThemeTrack]::New($This.Index,$Hash[0..($Hash.Count-1)]).Content
    }
}

# // _____________________________________________
# // | Generates an actionable write-host object |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ThemeStack
{
    [Object]    $Face
    [Object] $Factory # <- Probably could host this entire class as well
    [UInt32]    $Slot
    [String]    $Type
    [Object]   $Title
    [Object]  $Prompt
    [Object]  $Output
    ThemeStack([UInt32]$Slot,[Object]$Object,[String]$Title,[String]$Prompt)
    {
        $This.Title  = $Title
        $This.Prompt = $Prompt
        $This.Main($Slot,$Object)
    }
    ThemeStack([UInt32]$Slot,[Object]$Object,[String]$Title)
    {
        $This.Title  = $Title
        $This.Prompt = "<Press enter to continue>"
        $This.Main($Slot,$Object)
    }
    ThemeStack([Uint32]$Slot,[Object]$Object)
    {
        $This.Title  = [DateTime]::Now.ToString("MM-dd-yyyy HH:mm:ss")
        $This.Prompt = "<Press enter to continue>"
        $This.Main($Slot,$Object)
    }
    Main([UInt32]$Slot,[Object]$Object)
    {
        $This.Face    = $This.Mask()
        $This.Factory = [ThemeFactory]::New($Object)
        $This.Slot    = $This.Factory.Slot
        $This.Type    = $This.Factory.Type
        $This.Reset()
        $This.Write($Slot)
    }
    [UInt32[]] Palette([UInt32]$Slot)
    {
        If ($Slot -gt 35)
        {
            Throw "Invalid entry"
        }

        Return @( Switch ($Slot) 
        {  
            00 {10,12,15,00} 01 {12,04,15,00} 02 {10,02,15,00} # Default, R*/Error,   G*/Success
            03 {01,09,15,00} 04 {03,11,15,00} 05 {13,05,15,00} # B*/Info, C*/Verbose, M*/Feminine
            06 {14,06,15,00} 07 {00,08,15,00} 08 {07,15,15,00} # Y*/Warn, K*/Evil,    W*/Host
            09 {04,12,15,00} 10 {12,12,15,00} 11 {04,04,15,00} # R!,      R+,         R-
            12 {02,10,15,00} 13 {10,10,15,00} 14 {02,02,15,00} # G!,      G+,         G-
            15 {09,01,15,00} 16 {09,09,15,00} 17 {01,01,15,00} # B!,      B+,         B-
            18 {11,03,15,00} 19 {11,11,15,00} 20 {03,03,15,00} # C!,      C+,         C-
            21 {05,13,15,00} 22 {13,13,15,00} 23 {05,05,15,00} # M!,      M+,         M-
            24 {06,14,15,00} 25 {14,14,15,00} 26 {06,06,15,00} # Y!,      Y+,         Y-
            27 {08,00,15,00} 28 {08,08,15,00} 29 {00,00,15,00} # K!,      K+,         K-
            30 {15,07,15,00} 31 {15,15,15,00} 32 {07,07,15,00} # W!,      W+,         W-
            33 {11,06,15,00} 34 {06,11,15,00} 35 {11,12,15,00} # Steel*,  Steel!,     C+R+
        })
    }
    [Object] Mask()
    {
        Return (("20202020 5F5F5F5F AFAFAFAF 2D2D2D2D 2020202F 5C202020 2020205C "+
                 "2F202020 5C5F5F2F 2FAFAF5C 2FAFAFAF AFAFAF5C 5C5F5F5F 5F5F5F2F "+
                 "5B205F5F 5F5F205D 2A202020 20202A20 2020202A 202A2020 5B3D3D5D "+
                 "5B2D2D5D AFAFAF5D 5BAFAFAF 2020205D 5B5F5F5F 5F5F5F5D 5C5F5F5B "+
                 "205F5F5F 5F5F5F20 5D5F5F2F 2FAFAF5B 5D202020") -Split " ") | % {

            $This.Convert($_)
        }
    }
    [String] Convert([String]$Line)
    {
        Return [Char[]]@(0,2,4,6 | % { "0x$($Line.Substring($_,2))" | Invoke-Expression }) -join ''
    }
    [Object] Template([UInt32]$Index,[UInt32]$Rank)
    {
        <# 
        Class Code
        {
            [UInt32] $Index
            [UInt32] $Rank
            Code([UInt32]$Index,[UInt32]$Rank)
            {
                $This.Index = $Index
                $This.Rank  = $Rank
            }
        }
        $Count = @( )
        0..1+10..16+2..4 | % { $Count += [Code]::New($Count.Count,$_)}
        #>
        $Mask  = Switch ($Rank)
        {
            00 { "0;1;@(0)*25;1;1;0"               }
            01 { "4;9;12;@(1)*23;13;9;8;7"         }
            02 { "6;8;10;@(2)*23;11;8;10;0"        }
            03 { "0;11;27;28;@(1)*21;29;30;10;0;0" }
            04 { "0;0;@(2)*25;0;0;0"               }
            05 { "0;1;0;@(1)*25;0;0"               }
            06 { "4;9;8;10;@(2)*23;11;12;0"        }
            07 { "6;8;10;28;@(0)*23;13;9;5"        }
            08 { "0;11;12;@(1)*23;13;9;8;7"        }
            09 { "0;0;@(2)*25;0;2;0"               }
            10 { "6;8;10;@(2)*23;11;8;9;5"         }
            11 { "4;9;27;28;@(1)*21;29;30;9;8;7"   }
            12 { "6;8;10;@(2)*24;0;11;5"           }
            13 { "4;10;@(0)*26;4;7"                }
            14 { "6;5;@(0)*26;6;5"                 }
            15 { "6;12;@(0)*25;13;9;5"             }
            16 { "4;9;12;@(1)*23;13;10;13;7"       }
        }
        <#  #    R   
            0    0
            1    1
            2   10
            3   11
            4   12
            5   13
            6   14
            7   15
            8   16
            9    2
           10    3
           11    4
        #>
        $Fore  = Switch ($Rank)
        {
            00 { "@(0)*30"               }
            01 { "0;1;@(0)*25;1;1;0"     }
            02 { "0;1;@(1)*25;1;0;0"     }
            03 { "0;0;1;@(2)*23;1;0;0;0" }
            04 { "@(0)*30"               }
            05 { "@(0)*30"               }
            06 { "0;1;0;@(1)*25;0;0"     }
            07 { "0;1;1;@(2)*24;1;1;0"   }
            08 { "0;0;@(1)*25;0;1;0"     }
            09 { "@(0)*30"               }
            10 { "0;@(1)*28;0"           }
            11 { "0;1;1;@(2)*23;1;1;0"   }
            12 { "0;1;@(0)*26;0;0"       }
            13 { "@(0)*30"               }
            14 { "0;0;@(2)*26;0;0"       }
            15 { "@(0)*28;1;0"           }
            16 { "0;1;@(0)*25;1;1;0"     }
        }
        $Back  = "@(0)*30"

        Return [ThemeTemplate]::New($Index,$This.Face,$Mask,$Fore,$Back)
    }
    [Void] Reset()
    {
        $This.Output  = @( )
        $Value        = $This.Factory.Process.Value
        $C            = 0

        # // _______________________
        # // | Generates track set |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Switch ($This.Slot)
        {
            0 
            {
                # // ____________
                # // | Function |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯
                ForEach ($X in 0..4)
                {   
                    $Object       = $This.Template($This.Output.Count,$X)
                    If ($C -eq 3)
                    {
                        $Object   = $This.LineEntry($Value,$Object)
                    }
                    $This.Output += $Object
                    $C           ++
                }
            }
            1
            {
                # // __________
                # // | Action |
                # // ¯¯¯¯¯¯¯¯¯¯

                ForEach ($X in 5..9)
                {
                    $Object       = $This.Template($This.Output.Count,$X)
                    If ($C -eq 2)
                    {
                        $Object   = $This.LineEntry($Value,$Object)
                    }
                    $This.Output += $Object
                    $C           ++
                }
            }
            2 
            {
                # // ___________
                # // | Section |
                # // ¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($X in 0..1+10..16+2..4)
                {
                    If ($C -eq 3)
                    {
                        $Object           = $This.Template($This.Output.Count,$X)
                        $Object           = $This.LineEntry($This.Title,$Object)
                        $This.Output     += $Object
                        $C ++
                    }
                    ElseIf ($C -eq 6)
                    {
                        ForEach ($I in 0..($Value.Count-1))
                        {
                            $Object       = $This.Template($This.Output.Count,$X)
                            $Object       = $This.LineEntry($Value[$I],$Object)
                            If ($I % 2 -eq 1)
                            {
                                $Object.Content[ 0].String = "   /"
                                $Object.Content[ 1].String = "/   "
                                $Object.Content[28].String = "   /"
                                $Object.Content[29].String = "/   "
                            }
                            $This.Output += $Object
                            $C           ++
                        }
                        If ($I % 2 -eq 0)
                        {
                            $Object       = $This.Template($This.Output.Count,$X)
                            $Object.Content[ 0].String = "   /"
                            $Object.Content[ 1].String = "/   "
                            $Object.Content[28].String = "___/"
                            $Object.Content[29].String = "/   "
                            $This.Output += $Object
                        }
                        If ($I % 2 -eq 1)
                        {
                            $This.Output[-1].Content[28].String = "___/"
                        }
                    }
                    ElseIf ($X -eq 3)
                    {
                        $Object           = $This.Template($This.Output.Count,$X)
                        $Object           = $This.LineEntry($This.Prompt,$Object)
                        $This.Output     += $Object
                        $C ++
                    }
                    Else
                    {
                        $Object           = $This.Template($This.Output.Count,$X)
                        $This.Output     += $Object
                        $C               ++
                    }
                }
            }
        }
    }
    [Object] LineEntry([String]$String,[Object]$Object)
    {
        $String = " $String"
        Switch ($String.Length)
        {
            {$_ -lt 96}
            {
                $String += (@(" ") * (96 - ($String.Length+1)) -join '' )
            }
            {$_ -ge 96}
            {
                $String  = $String.Substring(0,96) + "..."
            }
        }
        $Array = [Char[]]$String
        $Hash  = @{ }
        $Block = ""
        ForEach ($X in 0..($Array.Count-1))
        {
            If ($X % 4 -eq 0 -and $Block -ne "")
            {
                $Hash.Add($Hash.Count,$Block)
                $Block = ""
            }
            $Block += $Array[$X]
        }
        
        ForEach ($X in 0..($Hash.Count-1))
        {
            $Object.Content[$X+3].String = $Hash[$X]
        }

        Return $Object
    }
    [Void] Write([UInt32]$Slot)
    {
        $0,$1,$2,$3 = $This.Palette($Slot)
        ForEach ($Track in $This.Output)
        {
            ForEach ($Item in $Track.Content)
            {
               $Item.Write($0,$1,$2,$3)
            }
        }
    }
    [String] ToString()
    {
        Return "<FightingEntropy.Module.ThemeStack>"
    }
}

$Obj     = @( )
$Obj    += "This is a string"

$Obj    += @{ Name   = "This is a hashtable"
              Value  = "Write cool stuff and whatever else"
              Target = "Awesome stuff...? Sure." }

$Obj    += @("This is another string",
           @{ Name   = "This is another hashtable"
              Value  = "This hashtable is cool, too."
              Target = "It's not trying to be TOO awesome, or anything like that..." })

$Obj    += [PSCustomObject]@{ 
              Name   = "This is a PSCustomObject"
              Value  = "PSCustomObjects are a lot like hashtables"
              Target = "But the 'keys' retain their order" }

$Obj    += @("Yet another string";
           @{ Name   = "This is a lame hashtable"; 
              Value  = "It doesn't care how lame it is..." 
              Target = "It thinks that being as lame as it is, is pretty cool." 
              Thesis = "Hashtables don't actually think anything, though."};
              [PSCustomObject]@{ 
              Name   = "This is another PSCustomObject"
              Value  = "This one doesn't play games." 
              Target = "You probably shouldn't mess around with this one..." };
              [PSCustomObject]@{ 
              Name   = "This is yet an additional PSCustomObject"
              Value  = "This one constantly plays games with the PSCustomObject above." 
              Target = "...there's nothing anybody can do about it, either."}
            )

$Stack  = @( )
$Stack += [ThemeStack]::New(1,$Obj)
$Stack += [ThemeStack]::New(2,$Obj,"<Insert a really cool title right here, bro>")
$Stack += [ThemeStack]::New(3,$Obj,"<Or, don't insert a really cool title at all.>","<Put a non-cool, non-title here, for progress indication or whatever.>")
$Stack += [ThemeStack]::New(4,"Testing some stuff, function mode")
$Stack += [ThemeStack]::New(5,"Testing [~] Stuff, action mode")
$Stack += [ThemeStack]::New(34,"These [!] objects can be reused")
$Stack += [ThemeStack]::New(1,"This is meant to look like an ERROR MESSAGE... Uh-oh.")
$Stack += [ThemeStack]::New(1,"Exception [!] This looks *slightly* more alarming...")

$C = 0
ForEach ($X in 0..($Stack.Count-1))
{
    $Stack[$X].Write($C)
    $C ++
}
