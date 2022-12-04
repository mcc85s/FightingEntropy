IRM https://github.com/mcc85s/FightingEntropy/blob/main/Music/Build-Discography.ps1?raw=true | IEX

# __________________________________________________________________________
# | This is experimental, meant to download music from YouTube via either: |
# | 1) full-album, or                                                      |
# | 2) playlist entries                                                    |
# | How this works, is that it will build a queue to download the music,   |
# | while also maintaining information about album name/year,              |
# | track names/times and then reconstituting all of it.                   |
# | I'm not sure if Trivium/Matt Heafy is gonna be pissed or not...        |
# | But I'll take it down if that is the case.                             |
# | Trivium kicks ass                                                      |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$Disc = Build-Discography Trivium

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Ember To Inferno (2003) [~] Extended Edition                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Ember to Inferno",2003)
$Disc.SetHash(0,"DVK3rWG_XA8")
$Album = $Disc.Get(0)

("Inception: The Bleeding Skies","0:35"),
("Pillars of Serpents","4:35"),
("If I Could Collapse the Masses","4:42"),
("Fugue (A Revelation)","4:21"),
("Requiem","4:53"),
("Ember to Inferno","4:11"),
("Ashes","0:53"),
("To Burn the Eye","7:01"),
("Falling to Grey","5:37"),
("My Hatred","4:34"),
("When All Light Dies","6:23"),
("A View of Burning Empires","1:48"),
("Blinding Tears Will Break the Skies","5:41"),
("The Deceived","6:00"),
("Demon","3:27"),
("The Storm","6:05"),
("Sworn","4:29")  | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Ascendancy (2005) [~] Extended Edition                                                         ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Ascendancy",2005)
$Disc.SetHash(1,"6evwc3r64Mk")
$Album = $Disc.Get(1)

("The End of Everything","1:20"),
("Rain","4:11"),
("Pull Harder on the Strings of Your Martyr","4:51"),
("Drowned and Torn Asunder","4:17"),
("Ascendancy","4:25"),
("A Gunshot to the Head of Trepidation","5:55"),
("Like Light to the Flies","5:40"),
("Dying in Your Arms","2:53"),
("The Deceived","5:11"),
("Suffocating Sight","3:47"),
("Departure","5:41"),
("Declaration","7:00"),
("Blinding Tears Will Break the Skies","5:10"),
("Washing Away Me in the Tides","3:46"),
("Master of Puppets","8:11"),
("Dying in Your Arms","3:05") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ The Crusade (2006) [~]                                                                          ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("The Crusade",2006)
$Album = $Disc.BuildPlayList(2)

("Ignition","SAZfz_iDkL0","03:55"),
("Detonation","s26_fFE0yzg","04:29"),
("Entrance of the Conflagration","oeZGGBLpbsM","04:38"),
("Anthem","Lp8p5OPtEe0","04:13"),
("Unrepentant","X5UIYGBoKRI","04:52"),
("And Sadness Will Sear","xvw0isHwhgo","03:35"),
("Becoming the Dragon","3rSfGtLzshc","04:47"),
("To The Rats","I1rnZY3HOWY","03:50"),
("This World Can't Tear Us Apart","LaIFLzYQCgg","03:31"),
("Tread the Floods","2Ylqgo8tOow","03:34"),
("Contempt Breeds Contamination","zMfywB7iYaM","04:29"),
("The Rising","HsmWOZRtN8s","03:48"),
("The Crusade","BBQXitgjoQE","08:20"),
("Broken One","1Ohj7wuzUEI","05:49"),
("Vengeance","5fTsFlnV-U0","03:37") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Shogun (2008) [~]                                                                              ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Shogun",2008)
$Disc.SetHash(3,"uG7dRX3DgqE")
$Album = $Disc.Get(3)

("Kirisute Gomen","06:28"),
("Torn Between Scylla and Charibdis","06:49"),
("Down From the Sky","05:35"),
("Into the Mouth of Hell We March","05:52"),
("Throes of Perdition","05:54"),
("Insurrection","04:57"),
("The Calamity","04:58"),
("He Who Spawned the Furies","04:08"),
("Of Prometheus And the Crucifix","04:40"),
("Like Callisto to a Star in Heaven","05:25"),
("Shogun","11:55"),
("Poison, the Knife or the Noose","04:14"),
("Upon the Shores","05:21"),
("Iron Maiden","03:44") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ In Waves (2011) [~]                                                                            ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("In Waves",2011)
$Disc.SetHash(4,"bxNaFabesuE")
$Album = $Disc.Get(4)

("Capsizing the Sea","01:30"),
("In Waves","05:02"),
("Inception of the End","03:48"),
("Dusk Dismantled","03:47"),
("Watch the World Burn","04:53"),
("Black","03:27"),
("A Skyline's Severance","04:51"),
("Ensnare the Sun","01:22"),
("Built to Fall","03:08"),
("Caustic Are the Ties That Bind","05:34"),
("Forsake Not the Dream","05:20"),
("Drowning in Slow Motion","04:29"),
("A Grey So Dark","02:41"),
("Chaos Reigns","04:07"),
("Of All These Yesterdays","04:21"),
("Leaving This World Behind","01:32"),
("Shattering the Skies Above","04:45"),
("Slave New World","02:57") | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Vengeance Falls (2013) [~]                                                                     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Vengeance Falls",2013)
$Disc.SetHash(5,"xZRHwWkGmAo")
$Album = $Disc.Get(5)

("Brave This Storm","04:29"),
("Vengeance Falls","04:13"),
("Strife","04:29"),
("No Way to Heal","04:05"),
("To Believe","04:32"),
("At the End of This War","04:47"),
("Through Blood and Dirt and Bone","04:26"),
("Villainy Thrives","04:54"),
("Incineration: The Broken World","05:52"),
("Wake (The End Is Nigh)","06:00"),
("No Hope for the Human Race","03:59"),
("As I Am Exploding","05:49"),
("Skulls... We Are 138","03:31") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Silence in the Snow (2015) [~]                                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Silence in the Snow",2015)
$Album = $Disc.BuildPlayList(6)

("Snofall","Kn-GfLLu55o","01:29"),
("Silence in the Snow","QFWbVX9GRCU","3:40"),
("Blind Leading the Blind","al8vRO-nbes","4:25"),
("Dead and Gone","SY0K_WsVb4k","3:46"),
("The Ghost That's Haunting You","vztsR5ifTOY","4:09"),
("Pull Me from the Void","Tqg4JYEDuhQ","3:53"),
("Until the World Goes Cold","53-LCHbuQlA","5:21"),
("Rise Above the Tides","jQiZNf6bl_4","3:54"),
("The Thing That's Killing Me","s0QkA_dqR-E","3:30"),
("Beneath the Sun","FauatoaLwnI","3:56"),
("Breathe in the Flames","EKFfks8TAe0","5:11"),
("Cease All Your Fire","R_Z08A4R4-4","05:02"),
("The Darkness of My Mind","GzJo2jdiGfs","04:47") | % {
    
    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ The Sin and the Sentence (2017) [~]                                                            ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("The Sin and the Sentence",2017)
$Album  = $Disc.BuildPlayList(7)

("The Sin and the Sentence","TNyFYvCyhdc","05:50"),
("Beyond Oblivion","pw9El5D2XIU","05:17"),
("Other Worlds","NCJof-ApQBE","04:50"),
("The Heart From Your Hate","fkPhXYLhfHM","04:04"),
("Betrayer","MYIYlLtjM5I","05:28"),
("The Wretchedness Inside","LDa-nmSbFN4","05:32"),
("Endless Night","7Re8KEjyl34","03:39"),
("Sever the Hand","joxDpn7PTZI","05:26"),
("Beauty in the Sorrow","0WWnq9x-O1w","04:32"),
("The Revanchist","3iLjfJh9Ybk","07:18"),
("Thrown into the Fire","E7LCScCI2vo","05:30"),
("Pillars of Serpents","tTYj7pF8P-k","05:01"),
("I Dont Wanna Be Me","c6s8IW-n4xc","03:49"),
("Drowning In The Sound","JJ90WGZ7AXk","03:44"),
("Kill The Poor","9QvYT47O8UQ","03:17") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ What the Dead Men Say (2020) [~]                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("What the Dead Men Say",2020)
$Album = $Disc.BuildPlayList(8)

("IX","ChpzUz_j1P8","01:59"),
("What The Dead Men Say","8VqQPBrhmaY","06:10"),
("Catastrophist","lNgyzREsaAA","07:37"),
("Amongest The Shadows & The Stones","wDcSigYUYZQ","05:41"),
("Bleed Into Me","gquJi978qeE","4:14"),
("The Defiant","KmoR-1vdR5I","04:30"),
("Sickness Unto You","I54SNoZ9QcE","06:14"),
("Bending The Arc To Fear","atT03FqAovA","04:46"),
("Scattering The Ashes","bYUJsE4FGV0","03:25"),
("The Ones We Leave Behind","4dmq2isSmdo","04:57") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ In the Court of the Dragon (2021) [~]                                                          ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("In the Court of the Dragon",2021)
$Album  = $Disc.BuildPlayList(9)

("X","vD1zxjewW3I","01:28"),
("In The Court Of The Dragon","ybekW8fZHH0","09:34"),
("Like A Sword Over Damocles","bnMMe_amFKc","05:31"),
("Feast Of Fire","mue8XLsKYtQ","04:19"),
("A Crisis Of Revelation","blWLvO_o-eQ","05:37"),
("The Shadow Of The Abattoir","wsmHCfSZM70","07:13"),
("No Way Back Just Through","6jaOKu7m2Xo","03:54"),
("Fall Into Your Hands","3zMR5AYmLRM","07:46"),
("The Phalanx","yMoOqlhC-l4","07:14"),
("From Dawn To Decadence","TxR3zUDaJZ8","04:10") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

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

$Disc.Download($YouTubeDL)
