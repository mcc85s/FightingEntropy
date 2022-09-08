# Unusual Sign in... 
# https://drive.google.com/drive/folders/1Pc4G426cLMr5uvrgcjeoWKhjKfbTQqN0?usp=sharing
# I believe it probably originated from one of the following military bases
Class MilitaryListing
{
    [UInt32] $Index
    [String] $Name
    [String] $Address
    [String] $Location
    [String] $Phone
    MilitaryListing([UInt32]$Index,[String]$Item)
    {
        $This.Index    = $Index
        $Split         = $Item -Split "`n"
        $This.Name     = $Split[0]
        $This.Address  = $Split[1]
        $This.Location = $Split[2]
        $This.Phone    = $Split[3]
    }
}

Class MilitaryList
{
    [Object] $Output
    MilitaryList()
    {
        $This.Output = @( )
    }
    Add([Object]$Item)
    {
        $This.Output += [MilitaryListing]::New($This.Output.Count,$Item)
    }
}

$Text = @'
Naval Station Norfolk
1530 Gilbert St Ste 26 
Norfolk, VA 23511
(757) 322-2366|Little Creek Naval Amphibious Base
N/A
Norfolk, VA 23501
(757) 462-7868|MARFORCOM, Camp Allen and MCSF Regiment
1251 Yalu St.
Norfolk, VA 23515
(757) 445-1255|Joint Expeditionary Base Little Creek-Fort Story
2600 Tarawa Ct.
Virginia Beach, VA 23459
(757) 462-7385|Newport News Shipyard
4101 Washington Ave Ste 2
Newport News, VA 23607
(757) 688-9288|Fort Story
Bldg 300
Virginia Beach, VA 23459
(757) 422-7033|Langley AFB
34 Elm St.
Hampton, VA 23665
(757) 225-3505|Joint Base Langley-Eustis
45 Nealy Ave.
Hampton, VA 23665
(757) 764-4169|Langley Air Force Base
Langley Air Force Base
Langley Afb, VA 23665
(757) 764-9990|Naval Air Station Oceana Dam Neck Annex
1912 Regulus Ave Building 127
Virginia Beach, VA 23461
(757) 444-0000|Naval Support Activity Northwest Annex
1320 Northwest Blvd Ste 145
Chesapeake, VA 23322
(757) 421-8210|Fort Eustis US Army-Base Operator/Directory Assistance
1387 Jackson Ave
Fort Eustis, VA 23604
(757) 878-1212|Naval Weapons Station Yorktown
1959 Main St.
Yorktown, VA 23690
(757) 887-4355|Yorktown Naval Weapons Station
160 Main Rd.
Yorktown, VA 23691
(757) 887-4000|Fort Lee
1231 Mahone Ave Bldg 9023
Fort Lee, VA 23801
(804) 734-6388|Naval Air Station Oceana
1750 Tomcat Blvd.
Virginia Beach, VA 23460
(757) 433-3131|Naval Air Station Oceana
1750 Tomcat Blvd Suite 203
Virginia Beach, VA 23460
(757) 433-2366|Civil Air Patrol - Langley Composite Squadron
308 Emmonds Rd.
Hampton, VA 23665
(757) 219-2338|US Navy Naval Air Station-Oceana
Virginia Beach 23450
Virginia Beach, VA 23450
(757) 433-5554
'@ -Split "\|"

$List = [MilitaryList]::New()
ForEach ($Item in $Text)
{
    $List.Add($Item)
}

$List.Output | Format-Table
