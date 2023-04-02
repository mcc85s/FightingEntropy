$Disc = Build-Discography "As I Lay Dying"

$Disc.AddAlbum("Beneath the Encasing of Ashes",2001)
$Disc.Select(0)
$Disc.SetHash("5TXr6S11CqA")

("Beneath the Encasing of Ashes","03:03"),
("Torn Within","01:46"),
("Forced to Die","02:43"),
("A Breath in the Eyes of Eternity","02:58"),
("Blood Turned to Tears","01:38"),
("The Voices That Betray Me","02:58"),
("When This World Fades","02:32"),
("A Long March","01:56"),
("Surrounded","00:50"),
("Refined By Your Embrace","01:44"),
("The Innocence Spilled","03:36"),
("Behind Me Lies Another Fallen Soldier","04:13") | % { 

    $Disc.AddTrack($_[0],$_[1])
}

$Disc.AddAlbum("Frail Words Collapse",2003)
$Disc.Select(1)
$Disc.SetHash("E9f9vA6ghE4")

("94 Hours","03:11"),
("Falling Upon Deaf Ears","02:31"),
("Forever","04:43"),
("Collision","03:11"),
("Distance Is Darkness","02:39"),
("Behind Me Lies Another Fallen Soldier","03:03"),
("Undefined","02:17"),
("A Thousand Steps","01:46"),
("The Beginning","03:29"),
("Song 10","04:16"),
("The Pain of Separation","02:57"),
("Elegy","04:47") | % { 

    $Disc.AddTrack($_[0],$_[1])
}

$Disc.AddAlbum("Shadows Are Security",2005)
$Disc.Select(2)
$Disc.SetHash("EnKllQmSIoE")

("Meaning in Tragedy","03:13"),
("Confined","03:12"),
("Losing Sight","03:24"),
("The Darkest Nights","03:52"),
("Empty Hearts","02:49"),
("Reflection","03:12"),
("Repeating Yesterday","04:02"),
("Through Struggle","03:59"),
("The Truth of My Perception","03:06"),
("Control Is Dead","02:56"),
("Morning Waits","03:56"),
("Illusions","05:48") | % { 

    $Disc.AddTrack($_[0],$_[1])
}

$Disc.AddAlbum("An Ocean Between Us",2007)
$Disc.Select(3)
$Disc.SetHash("T9TtmYCPCLU")

("Separation","01:15"),
("Nothing Left","03:43"),
("An Ocean Between Us","04:13"),
("Within Destruction","03:54"),
("Forsaken","05:18"),
("Comfort Betrays","02:50"),
("I Never Wanted","04:44"),
("Bury Us All","02:23"),
("The Sound of Truth","04:20"),
("Departed" ,"01:40"),
("Wrath Upon Ourselves","04:01"),
("This Is Who We Are","04:54") | % { 

    $Disc.AddTrack($_[0],$_[1])
}

$Disc.AddAlbum("The Powerless Rise",2010)
$Disc.Select(4)
$Disc.SetHash("jEovixCrZQI")

("Beyond Our Suffering","02:50"),
("Anodyne Sea","04:35"),
("Without Conclusion","03:15"),
("Parallels","04:57"),
("The Plague","03:42"),
("Anger and Apathy","04:26"),
("Condemned","02:50"),
("Upside Down Kingdom","04:00"),
("Vacancy","04:27"),
("The Only Constant Is Change","04:08"),
("The Blinding of False Light","05:05")  | % { 

    $Disc.AddTrack($_[0],$_[1])
}

$Disc.AddAlbum("Awakened",2012)
$Disc.Select(5)
$Playlist = $Disc.PlayListItem()

("Cauterize"            , "ihTABU6t8IU" , "03:37"),
("A Greater Foundation" , "CHXmHssCHY8" , "03:46"),
("Resilience"           , "WGmOoZ-7w8A" , "04:07"),
("Wasted Words"         , "Skj8FgokOQ8" , "04:20"),
("Whispering Silence"   , "uTy9uMWw85A" , "04:30"),
("Overcome"             , "gTt7Or2JQBc" , "04:36"),
("No Lungs to Breathe"  , "BcCGUZGo6Ls" , "04:04"),
("Defender"             , "O-RGJjedCnI" , "04:04"),
("Washed Away"          , "p1kmrin2SCY" , "01:00"),
("My Only Home"         , "ZDKzK_IaeHI" , "04:05"),
("Tear Out My Eyes"     , "RbAfw0IIzHw" , "04:37"),
("Unwound"              , "UVaPyvzyVxg" , "03:59"),
("A Greater Foundation" , "2bqwaOvs9zA" , "03:59") | % { 

    $Playlist.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Playlist)


$Disc.AddAlbum("Shaped by Fire",2019)
$Disc.Select(6)
$Disc.SetHash("IuYtU1a2g-s")

("Burn to Emerge","00:52"),
("Blinded","03:22"),
("Shaped by Fire","03:39"),
("Undertow","03:57"),
("Torn Between","04:01"),
("Gatekeeper","03:25"),
("The Wreckage","04:43"),
("My Own Grave","04:13"),
("Take What's Left","04:13"),
("Redefined","04:15"),
("Only After We've Fallen","03:29"),
("The Toll It Takes","03:56") | % { 

    $Disc.AddTrack($_[0],$_[1])
}

<# 
## [Album]

$Disc.AddAlbum("Cool album name #1",5000)
$Disc.SetHash(0,"YoUtUbEhAsH")

$Album = $Disc.Get(0)

("Cool track #1" , "00:00") ,
("Cool track #2" , "04:28") | % {

    $Album.AddTrack($_[0],$_[1])
}

## [Playlist]

$Disc.AddAlbum("Cool album playlist",5000)
$Album = $Disc.BuildPlayList($Index)

("Cool track #1","YoUtUbEhAsH","05:01") ,
("Cool track #2","yOuTuBeHaSh","04:29") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)
#>

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Validate [~]                                                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.Validate()

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Download [~]                                                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$YouTubeDL = "$Home\Downloads\youtube-dl.exe"

If (($Disc.Queue | ? Exists -eq 0).Count -gt 0)
{
    $Disc.Download($YoutubeDL)
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Rename [~]                                                                                     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.Rename()
