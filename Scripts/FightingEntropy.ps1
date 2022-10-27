
Function FightingEntropy
{
    # // _________________________________________________________________________________________
    # // | This is an array of character codes that create the desired blocks for the theme/mask |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleThemeFace
    {
        [Object]  $String
        ModuleThemeFace()
        {
    
            $This.String = ("20202020 5F5F5F5F AFAFAFAF 2020202F 5C202020 2020205C 2F202020 5C5F5F2F "+
            "2FAFAF5C 2FAFAFAF AFAFAF5C 5C5F5F5F 5F5F5F2F 205F5F5F" -Split " ") | % { $This.Convert($_) }
        }
        [String] Convert([String]$Line)
        {
            Return [Char[]]@(0,2,4,6 | % { [Convert]::FromHexString($Line.Substring($_,2)) }) -join ''
        }
    }

    # // _____________________________________________________________________
    # // | This is a 1x[track] x 4[char] chunk of information for Write-Host |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleThemeBlock
    {
        [UInt32]   $Index
        [Object]  $String
        [UInt32]    $Fore
        [UInt32]    $Back
        [UInt32]    $Last
        ModuleThemeBlock([Int32]$Index,[String]$String,[Int32]$Fore,[Int32]$Back)
        {
            $This.Index  = $Index
            $This.String = $String
            $This.Fore   = $Fore
            $This.Back   = $Back
            $This.Last   = 1
        }
        [Hashtable] Splat([UInt32[]]$Palette)
        {
            Return @{ 

                Object          = $This.String
                ForegroundColor = @($Palette)[$This.Fore]
                BackgroundColor = $This.Back
                NoNewLine       = $This.Last
            }
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    # // _______________________________________________
    # // | Represents a 1x[track] in a stack of tracks |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleThemeTrack
    {
        [UInt32] $Index
        [Object] $Content
        ModuleThemeTrack([UInt32]$Index,[Object]$Track)
        {
            $This.Index   = $Index
            $This.Content = $Track
        }
        Draw()
        {
            $This.Content | % { 
                
                $Splat = $_.Splat(@(10,12,15,0))
                Write-Host @Splat
            }
        }
        Draw([UInt32[]]$Palette)
        {
            $This.Content | % { 
                
                $Splat = $_.Splat($Palette)
                Write-Host @Splat
            }
        }
    }

    # // _____________________________________________
    # // | Generates an actionable write-host object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        
    Class ModuleThemeStack
    {
        Hidden [Object]  $Face
        Hidden [Object] $Track
        ModuleThemeStack([String]$Message)
        {
            $This.Face   = [ModuleThemeFace]::New().String
            $This.Reset()
            $This.Insert($Message)
            $This.Draw()
        }
        ModuleThemeStack([UInt32]$Color,[String]$Message)
        {
            $Palette = Switch ($Color)
            {
                0 { 10,12,15,00 }
                1 { 10,02,15,00 }
                2 { 14,06,15,00 }
                3 { 12,04,15,00 }
                4 { 11,03,15,00 }
                5 { 11,06,15,00 }
            }
            $This.Face  = [ModuleThemeFace]::New().String
            $This.Reset()
            $This.Insert($Message)
            $This.Draw($Palette)
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
                $Item      = [ModuleThemeBlock]::New($X,$Object[$X],$FG[$X],$BG[$X])
                If ($X -eq $Object.Count-1)
                {
                    $Item.Last = 0
                }
                $Hash.Add($Hash.Count,$Item)
            }
            $This.Track  += [ModuleThemeTrack]::New($This.Track.Count,$Hash[0..($Hash.Count-1)])
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
        Draw()
        {
            $This.Track | % { $_.Draw(@(10,12,15,0))}
        }
        Draw([UInt32[]]$Palette)
        {
            $This.Track | % { $_.Draw($Palette) }
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }
    
    # // ____________________________________________________
    # // | Property object which includes source and index  |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleOSProperty
    {
        [String] $Source
        [UInt32] $Index
        [String] $Name
        [Object] $Value
        ModuleOSProperty([UInt32]$Source,[UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Source = @("Environment","Variable","Host","PowerShell")[$Source]
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return @($This.PSObject.Properties | % { "{0}: [{1}]" -f $_.Name, $_.Value }) -join ', '
        }
    }

    # // _______________________________________________________
    # // | Collects various details about the operating system |
    # // | specifically for cross-platform compatibility       |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleOS
    {
        [Object] $Version
        [Object]    $Type
        [Object]  $Output
        ModuleOS()
        {
            $Hash          = @{ }

            # Environment
            Get-ChildItem Env: | % { $This.Add($Hash,0,$_.Key,$_.Value) }
            
            # Variable
            Get-ChildItem Variable: | % { $This.Add($Hash,1,$_.Name,$_.Value) }

            # Host
            (Get-Host).PSObject.Properties  | % { $This.Add($Hash,2,$_.Name,$_.Value) }
            
            # PowerShell
            (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add($Hash,3,$_.Name,$_.Value) }

            # Assign hashtable to output array
            $This.Output  = $Hash[0..($Hash.Count-1)]
            $This.Version = [Version]($This.Output | ? Name -eq PSVersion | % Value)
            $This.Type    = $This.GetOSType()
        }
        Add([Object]$Hashtable,[UInt32]$Type,[String]$Name,[Object]$Value)
        {
            $Hashtable.Add($Hashtable.Count,[ModuleOSProperty]::New($Type,$Hashtable.Count,$Name,$Value))
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
            Return "[{0}/{1}]" -f $This.Type, $This.Version
        }
    }
    
    # // __________________________________________________________
    # // | Checks individual files for their hash (content/value) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleHash
    {
        [String] $Name
        [String] $Hash
        ModuleHash([Object]$Object)
        {
            $This.Name = $Object.Name
            $This.Hash = Get-FileHash $Object.Fullname | % Hash
        }
        [String] ToString()
        {
            Return "{0}, {1}" -f $This.Name, $This.Hash
        }
    }

    # // ________________________________________________________
    # // | File manifest properties for (collection/validation) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleFile
    {
        Hidden [UInt32]    $Index
        [String]            $Type
        [String]            $Name
        [Object]            $Hash
        [UInt32]          $Exists
        Hidden [String] $Fullname
        Hidden [String]   $Source
        Hidden [Object]  $Content
        ModuleFile([UInt32]$Index,[UInt32]$Type,[String]$Name,[String]$Hash)
        {
            $This.Index  = $Index
            $This.Type   = @("Class","Control","Function","Graphic")[$Type]
            $This.Name   = $Name
            $This.Hash   = $Hash
        }
        [String] Folder()
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
        SetSource([String]$Source)
        {
            $This.Source   = "{0}/blob/main/{1}/{2}?raw=true" -f $Source, $This.Folder(), $This.Name
        }
        SetResource([String]$Resource)
        {
            $This.Fullname = "{0}\{1}\{2}" -f $Resource, $This.Folder(), $This.Name
        }
        AssignContent()
        {
            Try
            {
                $This.Content = Invoke-RestMethod $This.Source
            }
            Catch
            {
                Throw "Exception [!] An unspecified error occurred"
            }
        }
        SetContent()
        {
            If (!$This.Content)
            {
                Throw "Exception [!] Content not assigned, cannot (write/set) content."
            }

            Try
            {
                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    [System.IO.File]::WriteAllBytes($This.Fullname,[Byte[]]$This.Content)
                }
                Else
                {
                    [System.IO.File]::WriteAllLines($This.Fullname,$This.Content,[System.Text.Encoding]::UTF8)
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
                    $This.Content = [System.IO.File]::ReadAllLines($This.Fullname,[System.Text.Encoding]::UTF8)
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error has occurred"
            }
        }
        [String] ToString()
        {
            Return @($This.PSObject.Properties | % { "{0}: [{1}]" -f $_.Name, $_.Value }) -join ', '
        }
    }

    # // _____________________________________________________________________
    # // | File manifest container, laid out for hash (insertion+validation) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleManifest
    {
        Hidden [String]   $Source
        Hidden [String] $Resource
        [Object]          $Output
        ModuleManifest([String]$Source,[String]$Resource)
        {
            $This.Source   = $Source
            $This.Resource = $Resource
            $Hash          = @{ }

            # // ___________
            # // | Classes |
            # // ¯¯¯¯¯¯¯¯¯¯¯

            ("_Cache.ps1"                      , "7530C30D1F61B272D39BE12B0BB93B26301B052819891F23551AC2AA2F114925") ,
            ("_Drive.ps1"                      , "86DCAF296E9DFD05A6030765D40E6B830C9BA956235F86D9F4A871874F581AF1") ,
            ("_Drives.ps1"                     , "B7CFC0271E1FE7ADAC9ACD430ED79A1B46BC117DBCF7D310DE89A78A5D6F10DF") ,
            ("_File.ps1"                       , "4F3DFE27626A658B94C171EE292A3BF7C2EE7E0C8E0F20204BF225D4FED911D9") ,
            ("_FirewallRule.ps1"               , "812F160D050F0F5BC44D98A149CCA8B3E51B5FEA75E6967F871B62F50D0ABB6B") ,
            ("_Icons.ps1"                      , "7B87C1910C239D75FCADC937CE7801340B08BCFC0AF87EBD1A75063E1D017CB7") ,
            ("_Shortcut.ps1"                   , "3A31216D0FAF9D24F30129BDAB915E1EB1D89C6046EB0C9213A7A5B064E76E16") ,
            ("_ViperBomb.ps1"                  , "E2D20F3C730A15DEBAE26EB55B82A2F584C3CB5AD05E2B8EF84305E131148C95") | % { 
                
                $This.Add($Hash,0,$_[0],$_[1])
            }
            
            # // ___________
            # // | Control |
            # // ¯¯¯¯¯¯¯¯¯¯¯

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
                
                $This.Add($Hash,1,$_[0],$_[1])
            }

            # // _____________
            # // | Functions |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯

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
                
                $This.Add($Hash,2,$_[0],$_[1])
            }

            # // ____________
            # // | Graphics |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯

            ("background.jpg"                  , "94FD6CB32F8FF9DD360B4F98CEAA046B9AFCD717DA532AFEF2E230C981DAFEB5") ,
            ("banner.png"                      , "057AF2EC2B9EC35399D3475AE42505CDBCE314B9945EF7C7BCB91374A8116F37") ,
            ("icon.ico"                        , "594DAAFF448F5306B8B46B8DB1B420C1EE53FFD55EC65D17E2D361830659E58E") ,
            ("OEMbg.jpg"                       , "D4331207D471F799A520D5C7697E84421B0FA0F9B574737EF06FC95C92786A32") ,
            ("OEMlogo.bmp"                     , "98BF79CAE27E85C77222564A3113C52D1E75BD6328398871873072F6B363D1A8") ,
            ("PSDBackground.bmp"               , "05ABBABDC9F67A95D5A4AF466149681C2F5E8ECD68F11433D32F4C0D04446F7E") ,
            ("sdplogo.png"                     , "87C2B016401CA3F8F8FAD5F629AFB3553C4762E14CD60792823D388F87E2B16C") | % { 
                
                $This.Add($Hash,3,$_[0],$_[1])
            }

            # // _____________________
            # // | Assign the output |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Output = $Hash[0..($Hash.Count-1)]
        }
        Add([Hashtable]$Hashtable,[UInt32]$Type,[String]$Name,[String]$Hash)
        {
            $Item = [ModuleFile]::New($Hashtable.Count,$Type,$Name,$Hash)
            $Item.SetSource($This.Source)
            $Item.SetResource($This.Resource)
            $Item.TestPath()
            If ($Item.Exists)
            {
                $Item.GetContent()
            }
            $Hashtable.Add($Hashtable.Count,$Item)
        }
        [String] String()
        {
            $Max     = @{ 
                
                Name = ($This.Name | Sort-Object Length)[-1]
                Type = ($This.Type | Sort-Object Length)[-1]
            }

            $Out     = @( )
            ForEach ($Item in $This.Output)
            {
                $T   = $Item.Type
                $N   = $Item.Name
                $H   = $Item.Hash
                If ($T.Length -lt $Max.Type.Length)
                {
                    $T += (" " * ($Max.Type.Length - $T.Length) -join '')
                }
                If ($N.Length -lt $Max.Name.Length)
                {
                    $N += (" " * ($Max.Name.Length - $N.Length) -join '')
                }
                $Out += "$T | $N | $H"
            }

            Return $Out -join "`n"
        }
        [Object] List()
        {
            Return $This.Output
        }
        [String] ToString()
        {
            Return "<FightingEntropy.ModuleManifest>"
        }
    }

    # // ______________________________________
    # // | For file hash integrity mismatches |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleMismatch
    {
        [String] $Type
        [String] $Name
        [Object] $Hash
        [Object] $Property
        ModuleMismatch([String]$Type,[Object]$Hash,[Object]$Property)
        {
            $This.Type     = $Type
            $This.Name     = $Hash.Name
            $This.Hash     = $Hash.Hash
            $This.Property = $Property.Hash
        }
        [String] ToString()
        {
            Return "<FightingEntropy.ModuleMismatch>"
        }
    }

    # // ______________________________________
    # // | For file hash integrity validation |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleIntegrity
    {
        [String] $Base
        [Object] $Files
        [Object] $Manifest
        ModuleIntegrity([String]$Base)
        {
            $This.Base     = $Base
            $This.Files    = @( )
            $This.Manifest = [ModuleManifest]::New()
        }
        [String] Folder([UInt32]$Type)
        {
            Return @("Classes","Control","Functions","Graphics")[$Type]
        }
        [String] Label ([UInt32]$Type)
        {
            Return @("Class","Control","Function","Graphic")[$Type]
        }
        [Object[]] Validate([UInt32]$Type)
        {
            $Hash          = @{ }
            $This.Files    = Get-ChildItem "$($This.Base)\$($This.Folder($Type))" | % { [ModuleHash]::New($_) }
            $Filter        = $This.Manifest.Output | ? Source -eq $This.Label($Type)
            ForEach ($File in $This.Files)
            {
                $Compare   = $Filter | ? Name -eq $File.Name
                If ($Compare.Hash -ne $File.Hash)
                {
                    $Hash.Add($Hash.Count,$This.Mismatch($Type,$File,$Compare))
                }
            }

            Return @(Switch ($Hash.Count)
            {
                {$_ -eq 0} {$Null} {$_ -eq 1} {$Hash[0]} {$_ -gt 1} {$Hash[0..($Hash.Count-1)]}
            })
        }
        [Object] Mismatch([String]$Type,[Object]$Hash,[Object]$Property)
        {
            Return [ModuleMismatch]::New($Type,$Hash,$Property)
        }
        [String] ToString()
        {
            Return "<FightingEntropy.ModuleIntegrity>"
        }
    }

    # // __________________________________________________
    # // | Represents individual paths to the module root |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    Class ModuleRootProperty
    {
        [String] $Type
        [String] $Name
        [String] $Fullname
        [UInt32] $Exists
        Hidden [String] $Path
        ModuleRootProperty([String]$Name,[UInt32]$Type,[String]$Fullname)
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

            If ($This.Exists)
            {
                Throw "Exception [!] Item already exists, overwrite with another method"
            }

            New-Item $This.Fullname -ItemType $This.Type -Verbose
        }
        Delete()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                Throw "Exception [!] Cannot delete an item that does not exist"
            }

            Remove-Item $This.Fullname -Recurse -Verbose -Confirm:$False
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    # // ________________________________________________________
    # // | Represents a collection of paths for the module root |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleRoot
    {
        [Object] $Registry
        [Object] $Resource
        [Object]   $Module
        [Object]     $File
        [Object] $Manifest
        ModuleRoot([String]$Version,[String]$Resource,[String]$Path)
        {
            $This.Registry = $This.Set(0,0,"HKLM:\Software\Policies\Secure Digits Plus LLC\FightingEntropy\$Version")
            $This.Resource = $This.Set(1,0,"$Resource")
            $This.Module   = $This.Set(2,0,"$Path\FightingEntropy")
            $This.File     = $This.Set(3,1,"$Path\FightingEntropy\FightingEntropy.psm1")
            $This.Manifest = $This.Set(4,1,"$Path\FightingEntropy\FightingEntropy.psd1")
        }
        [String] Slot([UInt32]$Type)
        {
            Return @("Registry","Resource","Module","File","Manifest")[$Type]
        }
        [Object] Set([UInt32]$Index,[UInt32]$Type,[String]$Path)
        {
            Return [ModuleRootProperty]::New($This.Slot($Index),$Type,$Path)
        }
        [Void] Refresh()
        {
            $This.List() | % { $_.TestPath() }
        }
        [Object[]] List()
        {
            Return @( $This.PSObject.Properties.Name | % { $This.$_ } )
        }
        [String] ToString()
        {
            Return "<FightingEntropy.ModuleRoot>"
        }
    }

    # // ________________________________________________________
    # // | Represents an individual registry key for the module |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleRegistryKey
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Value
        ModuleRegistryKey([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    # // ___________________________________________________________
    # // | Represents a collection of registry keys for the module |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleRegistry
    {
        [String] $Path
        [Object] $Output
        ModuleRegistry([String]$Path)
        {
            $This.Path   = $Path
            $This.Reset()
        }
        [String[]] Names()
        {
            Return "PSPath","PSParentPath","PSChildName","PSDrive","PSProvider"
        }
        Reset()
        {
            $This.Output = @( )
            $Hash        = @{ }
            $Object      = Get-ItemProperty $This.Path
            ForEach ($Item in $Object.PSObject.Properties | ? Name -notin $This.Names())
            {
                $Hash.Add($Hash.Count,$This.Key($This.Output.Count,$Item.Name,$Item.Value))
            }

            $This.Output = $Hash[0..($Hash.Count-1)]
        }
        [Object] Key([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            Return [ModuleRegistryKey]::New($Index,$Name,$Value)
        }
    }

    # // ______________________________________________________________
    # // | Factory class to control all of the aforementioned classes |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleMain
    {
        [String]      $Source = "https://www.github.com/mcc85s/FightingEntropy"
        [String]        $Name = "[FightingEntropy(π)]"
        [String] $Description = "Beginning the fight against ID theft and cybercrime"
        [String]      $Author = "Michael C. Cook Sr."
        [String]     $Company = "Secure Digits Plus LLC"
        [String]   $Copyright = "(c) 2022 (mcc85s/mcc85sx/sdp). All rights reserved."
        [Guid]          $Guid = "95023676-e2a6-405c-a9d3-dfa548c4d106"
        [DateTime]      $Date = "10/10/2022 17:29:00"
        [Version]    $Version = "2022.10.1"
        [Object]          $OS
        [Object]        $Root
        [Object]    $Manifest
        ModuleMain()
        {
            $This.Guid     = [Guid]"95023676-e2a6-405c-a9d3-dfa548c4d106"
            $This.Date     = [DateTime]"10/10/2022 17:29:00"
            $This.Version  = [Version]"2022.10.1"

            $This.Write("Loading [~] $($This.Label())")
            $This.Main()

            $This
        }
        ModuleMain([UInt32]$New)
        {
            $This.Guid     = [Guid]::NewGuid()
            $This.Date     = [DateTime]::Now.ToString("M/d/yyyy HH:mm:ss")
            $This.Version  = [Version]$This.Version
            $This.Version.Build ++

            $This.Write("Loading [~] $($This.Label())")
            $This.Main()
        }
        [String] Label()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Version.ToString()
        }
        Main()
        {
            $This.OS       = $This.GetOS()
            Write-Host "[+] Operating System"

            $This.Root     = $This.GetRoot()
            Write-Host "[+] Module Root"

            $This.Manifest = $This.GetManifest($This.Source,$This.Root.Resource)
            Write-Host "[+] Module Manifest"
        }
        [Object[]] List()
        {
            Return $This.PSObject.Properties.Name | % { $This.$_ }
        }
        [Object] GetOS()
        {
            Return [ModuleOS]::New()
        }
        [Object] GetRoot()
        {
            $Resource = $Env:ProgramData, $This.Company, "FightingEntropy", $This.Version.ToString() -join "\"
            $Path     = Switch -Regex ($This.OS.Type)
            {
                ^Win32_ { $Env:PSModulePath -Split ";" -match [Regex]::Escape($Env:Windir) }
                Default { $Env:PSModulePath -Split ":" -Match "PowerShell"                 }
            }

            Return [ModuleRoot]::New($This.Version,$Resource,$Path)
        }
        [Object] GetManifest([String]$Source,[String]$Resource)
        {
            Return [ModuleManifest]::New($Source,$Resource)
        }
        [Object] GetRegistry()
        {
            Return [ModuleRegistry]::New($This.Root.Registry)
        }
        [Void] Write([String]$Message)
        {        
            [ModuleThemeStack]::New($Message) > $Null
        }
        [Void] Write([UInt32]$Color,[String]$Message)
        {
            [ModuleThemeStack]::New($Color,$Message) > $Null
        }
        [Void] Remove()
        {
            $This.Write(2,"Removing [~] $($This.Label())")

            ForEach ($Item in "Manifest","File","Module","Resource","Registry")
            {
                Remove-Item $This.Root.$Item -Recurse -Verbose -Confirm:$False
                If ($? -eq $True)
                {
                    Write-Host "Removed [+] $Item"
                }
                Else
                {
                    Write-Warning "Missing [+] $Item"
                }
            }

            $This.Write(2,"Removed [~] $($This.Label())")
        }
        [Void] Install()
        {
            $This.Write(1,"Installing [~] $($This.Label())")
            <#
            $This.Populate()
            [Void] Populate()
            {
                ForEach ($Branch in $This.Registry.Path, $This.Resource.Path)
                {
                    ForEach ($Type in "Classes","Control","Functions","Graphics")
                    {
                        If (!(Test-Path "$Branch\$Type"))
                        {
                            New-Item "$Branch\$Type" -ItemType Directory -Verbose
                        }
                    }
                }
            }
            If ($Type -ne 1)
            {
                $This.TestPath($Path)
            }
            [Void] TestPath ([String]$Path)
            {
                $Test = @( )
                ForEach ($Item in $Path -Split "/")
                {
                    $Test  += $Item
                    $Test -join "/" | % { 

                        If (!(Test-Path $_))
                        {
                            New-Item $_ -ItemType Directory -Verbose
                        }
                    }
                }
            }
            #>
        }
    }

    [ModuleMain]::New()
}

# $Module = FightingEntropy
