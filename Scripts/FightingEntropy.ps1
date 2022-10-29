
# // ___________________________________________________________________
# // | Installs the PowerShell module, [FightingEntropy(π)][2022.10.1] |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Function FightingEntropy.Module
{
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

    # // _____________________________________________
    # // | Generates an actionable write-host object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ThemeStack
    {
        Hidden [Object]  $Face
        Hidden [Object] $Track
        ThemeStack([UInt32]$Slot,[String]$Message)
        {
            $This.Main($Message)
            $This.Write($This.Palette($Slot))
        }
        ThemeStack([String]$Message)
        {
            $This.Main($Message)
            $This.Write($This.Palette(0))
        }
        Main([String]$Message)
        {
            $This.Face = $This.Mask()
            $This.Reset()
            $This.Insert($Message)
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
            Return ("20202020 5F5F5F5F AFAFAFAF 2020202F 5C202020 2020205C 2F202020 5C5F5F2F "+
            "2FAFAF5C 2FAFAFAF AFAFAF5C 5C5F5F5F 5F5F5F2F 205F5F5F" -Split " ") | % { $This.Convert($_) }
        }
        [String] Convert([String]$Line)
        {
            Return [Char[]]@(0,2,4,6 | % { [Convert]::FromHexString($Line.Substring($_,2)) }) -join ''
        }
        Add([String]$Mask,[String]$Fore)
        {
            # // ____________________________
            # // | Expands the mask strings |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Object        = Invoke-Expression $Mask | % { $This.Face[$_] }
            $FG            = Invoke-Expression $Fore
            $BG            = @(0)*30

            # // ____________________________
            # // | Generates a track object |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Hash          = @{ }
            ForEach ($X in 0..($Object.Count-1))
            {
                $Item      = [ThemeBlock]::New($X,$Object[$X],$FG[$X],$BG[$X])
                If ($X -eq $Object.Count-1)
                {
                    $Item.Last = 0
                }
                $Hash.Add($Hash.Count,$Item)
            }
            $This.Track  += [ThemeTrack]::New($This.Track.Count,$Hash[0..($Hash.Count-1)])
        }
        [Void] Reset()
        {
            $This.Track = @( )

            # // ____________________________
            # // | Generates default tracks |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Add("0,1,0+@(1)*25+0,0","@(0)*30")
            $This.Add("3,8,7,9+@(2)*23+10,11,0","0,1,0+@(1)*25+0,0")
            $This.Add("5,7,9,13+@(0)*23+12,8,4","0,1,1+@(2)*24+1,1,0")
            $This.Add("0,10,11+@(1)*23+12+8,7,6","0,0+@(1)*25+0,1,0")
            $This.Add("0,0+@(2)*25+0,2,0","@(0)*30")
        }
        Insert([String]$String)
        {
            $This.Reset()
            $String = " $String"
            Switch ($String.Length)
            {
                {$_ -lt 84}
                {
                    $String += (@(" ") * (84 - ($String.Length+1)) -join '' )
                }
                {$_ -ge 84}
                {
                    $String  = $String.Substring(0,84) + "..."
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
                $This.Track[2].Content[$X+3].String = $Hash[$X]
            }
        }
        [Void] Write([UInt32[]]$Palette)
        {
            $This.Track | % Content | % Write $Palette
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ThemeStack>"
        }
    }
    
    # // ____________________________________________________
    # // | Property object which includes source and index  |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class OSProperty
    {
        [String] $Source
        Hidden [UInt32] $Index
        [String] $Name
        [Object] $Value
        OSProperty([String]$Source,[UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Source = $Source
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OSProperty>"
        }
    }

    # // __________________________________________________________
    # // | Container object for indexed OS (property/value) pairs |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    Class OSPropertySet
    {
        Hidden [UInt32] $Index
        [String] $Source
        [Object] $Property
        OSPropertySet([UInt32]$Index,[String]$Source)
        {
            $This.Index     = $Index
            $This.Source    = $Source
            $This.Property  = @( )
        }
        Add([String]$Name,[Object]$Value)
        {
            $This.Property += [OSProperty]::New($This.Source,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            $D = ([String]$This.Property.Count).Length
            Return "({0:d$D}) <FightingEntropy.Module.OSPropertySet[{1}]>" -f $This.Property.Count, $This.Source
        }
    }

    # // _______________________________________________________
    # // | Collects various details about the operating system |
    # // | specifically for cross-platform compatibility       |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class OS
    {
        [Object]   $Caption
        [Object]  $Platform
        [Object] $PSVersion
        [Object]      $Type
        [Object]    $Output
        OS()
        {
            $This.Output = @( )

            # // _______________
            # // | Environment |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Environment")

            Get-ChildItem Env:              | % { $This.Add(0,$_.Key,$_.Value) }
            
            # // ____________
            # // | Variable |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Variable")

            Get-ChildItem Variable:         | % { $This.Add(1,$_.Name,$_.Value) }

            # // ________
            # // | Host |
            # // ¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Host")

            (Get-Host).PSObject.Properties  | % { $This.Add(2,$_.Name,$_.Value) }
            
            # // ______________
            # // | PowerShell |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("PowerShell")

            (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add(3,$_.Name,$_.Value) }

            # // ____________________________________
            # // | Assign hashtable to output array |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Caption   = $This.Tx("PowerShell","OS")
            $This.Platform  = $This.Tx("PowerShell","Platform")
            $This.PSVersion = $This.Tx("PowerShell","PSVersion")
            $This.Type      = $This.GetOSType()
        }
        [Object] Tx([String]$Source,[String]$Name)
        {
            Return $This.Output | ? Source -eq $Source | % Property | ? Name -eq $Name | % Value
        }
        Add([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Output[$Index].Add($Name,$Value)
        }
        AddPropertySet([String]$Name)
        {
            $This.Output += [OSPropertySet]::New($This.Output.Count,$Name)
        }
        [String] GetWinType()
        {
            Return @( Switch -Regex ( Invoke-Expression "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption" )
            {
                "Windows (10|11)" { "Win32_Client" } "Windows Server" { "Win32_Server" }
            })
        }
        [String] GetOSType()
        {
            Return @( If ($This.Version.Major -gt 5)
            {
                If (Get-Item Variable:\IsLinux | % Value)
                {
                    (hostnamectl | ? { $_ -match "Operating System" }).Split(":")[1].TrimStart(" ")
                }

                Else
                {
                    $This.GetWinType()
                }
            }

            Else
            {
                $This.GetWinType()
            })
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OS>"
        }
    }

    # // ______________________________________________________________
    # // | Manifest file -> filesystem object (collection/validation) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class File
    {
        Hidden [UInt32]    $Index
        [String]            $Type
        [String]            $Name
        [Object]            $Hash
        [UInt32]          $Exists
        Hidden [String] $Fullname
        Hidden [String]   $Source
        Hidden [Object]  $Content
        File([UInt32]$Index,[String]$Type,[String]$Parent,[String]$Name,[String]$Hash)
        {
            $This.Index    = $Index
            $This.Type     = $Type
            $This.Name     = $Name
            $This.Fullname = "$Parent\$Name"
            $This.Hash     = $Hash
            $This.TestPath()
        }
        [String] FolderName()
        {
            Return @{ 

                Class    = "Classes"
                Control  = "Control"
                Function = "Functions"
                Graphic  = "Graphics"
            
            }[$This.Type]
        }
        TestPath()
        {
            If (!$This.Fullname)
            {
                Throw "Exception [!] Resource path not set"
            }

            $This.Exists   = [System.IO.File]::Exists($This.Fullname)
        }
        [Void] Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                [System.IO.File]::Create($This.Fullname).Dispose()
                $This.Exists = 1
            }
        }
        [Void] Delete()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                [System.IO.File]::Delete($This.Fullname)
                $This.Exists = 0
            }
        }
        SetSource([String]$Source)
        {
            $This.Source   = "{0}/blob/main/{1}/{2}?raw=true" -f $Source, $This.FolderName(), $This.Name
        }
        Download()
        {
            Try
            {
                $This.Content = Invoke-WebRequest $This.Source -UseBasicParsing | % Content
            }
            Catch
            {
                Throw "Exception [!] An unspecified error occurred"
            }
        }
        Write()
        {
            If (!$This.Content)
            {
                Throw "Exception [!] Content not assigned, cannot (write/set) content."
            }

            If (!$This.Exists)
            {
                Throw "Exception [!] File does not exist."
            }

            Try
            {
                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    [System.IO.File]::WriteAllBytes($This.Fullname,[Byte[]]$This.Content)
                }
                Else
                {
                    [System.IO.File]::WriteAllLines($This.Fullname,$This.Content,[System.Text.UTF8Encoding]$False)
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error has occurred"
            }
        }
        GetContent()
        {
            If (!$This.Exists)
            {
                Throw "Exception [!] File does not exist, it needs to be created first."
            }

            Try
            {
                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    $This.Content = [System.IO.File]::ReadAllBytes($This.Fullname)
                }
                Else
                {
                    $This.Content = [System.IO.File]::ReadAllLines($This.Fullname,[System.Text.UTF8Encoding]::New($False))
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error has occurred"
            }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.File>"
        }
    }

    # // ________________________________________
    # // | Manifest folder -> filesystem object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Folder
    {
        Hidden [UInt32]    $Index
        [String]            $Type
        [String]            $Name
        [String]        $Fullname
        [UInt32]          $Exists
        Hidden [Object]    $Item
        Folder([UInt32]$Index,[String]$Type,[String]$Parent,[String]$Name)
        {
            $This.Index     = $Index
            $This.Type      = $Type
            $This.Name      = $Name
            $This.Fullname  = "$Parent\$Name"
            $This.Item      = @( )
            $This.TestPath()
        }
        Add([String]$Name,[Object]$Hash)
        {
            $File           = [File]::New($This.Item.Count,$This.Type,$This.Fullname,$Name,$Hash)
            If ($File.Exists)
            {
                If ((Get-FileHash $File.Fullname).Hash -ne $Hash)
                {
                    Throw "Exception [!] File exists, and the hash does not match"
                }
            }

            $This.Item     += $File
        }
        TestPath()
        {
            If (!$This.Fullname)
            {
                Throw "Exception [!] Resource path not set"
            }

            $This.Exists = [System.IO.Directory]::Exists($This.Fullname)
        }
        [Void] Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                [System.IO.Directory]::CreateDirectory($This.Fullname)
                $This.Exists = 1
            }
        }
        [Void] Delete()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                [System.IO.Directory]::Delete($This.Fullname)
                $This.Exists = 0
            }
        }
        [String] ToString()
        {
            $D = ([String]$This.Item.Count).Length
            Return "({0:d$D}) <FightingEntropy.Module.Folder[{1}]>" -f $This.Item.Count, $This.Name
        }
    }

    # // _____________________________________________________________________
    # // | File manifest container, laid out for hash (insertion+validation) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Manifest
    {
        [String]       $Source
        [String]     $Resource
        Hidden [UInt32] $Depth
        Hidden [UInt32] $Total
        [Object]       $Output
        Manifest([String]$Source,[String]$Resource)
        {
            $This.Source   = $Source
            $This.Resource = $Resource
            $This.Output   = @( )

            # // ___________
            # // | Classes |
            # // ¯¯¯¯¯¯¯¯¯¯¯

            $This.AddFolder("Class","Classes")

            ("_Cache.ps1"                      , "7530C30D1F61B272D39BE12B0BB93B26301B052819891F23551AC2AA2F114925") ,
            ("_Drive.ps1"                      , "86DCAF296E9DFD05A6030765D40E6B830C9BA956235F86D9F4A871874F581AF1") ,
            ("_Drives.ps1"                     , "B7CFC0271E1FE7ADAC9ACD430ED79A1B46BC117DBCF7D310DE89A78A5D6F10DF") ,
            ("_File.ps1"                       , "4F3DFE27626A658B94C171EE292A3BF7C2EE7E0C8E0F20204BF225D4FED911D9") ,
            ("_FirewallRule.ps1"               , "812F160D050F0F5BC44D98A149CCA8B3E51B5FEA75E6967F871B62F50D0ABB6B") ,
            ("_Icons.ps1"                      , "7B87C1910C239D75FCADC937CE7801340B08BCFC0AF87EBD1A75063E1D017CB7") ,
            ("_Shortcut.ps1"                   , "3A31216D0FAF9D24F30129BDAB915E1EB1D89C6046EB0C9213A7A5B064E76E16") ,
            ("_ViperBomb.ps1"                  , "E2D20F3C730A15DEBAE26EB55B82A2F584C3CB5AD05E2B8EF84305E131148C95") | % { 
                
                $This.Add(0,$_[0],$_[1])
            }
            
            # // ___________
            # // | Control |
            # // ¯¯¯¯¯¯¯¯¯¯¯

            $This.AddFolder("Control","Control")

            ("Computer.png"                    , "87EAB4F74B38494A960BEBF69E472AB0764C3C7E782A3F74111F993EA31D1075") ,
            ("DefaultApps.xml"                 , "766124051F5EBABF097B88513D9672EB5720C76A1CDA7F0DED30CDEF6365CC92") ,
            ("failure.png"                     , "59D479A0277CFFDD57AD8B9733912EE1F3095404D65AB630F4638FA1F40D4E99") ,
            ("FEClientMod.xml"                 , "46B0A31FAFC5616AAFC54751C785B0DDE1CEED387EAB8E544CBA7D3C231C0134") ,
            ("FEServerMod.xml"                 , "4CABB2EDFBB31571300ACA37C9A303CB586A8989C216AB494F8B64A4B87DDE39") ,
            ("header-image.png"                , "38F1E2D061218D31555F35C729197A32C9190999EF548BF98A2E2C2217BBCB88") ,
            ("MDTClientMod.xml"                , "7653012A93B133E15887A2E3EBCA5FB69C5E76EE84E8DDB602BC91C65A5BBEF1") ,
            ("MDTServerMod.xml"                , "87984E8F1E3A75C3CBE9CB4261D270E03BAEF6D18E8A7E17EC4570ABE55C9EBB") ,
            ("MDT_LanguageUI.xml"              , "02E6D26D13AE710145C39D33DA8B3830EF6163DF7049874CB8D0600286BCB774") ,
            ("PSDClientMod.xml"                , "AAE5DF95C2BCD756AC0CE153478ED1A7DFA2F4A6F53FA128F234C525E5BB8F80") ,
            ("PSDServerMod.xml"                , "AAE5DF95C2BCD756AC0CE153478ED1A7DFA2F4A6F53FA128F234C525E5BB8F80") ,
            ("success.png"                     , "46757AB0E2D3FFFFDBA93558A34AC8E36F972B6F33D00C4ADFB912AE1F6D6CE2") ,
            ("vendorlist.txt"                  , "7FFA7BFB487DEA9961BAFFDA7443FB492F0B85AE9B2C131E543B387E62FCC94E") ,
            ("zipcode.txt"                     , "38DF0D09C1093CF8571CF6C48BA6335C0314C437808CEDBCD725448742694277") | % { 
                
                $This.Add(1,$_[0],$_[1])
            }

            # // _____________
            # // | Functions |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddFolder("Function","Functions")

            ("Copy-FileStream.ps1"             , "53F003D63FE1EF88D0C5BEFA19AA63339A4121C9023AC9A3CB82E7DE4F2F6F6B") ,
            ("Get-AssemblyList.ps1"            , "6B69D03AECAF357F4568F65AF8BFA7B3A3D94DFCE1D8A06E42591361542B6BD3") ,
            ("Get-ControlExtension.ps1"        , "1872FC091A03B09840997F439179F9450696C5D86A4884FA41E1BB0A11930D6E") ,
            ("Get-DiskInfo.ps1"                , "DEDCC7E1BF1476208B99B4ECFEEC8EF0681732AFE89DE21D92D60103B79C6A11") ,
            ("Get-EnvironmentKey.ps1"          , "7757E194F5C223A67AD90619CDC2BCBF60A72139FD22D1A329FA034ED3323FEC") ,
            ("Get-EventLogArchive.ps1"         , "A410CF4F4F4A9A65CA51F5A6F414701E1A51501974762823BEA38AA77F3FF654") ,
            ("Get-EventLogConfigExtension.ps1" , "B6A101C08FD1EB475BA6F9C85F14A4C8D0274417A4D994C9711828A535E7A5C9") ,
            ("Get-EventLogController.ps1"      , "305C47991270A80DE4758779822177D247FF248B4FFEE42922128294013D62AA") ,
            ("Get-EventLogProject.ps1"         , "7CB8C9560DBA50E500BFA23C468FAD6C87D6EE6FDAF3815E6CFF2565DE768373") ,
            ("Get-EventLogRecordExtension.ps1" , "043C11C918468DCEED7DB6518335C6D69DCC95396784EE9859278CB9C1C0045D") ,
            ("Get-EventLogXaml.ps1"            , "2E20D3ACD2C705E4FFFCC759E42A77C8DCC139AD03B1ADEA80E002F5EE84FDCA") ,
            ("Get-FEADLogin.ps1"               , "96A2C343D8D0CA5D990920FECEC819BF566603A95E5AED87DDE79C165A8D3FBC") ,
            ("Get-FEDCPromo.ps1"               , "0D14EE381A210CDF54DED9FC32B7F71247DA60DFF08BE6EF56AF602AF52529F2") ,
            ("Get-FEHost.ps1"                  , "BE8B599E180EA8B4702D56FA97DF45F745265664DE72B7A077F5DC1692CFC915") ,
            ("Get-FEImageManifest.ps1"         , "8E17EDBD40594D58D0FB59D2D7D7F2331DC11054838A45FB2E4714F09F1E78C6") ,
            ("Get-FEInfo.ps1"                  , "B3F3C0278F5B4A6FFD91D0B9D06C8F782AE55CA110876E46399CF1121AF2864E") ,
            ("Get-FEManifest.ps1"              , "0EAB7303554870B4CAA4422D7C4FACBCC28CF902DE0C3AAFA58D8BF1C8FF5289") ,
            ("Get-FEModule.ps1"                , "3FB46DE2EC5E08512F230EA9C9D0222E9CF618EA6C1FAE8D63D0D5320A79FF7F") ,
            ("Get-FENetwork.ps1"               , "07B204F33B7AD3C69BB23F5AD7F858B61175521A4946B243DCB7BB4A23FB4949") ,
            ("Get-FEOS.ps1"                    , "541931942778EEC5F107BB5F64B9D6631948461DCC8BB5FE57402F7CF0D590C1") ,
            ("Get-FEProcess.ps1"               , "1F5B7E0F734039731536599B056BAD2AC367D1BE7E70A48C2FA3B53E9BD8A88C") ,
            ("Get-FERole.ps1"                  , "E56D281B1CC7754FA6D04825F2FB35702690D3D65630B744F72F847D69CA2C9A") ,
            ("Get-FEService.ps1"               , "C7CBF1273C4789E0E6253A2F3E26979D13A4EF065CF62BFAF9DBF557F0A37B7A") ,
            ("Get-FESitemap.ps1"               , "57E248072385BD311A4D34FD4F818287CB5309D8E0DCF982F22982B44B719907") ,
            ("Get-MadBomb.ps1"                 , "5686719FA0C340817FF62559ADE460CD27E3641FE6D87916FD860EE4DB7EB3C2") ,
            ("Get-MDTModule.ps1"               , "A3798D5BD9C9962925D4854E9C3296D44B2EA51C375BA6A369E5596E9168C9E9") ,
            ("Get-PowerShell.ps1"              , "5D9AD290272CB912FF32D3BA5CF32100403D6CF0BDA0BBB8DD5E83062483C31F") ,
            ("Get-PropertyItem.ps1"            , "A85038A552AABF058D5BC16F45D168EDE98781BC2A66CF14FD87AD78E34F2C2A") ,
            ("Get-PropertyObject.ps1"          , "5FE79E566CCF05910FE1D98A77BC5C238AA58606E1D081712D1DDAC9DD72761F") ,
            ("Get-PSDLog.ps1"                  , "FCEAAA2C6B30549DF518AD4C1D120F06D721AA3830E6C43F78B98E0A76ACAE49") ,
            ("Get-PSDLogGUI.ps1"               , "D4AA8D559722BBB5920FCC4636C604324F0752A81365D581EDB3DB5B646CDEA6") ,
            ("Get-PSDModule.ps1"               , "F14856CCD15F88C818F6D5F845A85277558343517BA376ECF194A587E813514F") ,
            ("Get-SystemDetails.ps1"           , "84C8A1A8221815DBF4437E64DCE340EECD0CD8F41B7F4E12B922C0B500646359") ,
            ("Get-ThreadController.ps1"        , "3541207F754EBE1C2A2C0F3948AFFAE6DFC81A835AAD9B9876BA973706B265C8") ,
            ("Get-ViperBomb.ps1"               , "82826D97915837BE55BBB49305951551730DE90A9D9DB5EE1522E9A0EA00A99F") ,
            ("Get-WhoisUtility.ps1"            , "7ACE708D974C4B92E8B925AC7BF37C2E6C4D858B26DA364FD08610712257502F") ,
            ("Install-BossMode.ps1"            , "1C59499BBCE8109EB0834ED537DFCE360482498CB1CD7C23EB6EEDD39102E1B0") ,
            ("Install-IISServer.ps1"           , "250C7F76E32B1DC8E3A834083D144A998ACB49693BAFA80CE310E493217A8FBC") ,
            ("Install-PSD.ps1"                 , "3A0D35C9F5FF754EB5ED6FC587BC0D17021E9E767B38532EE6DFD8FB44E12C7F") ,
            ("Invoke-cimdb.ps1"                , "6C09A4D4EBEDCDE2A4EB94F1073F86574EC3BD5B104C541F4C04D1D37340355E") ,
            ("Invoke-KeyEntry.ps1"             , "BEA1ADDD6379CF1FDB9EA1F21045B47F861FFA2A48459AEF942C3F20023C26F6") ,
            ("New-EnvironmentKey.ps1"          , "35FA7E730063BF9FB1D7A1638B02C60533D300FA44A4EABC2F93E2CF940331FA") ,
            ("New-FEInfrastructure.ps1"        , "200A6A8EE10C4180AB4F118A0FA2CAE330A376A92CE5397BF6E2B20EA31347A4") ,
            ("Search-WirelessNetwork.ps1"      , "C97AC96001EB6937D8B90BC4A3BA37CAA629612BEF3B9120887F6E767C74CD5D") ,
            ("Set-ScreenResolution.ps1"        , "BB83B58369EBC8E80BB6B1E7D056DAEB7067999D463EB3FB16A898F040FBB838") ,
            ("Show-ToastNotification.ps1"      , "E0450188039CB8A0064E87F6A99E2C98A2741804118B2BDB825AEC9C98016BC6") ,
            ("Update-PowerShell.ps1"           , "F55BC8401B301D25BB37D4E24D544752D092D8EF072C0734EEBA916B5DCFBA13") ,
            ("Use-Wlanapi.ps1"                 , "2680580442927F1F17B0D27383BC4EF71B14C77F627EA62613659772250A3F17") ,
            ("Write-Theme.ps1"                 , "4AD5960F09A89CB9C20C6C5FC9AFBEF9A5FCC0232BE8E7B7B1A9F033CC5272AA") | % { 
                
                $This.Add(2,$_[0],$_[1])
            }

            # // ____________
            # // | Graphics |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddFolder("Graphic","Graphics")

            ("background.jpg"                  , "94FD6CB32F8FF9DD360B4F98CEAA046B9AFCD717DA532AFEF2E230C981DAFEB5") ,
            ("banner.png"                      , "057AF2EC2B9EC35399D3475AE42505CDBCE314B9945EF7C7BCB91374A8116F37") ,
            ("icon.ico"                        , "594DAAFF448F5306B8B46B8DB1B420C1EE53FFD55EC65D17E2D361830659E58E") ,
            ("OEMbg.jpg"                       , "D4331207D471F799A520D5C7697E84421B0FA0F9B574737EF06FC95C92786A32") ,
            ("OEMlogo.bmp"                     , "98BF79CAE27E85C77222564A3113C52D1E75BD6328398871873072F6B363D1A8") ,
            ("PSDBackground.bmp"               , "05ABBABDC9F67A95D5A4AF466149681C2F5E8ECD68F11433D32F4C0D04446F7E") ,
            ("sdplogo.png"                     , "87C2B016401CA3F8F8FAD5F629AFB3553C4762E14CD60792823D388F87E2B16C") | % { 
                
                $This.Add(3,$_[0],$_[1])
            }

            $This.Total = ($This.Output | % Item).Count
            $This.Depth = ([String]$This.Total).Length
        }
        Add([UInt32]$Index,[String]$Name,[String]$Hash)
        {
            $This.Output[$Index] | % { 

                $_.Add($Name,$Hash)
                $_.Item[-1].SetSource($This.Source)
            }
        }
        AddFolder([String]$Type,[String]$Name)
        {
            $This.Output += [Folder]::New($This.Output.Count,$Type,$This.Resource,$Name)
        }
        [String] Status([UInt32]$Rank)
        {
            Return "({0:d$($This.Depth)}/{1})" -f ($Rank+1), $This.Total
        }
        [String] Percent([UInt32]$Rank)
        {   
            Return "{0:n2}" -f (($Rank/$This.Total) * 100)
        }
        Refresh()
        {
            $This.Output | % { $_.TestPath(); $_.Item | % TestPath }
        }
        Install()
        {
            $This.Refresh()

            $This.Output | ? Exists -eq 0 | % Create

            $List = $This.Output | % Item
            ForEach ($X in 0..($List.Count-1))
            {
                $File = $List[$X]
                $File.TestPath()
                If (!$File.Exists)
                {
                    $File.Create()
                    $File.Download()
                    $File.Write()
                    $File.TestPath()
                }
                Write-Host ("Installed [~] {0} {1}% -> {2}" -f $This.Status($X), $This.Percent($X), $File.Name)
            }
        }
        Remove()
        {
            $This.Refresh()

            $List  = $This.Output | % Item
            ForEach ($X in 0..($List.Count-1))
            {
                $File = $List[$X]
                $File.TestPath()
                If ($File.Exists)
                {
                    $File.Delete()
                    $File.TestPath()
                }
                Write-Host ("Removed [+] {0} {1:n2}% -> {2}" -f $This.Status($X), $This.Percent($X), $File.Name)
            }

            $This.Output | ? Exists -eq 1 | % Delete
        }
        [Object] List()
        {
            Return @(ForEach ($Folder in $This.Output)
            {
                $Folder
                $Folder | % Item
            })
        }
        [Object] Files([UInt32]$Index)
        {
            Return $This.Output[$Index] | % Item
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.Manifest>"
        }
    }

    # // ___________________________________
    # // | Template for registry injection |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Template
    {
        [String]      $Source
        [String]        $Name
        [String] $Description
        [String]      $Author
        [String]     $Company
        [String]   $Copyright
        [Guid]          $Guid
        [DateTime]      $Date
        [String]     $Caption
        [String]    $Platform
        [String]        $Type
        [String]    $Registry
        [String]    $Resource
        [String]      $Module
        [String]        $File
        [String]    $Manifest
        Template([Object]$Module)
        {
            $This.Source      = $Module.Source
            $This.Name        = $Module.Name
            $This.Description = $Module.Description
            $This.Author      = $Module.Author
            $This.Company     = $Module.Company
            $This.Copyright   = $Module.Copyright
            $This.Guid        = $Module.Guid
            $This.Date        = $Module.Date
            $This.Caption     = $Module.OS.Caption
            $This.Platform    = $Module.OS.Platform
            $This.Type        = $Module.OS.Type
            $This.Registry    = $Module.Root.Registry
            $This.Resource    = $Module.Root.Resource
            $This.Module      = $Module.Root.Module
            $This.File        = $Module.Root.File
            $This.Manifest    = $Module.Root.Manifest
        }
    }

    # // __________________________________________________
    # // | Represents individual paths to the module root |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    Class RootProperty
    {
        [String] $Type
        [String] $Name
        [String] $Fullname
        [UInt32] $Exists
        Hidden [String] $Path
        RootProperty([String]$Name,[UInt32]$Type,[String]$Fullname)
        {
            $This.Type     = Switch ($Type) { 0 { "Directory" } 1 { "File" } }
            $This.Name     = $Name
            $This.Fullname = $Fullname
            $This.Path     = $Fullname
            $This.TestPath()
        }
        TestPath()
        {
            $This.Exists   = Test-Path $This.Path
        }
        Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                Switch -Regex ($This.Name)
                {
                    "(Resource|Module)"
                    {
                        [System.IO.Directory]::CreateDirectory($This.Fullname)
                    }
                    "(File|Manifest)"
                    {
                        [System.IO.File]::Create($This.Fullname).Dispose()
                    }
                }

                $This.TestPath()
            }
        }
        Remove()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                Switch -Regex ($This.Name)
                {
                    "(Resource|Module)"
                    {
                        [System.IO.Directory]::Delete($This.Fullname)
                    }
                    "(File|Manifest)"
                    {
                        [System.IO.File]::Delete($This.Fullname)
                    }
                }
                $This.Exists = 0
            }
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    # // ________________________________________________________
    # // | Represents a collection of paths for the module root |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Root
    {
        [Object] $Registry
        [Object] $Resource
        [Object]   $Module
        [Object]     $File
        [Object] $Manifest
        [Object] $Shortcut
        Root([String]$Version,[String]$Resource,[String]$Path)
        {
            $This.Registry = $This.Set(0,0,"HKLM:\Software\Policies\Secure Digits Plus LLC\FightingEntropy\$Version")
            $This.Resource = $This.Set(1,0,"$Resource")
            $This.Module   = $This.Set(2,0,"$Path\FightingEntropy")
            $This.File     = $This.Set(3,1,"$Path\FightingEntropy\FightingEntropy.psm1")
            $This.Manifest = $This.Set(4,1,"$Path\FightingEntropy\FightingEntropy.psd1")
            $This.Shortcut = $This.Set(5,1,"$Env:Public\Desktop\FightingEntropy.lnk")
        }
        [String] Slot([UInt32]$Type)
        {
            Return @("Registry","Resource","Module","File","Manifest","Shortcut")[$Type]
        }
        [Object] Set([UInt32]$Index,[UInt32]$Type,[String]$Path)
        {
            Return [RootProperty]::New($This.Slot($Index),$Type,$Path)
        }
        [Void] Refresh()
        {
            $This.List() | % { $_.TestPath() }
        }
        [Object[]] List()
        {
            Return $This.PSObject.Properties.Name | % { $This.$_ }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.Root>"
        }
    }

    Class RegistryKeyTemp
    {
        Hidden [Microsoft.Win32.RegistryKey] $Key
        Hidden [Microsoft.Win32.RegistryKey] $Subkey
        [String]            $Enum
        [String]            $Hive
        [String]            $Path
        [String]            $Name
        Hidden [String] $Fullname
        RegistryKeyTemp([String]$Path)
        {
            $This.Fullname = $Path
            $Split         = $Path -Split "\\"
            $This.Hive     = $Split[0]
            $This.Name     = $Split[-1]
            $This.Enum     = Switch -Regex ($This.Hive)
            {
                HKLM: {"LocalMachine"} HKCU: {"CurrentUser"} HKCR: {"ClassesRoot"} 
            }
            $This.Path     = $Path -Replace "$($This.Hive)\\", "" | Split-Path -Parent
        }
        Open()
        {
            $X             = $This.Enum
            $This.Key      = [Microsoft.Win32.Registry]::$X.CreateSubKey($This.Path)
        }
        Create()
        {
            If (!$This.Key)
            {
                Throw "Must open the key first."
            }

            $This.Subkey = $This.Key.CreateSubKey($This.Name)
            Write-Host "Registry [+] Path: [$($This.Fullname)]"
        }
        Add([String]$Name,[Object]$Value)
        {
            If (!$This.Subkey)
            {
                Throw "Must create the subkey first."
            }

            $This.Subkey.SetValue($Name,$Value)
            Write-Host "Key [+] Property: [$Name], Value: [$Value]"
        }
        [Void] Delete()
        {
            If ($This.Key)
            {
                $This.Key.DeleteSubKeyTree($This.Name)
                Write-Host "Registry [-] Path [$($This.Fullname)"
            }
        }
        [Void] Dispose()
        {
            If ($This.Subkey)
            {
                $This.Subkey.Flush()
                $This.Subkey.Dispose()
            }

            If ($This.Key)
            {
                $This.Key.Flush()
                $This.Key.Dispose()
            }
        }
    }

    # // ________________________________________________________
    # // | Represents an individual registry key for the module |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class RegistryKeyProperty
    {
        Hidden [UInt32] $Index
        [String] $Name
        [Object] $Value
        [UInt32] $Exists
        RegistryKeyProperty([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.RegistryKeyProperty>"
        }
    }

    # // ___________________________________________________________
    # // | Represents a collection of registry keys for the module |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class RegistryKey
    {
        [String] $Path
        [UInt32] $Exists
        [Object] $Property
        RegistryKey([Object]$Module)
        {
            $This.Path         = $Module.Root.Registry.Path
            $This.TestPath()
            If ($This.Exists)
            {
                $Object        = Get-ItemProperty $This.Path
                $This.Property = $This.Inject($Object)
            }
            Else
            {
                $Object        = $Module.Template()
                $This.Property = $This.Inject($Object)
            }
        }
        [Object] Inject([Object]$Object)
        {
            $Hash              = @{ }
            $Object.PSObject.Properties | ? Name -notmatch ^PS | % { 

                $Item          = $This.Key($Hash.Count,$_.Name,$_.Value)
                $Item.Exists   = $This.Exists
                $Hash.Add($Hash.Count,$Item)
            }

            Return $Hash[0..($Hash.Count-1)]
        }
        TestPath()
        {
            $This.Exists = Test-Path $This.Path
        }
        [String] Status([UInt32]$Rank)
        {
            $D = ([String]$This.Property.Count).Length
            Return "({0:d$D}/{1})" -f $Rank, $This.Property.Count
        }
        Install()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                Throw "Exception [!] Path already exists"
            }

            $Key            = $This.RegistryKeyTemp($This.Path)
            $Key.Open()
            $Key.Create()

            $This.Exists    = 1
            
            ForEach ($X in 0..($This.Property.Count-1))
            {
                $Item        = $This.Property[$X]
                $Key.Add($Item.Name,$Item.Value)
                $Item.Exists = 1
            }
            $Key.Dispose()
        }
        Remove()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                Throw "Exception [!] Registry path does not exist"
            }

            $Key             = $This.RegistryKeyTemp($This.Path)
            $Key.Open()
            $Key.Create()
            $Key.Delete()

            ForEach ($Item in $This.Property)
            {
                $Item.Exists = 0
            }

            $This.Exists     =   0
            $Key.Dispose()
        }
        [Object[]] List()
        {
            Return $This.Output
        }
        [Object] Key([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            Return [RegistryKeyProperty]::New($Index,$Name,$Value)
        }
        [Object] RegistryKeyTemp([String]$Path)
        {
            Return [RegistryKeyTemp]::New($Path)
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.RegistryKey>"
        }
    }

    Class FEVersion
    {
        [Version]      $Version
        Hidden [DateTime] $Time
        [String]          $Date
        [Guid]            $Guid
        FEVersion([String]$Line)
        {
            $This.Version = $This.Tx(0,$Line)
            $This.Time    = $This.Tx(1,$Line)
            $This.Date    = $This.MilitaryTime()
            $This.Guid    = $This.Tx(2,$Line)
        }
        FEVersion([Switch]$New,[String]$Version)
        {
            $This.Version = $Version
            $This.Time    = [DateTime]::Now
            $This.Date    = $This.MilitaryTime()
            $This.Guid    = [Guid]::NewGuid()
        }
        [String] MilitaryTime()
        {
            Return $This.Time.ToString("MM/dd/yyyy HH:mm:ss")
        }
        [String] Tx([UInt32]$Type,[String]$Line)
        {
            $Pattern = Switch ($Type)
            {
                0 { "\d{4}\.\d{2}\.\d+" }
                1 { "\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}" }
                2 { @(8,4,4,4,12 | % { "[a-f0-9]{$_}" }) -join '-' }
            }

            Return [Regex]::Matches($Line,$Pattern).Value
        }
        [String] ToString()
        {
            Return "| {0} | {1} | {2} |" -f $This.Version, $This.Date.ToString("MM/dd/yyyy HH:mm:ss"), $This.Guid
        } 
    }

    # // ______________________________________________________________
    # // | Factory class to control all of the aforementioned classes |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Main
    {
        [String]      $Source = "https://www.github.com/mcc85s/FightingEntropy"
        [String]        $Name = "[FightingEntropy(π)]"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2022 (mcc85s/mcc85sx/sdp). All rights reserved."
        [Guid]          $Guid = "b139e090-db90-4536-95e8-91ea49ab74a9"
        [DateTime]      $Date = "10/27/2022 20:00:08"
        [Version]    $Version = "2022.10.1"
        [Object]          $OS
        [Object]        $Root
        [Object]    $Manifest
        [Object]    $Registry
        Main()
        {
            $This.Write("Loading [~] $($This.Label())")

            $This.OS       = $This.GetOS()
            Write-Host "[+] Operating System"

            $This.Root     = $This.GetRoot()
            Write-Host "[+] Module Root"

            $This.Manifest = $This.GetManifest($This.Source,$This.Root.Resource)
            Write-Host "[+] Module Manifest"

            $This.Registry = $This.GetRegistry()
            Write-Host "[+] Module Registry"
        }
        [Object] NewVersion([String]$Version)
        {
            If ($Version -notmatch "\d{4}\.\d{2}\.\d+")
            {
                Throw "Invalid version entry"
            }

            Return [FEVersion]::New($True,$Version)
        }
        [Object[]] Versions()
        {
            $MD       = Invoke-RestMethod "$($This.Source)/blob/main/README.md?raw=true"
            Return [FEVersion[]]($MD -Split "`n" -match "\d{4}\.\d{2}\.\d+")
        }
        [String] Label()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Version.ToString()
        }
        [Object] Template()
        {
            Return [Template]::New($This)
        }
        [Object] GetOS()
        {
            Return [OS]::New()
        }
        [Object] GetRoot()
        {
            $Resource = $Env:ProgramData, $This.Company, "FightingEntropy", $This.Version.ToString() -join "\"
            $Path     = Switch -Regex ($This.OS.Type)
            {
                ^Win32_ { $Env:PSModulePath -Split ";" -match [Regex]::Escape($Env:Windir) }
                Default { $Env:PSModulePath -Split ":" -Match "PowerShell"                 }
            }

            Return [Root]::New($This.Version,$Resource,$Path)
        }
        [Object] GetManifest([String]$Source,[String]$Resource)
        {
            Return [Manifest]::New($Source,$Resource)
        }
        [Object] GetRegistry()
        {
            Return [RegistryKey]::New($This)
        }
        [Void] Write([String]$Message)
        {        
            [ThemeStack]::New($Message)
        }
        [Void] Write([UInt32]$Slot,[String]$Message)
        {
            [ThemeStack]::New($Slot,$Message)
        }
        [Object] File([String]$Type,[String]$Name)
        {
            Return $This.Manifest.List() | ? Type -eq $Type | ? Name -eq $Name
        }
        [Object] Class([String]$Name)
        {
            Return $This.File("Class",$Name)
        }
        [Object] Control([String]$Name)
        {
            Return $This.File("Control",$Name)
        }
        [Object] Function([String]$Name)
        {
            Return $This.File("Function",$Name)
        }
        [Object] Graphic([String]$Name)
        {
            Return $This.File("Graphic",$Name)
        }

        [Void] Refresh()
        {
            # // ____________________________________________
            # // | Tests all manifest (folder/file) entries |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


            $This.Manifest.Output | % { $_.TestPath(); $_.Item | % TestPath }
            
            $This.Registry.TestPath()
            If ($This.Registry.Exists)
            {
                $This.Root.Registry.Exists = 1
            }
            $This.Root.Manifest.TestPath()
            $This.Root.File.TestPath()
            $This.Root.Module.TestPath()
        }
        [Void] Remove()
        {
            $This.Write(1,"Removing [~] $($This.Label())")
            
            # // ___________________________________________
            # // | Removing [Module]: (Manifest/File/Path) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "Shortcut","Manifest","File","Module" | % { 

                $Item = $This.Root.$_
                $Item.Remove()
                Write-Host "Removed [+] $_ | $($Item.Fullname)"
            }

            # // ________________________________________________
            # // | Removing [Manifest/Registry]: (Content/Path) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            "Manifest","Registry" | % {

                Write-Host "Removing [~] $_"
                $This.$_.Remove()
                Write-Host "Removed [+] $_"
            }

            $This.Write(1,"Removed [+] $($This.Label())")
        }
        [Void] Install()
        {
            $This.Write(2,"Installing [~] $($This.Label())")

            $This.Manifest.Install()
            $This.Registry.Install()
            $This.Root.Module.Create()
            $This.Root.File.Create()

            # PS Core
            # PS Server

            # // ___________________
            # // | PowerShell Full |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($This.Root.Resource.Exists)
            {
                $Module        = @( )
                $Module       += "# Downloaded from {0}" -f $This.Source
                $Module       += "# {0}" -f $This.Resource
                $Module       += "# {0}" -f $This.Version.ToString()
                $Module       += "# <Types>"
                $Assemblies    = "PresentationFramework",
                                 "System.Runtime.WindowsRuntime",
                                 "System.IO.Compression", 
                                 "System.IO.Compression.Filesystem", 
                                 "System.Windows.Forms"
                $Assemblies    | % { $Module += "Add-Type -AssemblyName $_" }
                $Module       += "# <Classes>"
                $This.Manifest.Files(0) | % {
            
                    $Module   += "# <{0}/{1}>" -f $_.Type, $_.Name
                    $Module   += "# {0}" -f $_.Fullname
                    If (!$_.Content)
                    {
                        $_.GetContent()
                    }
                    $Module   += $_.Content
                    $Module   += "# </{0}/{1}>" -f $_.Type, $_.Name
                }
                $Module       += "# </Classes>"
                $Module       += "# <Functions>"
                $This.Manifest.Files(2)  | % { 
            
                    $Module   += "# <{0}/{1}>" -f $_.Type, $_.Name
                    $Module   += "# {0}" -f $_.Fullname
                    If (!$_.Content)
                    {
                        $_.GetContent()
                    }
                    $Module   += $_.Content
                    $Module   += "# </{0}/{1}>" -f $_.Type, $_.Name
                }
                $Module       += "# </Functions>"
                $Module       += "Write-Theme `"Loaded Module [+] FightingEntropy [$($This.Version)]`" @(10,3,15,0)"
        
                [System.IO.File]::WriteAllLines($This.Root.File,$Module,[System.Text.UTF8Encoding]$False)
            
                @{  
                    GUID                 = $This.GUID
                    Path                 = $This.Root.Manifest
                    ModuleVersion        = $This.Version
                    Copyright            = $This.Copyright
                    CompanyName          = $This.Company
                    Author               = $This.Author
                    Description          = $This.Description
                    RootModule           = $This.Root.File
                    RequiredAssemblies   = $Assemblies

                }                        | % { New-ModuleManifest @_ }

                $This.Root.Manifest.TestPath()
            }

            # // _____________________________________________
            # // | Installs a shortcut to the module console |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Item              = (New-Object -ComObject WScript.Shell).CreateShortcut($This.Root.Shortcut.Path)
        
            # // ___________________________________
            # // | Assigns details to the shortcut |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Item.TargetPath   = "PowerShell"
            $Item.Arguments    = '-NoExit -ExecutionPolicy Bypass -Command {0}' -f @(
            'Add-Type -AssemblyName PresentationFramework','Import-Module FightingEntropy',
            '$Module = Get-FEModule','$Module' -join ";" )
            $Item.Description  = $This.Description
            $Item.IconLocation = $This.Graphic("icon.ico").Fullname
            $Item.Save()
            
            # // _____________________________________________________
            # // | Assigns administrative privileges to the shortcut |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Bytes             = [System.IO.File]::ReadAllBytes($This.Root.Shortcut)
            $Bytes[0x15]       = $Bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
            [System.IO.File]::WriteAllBytes($This.Root.Shortcut, $Bytes)

            $This.Root.Shortcut.TestPath()

            $This.Write(2,"Installed [+] $($This.Label())")
        }
    }

    [Main]::New()
}

$Module = FightingEntropy.Module
