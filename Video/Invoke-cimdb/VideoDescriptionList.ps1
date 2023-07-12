# A little script to keep things nice and tidy.

Enum VideoDisplayNameType
{
    I
    II
    III
    IV
    V
    VI
    VII
    VIII
    IX
    X
    XI
    XII
    XIII
    XIV
    XV
    XVI
    XVII
    XVIII
    XIX
    XX
    XXI
    XXII
    XXIII
    XXIV
    XXV
    XXVI
    XXVII
    XXVIII
    XXIX
    XXX
    XXXI
    XXXII
    XXXIII
    XXXIV
    XXXV
    XXXVI
    XXXVII
    XXXVIII
    XXXIX
    XL
    XLI
    XLII
    XLIII
    XLIV
    XLV
    XLVI
    XLVII
    XLVIII
    XLIX
    L
    LI
    LII
    LIII
    LIV
    LV
    LVI
    LVII
    LVIII
    LIX
    LX
    LXI
    LXII
    LXIII
    LXIV
    LXV
    LXVI
    LXVII
    LXVIII
    LXIX
    LXX
    LXXI
    LXXII
    LXXIII
    LXXIV
    LXXV
    LXXVI
    LXXVII
    LXXVIII
    LXXIX
    LXXX
    LXXXI
    LXXXII
    LXXXIII
    LXXXIV
    LXXXV
    LXXXVI
    LXXXVII
    LXXXVIII
    LXXXIX
    XC
    XCI
    XCII
    XCIII
    XCIV
    XCV
    XCVI
    XCVII
    XCVIII
    XCIX
    C
}

Class VideoDisplayNameItem
{
    [UInt32] $Index
    [String] $Name
    [String] $DisplayName
    [UInt32] $Rank
    VideoDisplayNameItem([UInt32]$Index)
    {
        $This.Index       = $Index
        $This.Name        = [VideoDisplayNameType]$Index
        $This.DisplayName = "Part {0}" -f $This.Name
        $This.Rank        = $Index + 1
    }
}

Class VideoDisplayNameList
{
    [Object] $Output
    VideoDisplayNameList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] VideoDisplayNameItem([UInt32]$Index)
    {
        Return [VideoDisplayNameItem]::New($Index)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($X in 0..99)
        {
            $This.Output += $This.VideoDisplayNameItem($X)
        }
    }
    [String] ToString()
    {
        Return "<VideoDisplayNameList>"
    }
}

# Suppose I want to extract them all into an object...
Class ComVideoFile
{
    [UInt32]           $Index
    Hidden [String]     $Name
    Hidden [String] $Fullname
    [String]     $DisplayName
    [String]            $Date
    [String]        $Resource
    [TimeSpan]        $Length
    ComVideoFile([UInt32]$Index,[Object]$File)
    {
        $This.Index       = $Index
        $This.Name        = $File.Name
        $This.Fullname    = $File.Path
        $This.Date        = $File.ModifyDate.ToString("MM/dd/yy")
        $This.Length      = $File.Parent.GetDetailsOf($File,27)
    }
    [String] ToString()
    {
        Return $This.DisplayName
    }
}

# Suppose I want to turn all of that information into a parent class
Class ComVideoFolder
{
    Hidden [Object]  $Slot
    [String]         $Name
    [String]         $Path
    Hidden [Object] $Shell
    [Object]       $Output
    ComVideoFolder([String]$Name,[String]$Path)
    {
        If (![System.IO.Directory]::Exists($Path))
        {
            Throw "Invalid path"
        }

        $This.Slot   = [VideoDisplayNameList]::New()
        $This.Name   = $Name
        $This.Path   = $Path
        $This.Shell  = $This.NewShell()
        $This.Output = @( )
        
        ForEach ($File in @($This.Shell.NameSpace($This.Path).Items()))
        {
            $Item             = $This.ComVideoFile($This.Output.Count,$File)
            $Item.DisplayName = $This.Slot.Output | ? Index -eq $Item.Index | % DisplayName
            $Item.Resource    = Switch ($Item.Index)
            {
                0 { "https://youtu.be/Z5V18nlsSt4" }
                1 { "https://youtu.be/I_mydf6mjuk" }
                2 { "https://youtu.be/0ceIJhGCTnI" }
                3 { "https://youtu.be/hTqIO2rro34" }
                4 { "https://youtu.be/kvMrFEOXMBY" }
                5 { "https://youtu.be/K4VIKy2oFRY" }
                6 { "https://youtu.be/Sh3I0MemkqU" }
                7 { "https://youtu.be/mxYJz5NWtRI" }
                8 { "https://youtu.be/HFgXGvxp1nM" }
                9 { "https://youtu.be/O8EpeXCzdS4" }
               10 { "https://youtu.be/uWoDIJ00T9g" }
               11 { "https://youtu.be/SeR_FqwKioM" }
               12 { "https://youtu.be/HTkN1bKkKk0" }
               13 { "https://youtu.be/_t_Bt_Ni_aY" }
               14 { "https://youtu.be/cHmr6nOBuMc" }
               15 { "https://youtu.be/ONexPjMMNME" }
               16 { "https://youtu.be/fed5gbA32lo" }
            }

            $This.Output += $Item
        }
    }
    [Object] NewShell()
    {
        Return New-Object -ComObject Shell.Application
    }
    [Object] ComVideoFile([UInt32]$Index,[Object]$File)
    {
        Return [ComVideoFile]::New($Index,$File)
    }
}

$Name  = "Invoke-cimdb"
$Path  = "\\172.16.0.1\Transfer\$Name"
$Video = [ComVideoFolder]::New($Name,$Path)
