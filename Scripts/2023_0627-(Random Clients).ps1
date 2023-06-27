Class TestCriteria
{
    [UInt32]           $Index
    [String[]]          $Name
    [String[]] $StreetAddress
    [UInt32]          $Gender
    [UInt32[]]           $Dob
    [String]           $Phone
    [String]           $Email
    TestCriteria([UInt32]$Index,[String]$Name,[String]$StreetAddress,[UInt32]$Gender,[String]$Dob,[String]$Phone,[String]$Email)
    {
        $This.Index         = $Index
        $This.Name          = $This.SplitName($Name)
        $This.StreetAddress = $This.SplitAddress($StreetAddress)
        $This.Gender        = $Gender
        $This.Dob           = $This.SplitDob($Dob)
        $This.Phone         = $Phone
        $This.Email         = $Email
    }
    [String[]] SplitName([String]$String)
    {
        $Split = $String -Split " "
        $Out   = @{ }
        $Out.Add(0,$Split[0])
        $Out.Add(1,$Split[1])
        $Out.Add(2,$Split[2])

        Return $Out[0..2]
    }
    [String[]] SplitAddress([String]$String)
    {
        $Split0 = $String -Split "\|"

        $Out    = @{ }
        $Out.Add(0,$Split0[0])

        $Split1 = $Split0[1] -Split ", "
        $Out.Add(1,$Split1[0])

        $Split2 = $Split1[1] -Split " "

        $Out.Add(2,$Split2[0])
        $Out.Add(3,$Split2[1])
        $Out.Add(4,"US")

        Return $Out[0..4]
    }
    [UInt32[]] SplitDob([String]$String)
    {
        Return $String -Split "\/"
    }
}

$Names = "Laylah Y Khan",
"Kendrick M Tang",
"Belle X James",
"Jaxson C Hahn",
"Fallon B Odom",
"Kylian P Rangel",
"Gloria Y Archer",
"Ephraim Q Hardin",
"Vada R Burch",
"Gerald A Ali",
"Zelda M Hart",
"Joel E Andersen",
"Zoie E Farley",
"Graysen D Hicks",
"Alina Q Bowers",
"Dorian X Andersen",
"Zoie T Haley",
"Leif Y Cantrell",
"Yamileth A Cross",
"Fabian G Robbins",
"Stevie A Cantu",
"Anakin I Schmidt",
"Kimberly G Leach",
"Westin W Day",
"Hayden M Fletcher",
"Jay L Mullins",
"Maliyah Y Mercado",
"Abram J Kerr",
"Baylee C Hobbs",
"Brendan K Houston",
"Lylah D Pollard",
"Jad D Blankenship",
"Rosalee S Avila",
"Jaylen O Gillespie",
"Alianna W Nicholson",
"Rodrigo R Nichols",
"Aliyah M Barry",
"Emery X Franco",
"Charleigh F Bryan",
"Jaxtyn N Wilkins",
"Amalia G Sexton",
"Mylo U Stout",
"Chana P McCarthy",
"Devin O Beasley",
"Jaylah M Potter",
"Lucca W Rowe",
"Matilda G Kennedy",
"Maxwell U Reynolds"

$Addresses = "9450 Paris Hill Dr.|Fairburn, GA 30213",
"76 Catherine Dr.|Danville, VA 24540",
"75 West Drive|Lithonia, GA 30038",
"745 East Monroe Court|Nottingham, MD 21236",
"9877 Gartner Ave.|Skokie, IL 60076",
"40 Woodland Street|Jacksonville, NC 28540",
"942 Westminster Street|Crofton, MD 21114",
"8 Parker Lane|Brookfield, WI 53045",
"7191 Campfire Street|Birmingham, AL 35209",
"2 Linden Ave.|Milwaukee, WI 53204",
"9320 Lincoln St.|Frederick, MD 21701",
"8917 East Halifax Street|Ogden, UT 84404",
"911 Philmont Rd.|Waxhaw, NC 28173",
"6 Harrison St.|Whitestone, NY 11357",
"910 West Summerhouse Dr.|Morrisville, PA 19067",
"7958 Mayfair Court|Bolingbrook, IL 60440",
"205 Pilgrim Ave.|Snohomish, WA 98290",
"7443 Glenholme Street|Macomb, MI 48042",
"458 El Dorado St.|Cedar Rapids, IA 52402",
"449 Beechwood Rd.|Lorton, VA 22079",
"9634 Belmont Street|Coram, NY 11727",
"131 South River Drive|Avon, IN 46123",
"482 Somerset Dr.|New Albany, IN 47150",
"9439 Homestead Lane|Branford, CT 06405",
"685 Oakland Ave.|North Fort Myers, FL 33917",
"7805 Canal St.|Ambler, PA 19002",
"6 Main Circle|Culpeper, VA 22701",
"9270 Windsor Dr.|Dracut, MA 01826",
"374 Wagon Court|Richmond, VA 23223",
"468 Forest St.|Niagara Falls, NY 14304",
"685 Oakland Ave.|North Fort Myers, FL 33917",
"7805 Canal St.|Ambler, PA 19002",
"6 Main Circle|Culpeper, VA 22701",
"9270 Windsor Dr.|Dracut, MA 01826",
"374 Wagon Court|Richmond, VA 23223",
"468 Forest St.|Niagara Falls, NY 14304",
"965 Elizabeth Ave.|Wausau, WI 54401",
"145 Morris Road|Owatonna, MN 55060",
"97 Stillwater Rd.|Columbus, GA 31904",
"67 Military Ave.|New Windsor, NY 12553",
"3 Heather Court|Oshkosh, WI 54901",
"7200 Philmont Drive|Huntington Station, NY 11746",
"965 Elizabeth Ave.|Wausau, WI 54401",
"145 Morris Road|Owatonna, MN 55060",
"97 Stillwater Rd.|Columbus, GA 31904",
"67 Military Ave.|New Windsor, NY 12553",
"3 Heather Court|Oshkosh, WI 54901",
"7200 Philmont Drive|Huntington Station, NY 11746"

$Gender = 0..47 | % { Get-Random -Min 0 -Max 3 }

$Dob = "01/18/1964",
"10/08/1945",
"11/09/1937",
"10/17/1961",
"07/18/1950",
"03/14/1987",
"12/20/1979",
"01/31/1964",
"08/03/1945",
"03/16/1961",
"10/27/1996",
"10/17/1978",
"08/20/1978",
"11/22/2002",
"06/18/1981",
"12/23/2005",
"06/02/1994",
"04/24/1969",
"08/09/1952",
"12/17/1943",
"06/06/1950",
"05/07/2005",
"01/02/1969",
"02/28/2000",
"01/06/1999",
"11/19/1972",
"05/07/1980",
"11/09/1940",
"11/09/1990",
"11/12/1952",
"08/17/1967",
"06/23/1943",
"03/05/2002",
"06/09/1970",
"01/09/1993",
"04/08/1967",
"09/11/1984",
"11/12/1983",
"03/03/1983",
"10/13/1962",
"06/17/1943",
"11/21/1939",
"12/06/1983",
"11/26/1942",
"12/20/2002",
"10/15/1950",
"07/23/1976",
"08/01/1941"

$Phone = "848-563-2253",
"660-231-7372",
"979-617-1987",
"837-565-8840",
"592-963-3389",
"987-428-2855",
"587-662-2286",
"998-807-2400",
"657-978-4838",
"817-207-7059",
"235-529-0236",
"580-586-6593",
"298-629-2030",
"742-646-1912",
"621-373-4274",
"746-955-5678",
"416-950-0873",
"981-945-8434",
"394-673-2748",
"315-289-7677",
"339-996-2467",
"676-700-8240",
"202-770-6788",
"965-979-7923",
"666-822-2849",
"378-737-5308",
"778-221-4730",
"714-839-5527",
"666-436-7774",
"334-787-3619",
"489-977-4291",
"722-686-6140",
"917-692-1323",
"377-781-3442",
"449-698-0729",
"942-451-2057",
"407-217-5895",
"616-346-3904",
"546-613-4199",
"559-586-1828",
"960-213-9014",
"511-211-8832",
"334-442-5326",
"537-437-5578",
"432-370-6707",
"382-976-1115",
"415-543-4375",
"256-616-9689"

$Email = "dkeeler@comcast.net",
"overbom@gmail.com",
"richard@msn.com",
"rgiersig@mac.com",
"louise@mac.com",
"alastair@sbcglobal.net",
"openldap@me.com",
"jelmer@me.com",
"mwilson@live.com",
"ghaviv@yahoo.com",
"konst@comcast.net",
"fangorn@msn.com",
"fudrucker@outlook.com",
"nwiger@aol.com",
"maradine@live.com",
"dleconte@yahoo.com",
"murty@outlook.com",
"jmcnamara@mac.com",
"bruck@outlook.com",
"arachne@yahoo.ca",
"mxiao@verizon.net",
"lbecchi@att.net",
"reziac@hotmail.com",
"flavell@hotmail.com",
"privcan@me.com",
"scottlee@hotmail.com",
"nwiger@live.com",
"linuxhack@gmail.com",
"nullchar@sbcglobal.net",
"mglee@hotmail.com",
"rafasgj@sbcglobal.net",
"chlim@yahoo.com",
"dodong@outlook.com",
"kudra@outlook.com",
"jacks@yahoo.ca",
"matloff@sbcglobal.net",
"monopole@live.com",
"jdray@live.com",
"zilla@yahoo.com",
"tmaek@optonline.net",
"tedrlord@mac.com",
"ryanshaw@optonline.net",
"mlewan@outlook.com",
"moxfulder@live.com",
"jfinke@mac.com",
"ajohnson@live.com",
"josem@att.net",
"hling@comcast.net"

$Out = @( )
ForEach ($X in 0..47)
{
    $Out += [TestCriteria]::New($X,$Names[$X],$Addresses[$X],$Gender[$X],$Dob[$X],$Phone[$X],$Email[$X])
}
