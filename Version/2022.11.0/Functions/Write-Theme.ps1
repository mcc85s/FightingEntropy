<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Write-Theme.ps1                                                                          //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : The lifeblood of [FightingEntropy()]... With it? You can stylize the hell                //   
   \\                     out a PowerShell command prompt console.                                                 \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-11-14                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-14-2022 20:53:45    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Write-Theme
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
    [Parameter(ParameterSetName=0,Mandatory,Position=0)]
    [Parameter(ParameterSetName=1,Mandatory,Position=0)]
    [Parameter(ParameterSetName=2,Mandatory,Position=0)][Object]$InputObject,
    [Parameter(ParameterSetName=1,Mandatory,Position=1)]
    [Parameter(ParameterSetName=2,Mandatory,Position=1)][String]$Title,
    [Parameter(ParameterSetName=2,Mandatory,Position=2)][String]$Prompt,
    [Parameter(ParameterSetName=0,Position=1)]
    [Parameter(ParameterSetName=1,Position=2)]
    [Parameter(ParameterSetName=2,Position=3)][UInt32] $Palette = 0,
    [Parameter(ParameterSetName=3,Mandatory)][Switch] $Banner,
    [Parameter(ParameterSetName=4,Mandatory)][Switch] $Flag,
    [Parameter(ParameterSetName=0)]
    [Parameter(ParameterSetName=1)]
    [Parameter(ParameterSetName=2)]
    [Parameter(ParameterSetName=3)]
    [Parameter(ParameterSetName=4)][Switch] $Text)

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
                If ($This.Process[0].Value -notmatch "^.+\[\W{1}\]")
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
        Write()
        {
            $Splat = @{ 

                Object          = $This.String
                ForegroundColor = $This.Fore
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
        [UInt32]   $Color
        [Object]    $Face
        [Object] $Factory
        [UInt32]    $Slot
        [String]    $Type
        [Object]   $Title
        [Object]  $Prompt
        [Object]  $Output
        ThemeStack([UInt32]$Color,[Object]$Object,[String]$Title,[String]$Prompt)
        {
            $This.Color   = $Color
            $This.Title   = $Title
            $This.Prompt  = $Prompt
            $This.Main($Object)
        }
        ThemeStack([UInt32]$Color,[Object]$Object,[String]$Title)
        {
            $This.Color   = $Color
            $This.Title   = $Title
            $This.Prompt  = "<Press enter to continue>"
            $This.Main($Object)
        }
        ThemeStack([UInt32]$Color,[Object]$Object)
        {
            $This.Color   = $Color
            $This.Title   = $This.GetDate()
            $This.Prompt  = "<Press enter to continue>"
            $This.Main($Object)
        }
        ThemeStack([String]$Type)
        {
            $This.Face   = $This.Mask()
            $This.Title  = $This.GetDate()
            $This.Prompt = "<Press Enter to continue>"
            $This.Output = @( )

            Switch -Regex ($Type)
            {
                ^Banner$
                {
                    # // ____________________
                    # // | Banner injection |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $This.Slot   = 3
                    $This.Type   = "Banner"

                    ForEach ($X in 0..24)
                    {
                        $Object = $This.Banner($X,$X)
                        Switch ($X)
                        {
                            03 { $Object = $This.LineEntry(2,$This.Title,$Object)  }
                            23 { $Object = $This.LineEntry(2,$This.Prompt,$Object) }
                        }
                        $This.Output += $Object
                    }

                    # // String insertion
                    $Hash = @{ }
                    "   Secure Digits Plus LLC ($([Char]960))   ",
                    "   --------------------------   ",
                    "Network & Hardware Magistration ",
                    "------------------------------- ",
                    "Dynamically Engineered Digital Security ",
                    "--------------------------------------- ",
                    "Application Development - Virtualization",
                    "----------------------------------------" | % { 

                        $This.Slice($Hash,$_)
                    }

                    ForEach ($X in 0..7)
                    {
                        $This.Output[ 9].Content[11+$X].String = $Hash[0][$X]
                        $This.Output[10].Content[11+$X].String = $Hash[1][$X]
                        $This.Output[15].Content[11+$X].String = $Hash[2][$X]
                        $This.Output[16].Content[11+$X].String = $Hash[3][$X]
                    }

                    ForEach ($X in 0..9)
                    {
                        $This.Output[11].Content[10+$X].String = $Hash[4][$X]
                        $This.Output[12].Content[10+$X].String = $Hash[5][$X]
                        $This.Output[13].Content[10+$X].String = $Hash[6][$X]
                        $This.Output[14].Content[10+$X].String = $Hash[7][$X]
                    }
                }
                ^Flag$
                {

                    # // __________________
                    # // | Flag injection |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $This.Slot   = 4
                    $This.Type   = "Flag"

                    ForEach ($X in 0..38)
                    {
                        $Object = $This.Flag($X,$X)
                        Switch ($X)
                        {
                            03 { $Object = $This.LineEntry(2,$This.Title,$Object)  }
                            37 { $Object = $This.LineEntry(2,$This.Prompt,$Object) }
                        }
                        $This.Output += $Object
                    }

                    # // ___________________
                    # // | String division |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Hash = @{ }
                    "[__[ Dynamically Engineered Digital Security ]_/",
                    "[_[ Application Development - Virtualization ]_/",
                    "[_____[ Network & Hardware Magistration ]______/",
                    "----------------",
                    "  Fighting ($([Char]960))  ",
                    "     Entropy    ",
                    "----------------",
                    "_[ $([DateTime]::Now.ToString("MM-dd-yyyy")) ]_" | % { 

                        $This.Slice($Hash,$_)
                    }

                    # // ____________________
                    # // | String insertion |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    ForEach ($X in 0..11)
                    {
                        $This.Output[10].Content[14+$X].String = $Hash[0][$X]
                        $This.Output[10].Content[14+$X].Fore   = 0
                        $This.Output[14].Content[14+$X].String = $Hash[1][$X]
                        $This.Output[14].Content[14+$X].Fore   = 0
                        $This.Output[18].Content[14+$X].String = $Hash[2][$X]
                        $This.Output[18].Content[14+$X].Fore   = 0
                    }

                    ForEach ($X in 0..3)
                    {
                        $This.Output[24].Content[13+$X].String = $Hash[3][$X]
                        $This.Output[25].Content[13+$X].String = $Hash[4][$X]
                        $This.Output[26].Content[13+$X].String = $Hash[5][$X]
                        $This.Output[27].Content[13+$X].String = $Hash[6][$X]
                        $This.Output[32].Content[13+$X].String = $Hash[7][$X]
                    }
                }
            }
        }
        Slice([Hashtable]$Hash,[String]$Line)
        {
            $Hash.Add($Hash.Count,(@( 0..(($Line.Length / 4)-1)) | % { $Line.Substring(($_ * 4),4) }))
        }
        [String] GetDate()
        {
            Return [DateTime]::Now.ToString("MM-dd-yyyy HH:mm:ss")
        }
        Main([Object]$Object)
        {
            $This.Face    = $This.Mask()
            $This.Factory = [ThemeFactory]::New($Object)
            $This.Slot    = $This.Factory.Slot
            $This.Type    = $This.Factory.Type
            $This.Reset()
        }
        [UInt32[]] Palette([UInt32]$Color)
        {
            If ($Color -gt 35)
            {
                Throw "Invalid entry"
            }

            Return @( Switch ($Color) 
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
        [Object] Banner([UInt32]$Index,[UInt32]$Rank)
        {
            $Mask = Switch ($Rank)
            {
                00 { "0;1;@(0)*25;1;1;0"                         } 
                01 { "4;9;12;@(1)*23;13;9;8;7"                   }
                02 { "6;8;10;@(2)*23;11;8;9;5"                   }
                03 { "4;9;27;28;@(1)*21;29;30;9;8;7"             }
                04 { "6;8;10;@(2)*24;0;11;5"                     }
                05 { "4;10;@(0)*26;4;7"                          }
                06 { "6;5;0;0;@(1)*22;0;0;6;5"                   }
                07 { "4;7;0;13;@(9;8)*5;10;11;@(8;9)*5;12;0;4;7" }
                08 { "6;5;4;9;8;9;8;10;@(2)*14;11;8;9;8;9;5;6;5" }
                09 { "4;7;6;8;9;8;10;@(0)*16;11;8;9;8;7;4;7"     }
                10 { "6;5;4;9;8;10;@(0)*18;11;8;9;5;6;5"         }
                11 { "4;7;6;8;9;5;@(0)*18;4;9;8;7;4;7"           }
                12 { "6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5"           }
                13 { "4;7;6;8;9;5;@(0)*18;4;9;8;7;4;7"           }
                14 { "6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5"           }
                15 { "4;7;6;8;9;12;@(0)*18;13;9;8;7;4;7"         }
                16 { "6;5;4;9;8;9;12;@(0)*16;13;9;8;9;5;6;5"     }
                17 { "4;7;6;8;9;8;9;12;@(1)*14;13;9;8;9;8;7;4;7" }
                18 { "6;5;0;11;@(8;9)*5;12;13;@(9;8)*5;10;0;6;5" }
                19 { "4;7;0;0;@(2)*22;0;0;13;7"                  }
                20 { "6;12;@(0)*25;13;9;5"                       }
                21 { "4;9;12;@(1)*23;13;9;8;7"                   }
                22 { "6;8;10;@(2)*23;11;8;10;0"                  }
                23 { "0;11;27;28;@(1)*21;29;30;10;0;0"           }
                24 { "0;0;@(2)*25;0;0;0"                         }
            }

            $Fore = Switch ($Rank)
            {
                00 { "@(10)*30"                                       } 
                01 { "10;12;@(10)*25;12;12;10"                        }
                02 { "10;@(12)*28;10"                                 }
                03 { "10;12;12;@(15)*23;12;10;12;10"                  }
                04 { "10;12;@(10)*28"                                 }
                05 { "@(10)*30"                                       }
                06 { "@(10)*30"                                       }
                07 { "@(10)*4;@(12)*22;@(10)*4"                       }
                08 { "@(10)*3;@(12)*4;@(10)*16;@(12)*4;@(10)*3"       }
                09 { "@(10)*3;@(12)*3;10;@(15)*16;10;@(12)*3;@(10)*3" }
                10 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                11 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                12 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                13 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                14 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                15 { "@(10)*3;@(12)*2;10;@(15)*18;10;@(12)*2;@(10)*3" }
                16 { "@(10)*3;@(12)*3;10;@(15)*16;10;@(12)*3;@(10)*3" }
                17 { "@(10)*3;@(12)*4;@(10)*16;@(12)*4;@(10)*3"       }
                18 { "@(10)*4;@(12)*22;@(10)*4"                       }
                19 { "@(10)*30"                                       }
                20 { "@(10)*28;12;10"                                 }
                21 { "10;12;@(10)*25;12;12;10"                        }
                22 { "10;@(12)*27;10;10"                              }
                23 { "10;10;12;@(15)*23;12;10;10;10"                  }
                24 { "@(10)*30"                                       }
            }
            $Back  = "@(0)*30"

            Return [ThemeTemplate]::New($Index,$This.Face,$Mask,$Fore,$Back)
        }
        [Object] Flag([UInt32]$Index,[UInt32]$Rank)
        {
            $Mask = Switch ($Rank)
            {
                00 { "0;1;@(0)*25;1;1;0"                                                         } 
                01 { "4;9;12;@(1)*23;13;9;8;7"                                                   }
                02 { "6;8;10;@(2)*23;11;8;9;5"                                                   }
                03 { "4;9;27;28;@(1)*21;29;30;9;8;7"                                             }
                04 { "6;8;10;@(2)*24;0;11;5"                                                     }
                05 { "4;10;@(0)*26;4;7"                                                          }
                06 { "6,5,0,0;@(1)*22;0,0,6,5"                                                   }
                07 { "4,7,0,4,10;@(2)*8;22,23;@(2)*10;11,5,0,4,7"                                }
                08 { "6,5,0,6,5,16,17,0,16,17,0,16,17,24,25;@(1)*10;13,7,0,6,5"                  }
                09 { "4,7,0,4,7,18,0,19,18,0,19,18,0,24,23;@(2)*10;11,5,0,4,7"                   }
                10 { "6,5,0,6,5;@(0)*8;24,25;@(1)*10;13,7,0,6,5"                                 }
                11 { "4,7,0,4,7,16,17,0,16,17,0,16,17,24,23;@(2)*10;11,5,0,4,7"                  }
                12 { "6,5,0,6,5,18,0,19,18,0,19,18,0,24,25;@(1)*10;13,7,0,6,5"                   }
                13 { "4,7,0,4,7;@(0)*8;24,23;@(2)*10;11,5,0,4,7"                                 }
                14 { "6,5,0,6,5,16,17,0,16,17,0,16,17,24,25;@(1)*10;13,7,0,6,5"                  }
                15 { "4,7,0,4,7,18,0,19,18,0,19,18,0,24,23;@(2)*10;11,5,0,4,7"                   }
                16 { "6,5,0,6,5;@(0)*8;24,25;@(1)*10;13,7,0,6,5"                                 } 
                17 { "4,7,0,4,7,16,17,0,16,17,0,16,17,24,23;@(2)*10;11,5,0,4,7"                  }
                18 { "6,5,0,6,5,18,0,19,18,0,19,18,0,24,25;@(1)*10;13,7,0,6,5"                   }
                19 { "4,7,0,4,7,16,17,0,16,17,0,16,17,24,23;@(2)*10;11,5,0,4,7"                  }
                20 { "6,5,0,6,12;@(1)*8;26,25;@(1)*10;13,7,0,6,5"                                }
                21 { "4,7,0,4,10;;@(2)*20;;11,5,0,4,7"                                           }
                22 { "6,5,0,6,12;@(1)*7;20,8,20,20,8,20;@(1)*7;13,7,0,6,5"                       }
                23 { "4,7,0,4,10;@(2)*7;20;@(2)*4;20;@(2)*7;11,5,0,4,7"                          }
                24 { "6,5,0,6,12;@(1)*7;20,0,0,0,0,20;@(1)*7;13,7,0,6,5"                         }
                25 { "4,7,0,4,10;@(2)*7;20,0,0,0,0,20;@(2)*7;11,5,0,4,7"                         }
                26 { "6,5,0,6,12,1,1,1,21,20,8,20,20,0,0,0,0,20,20,8,20,21,1,1,1,13,7,0,6,5"     }
                27 { "4,7,0,4,10,2,2,2,21,2,2,2,2,0,0,0,0,2,2,2,2,21,2,2,2,11,5,0,4,7"           }
                28 { "6,5,0,6,12,1,1,1,21;@(1)*12;21,1,1,1,13,7,0,6,5"                           }
                29 { "4,7,0,4,10,2,2,2,21;@(2)*12;21,2,2,2,11,5,0,4,7"                           }
                30 { "6,5,0,6,12,1,1,20,21,20,8,20,20,8,20,20,8,20,20,8,20,21,20,1,1,13,7,0,6,5" }
                31 { "4,7,0,4,10,2,2,20;@(2)*14;20,2,2,11,5,0,4,7"                               }
                32 { "6,5,0,6,12,1,1,20;@(1)*14;20,1,1,13,7,0,6,5"                               } 
                33 { "4,7,0,0;@(2)*22;0,0,13,7"                                                  }
                34 { "6;12;@(0)*25;13;9;5"                                                       }
                35 { "4;9;12;@(1)*23;13;9;8;7"                                                   }
                36 { "6;8;10;@(2)*23;11;8;10;0"                                                  }
                37 { "0;11;27;28;@(1)*21;29;30;10;0;0"                                           }
                38 { "0;0;@(2)*25;0;0;0"                                                         }
            }

            $Fore = Switch ($Rank)
            {
                00 { "@(10)*30"                                 } 
                01 { "10;12;@(10)*25;12;12;10"                  }
                02 { "10;@(12)*28;10"                           }
                03 { "10;12;12;@(15)*23;12;10;12;10"            }
                04 { "10;12;@(10)*28"                           }
                05 { "@(10)*30"                                 }
                06 { "@(10)*3;@(15)*24;@(10)*3"                 }
                07 { "@(10)*3;@(15)*24;@(10)*3"                 }
                08 { "@(10)*3;@(15)*24;@(10)*3"                 }
                09 { "@(10)*3;@(15)*24;@(10)*3"                 }
                10 { "@(10)*3;@(15)*24;@(10)*3"                 }
                11 { "@(10)*3;@(15)*24;@(10)*3"                 }
                12 { "@(10)*3;@(15)*24;@(10)*3"                 }
                13 { "@(10)*3;@(15)*24;@(10)*3"                 }
                14 { "@(10)*3;@(15)*24;@(10)*3"                 }
                15 { "@(10)*3;@(15)*24;@(10)*3"                 }
                16 { "@(10)*3;@(15)*24;@(10)*3"                 }
                17 { "@(10)*3;@(15)*24;@(10)*3"                 }
                18 { "@(10)*3;@(15)*24;@(10)*3"                 }
                19 { "@(10)*3;@(15)*24;@(10)*3"                 }
                20 { "@(10)*3;@(15)*24;@(10)*3"                 }
                21 { "@(10)*3;@(15)*24;@(10)*3"                 } 
                22 { "@(10)*3;@(15)*9;@(10)*6;@(15)*9;@(10)*3"  }
                23 { "@(10)*3;@(15)*9;@(10)*6;@(15)*9;@(10)*3"  }
                24 { "@(10)*3;@(15)*9;@(10)*6;@(15)*9;@(10)*3"  }
                25 { "@(10)*3;@(15)*9;@(10)*6;@(15)*9;@(10)*3"  }
                26 { "@(10)*3;@(15)*5;@(10)*14;@(15)*5;@(10)*3" }
                27 { "@(10)*3;@(15)*5;@(10)*14;@(15)*5;@(10)*3" }
                28 { "@(10)*3;@(15)*5;@(10)*14;@(15)*5;@(10)*3" }
                29 { "@(10)*3;@(15)*5;@(10)*14;@(15)*5;@(10)*3" }
                30 { "@(10)*3;@(15)*4;@(10)*16;@(15)*4;@(10)*3" }
                31 { "@(10)*3;@(15)*4;@(10)*16;@(15)*4;@(10)*3" }
                32 { "@(10)*3;@(15)*4;@(10)*16;@(15)*4;@(10)*3" }
                33 { "@(10)*3;@(15)*24;@(10)*3"                 } 
                34 { "@(10)*28;12;10"                           }
                35 { "10;12;@(10)*25;12;12;10"                  }
                36 { "10;@(12)*27;10;10"                        }
                37 { "10;10;12;@(15)*23;12;10;10;10"            }
                38 { "@(10)*30"                                 }
            }

            $Back = Switch ($Rank)
            {
                00 { "@(0)*30"                               } 
                01 { "@(0)*30"                               }
                02 { "@(0)*30"                               }
                03 { "@(0)*30"                               }
                04 { "@(0)*30"                               }
                05 { "@(0)*30"                               }
                06 { "@(0)*30"                               }
                07 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        } 
                08 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                09 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                10 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                11 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                12 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                13 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                14 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                15 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                16 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                17 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                18 { "@(0)*4;@(9)*10;@(15)*12;@(0)*4"        }
                19 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                20 { "@(0)*4;@(9)*10;@(12)*12;@(0)*4"        }
                21 { "@(0)*4;@(15)*22;@(0)*4"                }
                22 { "@(0)*4;@(15)*8;@(0)*6;@(15)*8;@(0)*4"  }
                23 { "@(0)*4;@(12)*8;@(0)*6;@(12)*8;@(0)*4"  }
                24 { "@(0)*4;@(12)*8;@(0)*6;@(12)*8;@(0)*4"  }
                25 { "@(0)*4;@(15)*8;@(0)*6;@(15)*8;@(0)*4"  }
                26 { "@(0)*4;@(15)*4;@(0)*14;@(15)*4;@(0)*4" }
                27 { "@(0)*4;@(12)*4;@(0)*14;@(12)*4;@(0)*4" }
                28 { "@(0)*4;@(12)*4;@(0)*14;@(12)*4;@(0)*4" }
                29 { "@(0)*4;@(15)*4;@(0)*14;@(15)*4;@(0)*4" }
                30 { "@(0)*4;@(15)*3;@(0)*16;@(15)*3;@(0)*4" } 
                31 { "@(0)*4;@(12)*3;@(0)*16;@(12)*3;@(0)*4" }
                32 { "@(0)*4;@(12)*3;@(0)*16;@(12)*3;@(0)*4" }
                33 { "@(0)*30"                               }
                34 { "@(0)*30"                               }
                35 { "@(0)*30"                               }
                36 { "@(0)*30"                               }
                37 { "@(0)*30"                               }
                38 { "@(0)*30"                               }
            }

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
                            $Object   = $This.LineEntry(1,$Value,$Object)
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
                            $Object   = $This.LineEntry(0,$Value,$Object)
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
                            $Object           = $This.LineEntry(1,$This.Title,$Object)
                            $This.Output     += $Object
                            $C ++
                        }
                        ElseIf ($C -eq 6)
                        {
                            ForEach ($I in 0..($Value.Count-1))
                            {
                                $Object       = $This.Template($This.Output.Count,$X)
                                $Object       = $This.LineEntry(0,$Value[$I],$Object)
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
                            $Object           = $This.LineEntry(1,$This.Prompt,$Object)
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
        [Object] LineEntry([UInt32]$Mode,[String]$In,[Object]$Object)
        {
            If ($In.Length -gt 90)
            {
                $In            = $In.Substring(0,87) + "..."
            }

            $In                = " $In "

            # // _____________________________
            # // | (Calculate/divide) string |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $CharRemain        = $In.Length % 4
            If ($CharRemain -gt 0)
            {
                $In            = "{0}{1}" -f $In, (@(" ") * (4-$CharRemain) -join '')
            }
            $BlockCount        = $In.Length / 4

            # // ____________________________________________
            # // | Reconstitute track based on string input |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $Tray              = @( )
            ForEach ($X in 0..2)
            {
                $Tray         += $Object.Content[$X]
            }
            
            ForEach ($X in 0..($BlockCount-1))
            {
                $Tray         += $This.Block($Tray.Count,$In.Substring(($X*4),4),@(2,2,15)[$Mode],0)
            }

            # // _____________________________________________________________
            # // | If in injection mode, provide remaining track adjustments |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($Mode -ne 0 -and $Tray.Count -lt 26)
            {
                $Tray         += $This.Block($Tray.Count,"]___",@(1,1,12)[$Mode],0)
                If ($Tray.Count -lt 26)
                {
                    Do
                    {
                        $Tray += $This.Block($Tray.Count,"____",@(1,1,12)[$Mode],0)
                    }
                    Until ($Tray.Count -eq 26)
                    $Tray     += $This.Block($Tray.Count,"___/",@(1,1,12)[$Mode],0)
                }
            }

            # // ___________________________
            # // | Provide track injection |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            ForEach ($X in 0..($Tray.Count-1))
            {
                $Object.Content[$X] = $Tray[$X]
            }

            Return $Object
        }
        [Object] Block([UInt32]$Index,[String]$String,[UInt32]$Fore,[UInt32]$Back)
        {
            Return [ThemeBlock]::New($Index,$String,$Fore,$Back)
        }
        [Void] Write([UInt32]$Color)
        {
            $0,$1,$2,$3 = $This.Palette($Color)
            ForEach ($Track in $This.Output)
            {
                ForEach ($Item in $Track.Content)
                {
                $Item.Write($0,$1,$2,$3)
                }
            }
        }
        [Void] Write()
        {
            ForEach ($Track in $This.Output)
            {
                ForEach ($Item in $Track.Content)
                {
                    $Item.Write()
                }
            }
        }
        [String[]] Text()
        {
            Return @( 0..($This.Output.Count-1) | % { "#$($This.Output[$_].Content.String -join '')" } )
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ThemeStack>"
        }
    }

    $Item = Switch ($PSCmdlet.ParameterSetName)
    {
        0 { [ThemeStack]::New($Palette,$InputObject) }
        1 { [ThemeStack]::New($Palette,$InputObject,$Title) }
        2 { [ThemeStack]::New($Palette,$InputObject,$Title,$Prompt) }
        3 { [ThemeStack]::New("Banner") }
        4 { [ThemeStack]::New("Flag") }
    }

    If ($Text)
    {
        $Item.Text()
    }

    If (!$Text)
    {
        If ($PsCmdlet.ParameterSetName -lt 3)
        {
            $Item.Write($Item.Color)
        }
        Else
        {
            $Item.Write()
        }
    }
}
