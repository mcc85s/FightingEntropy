<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-01-04 14:28:05                                                                  //
 \\==================================================================================================// 

   FileName   : Get-FEModule.ps1
   Solution   : [FightingEntropy()][2022.12.0]
   Purpose    : Loads the FightingEntropy module
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2022-12-14
   Modified   : 2023-01-04
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : Have the hash values restore themselves from registry

.Example
#>
Function Get-FEModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
        [Parameter(ParameterSetName=0)][UInt32]      $Mode = 0,
        [Parameter(ParameterSetName=1)][Switch]   $Control ,
        [Parameter(ParameterSetName=2)][Switch] $Functions ,  
        [Parameter(ParameterSetName=3)][Switch]  $Graphics )

    # // =====================================================================
    # // | This is a 1x[track] x 4[char] chunk of information for Write-Host |
    # // =====================================================================

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

    # // ===============================================
    # // | Represents a 1x[track] in a stack of tracks |
    # // ===============================================

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

    # // =============================================
    # // | Generates an actionable write-host object |
    # // =============================================

    Class ThemeStack
    {
        Hidden [Object]  $Face
        Hidden [Object] $Track
        ThemeStack([UInt32]$Slot,[String]$Message)
        {
            $This.Main($Message)
            $Object = $This.Palette($Slot)
            $This.Write($Object)
        }
        ThemeStack([String]$Message)
        {
            $This.Main($Message)
            $Object = $This.Palette(0)
            $This.Write($Object)
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
            Return [Char[]]@(0,2,4,6 | % { "0x$($Line.Substring($_,2))" | IEX }) -join ''
        }
        Add([String]$Mask,[String]$Fore)
        {
            # // ============================
            # // | Expands the mask strings |
            # // ============================

            $Object        = Invoke-Expression $Mask | % { $This.Face[$_] }
            $FG            = Invoke-Expression $Fore
            $BG            = @(0)*30

            # // ============================
            # // | Generates a track object |
            # // ============================

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

            # // ============================
            # // | Generates default tracks |
            # // ============================

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
            $0,$1,$2,$3 = $Palette
            ForEach ($Track in $This.Track)
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
    
    # // ====================================================
    # // | Property object which includes source and index  |
    # // ====================================================

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

    # // ==========================================================
    # // | Container object for indexed OS (property/value) pairs |
    # // ==========================================================
    
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

    # // =======================================================
    # // | Collects various details about the operating system |
    # // | specifically for cross-platform compatibility       |
    # // =======================================================

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

            # // ===============
            # // | Environment |
            # // ===============

            $This.AddPropertySet("Environment")

            Get-ChildItem Env:              | % { $This.Add(0,$_.Key,$_.Value) }
            
            # // ============
            # // | Variable |
            # // ============

            $This.AddPropertySet("Variable")

            Get-ChildItem Variable:         | % { $This.Add(1,$_.Name,$_.Value) }

            # // ========
            # // | Host |
            # // ========

            $This.AddPropertySet("Host")

            (Get-Host).PSObject.Properties  | % { $This.Add(2,$_.Name,$_.Value) }
            
            # // ==============
            # // | PowerShell |
            # // ==============

            $This.AddPropertySet("PowerShell")

            (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add(3,$_.Name,$_.Value) }

            If ($This.Tx("PowerShell","PSedition") -eq "Desktop")
            {
                Get-CimInstance Win32_OperatingSystem | % { $This.Add(3,"OS","Microsoft Windows $($_.Version)") }
                $This.Add(3,"Platform","Win32NT")
            }

            # // ====================================
            # // | Assign hashtable to output array |
            # // ====================================

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
        [String] GetWinCaption()
        {
            Return "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption"
        }
        [String] GetWinType()
        {
            Return @(Switch -Regex (Invoke-Expression $This.GetWinCaption())
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

    # // ==============================================================
    # // | Manifest file -> filesystem object (collection/validation) |
    # // ==============================================================

    Class File
    {
        Hidden [UInt32]    $Index
        [String]            $Type
        [String]            $Name
        [String]            $Hash
        [UInt32]          $Exists
        Hidden [String] $Fullname
        Hidden [String]   $Source
        Hidden [UInt32]    $Match
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

                Control  = "Control"
                Function = "Functions"
                Graphic  = "Graphics"
            
            }[$This.Type]
        }
        TestPath()
        {
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
            $Version = [Regex]::Matches($This.Fullname,"\d{4}\.\d{2}\.\d+").Value
            $This.Source   = "{0}/blob/main/Version/{1}/{2}/{3}?raw=true" -f $Source, $Version, $This.FolderName(), $This.Name
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
                    [System.IO.File]::WriteAllText($This.Fullname,
                                                   $This.Content,
                                                   [System.Text.UTF8Encoding]$False)
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
                    $This.Content = [System.IO.File]::ReadAllLines($This.Fullname,
                                                                   [System.Text.UTF8Encoding]$False)
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

    # // ========================================
    # // | Manifest folder -> filesystem object |
    # // ========================================

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
                $Hash       = Get-FileHash $File.Fullname | % Hash
                If ($Hash -eq $File.Hash)
                {
                    $File.Match = 1
                }
                If ($Hash -ne $File.Hash)
                {
                    $File.Match = 0
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

    # // =====================================================================
    # // | File manifest container, laid out for hash (insertion+validation) |
    # // =====================================================================

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
            
            # // ===========
            # // | Control |
            # // ===========

            $This.AddFolder("Control","Control")

            ("Computer.png"                    , "87EAB4F74B38494A960BEBF69E472AB0764C3C7E782A3F74111F993EA31D1075") ,
            ("DefaultApps.xml"                 , "939CE697246AAC96C6F6A4A285C8EE285D7C5090523DB77831FF76D5D4A31539") ,
            ("failure.png"                     , "59D479A0277CFFDD57AD8B9733912EE1F3095404D65AB630F4638FA1F40D4E99") ,
            ("FEClientMod.xml"                 , "B3EB870C6B4206D11C921E70C6D058777A5F69FD1D9DEA8B6071759CAFCD2593") ,
            ("FEServerMod.xml"                 , "55A881BFE436EF18C104BFA51ECF6D12583076D576BA3276F53A682E056ACA5C") ,
            ("header-image.png"                , "38F1E2D061218D31555F35C729197A32C9190999EF548BF98A2E2C2217BBCB88") ,
            ("MDTClientMod.xml"                , "C22C53DAAB87AAC06DC3AC64F66C8F6DF4B7EAE259EC5D80D60E51AF82055231") ,
            ("MDTServerMod.xml"                , "3724FE189D8D2CFBA17BC2A576469735B1DAAA18A83D1115169EFF0AF5D42A2F") ,
            ("MDT_LanguageUI.xml"              , "100B5CA10BCF99E2A8680C394266042DEA5ECA300FBDA33289F6E4A17E44CBCF") ,
            ("PSDClientMod.xml"                , "4175C9569C8DFC1F14BADF70395D883BDD983948C2A6633CBBB6611430A872C7") ,
            ("PSDServerMod.xml"                , "4175C9569C8DFC1F14BADF70395D883BDD983948C2A6633CBBB6611430A872C7") ,
            ("success.png"                     , "46757AB0E2D3FFFFDBA93558A34AC8E36F972B6F33D00C4ADFB912AE1F6D6CE2") ,
            ("vendorlist.txt"                  , "9BD91057A1870DB087765914EAA5057D673CDC33145D804BBF4B024A11D66934") ,
            ("Wifi.cs"                         , "698AA48C98F500C6ED98305BCCA3C59C52784A664E01526D965A07AB24E47A2A") ,
            ("zipcode.txt"                     , "45D5F4B9B50782CEC4767A7660583C68A6643C02FC7CC4F0AE5A79CCABE83021") | % { 
                
                $This.Add(0,$_[0],$_[1])
            }

            # // =============
            # // | Functions |
            # // =============

            $This.AddFolder("Function","Functions")

            ("Copy-FileStream.ps1"             , "51691C4F53482684E2BF2619E33452E69F7EEBC2B081A0CD64C0BCBA1A14BA13") ,
            ("Get-AssemblyList.ps1"            , "303CE72974C50EDDBD880FCF5B72FED0D2AB5CBFBA7B2D7DE2310703612AF069") ,
            ("Get-ControlExtension.ps1"        , "4923A7C734BD01047502006027A8054C7C0B87BD37E48D60C0BF38ABC376376A") ,
            ("Get-EnvironmentKey.ps1"          , "3CB3DF68CF3E49DDAF5B1E79C1D82E82B11D9FBCA4AD2253554D97D8AE63D63B") ,
            ("Get-EventLogArchive.ps1"         , "90FD0564822E764CB602536E45410230E09A628AEA303EA7D3A025A34DBF5308") ,
            ("Get-EventLogConfigExtension.ps1" , "A32987DFDECDDD8D1976E7BABB1B00EA4993C6EB4430E0ED14AB61BC101C5458") ,
            ("Get-EventLogController.ps1"      , "7E5674C6AB6A1E82934FBC5589F2DA5905DF180AD1745B375F431A98F74E72B8") ,
            ("Get-EventLogProject.ps1"         , "5AE177E8FE9985369673BA3D159F57A9F65439C048896197B752D7362E4E73A5") ,
            ("Get-EventLogRecordExtension.ps1" , "46BDD7B43F1221E1691B2B9079AE8F62099099C2298F30AF050E576F8C818DDD") ,
            ("Get-EventLogXaml.ps1"            , "5BA7F7099DD7EF55498A889E7AC83CA5EAC1F335EDA53ACF1D7EA23864BF5180") ,
            ("Get-FEADLogin.ps1"               , "1EEA605D7181E9F1985FC012E7EABB1884B39B9D33D2E2E8AB6A8C21C3770B56") ,
            ("Get-FEDCPromo.ps1"               , "B6D87EA815922BAD9DABBB0C061B28A8EF3A2667254EE6F03F606EDCE8D04D39") ,
            ("Get-FEImageManifest.ps1"         , "3665C48E2A0A947F6DDACF6F036ED88D33318595F67129718A1CB5F17D9A5D80") ,
            ("Get-FEModule.ps1"                , "") ,
            ("Get-FENetwork.ps1"               , "0048A6208F9DDF0CCCFBCEE0621426DE2B49ACCBDBED71FB1E5D8B027330CEFC") ,
            ("Get-FERole.ps1"                  , "A26A3D36FADC3FA27B6E6978561EF4A3B532442EAB9D97FC9A0F6950B250F8C4") ,
            ("Get-FESystem.ps1"                , "47B1FF7BE39A95CEAFFD450336F01D3559B6E6059DA984A06D76980A391C7E2C") ,
            ("Get-MDTModule.ps1"               , "A867850639534E9D24A5EA0EEECBC6F9E078BB4E2FCFAE1D82486BA0BE654C51") ,
            ("Get-PSDLog.ps1"                  , "6FA5187C71FBEDA668811BE166E0EAFC9135EB90948B563AAC040FC4D3DC5DB1") ,
            ("Get-PSDLogGUI.ps1"               , "B9084471E0906694B8469501B2E280E9F3163EFF63BCD006E162B7B3FD3B49CD") ,
            ("Get-PSDModule.ps1"               , "A3B4984BFF3835A0938E82D9501FAA63A852C82064559638232134E96F672A3B") ,
            ("Get-PowerShell.ps1"              , "3D778E96A8134D4E43DD0C93101727B98BECCBD1E1829B2495668DB3B60AA7B0") ,
            ("Get-PropertyItem.ps1"            , "DED775999AAACA8DB127C40B1C0E0F7CFCCE6409F64B9332CC21771E81C39198") ,
            ("Get-PropertyObject.ps1"          , "1B0BD523F33DE4B50C83B0561579AD57F348DB2384BD8E70F06CC268D92E7323") ,
            ("Get-ThreadController.ps1"        , "7E573D21AB6A96450CBBEF9D87AF23797D4A8CFE822D543BE2B4BF696EADE2D8") ,
            ("Get-ViperBomb.ps1"               , "4771549A426A4E841A7D048613D65907BF7F416CF69797A1EAF9FAC8B28D797F") ,
            ("Get-WhoisUtility.ps1"            , "8F397C28276878C615672B653A82C58A5894956AC14DE431C030E80326BCDEE7") ,
            ("Install-BossMode.ps1"            , "93CC648B8DB4F78225F7EF8F36FC081DBB8FD0A1ACF6C9CE7E6861AA33F10B94") ,
            ("Install-IISServer.ps1"           , "A52DA72273CF1F24CB774003BC645AA8A6DA37A0D05E108D60D868159404095C") ,
            ("Install-PSD.ps1"                 , "3487614D00E8175941FB4EEFC9E83BAA37CE8B43A1D86858AB6E6E3D43180A94") ,
            ("Invoke-cimdb.ps1"                , "FAEB8030E3FF7AA205B02DB720DBA19E2FB3B9D10C274FBAFF814A059CA6B114") ,
            ("New-EnvironmentKey.ps1"          , "4783E3A5AFE777F91A59AB73A0D2B7311BD4E9760EA6BDDCB366FAFE52FB5CDD") ,
            ("New-FEConsole.ps1"               , "16F320BBCCEE1F8CE5F2F6CF9352886E1C16012705318CDBE6D50B0FDB840758") ,
            ("New-FEFormat.ps1"                , "47CCD7579C4EBBEE9A646264CBB61EEC382046B47C555858F78ED8A672FB39A1") ,
            ("New-FEInfrastructure.ps1"        , "04C48E828FEF3DDCC6B07D914D088AB471B6C768C10F2DD38FD230A5B0566F67") ,
            ("Search-WirelessNetwork.ps1"      , "22304116A8BFD8C584321F2DC986870E061023789526928CF4162109411C5294") ,
            ("Set-ScreenResolution.ps1"        , "550BABB4ECCB26E835A952E1A749EDC857816B202881DC68C22F2727EB3493F7") ,
            ("Show-ToastNotification.ps1"      , "B7D9BC8BF580EABFAFF35A7FF97DFCBB7BF7BEDEF30D1469AEB140F0D4A30DFE") ,
            ("Update-PowerShell.ps1"           , "0D803B07A9FF514B2376CEB4EB5E792F526785EBE89CCA7E5E9FA9CAF2A9154F") ,
            ("Write-Theme.ps1"                 , "9B75801191BF001F1C47A63E00E17AA2254ADF3C4FC9CDE381FA749ED300D88D") | % { 
                
                $This.Add(1,$_[0],$_[1])
            }

            # // ============
            # // | Graphics |
            # // ============

            $This.AddFolder("Graphic","Graphics")

            ("background.jpg"                  , "94FD6CB32F8FF9DD360B4F98CEAA046B9AFCD717DA532AFEF2E230C981DAFEB5") ,
            ("banner.png"                      , "057AF2EC2B9EC35399D3475AE42505CDBCE314B9945EF7C7BCB91374A8116F37") ,
            ("icon.ico"                        , "594DAAFF448F5306B8B46B8DB1B420C1EE53FFD55EC65D17E2D361830659E58E") ,
            ("OEMbg.jpg"                       , "D4331207D471F799A520D5C7697E84421B0FA0F9B574737EF06FC95C92786A32") ,
            ("OEMlogo.bmp"                     , "98BF79CAE27E85C77222564A3113C52D1E75BD6328398871873072F6B363D1A8") ,
            ("PSDBackground.bmp"               , "05ABBABDC9F67A95D5A4AF466149681C2F5E8ECD68F11433D32F4C0D04446F7E") ,
            ("sdplogo.png"                     , "87C2B016401CA3F8F8FAD5F629AFB3553C4762E14CD60792823D388F87E2B16C") | % { 
                
                $This.Add(2,$_[0],$_[1])
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
                Write-Host ("Installed [~] {0} {1}% -> {2}" -f $This.Status($X), 
                                                               $This.Percent($X), 
                                                               $File.Name)
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
                Write-Host ("Removed [+] {0} {1:n2}% -> {2}" -f $This.Status($X), 
                                                                $This.Percent($X), 
                                                                $File.Name)
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
        [Object] Full()
        {
            $D = "Index Type Name Hash Exists Fullname Source Match" -Split " "
            Return $This.Output | % Item | Select-Object $D
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.Manifest>"
        }
    }

    # // ===================================
    # // | Template for registry injection |
    # // ===================================

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

    # // ==================================================
    # // | Represents individual paths to the module root |
    # // ==================================================
    
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

    # // ========================================================
    # // | Represents a collection of paths for the module root |
    # // ========================================================

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
            $SDP = "Secure Digits Plus LLC"
            $FE  = "FightingEntropy"
            $This.Registry = $This.Set(0,0,"HKLM:\Software\Policies\$SDP\$FE\$Version")
            $This.Resource = $This.Set(1,0,"$Resource")
            $This.Module   = $This.Set(2,0,"$Path\$FE")
            $This.File     = $This.Set(3,1,"$Path\$FE\$FE.psm1")
            $This.Manifest = $This.Set(4,1,"$Path\$FE\$FE.psd1")
            $This.Shortcut = $This.Set(5,1,"$Env:Public\Desktop\$FE.lnk")
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

    # // ===========================================
    # // | Works as a PowerShell Registry provider |
    # // ===========================================

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

    # // ========================================================
    # // | Represents an individual registry key for the module |
    # // ========================================================

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

    # // ===========================================================
    # // | Represents a collection of registry keys for the module |
    # // ===========================================================

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

    # // ===========================================
    # // | Collects/creates versions of the module |
    # // ===========================================

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
            Return "| {0} | {1} | {2} |" -f $This.Version, 
                                            $This.Date.ToString("MM/dd/yyyy HH:mm:ss"), 
                                            $This.Guid
        } 
    }

    # // ========================================================
    # // | Specifically used for file hash validation/integrity |
    # // ========================================================

    Class ValidateFile
    {
        [String] $Type
        [String] $Name
        Hidden [String] $Fullname
        Hidden [String] $Source
        [String] $Hash
        [UInt32] $Match
        [String] $Compare
        ValidateFile([String]$Leaf,[Object]$File)
        {
            $This.Type     = $File.Type
            $This.Name     = $File.Name
            $This.Fullname = $File.Fullname
            $This.Hash     = $File.Hash
            $This.Source   = $File.Source
            
            # // =======================
            # // | Temporary variables |
            # // =======================

            $Content       = Invoke-WebRequest $This.Source -UseBasicParsing | % Content
            $Target        = "{0}\{1}" -f $Env:Temp, $This.Name

            If ([System.IO.File]::Exists($Target))
            {
                [System.IO.File]::Delete($Target)
            }

            If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
            {
                [System.IO.File]::WriteAllBytes($Target,[Byte[]]$Content)
            }
            Else
            {
                [System.IO.File]::WriteAllText($Target,$Content,[System.Text.UTF8Encoding]$False)
            }

            # // ========================================
            # // | Get target hash and final comparison |
            # // ========================================

            $This.Compare  = $This.GetFileHash($Target)
            $This.Match    = $This.Hash -eq $This.Compare

            [System.IO.File]::Delete($Target)
        }
        [String] GetFileHash([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid path"
            }

            Return Get-FileHash $Path | % Hash
        }
    }

    # // ==================================================
    # // | Container class for (manifest/file) validation |
    # // ==================================================

    Class Validate
    {
        [Object] $Output
        Validate([Object]$Module)
        {
            $Hash     = @{ }
            ForEach ($Branch in $Module.Manifest.Output)
            {
                Write-Host ("Path [~] [{0}]" -f $Branch.Fullname)
                ForEach ($File in $Branch.Item)
                {
                    Write-Host "File [~] [$($File.Fullname)]"
                    $Hash.Add($Hash.Count,$This.ValidateFile($Branch.Name,$File))
                }
            }

            $This.Output = $Hash[0..($Hash.Count-1)]
        }
        [Object] ValidateFile([String]$Name,[Object]$File)
        {
            Return [ValidateFile]::New($Name,$File)
        }
        [String] BuildManifest()
        {
            $MaxName = ($This.Output.Name | Sort-Object Length)[-1]
            Return @( $This.Output | % { 

                "            (`"{0}`"{1}, `"{2}`") ," -f $_.Name,
                (@(" ") * ($MaxName.Length - $_.Name.Length + 1) -join ''), 
                $_.Hash

            }) -join "`n"
        }
    }

    # // ==============================================================
    # // | Factory class to control all of the aforementioned classes |
    # // ==============================================================

    Class Controller
    {
        [String]      $Source = "https://www.github.com/mcc85s/FightingEntropy"
        [String]        $Name = "[FightingEntropy($([Char]960))]"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2022 (mcc85s/mcc85sx/sdp). All rights reserved."
        [Guid]          $Guid = "5e6c9634-1c88-49a2-8794-2970095d8793"
        [DateTime]      $Date = "12/14/2022 14:26:18"
        [Version]    $Version = "2022.12.0"
        [Object]          $OS
        [Object]        $Root
        [Object]    $Manifest
        [Object]    $Registry
        Controller([UInt32]$Mode)
        {
            If ($Mode -eq 0)
            {
                $This.Write("Loading [~] $($This.Label())")
            }

            $This.OS       = $This.GetOS()

            If ($Mode -eq 0)
            {
                Write-Host "[+] Operating System"
            }

            $This.Root     = $This.GetRoot()
            If ($Mode -eq 0)
            {
                Write-Host "[+] Module Root"
            }

            $This.Manifest = $This.GetManifest($This.Source,$This.Root.Resource)
            If ($Mode -eq 0)
            {
                Write-Host "[+] Module Manifest"
            }

            $This.Registry = $This.GetRegistry()
            If ($Mode -eq 0)
            {
                Write-Host "[+] Module Registry"
            }
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
            $Markdown = Invoke-RestMethod "$($This.Source)/blob/main/README.md?raw=true"
            Return $Markdown -Split "`n" | ? { $_ -match "^\|\s\*\*\d{4}\.\d{2}\.\d+\*\*" } | % { [FEVersion]$_ }
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
            $Resource = $Env:ProgramData, 
                        $This.Company, 
                        "FightingEntropy", 
                        $This.Version.ToString() -join "\"
            $Path     = Switch -Regex ($This.OS.Type)
            {
                ^Win32_ { $Env:PSModulePath -Split ";" -match [Regex]::Escape($Env:Windir) }
                Default { $Env:PSModulePath -Split ":" -match "PowerShell"                 }
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
        [Object] GetFEVersion()
        {
            Return [FEVersion]::New("| $($This.Version) | $($This.Date) | $($This.Guid) |")
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
        [Object] _Control([String]$Name)
        {
            Return $This.File("Control",$Name)
        }
        [Object] _Function([String]$Name)
        {
            Return $This.File("Function",$Name)
        }
        [Object] _Graphic([String]$Name)
        {
            Return $This.File("Graphic",$Name)
        }
        [Void] Refresh()
        {
            # // ============================================
            # // | Tests all manifest (folder/file) entries |
            # // ============================================

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
            
            # // ===========================================
            # // | Removing [Module]: (Manifest/File/Path) |
            # // ===========================================

            "Shortcut","Manifest","File","Module" | % { 

                $Item = $This.Root.$_
                $Item.Remove()
                Write-Host "Removed [+] $_ | $($Item.Fullname)"
            }

            # // ================================================
            # // | Removing [Manifest/Registry]: (Content/Path) |
            # // ================================================

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

            # // =====================
            # // | Build the PSM/PSD |
            # // =====================

            $This._Module()

            # // =============================================
            # // | Installs a shortcut to the module console |
            # // =============================================

            $Com  = New-Object -ComObject WScript.Shell
            $Item = $Com.CreateShortcut($This.Root.Shortcut.Path)
        
            # // ===================================
            # // | Assigns details to the shortcut |
            # // ===================================

            $Item.TargetPath   = "PowerShell"

            $Command           = 'Add-Type -AssemblyName PresentationFramework',
                                 'Import-Module FightingEntropy',
                                 '$Module = Get-FEModule',
                                 '$Module' -join ";"
            $Item.Arguments    = "-NoExit -ExecutionPolicy Bypass -Command $Command"

            $Item.Description  = $This.Description
            $Item.IconLocation = $This.Graphic("icon.ico").Fullname
            $Item.Save()
            
            # // =====================================================
            # // | Assigns administrative privileges to the shortcut |
            # // =====================================================

            $Bytes             = [System.IO.File]::ReadAllBytes($This.Root.Shortcut)
            $Bytes[0x15]       = $Bytes[0x15] -bor 0x20 
                                 # Set [byte] (21/0x15) bit 6 (0x20) ON... or else.
            [System.IO.File]::WriteAllBytes($This.Root.Shortcut, $Bytes)

            $This.Root.Shortcut.TestPath()

            $This.Write(2,"Installed [+] $($This.Label())")
        }
        [Void] Update()
        {
            $This.Root.File.Remove()
            $This.Root.Manifest.Remove()

            ForEach ($File in $This.Manifest.Output | % Item)
            {
                $Hash = Get-FileHash $File.Fullname | % Hash
                If ($Hash -ne $File.Hash)
                {
                    $Message = @(
                    "Exception [!] Type: [{0}]" -f $File.Type;
                    "              File: [{0}]" -f $File.Fullname;
                    "              Hash: [{0}]" -f $File.Hash;
                    "          Mismatch: [{0}]" -f $Hash)

                    Switch ((Get-Host).UI.PromptForChoice($Message,"Replace...?",@("&Yes","&No"),1))
                    {
                        0
                        {
                            $File.Hash = $Hash
                            Write-Host ("Updated [+] File: [{0}]" -f $File.Name)
                            $File.GetContent()
                        }

                        1
                        {
                            Throw ("Exception [!] Hash mismatch, file: [{0}]" -f $File.Name)
                        }
                    }
                }
            }

            $This._Module()
        }
        [Void] _Module()
        {
            # // ===================
            # // | PowerShell Full |
            # // ===================

            If ($This.Root.Resource.Exists)
            {
                # // ==============================
                # // | Cobble together assemblies |
                # // ==============================

                $Bin = "PresentationFramework",
                       "System.Runtime.WindowsRuntime",
                       "System.IO.Compression", 
                       "System.IO.Compression.Filesystem", 
                       "System.Windows.Forms"

                # // =============================================
                # // | Write the module file to disk using PSM() |
                # // =============================================

                [System.IO.File]::WriteAllLines($This.Root.File,
                                                $This.PSM($Bin),
                                                [System.Text.UTF8Encoding]$False)

                # // ====================================
                # // | Splat the Module Manifest params |
                # // ====================================

                $Splat = $This.PSDParam($Bin)

                # // ================================================
                # // | Write the PowerShell module manifest to disk |
                # // ================================================

                New-ModuleManifest @Splat

                $This.Root.Manifest.TestPath()
            }

            # // ===================================================================
            # // | Todo | PS Core | PS Server | <- Just a manner of file selection |
            # // ===================================================================
        }
        [String] PSM([String[]]$Bin)
        {
            $F  = @( )

            # // ==========
            # // | Header |
            # // ==========

            $F += "# Downloaded from {0}" -f $This.Source
            $F += "# {0}" -f $This.Resource
            $F += "# {0}" -f $This.Version.ToString()
            $F += "# <Types>"
            $Bin | % { $F += "Add-Type -AssemblyName $_" }

            # // =============
            # // | Functions |
            # // =============

            $F += "# <Functions>"
            $This.Manifest.Files(1)  | % { 
        
                $F += "# <{0}/{1}>" -f $_.Type, $_.Name
                $F += "# {0}" -f $_.Fullname
                If (!$_.Content)
                {
                    $_.GetContent()
                }
                $F += $_.Content
                $F += "# </{0}/{1}>" -f $_.Type, $_.Name
            }
            $F += "# </Functions>"
            $F += "Write-Theme `"Module [+] [FightingEntropy(`$([Char]960))][$($This.Version)]`" @(10,3,15,0)"

            Return $F -join "`n"
        }
        [Hashtable] PSDParam([String[]]$Bin)
        {
            Return @{  

                GUID                 = $This.GUID
                Path                 = $This.Root.Manifest
                ModuleVersion        = $This.Version
                Copyright            = $This.Copyright
                CompanyName          = $This.Company
                Author               = $This.Author
                Description          = $This.Description
                RootModule           = $This.Root.File
                RequiredAssemblies   = $Bin
            }
        }
        [Object] Validation()
        {
            $This.Write(3,"Validation [~] Module manifest")

            $Validate = [Validate]::New($This)
            $Ct       = $Validate.Output | ? Match -eq 0

            Switch ($Ct.Count)
            {
                {$_ -eq 0}
                {
                    $This.Write(3,"Validation [+] All files passed validation")
                }
                {$_ -gt 0}
                {
                    $This.Write(1,"Validation [!] ($($Ct.Count)) files failed validation")
                    $Ct
                }
            }

            Return $Validate
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.Controller>"
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 
        { 
            [Controller]::New($Mode)
        } 
        1
        {
            [Controller]::New(1).Manifest.Files(0)
        }
        2
        {
            [Controller]::New(1).Manifest.Files(1)
        }
        3
        {
            [Controller]::New(1).Manifest.Files(2)
        }
    }
}
