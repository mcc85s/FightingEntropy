#  [lvlworld2.cfg]

Class MapItem
{
    [UInt32]       $Index
    [String]        $Name
    Hidden [UInt32] $Mode
    [String]      $Rating
    MapItem([UInt32]$Index,[String]$Name)
    {
        $This.Index = $Index
        $This.Name  = $Name
    }
    MapItem([UInt32]$Index,[String]$Name,[String]$Rating)
    {
        $This.Index = $Index
        $This.Name  = $Name
        $This.Mode ++
        $This.SetRating($Rating)
    }
    SetRating([String]$Rating)
    {
        $This.Rating = $Rating
    }
    [String] ToString()
    {
        Return @($This.Name;"{0}/({1})" -f $This.Name, $This.Rating)[$This.Mode]
    }
}

Class MapList
{
    [String]   $Name
    [String]   $Path
    [Object] $Config
    [Object] $Output
    MapList([String]$Name,[String]$Path)
    {
        $This.Name   = $Name
        $This.Path   = $Path
        $This.Config = $Null
        $This.Clear()
    }
    Clear()
    {
        $This.Output  = @( )
    }
    [Object] MapItem([UInt32]$Index,[String]$Name)
    {
        Return [MapItem]::New($Index,$Name)
    }
    [Object] MapItem([UInt32]$Index,[String]$Name,[String]$Rating)
    {
        Return [MapItem]::New($Index,$Name,$Rating)
    }
    [UInt32] GetRandom([UInt32]$Max)
    {
        Return Get-Random -Maximum $Max
    }
    Randomize()
    {
        $Total = $This.Output.Count
        $Out   = @( )
        ForEach ($X in 0..($Total-1))
        {
            Do
            {
                $Number = $This.GetRandom($Total)
            }
            Until ($Number -notin $Out)

            $Out += $Number
        }

        ForEach ($X in 0..($Total-1))
        {
            $This.Output[$X].Index = $Out[$X]
        }

        $This.Output = $This.Output | Sort-Object Index
    }
    Add([String]$Name,[String]$Rating)
    {
        $Item         = $This.MapItem($This.Output.Count,$Name,$Rating)

        [Console]::WriteLine($Item)

        $This.Output += $Item
    }
    SetRating([String]$Name,[String]$Rating)
    {
        $Item = $This.Output | ? Name -eq $Name
        If ($Item)
        {
            $Item.SetRating($Rating)
        }
    }
    WriteConfig()
    {
        $Total       = $This.Output.Count
        $This.Config = @("set g_gametype 0;","set fraglimit 10;","set timelimit 0;")

        ForEach ($X in 0..($Total-1))
        {
            $Item    = $This.Output[$X]
            $NextMap = Switch ($X)
            {
                {$_ -ne ($Total-1)}
                {
                    "lvl{0}" -f ($X + 1)
                }
                {$_ -eq ($Total-1)}
                {
                    "lvl0"
                }
            }

            $This.Config += "seta lvl$X `"map $($Item.Name); kick allbots; addbot hunter 5; set nextmap vstr $NextMap`""
        }

        $This.Config += "vstr lvl0"

        [System.IO.File]::WriteAllLines($This.Path,$This.Config)
    }
    ReadConfig()
    {
        $This.Config = [System.IO.File]::ReadAllLines($This.Path)
    }
    [String] ToString()
    {
        Return "<Map Controller>"
    }
}

# [Initial variables]
$Directory = "C:\Program Files (x86)\Quake III Arena\baseq3"

# Start-Process $Directory
$Name      = "lvlworld2.cfg"
$Target    = "$Directory\$Name"

# [Map controller]
$Ctrl      = [MapList]::New($Name,$Target)

# [Desired maps]
("hub3aeroq3"     , "10/10") ,
("phantq3dm1_rev" , "10/10") ,
("storm3tourney2" , "9/10")  ,
("mrcq3t6"        , "10/10") ,
("20kdm2"         , "7/10")  ,
("unitooldm6"     , "7/10")  ,
("unitooldm4"     , "7/10")  ,
("tymo3dm5"       , "8/10")  ,
("ts_t6"          , "9/10")  ,
("ts_dm4"         , "9/10")  ,
("storm3tourney5" , "9/10")  ,
("storm3tourney1" , "7/10")  ,
("rota3dm4"       , "7/10")  ,
("rota3dm3"       , "9/10")  ,
("rdogdm4"        , "10/10") ,
("pukka3tourney6" , "9/10")  ,
("mrcq3t4"        , "8/10")  ,
("wvwq3dm6"       , "8/10")  ,
("uzul3"          , "8/10")  ,
("qfraggel3ffa"   , "8/10")  ,
("acid3dm9"       , "10/10") ,
("lun3_20b1"      , "7/10")  ,
("lun3dm2"        , "10/10") ,
("kamq3dm2"       , "8/10")  ,
("jof3dm2"        , "10/10") ,
("ik3dm2"         , "9/10")  ,
("geit3dm6"       , "7/10")  ,
("fr3dm1"         , "11/10") ,
("dubenigma"      , "9/10")  ,
("devdm3"         , "10/10") ,
("storm3tourney8" , "7/10")  ,
("pro-q3tourney7" , "7/10")  ,
("hub3dm1"        , "11/10") ,
("auh3dm1"        , "8/10") ,
("ztn3dm1"        , "11/10") ,
("ztn3dm2"        , "10/10") ,
("tig_den"        , "10/10") | % {

    $Ctrl.Add($_[0],$_[1])
}

$Ctrl.Randomize()
$Ctrl.WriteConfig()

$Directory = "${Env:ProgramFiles(x86)}\Quake III Arena"

$Splat     = @{

    Filepath         = "{0}\quake3.exe" -f $Directory
    ArgumentList     = "+exec lvlworld2.cfg"
    WorkingDirectory = $Directory
}

Start-Process @Splat

<# [Unselected]
    trespass
    shibam
    rustgrad
    rota3dm2
    q3tbdm3
    q3nem06
    q3gwdm2
    q3gwdm1
    q3dmp23
    pukka3tourney7
    pukka3tourney2
    pom_bots
    necro6
    estatica
    lun3dm5
    goldleaf
    focal_p132
    ct3tourney3
    ct3tourney2
#>
