
Class CharType
{
    [UInt32] $Index
    [String] $Char
    [UInt32] $Rank
    [String] $Language
    [String] $Meaning
    CharType([UInt32]$Index,[String]$Char)
    {
        $This.Index    = $Index
        $This.Char     = $Char
        $This.Rank     = [UInt32][Char]$Char
    }
    CharType([UInt32]$Index,[UInt32]$Rank,[String]$Language,[String]$Meaning)
    {
        $This.Index    = $Index
        $This.Char     = [Char]$Rank
        $This.Rank     = $Rank
        $This.Language = $Language
        $This.Meaning  = $Meaning
    }
}

Class CharTypeList
{
    [String] $Line
    [Object] $Output
    CharTypeList([String]$Line)
    {
        $This.Line   = $Line
        $This.Output = @( )

        ForEach ($Char in [Char[]]$Line)
        {
            $This.Add($Char)
        }
    }
    CharTypeList([Bool]$Flags)
    {
        $This.Output = @( )
    }
    [Object] CharType([UInt32]$Index,[String]$Char)
    {
        Return [CharType]::New($Index,$Char)
    }
    [Object] CharType([UInt32]$Index,[UInt32]$Rank,[String]$Language,[String]$Meaning)
    {
        Return [CharType]::New($Index,$Rank,$Language,$Meaning)
    }
    Add([String]$Char)
    {
        $This.Output += $This.CharType($This.Output.Count,$Char)
    }
    Add([UInt32]$Index,[UInt32]$Rank,[String]$Language)
    {
        $Split   = $Language -Split " "
        If ($Language -notmatch " ")
        {
            $Meaning = $Null
        }
        Else
        {
            $Language, $Meaning = $Language -Split " "
        }
        $This.Output += $This.CharType($Index,$Rank,$Language,$Meaning)
    }
}

$Line = "ӂ嘀瓿తhܶ栁㚜ćꑨܶ樁栂⼀ā遨Ě樁！⑴跥￿୴桖ƶâ귨﻽诿廆ࣂ谼￿譕菬㓬斃ü橖￿ၵ䖍僼廨ﾌ藿痀븒耇桖ƶɂ痨﻽譵ࡅ㢃＀ᡵ䉴䶋褌푍䶋觼䶋樔褈䶍凌ͪժ晐䗇ό昀䗇ࣜ昀䗇Ϭ观￿ぴ桖ƶə곫痿謔р痿诼（౵ｐけၴɨ܀嚀뙨昁ﴒ￾綃üॴ痿￼謁廆싉譕菬擬斃ü噓䖍僬ᗿᐐĀ疋茘Ǿ⑴ﺃ琂縛茉Ӿѿࡪ᛫垾܀嚀덨䔁Ý"
$List = [CharTypeList]::New($False)



Index Char  Rank Type      Meaning
----- ----  ---- ----      -------
    0 ӂ     1218 Russian   ?
    1 嘀    22016 Chinese Si backbite
    2 瓿    29951 Chinese Si jar
    3 త     3108 Telugu  t
    4 h      104 ?         h
    5 ܶ     1846 English
    6 栁    26625 Chinese Si Chestnut
    7 㚜    13980 Chinese Si ?
    8 ć      263 Croatian ?
    9 ꑨ    42088 English ?
   10 ܶ     1846 English ?
   11 樁    27137 Chinese Tr   pile / zhuāng
   12 栂    26626 Japanese Toga
   13 ⼀    12032  ?       ?
   14 ā      257 Latvian  ?
   15 遨    36968 Chinese Si ramble / áo
   16 Ě      282 Czech     ?
   17 樁    27137 Chinese Tr   pile / zhuāng
   18 ！    65281 English
   19 ⑴     9332 
   20     59432
   21 跥    36325 Chinese Si wow/duò
   22 ￿    65535
   23     61579
   24     63109
   25 ୴     2932
   26 桖    26710
   27 ƶ      438
   28 â      226     
   29 귨    44520
   30 ﻽    65277
   31 诿    35839
   32 廆    24262
   33 ࣂ     2242
   34     59648
   35 谼    35900
   36 ￿    65535
   37 譕    35669
   38 菬    33772
   39 㓬    13548     
   40 斃    25987
   41 ü      252
   42 橖    27222
   43 ￿    65535
   44 ၵ     4213
   45 䖍    17805
   46 僼    20732
   47 廨    24296
   48 ﾌ    65420
   49 藿    34303
   50 痀    30144
   51 븒    48658
   52 ♫       14
   53 耇    32775
   54 桖    26710
   55 ƶ      438
   56 ɂ      578
   57 痨    30184
   58 ﻽    65277
   59     60415
   60 譵    35701
   61 ࡅ     2117
   62 㢃    14467
   63 ＀    65280     
   64 ᡵ     6261
   65 䉴    17012
   66 䶋    19851
   67 褌    35084
   68 푍    54349
   69 䶋    19851
   70 觼    35324
   71     58445
   72 䶋    19851
   73 樔    27156
   74 褈    35080
   75     62541
   76 䶍    19853
   77 凌    20940
   78 ͪ      874
   79 ժ     1386
   80 晐    26192
   81 䗇    17863
   82 ό      972
   83 昀    26112
   84 䗇    17863
   85 ࣜ     2268     
   86 昀    26112
   87 䗇    17863
   88 Ϭ     1004
   89     59392
   90 观    35266
   91 ￿    65535
   92     61579
   93     63109
   94 ぴ    12404
   95 桖    26710
   96 ƶ      438
   97 ə      601
   98 곫    44267
   99 痿    30207     
  100 謔    35604
  101 р     1088
  102 痿    30207
  103 诼    35836
  104 （    65288
  105 ౵     3189
  106 ｐ    65360
  107 け    12369
  108     61579
  109     63109
  110 ၴ     4212
  111 ɨ      616
  112 ܀     1792
  113 嚀    22144
  114 뙨    46696
  115 昁    26113
  116     59394
  117 ﴒ    64786
  118 ￾    65534
  119 綃    32131
  120 ü      252     
  121 ॴ     2420
  122 痿    30207
  123 ￼    65532
  124     63509     
  125 ‼       19
  126 謁    35585
  127 廆    24262
  128 싉    49865
  129 ¶       20
  130 譕    35669
  131 菬    33772
  132 擬    25836     
  133 斃    25987
  134 ü      252
  135 噓    22099
  136 䖍    17805
  137 僬    20716
  138 ᗿ     5631
  139 ᐐ     5136
  140 Ā      256
  141 疋    30091
  142 茘    33560     
  143 Ǿ      510
  144 ⑴     9332
  145 ﺃ    65155
  146 琂    29698
  147 縛    32283
  148 茉    33545
  149 Ӿ     1278
  150 ѿ     1151
  151 ࡪ     2154
  152 ᛫     5867
  153 垾    22462
  154 ܀     1792
  155 嚀    22144
  156 덨    45928
  157 䔁    17665     
  158     59648
  159 Ý      221


(   52,       14, "English"),
(  125,       19, "English"),
(  129,       20, "English"),
(    4,      104, "English"),
(   55,      438, "English"),
(   27,      438, "English"),
(   96,      438, "English"),
(  143,      510, "English"),
(   56,      578, "English"),
(   97,      601, "English"),
(  111,      616, "English"),
(   78,      874, "English"),
(   88,     1004, "English"),
(  154,     1792, "English"),
(  112,     1792, "English"),
(   10,     1846, "English"),
(    5,     1846, "English"),
(   61,     2117, "English"),
(  151,     2154, "English"),
(   33,     2242, "English"),
(   85,     2268, "English"),
(  121,     2420, "English"),
(   25,     2932, "English"),
(    3,     3108, "English"),
(  105,     3189, "English"),
(  110,     4212, "English"),
(   44,     4213, "English"),
(  139,     5136, "English"),
(  138,     5631, "English"),
(  152,     5867, "English"),
(   64,     6261, "English"),
(   19,     9332, "English"),
(  144,     9332, "English"),
(   13,    12032, "English"),
(  107,    12369, "English"),
(   94,    12404, "English"),
(  101,     1088, "Ukrainian R"),
(  150,     1151, "Russian"),
(    0,     1218, "Russian"),
(  149,     1278, "Russian"),
(   79,     1386, "Armenian"),
(   82,      972, "Greek whatever"),
(   28,      226, "Welsh"),
(  120,      252, "German"),
(   41,      252, "German"),
(  134,      252, "German"),
(  140,      256, "Latvian"),
(   14,      257, "Latvian"),
(    8,      263, "Croatian"),
(   16,      282, "Czech"),
(    9,    42088, "Unknown"),
(  159,      221, "Vietnamese"),
(   39,    13548, "Chinese -"),
(    7,    13980, "Chinese -"),
(   62,    14467, "Chinese high"),
(   65,    17012, "Chinese wow"),
(  157,    17665, "Chinese Qi"),
(  136,    17805, "Chinese Gong"),
(   45,    17805, "Chinese Gong"),
(   81,    17863, "Chinese earthworm"),
(   84,    17863, "Chinese earthworm"),
(   87,    17863, "Chinese earthworm"),
(   66,    19851, "Chinese sound"),
(   69,    19851, "Chinese sound"),
(   72,    19851, "Chinese sound"),
(   76,    19853, "Chinese sneeze"),
(  137,    20716, "Chinese clever/jiāo"),
(   46,    20732, "Chinese Huh/fēng"),
(   77,    20940, "Chinese insult/líng"),
(    1,    22016, "Chinese backbite/dī"),
(  135,    22099, "Chinese hush/xū"),
(  155,    22144, "Chinese enjoin/níng"),
(  113,    22144, "Chinese enjoin/níng"),
(  153,    22462, "Chinese Fall/àn"),
(  127,    24262, "Chinese stable/jiù"),
(   32,    24262, "Chinese stable/jiù"),
(   47,    24296, "Chinese government office/xiè"),
(  132,    25836, "Chinese draft/nǐ"),
(   40,    25987, "Chinese Shoot/bì"),
(  133,    25987, "Chinese Shoot/bì"),
(   86,    26112, "Chinese Yun/yún"),
(   83,    26112, "Chinese Yun/yún"),
(  115,    26113, "Chinese Huh/bèi"),
(   80,    26192, "Chinese Dawn/gāi"),
(    6,    26625, "Chinese Chestnut/liǔ"),
(   12,    26626, "Chinese Toga/toga"),
(   95,    26710, "Chinese Whether/xuè"),
(   26,    26710, "Chinese Whether/xuè"),
(   54,    26710, "Chinese Whether/xuè"),
(   11,    27137, "Chinese pile/zhuāng"),
(   17,    27137, "Chinese pile/zhuāng"),
(   73,    27156, "Chinese Tree/chāo"),
(   42,    27222, "Chinese Chop/chēng"),
(  146,    29698, "Chinese Qi/yán"),
(    2,    29951, "Chinese jar/bù"),
(  141,    30091, "Chinese Bunkers/pǐ"),
(   50,    30144, "Chinese hunchback/jū"),
(   57,    30184, "Chinese tuberculosis/láo"),
(   99,    30207, "Chinese paralysis/wěi"),
(  122,    30207, "Chinese paralysis/wěi"),
(  102,    30207, "Chinese paralysis/wěi"),
(  119,    32131, "Chinese Silk/xiāo"),
(  147,    32283, "Chinese tie/fù"),
(   53,    32775, "Chinese Hip/gǒu"),
(  148,    33545, "Chinese Mo/mò"),
(  142,    33560, "Chinese Rhizoma/lì"),
(  131,    33772, "Chinese Naps/qiáo"),
(   38,    33772, "Chinese Naps/qiáo"),
(   49,    34303, "Chinese Patchouli/huò"),
(   74,    35080, "Chinese Pleats/chōng"),
(   67,    35084, "Chinese loincloth"),
(   90,    35266, "Chinese see/guān"),
(   70,    35324, "Chinese buckle/jué"),
(  126,    35585, "Chinese visit/yè"),
(  100,    35604, "Chinese Sneer/xuè"),
(  130,    35669, "Chinese Shun/mó"),
(   37,    35669, "Chinese Shun/mó"),
(   60,    35701, "Chinese Ochre/duì"),
(  103,    35836, "Chinese Whoops/zhuó"),
(   31,    35839, "Chinese Yikes/wěi"),
(   35,    35900, "Chinese Oh/hóng"),
(   21,    36325, "Chinese Wow/duò"),
(   15,    36968, "Chinese ramble/áo"),
(   98,    44267, "Korean Cape/golp"),
(   29,    44520, "Korean Guin/gyukh"),
(  156,    45928, "Korean Dyan/deoss"),
(  114,    46696, "Korean Wow/ttoen"),
(   51,    48658, "Korean Boom/beunh"),
(  128,    49865, "Korean -/suilk"),
(   68,    54349, "Korean Fook/poej"),
(   48,    65420, "Japanese"),
(  145,    65155, "Arabic"),
(   44,     4213, "Burmese"),
(  139,     5136, "Inuktitut"),
(  138,     5631, "Inuktitut"),
(18, 65281, "English"),
(20, 59432, "-"),
(22, 65535, "-"),
(23, 61579, "-"),
(24, 63109, "-"),
(30, 65277, "-"),
(34, 59648, "-"),
(36, 65535, "-"),
(43, 65535, "-"),
(58, 65277, "-"),
(59, 60415, "-"),
(63, 65280, "-"),
(71, 58445, "-"),
(75, 62541, "-"),
(89, 59392, "-"),
(91, 65535, "-"),
(92, 61579, "-"),
(93, 63109, "-"),
(104, 65288, "English"),
(106, 65360, "English"),
(108, 61579, "-"),
(109, 63109, "-"),
(116, 59394, "-"),
(117, 64786, "-"),
(118, 65534, "-"),
(123, 65532, "-"),
(124, 63509, "-"),
(158, 59648, "-") | % { 

    $List.Add($_[0],$_[1],$_[2])
}

$List.Output = $List.Output | Sort-Object Index

Index Char  Rank Type Language   Meaning
----- ----  ---- ---- --------   -------               
    0 ӂ     1218      Russian                          
    1 嘀    22016      Chinese    backbite/dī
    2 瓿    29951      Chinese    jar/bù
    3 త     3108      English                          
    4 h      104      English                          
    5 ܶ     1846      English                          
    6 栁    26625      Chinese    Chestnut/liǔ
    7 㚜    13980      Chinese    -
    8 ć      263      Croatian                         
    9 ꑨ    42088      Unknown
   10 ܶ     1846      English                          
   11 樁    27137      Chinese    pile/zhuāng
   12 栂    26626      Chinese    Toga/toga
   13 ⼀    12032      English
   14 ā      257      Latvian                          
   15 遨    36968      Chinese    ramble/áo
   16 Ě      282      Czech                            
   17 樁    27137      Chinese    pile/zhuāng
   18 ！    65281      English
   19 ⑴     9332      English                          
   20     59432      -                                
   21 跥    36325      Chinese    Wow/duò
   22 ￿    65535      -
   23     61579      -
   24     63109      -
   25 ୴     2932      English
   26 桖    26710      Chinese    Whether/xuè
   27 ƶ      438      English
   28 â      226      Welsh
   29 귨    44520      Korean     Guin/gyukh
   30 ﻽    65277      -
   31 诿    35839      Chinese    Yikes/wěi
   32 廆    24262      Chinese    stable/jiù
   33 ࣂ     2242      English
   34     59648      -
   35 谼    35900      Chinese    Oh/hóng
   36 ￿    65535      -
   37 譕    35669      Chinese    Shun/mó
   38 菬    33772      Chinese    Naps/qiáo
   39 㓬    13548      Chinese    -
   40 斃    25987      Chinese    Shoot/bì
   41 ü      252      German
   42 橖    27222      Chinese    Chop/chēng
   43 ￿    65535      -
   44 ၵ     4213      English
   44 ၵ     4213      Burmese
   45 䖍    17805      Chinese    Gong
   46 僼    20732      Chinese    Huh/fēng
   47 廨    24296      Chinese    government office/xiè
   48 ﾌ    65420      Japanese
   49 藿    34303      Chinese    Patchouli/huò
   50 痀    30144      Chinese    hunchback/jū
   51 븒    48658      Korean     Boom/beunh
   52 ♫       14      English
   53 耇    32775      Chinese    Hip/gǒu
   54 桖    26710      Chinese    Whether/xuè
   55 ƶ      438      English
   56 ɂ      578      English
   57 痨    30184      Chinese    tuberculosis/láo
   58 ﻽    65277      -
   59     60415      -
   60 譵    35701      Chinese    Ochre/duì
   61 ࡅ     2117      English
   62 㢃    14467      Chinese    high
   63 ＀    65280      -
   64 ᡵ     6261      English
   65 䉴    17012      Chinese    wow
   66 䶋    19851      Chinese    sound
   67 褌    35084      Chinese    loincloth
   68 푍    54349      Korean     Fook/poej
   69 䶋    19851      Chinese    sound
   70 觼    35324      Chinese    buckle/jué
   71     58445      -
   72 䶋    19851      Chinese    sound
   73 樔    27156      Chinese    Tree/chāo
   74 褈    35080      Chinese    Pleats/chōng
   75     62541      -
   76 䶍    19853      Chinese    sneeze
   77 凌    20940      Chinese    insult/líng
   78 ͪ      874      English
   79 ժ     1386      Armenian
   80 晐    26192      Chinese    Dawn/gāi
   81 䗇    17863      Chinese    earthworm
   82 ό      972      Greek      whatever
   83 昀    26112      Chinese    Yun/yún
   84 䗇    17863      Chinese    earthworm
   85 ࣜ     2268      English
   86 昀    26112      Chinese    Yun/yún
   87 䗇    17863      Chinese    earthworm
   88 Ϭ     1004      English
   89     59392      -
   90 观    35266      Chinese    see/guān
   91 ￿    65535      -
   92     61579      -
   93     63109      -
   94 ぴ    12404      English
   95 桖    26710      Chinese    Whether/xuè
   96 ƶ      438      English
   97 ə      601      English
   98 곫    44267      Korean     Cape/golp
   99 痿    30207      Chinese    paralysis/wěi
  100 謔    35604      Chinese    Sneer/xuè
  101 р     1088      Ukrainian  R
  102 痿    30207      Chinese    paralysis/wěi
  103 诼    35836      Chinese    Whoops/zhuó
  104 （    65288      English
  105 ౵     3189      English
  106 ｐ    65360      English
  107 け    12369      English
  108     61579      -
  109     63109      -
  110 ၴ     4212      English
  111 ɨ      616      English
  112 ܀     1792      English
  113 嚀    22144      Chinese    enjoin/níng
  114 뙨    46696      Korean     Wow/ttoen
  115 昁    26113      Chinese    Huh/bèi
  116     59394      -
  117 ﴒ    64786      -
  118 ￾    65534      -
  119 綃    32131      Chinese    Silk/xiāo
  120 ü      252      German
  121 ॴ     2420      English
  122 痿    30207      Chinese    paralysis/wěi
  123 ￼    65532      -
  124     63509      -
  125 ‼       19      English
  126 謁    35585      Chinese    visit/yè
  127 廆    24262      Chinese    stable/jiù
  128 싉    49865      Korean     -/suilk
  129 ¶       20      English
  130 譕    35669      Chinese    Shun/mó
  131 菬    33772      Chinese    Naps/qiáo
  132 擬    25836      Chinese    draft/nǐ
  133 斃    25987      Chinese    Shoot/bì
  134 ü      252      German
  135 噓    22099      Chinese    hush/xū
  136 䖍    17805      Chinese    Gong
  137 僬    20716      Chinese    clever/jiāo
  138 ᗿ     5631      Inuktitut
  138 ᗿ     5631      English
  139 ᐐ     5136      Inuktitut
  139 ᐐ     5136      English
  140 Ā      256      Latvian
  141 疋    30091      Chinese    Bunkers/pǐ
  142 茘    33560      Chinese    Rhizoma/lì
  143 Ǿ      510      English
  144 ⑴     9332      English
  145 ﺃ    65155      Arabic
  146 琂    29698      Chinese    Qi/yán
  147 縛    32283      Chinese    tie/fù
  148 茉    33545      Chinese    Mo/mò
  149 Ӿ     1278      Russian
  150 ѿ     1151      Russian
  151 ࡪ     2154      English
  152 ᛫     5867      English
  153 垾    22462      Chinese    Fall/àn
  154 ܀     1792      English
  155 嚀    22144      Chinese    enjoin/níng
  156 덨    45928      Korean     Dyan/deoss
  157 䔁    17665      Chinese    Qi
  158     59648      -
  159 Ý      221      Vietnamese
