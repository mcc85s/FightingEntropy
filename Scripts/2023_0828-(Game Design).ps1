
<#

    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Game Design (Part I) [~] 08/27/2023                                                            ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

\______________________________________________________________________________________________________________________/
  Introduction /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                         

    In order to design games, it is important to note what avenue of [game design] you wish to pursue,
    as there are multiple paths that can be taken, and are required, to design a game.
    
    Some of those avenues are:
    
    =============================================================================================
    | application development  | computer science |  mathematics | physics  | assets | graphics |
    | content | design philosophy | gameplay mechanics | publication | marketing | distribution |
    =============================================================================================
    
    In this particular study, we will be focusing on a study sample called [Quake III Arena],
    which was developed by [id Software] and released in [December 1999].
    
    This game had [(cutting/bleeding) edge] graphics that pushed the limits of what computer games could do.
    It required a special piece of PC hardware called a [graphics card] which in 1999, would utilize either
    a (PCI/peripheral component interconnect) slot, or an (AGP/accelerated graphics port) slot.
    
    We won't be covering the history of [id Software], nor the number of games it has made that led
    to the creation of [Quake III Arena], however... as stated, the game pushed the limits of what 
    computer games could do in many various ways.
    
    It is worth mentioning that the game retains quite a lot of charm and character that has prevailed
    over the course of the last (24) years.
                                                                                                         ______________/
\_______________________________________________________________________________________________________/ Introduction  
  Objective /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯                                                                                                            

    The objective of this document, is to cover the many things that go into creating a level for 
    [Quake III Arena], as well as the necessary tools and skills to build a level with [replayability],
    and [competitiveness] to it.
    
    First and foremost, I covered a lot of concepts related to [Quake III Arena] and [GtkRadiant], here.
    https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant
    
    [GtkRadiant] is the level editor for [Quake III Arena], though I will be covering additional level
    design concepts with an alternative that is based on [GtkRadiant], called [NetRadiant].
    
    As for the link above, what I did NOT cover, was [HOW] gameplay mechanics are the reason why the game
    has retained its charm and character over the course of the last (24) years or so.
    
    Unlike its predecessors [Doom I+II], and [Quake I+II], the game can be configured to utilize custom
    resolutions and high graphics settings that allow it to run in HD without modifying the game or its
    content.
    
    While there have been many games released by [id Software] since 1999 that have better graphics, 
    lighting, shading, animations, and et cetera... every single one of them is based on a very heavily
    modified version of the [Quake III Arena] engine, such as [Wolfenstein (long list)], [Doom III + ROE],
    [Rage], [Doom 2016 + Eternal], and [Quake IV + Champions].
    
    Given its age, the game runs relatively well on older hardware, and still retains quite a lot of 
    chess-like characteristics. It's many modes of play range from [Free-for-all/Deathmatch], [Tournament/1v1],
    and [Capture the flag/CTF]. 
    
    There is plenty of debate on which mode is the most popular or the "best"...
    ...but make no mistake, its' [Tournament/1v1] cemented its position at a large number of yearly [QuakeCon]
    events, and is synonymous with [Quake Live]... since it is the [same exact game]. It also resurfaced as
    a staple of [Quake Champions] with the advent of [Overwatch], [Fortnite], and [Player Unknown Battlegrounds].
    
    To narrow the objective even further, we'll be focusing on [Tournament/1v1] mode, as well as how to make a
    really cool + fun level for it that focuses on aspects of the mode and the game, in order to produce
    something that is incredibly polished.
    
    In order to complete the objective, we should first analyze a number of tournament maps and describe them
    all in a way where their strengths and weaknesses can evoke a sense of "common denominators" that will be
    key in shaping, desigining, and developing the level in the editor.
                                                                                                            ___________/
\__________________________________________________________________________________________________________/ Objective  
  Analysis /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯                                                                                                             

    While the original [Quake III Arena] has a lot of tournament maps in it, [Quake III Team Arena] introduced
    a handful of maps that I think really illustrates what to do, and what NOT to do, in desigining levels for
    the particular mode in question.
    
    ==============================================================================================
    | Date       | Title           | Name       | Link                         | Record | Rating |
    ==============================================================================================
    | 08/26/2023 | House of Decay  | mptourney1 | https://youtu.be/y-SgDVzWdGw | 1m 19s |  10/10 |
    | 08/26/2023 | Death Factory   | mptourney2 | https://youtu.be/7_Jh6HLvjBE | 1m 45s |   5/10 |
    | 08/26/2023 | Temple of Pain  | mptourney3 | https://youtu.be/g6W5opegQ3Y | 1m 47s |   7/10 |
    | 08/26/2023 | Evil Playground | mptourney4 | https://youtu.be/HBde-PjqTF4 | 1m 09s |  10/10 |
    ==============================================================================================
    
    So, allow me to explain each levels strengths and weaknesses, and at some point I will talk about
    each map in further detail, by providing commentary in a video that focuses on the layout and
    item placement.
    
    =============================
    | House of Decay/mptourney1 |
    =============================
    
    This map is without a doubt, [extremely well made]. It is small enough to have a strong focus on (3)
    different weapons, and provides a really strong emphasis on aesthetics and geometry to allow the gameplay
    to swing in either direction.
    
    This map was remade for [Quake Live], and has other items added to it which take away from the charm of
    the original. It probably goes without saying... but this is one of my favorite maps, above ALL of the
    original pro-q3(dm|tourney) maps.
    
    ============================
    | Death Factory/mptourney2 |
    ============================
    
    Reminds me of (Base Siege/mpteam1), and feels like a recycled version of that map.
    
    While that's not exactly a bad thing as it is common for a game developer to recycle assets and attempt to
    reuse those assets with a slightly different twist... in this instance, there are a lot of shortcomings to
    this map that I don't particularly care for, given that it is a tournament map.
    
    It is too big to be a tournament map, it has too many spawn points, and is better suited for FFA/deathmatch.
    If it were an FFA map...? This map would get about a 7-8 out of 10.
    
    As it stands, the middle tier is disconnected from the top tier. 
    This forces the players to have to use jump pads to traverse from tier to tier, which exposes a player to
    be quite vulnerable when they use them... which can be seen in the video link above.
    
    The jump pads is a serious sticking point, here... because this map would actually score a LOT higher as
    a tournament map if there were stairs on both sides to connect the middle tier to the top tier, because at
    that point, the multi-tiered combat would be far more cohesive and a lot less predictable.
    
    This point alone, though incredibly small... can be the difference between whether it makes or breaks a
    level. Simply put, the map isn't badly made at all, but considering that it is named mptourney2... 
    ...it does not feel like a great 1v1 map.
    
    I have to tank its score a lot because it would've made more sense to add some stairs to connect the middle
    and top tier, or instead, use another map in the rotation.
    
    =============================
    | Temple of Pain/mptourney3 |
    =============================
    
    I have mixed feelings about this map because it has areas that feel very claustrophobic, and it has a rather
    simple item placement which does not promote a healthy multi-tiered experience. 
    
    However, the map [looks really awesome]. Problem is, [looks aren't everything], because there's just some
    things about this map that don't make much practical sense in a tournament map.
    
    The rocket launcher, nailgun, and shotgun are all very close to each other, and the railgun is the only
    weapon on that side of the map. This would've been a much better map if it made better use of the courtyard
    area by adding some stairs and ledges and a bridge to where the armor is... in addition to providing other
    ways to get to either side of the map from that higher tier, as this would've given the map a lot more depth.
    
    Eliminating the hallway to the nailgun ammunition, OR, providing an alternate way to access traverse from
    the railgun tower to that hallway would've made perfect sense.
    
    ==============================
    | Evil Playground/mptourney4 |
    ==============================
    
    This map is without a doubt, extremely well made. It isn't as small as
    [House of Decay], but it has a really well thought out approach to multi-tiered combat, which is a signature
    of extremely well made maps. The only thing that I do not like about this map, is the fact that it has death
    pits, and they're pretty annoying. 
    
    However, that's just a pet peeve at this point, because I'm not going to tank its score based on that...
    the combat is extremely fun, challenging, and the pendulum of fairness can swing in either direction- which
    is an indication of an extremely well made tournament map.
                                                                                                             __________/
\___________________________________________________________________________________________________________/ Analysis  
  Common Denominators /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                  

    So, what ARE the common denominators in the levels I discussed...?
    
    [+] multi-tiered combat
    [+] effective use of geometry
    [+] effective use of texturing
    [+] effective use of space
    [+] effective use of lighting
    [+] effective item placement
    
    What I will do, is talk about these concepts in great detail BEFORE coming up with a design philosophy to
    create a map and then to texture, shape, sculpt, modify, populate, light, and (compile/render) the map.
    
    If any of these things aren't up to snuff or are out of place...?
    It will adversely impact it's performance.
    
    The mapping process takes a while to complete, and typically speaking, without a lot of experience, you
    won't be able to create a really good map in a single day. Even the map that I made in a single day in
    this particular video... 
    
    ============================================================================================
    | Date       | Title                 | Name                 |  Link                        |
    ============================================================================================
    | 07/17/2023 | 07/17/2023 - Test Map | 2023_0717-(testmap3) | https://youtu.be/cbdJ-rWJbVI |
    ============================================================================================
    
    ...isn't finished. Ever since I created that level, I've thought about changing things in it to make it
    more fun to play. As it stands, it has some issues that stem from being incomplete. I wouldn't expect
    it to get a 10/10 like [mptourney1] or [mptourney4].
    
    However, there is an issue about that map which leads me to believe that no amount of changes will be able
    to make it a viable competitive level. And, the issue that leads me to believe as such, stems from...
    
    https://github.com/mcc85s/FightingEntropy/raw/main/Video/GtkRadiant/2023_0717-(mapdiagram).jpg
    
    ...the structure of the map.
                                                                                                  _____________________/
\________________________________________________________________________________________________/ Common Denominators  
  The Edge of Forever /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                  

    A man by the name of [Carl Sagan], a famed science communicator that won a [Pulitzer prize] for his 
    books [The Dragons of Eden], and for [Cosmos: A Personal Voyage] once raised an analogy called...
    
    [Flatland].
    And in this [Flatland] analogy from his show [Cosmos: A Personal Voyage]...
    
    ============================================================================
    | Date       | Title                        | Link                         |
    ============================================================================
    | 11/30/1980 | Cosmos - The Edge of Forever | https://youtu.be/UnURElCzGc0 |
    ============================================================================
    
    ...the man talks about how inhabitants of [Flatland] are about as [flat] as can be.
    
    They go about their [flat business].
    They go in and out of their [flat houses].
    Driving around in their [flat cars].
    
    They take part in [flat parties] and [eat flat food], they [breathe flat air].
    All of their friends are [flat], too.
    
    [Everything they do, is about as flat, as flat could possibly even be].
    Sounds pretty [flat], doesn't it...?
    
    Yeah, well, [John Carmack] and [John Romero] probably grew up playing [Atari] for years, 
    watching [Carl Sagan] in this show [Cosmos: A Personal Voyage], until they eventually said 
    to each other...
    
    =============
    | (2) Johns |
    =============
    
    [Carmack] : Hey [John]...
    [Romero]  : What's up, [John]...?
    [Carmack] : Ya know, I was thinking a lot about making a game.
    [Romero]  : Oh yeh...?
    [Carmack] : Yeh.
    [Romero]  : Buddy, there's a LOT of games out there.
    [Carmack] : Oh, I know, [John].
                But- they all have (1) thing in common.
    [Romero]  : ...oh yeh...?
    [Carmack] : Yeh.
    [Romero]  : Well, [John]...
                Do tell.
                What do they all have in common...?
    [Carmack] : They're all pretty [flat].
    [Romero]  : ...I was thinking the same thing, dude...
    [Carmack] : ...and I want to make a game that's NOT [flat].
    [Romero]  : ...really...?
    [Carmack] : Yeh.
    [Romero]  : ...nobody has ever done that before.
    [Carmack] : I know.
                What if we made the [first game in existence], that wasn't [flat]...?
    [Romero]  : *long hard stare* 
                ...dude...
    [Carmack] : I could totally do it, bro.
    [Romero]  : Nobody's ever done it before, though.
    [Carmack] : Oh, I know, [John].
                I know.
                But- I believe in myself, [John].
    [Romero]  : Well, buddy, I believe in you too, but-
    [Carmack] : *long hard stare*
                It'll change the entire way games are played, [John].
    [Romero]  : Yeh.
                But, you would need to be a genius to pull that off...
    [Carmack] : You sayin' I'm not a genius or somethin'...?
                *adjusts glasses, long hard stare*
    [Romero]  : Nah, never said that.
                Just sayin', you'd have your work cut out for you, [John].
    [Carmack] : I was thinkin', [Wolfenstein 3D].
    [Romero]  : ...that'd be pretty cool.
    [Carmack] : Yeh, escaping from the clutches of the nazi's.
                [B.J. Blazkowicz].
    [Romero]  : That sounds intense.
                Count me in.
    
    And from that day forward, [(2) Johns] took an oath to embark on a journey to make a game that
    had [depth], as they went about changing the entire way that games were played by people all
    around the world. (It's worth noting that there were ALSO [(2) Carmacks]...)
    
    They actually did this with the games [Hovertank 3D] and [Catacombs 3D], but that wasn't enough...
    They did this again with [Wolfenstein 3D], but that wasn't enough, either...
    Then, they did it AGAIN, with [Doom].
    
    [Doom] raised the bar to such an immensely high level, that the game actually had horizontal
    AND vertical depth.
    
    But then, in (1996), with the release of a cool game called [Quake], they permanently impacted
    the world by making the first FPS that was truly [3D], and wasn't [flat]... (though [Descent]
    from (1995) officially holds that title, [Descent]'s gameplay was quite disorienting.)
    
    Because in it, there were rooms above and below other rooms, which [Doom] was unable to do.
    
    In [Doom], and [Doom clones] like [Duke Nukem 3D], [Shadow Warrior], [Dark Forces], et cetera...
    there had been a limitation to where the z-buffer could not allow multiple rooms to be stacked
    above or below one another without some sort of [hacky view portal magic].
    
    With [Quake], [hacky view portal magic] became a thing of the past.
    
    =========================
    | Comparing to Flatland |
    ========================= 
    
    In reference to [Flatland], the same sort of thing happened.
    
    One day, a 3-dimensional creature represented by a sphere, decided to pass through [Flatland]...
    ...not unlike the idea that [John Carmack] had, to create the first 3-dimensional game...
    ...and that's when the 2-dimensional flatlanders saw slices of the 3-dimensional sphere...
    ...not unlike when [id Software] made multiple games that capitalized on more aspects of [depth]...
    
    Now remember, [flatlanders] can't actually see the full, third dimension of [depth].
    Not unless they remember each prior layer of the sphere.
    
    Because, what [they] see, are individual layers of that sphere...
    Not unlike when people saw each individual game that [id Software] made.
    
    At first, the circle appeared as a little dot.
    But after a while... the circle got bigger and bigger.
    Not unlike how the games [id Software] kept making, got bigger and bigger....
    
    If a circle appears out of thin [flat] air, grows to a pretty large size.
    Not unlike how [id Software] grew into an industry giant...
    
    At which point, the [flatlanders] who saw the sphere pass through their dimension, they began 
    to question their [flat] sanity, asking each other: 
    
    [Flatlanders]: Just what the [flat] is goin' on around here...?
    
    The answer, is that nobody in [Flatland] really knew what the hell was going on...
    Because, they didn't understand [depth].
    
    But in [Quake III Arena]...?
    [That's what the game was designed to take advantage of].
                                                                                                  _____________________/
\________________________________________________________________________________________________/ The Edge of Forever  
  Mechanics /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯                                                                                                            

    In order to understand how to make the best use of the space in a particular map...
    
    ...well, a lot of trial and error is in order, before anyone has a great idea of how to do that, 
    as well as how to arrange the items in that map.
    
    For instance, in [House of Decay/mptourney1], there's a lot of areas and choke points that
    allow each weapon to be better suited for the situation.
    
    You wouldn't want to use the rocket launcher if you're IN the hallway...
    ...unless you're aiming the rockets a fair distance away.
    
    You wouldn't want to use the plasmagun from a fair distance away...
    ...unless you know the opponent is running in a predictable manner.
    
    You wouldn't want to use the lightning gun from a fair distance away...
    ...unless you can close in that particular distance.
    
    There are strengths and weaknesses to each particular gun that aren't readily apparent.
    So, let's talk about [weapon mechanics].
     ____________________
    //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
    || Weapon Mechanics ||
    \\__________________//
     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    In [Quake III (Arena/*Team Arena)], there are a number of weapons:
    [+] gauntlet
    [+] machinegun
    [+] shotgun
    [+] grenade launcher
    [+] rocket launcher
    [+] lightning gun
    [+] plasmagun
    [+] BFG10K
    [+] *nailgun
    [+] *proximity mine launcher
    [+] *chaingun
    
    Here's a guide about the weapon mechanics: [https://strategywiki.org/wiki/Quake_III_Arena/Weapons],
    as well as [below].
    
    ================
    | Gauntlet / ∞ |
    ================
    
    This is only useful if you're in close proximity to the opponent, otherwise it isn't.
    While you do not need any ammunition for this gun (since it isn't a gun)...
    ...it does not do ANY damage at all, unless you're literally touching an opponent with it.
    
    [+] good for close up fights, does (50) damage
    [+] unlimited uses
    [-] can only use in close proximity
    
    ========================
    | Machinegun / Bullets |
    ========================
    
    This is extremely useful, in basically any scenario, but it does not do a lot of damage
    unless you are accurate and consistently hitting the target.
    
    [+] good for general purpose, does (7) damage
    [=] spawn with (100) rounds each time
    [-] not great against more powerful weapons
    
    ====================
    | Shotgun / Shells |
    ====================
    
    This is moderately useful in scenarios from low to mid range.
    It shoots (10) pellets per [shell], which each do (10) damage.
    
    [+] great for low range
    [=] start with (10) rounds on pickup, (10) for [shell] pickup
    [=] less great for mid range
    [-] poor for long range
    
    ===============================
    | Grenade Launcher / Grenades |
    ===============================
    
    This is not very useful for most situations, but is extremely useful in close proximity.
    The grenades bounce and linger until they explode, or they explode if they land on an enemy.
    They do splash damage to enemies, OR they will do (100) damage upon impact.
    
    [+] pretty useful if you have nothing better
    [+] can be used for a grenade jump (not exactly easy)
    [+] great for close quarters, but...
    [-] they do splash damage which can hurt you
    [=] start with (10) grenades, (10) per [grenade] pickup
    
    =============================
    | Rocket Launcher / Rockets |
    =============================
    
    This is basically the main weapon in the game, and it is the staple of the [Quake] series.
    This shoots a rocket which does either splash damage, or (100) direct damage if they hit an enemy.
    This can be used mid-long range, but short range is risky.
    
    [+] mainstay of the game, staple of the series
    [+] great for mid-long range
    [+] can be used to rocket jump, but...
    [-] does splash damage which can hurt you
    [=] start with (10) rockets, (10) per [rocket] pickup
    
    =============================
    | Lightning Gun / Lightning |
    =============================
    
    This gun does a lot of damage in short-mid range, but is completely useless long range.
    Does not do any splash damage, nor can it provide any movement advantage
    
    [+] extremely useful in tight situations
    [+] does a lot of damage fast
    [-] uses a lot of ammo fast
    [=] start with (100) lightning, (60) per [lightning] pickup
    
    ======================
    | Plasmagun / Plasma |
    ======================
    
    This gun is really useful for mid range, though it can also be used effectively in
    short or long range, depending on whether the user can sufficiently track the movement
    of a target.
    
    [+] does a lot of damage pretty fast
    [+] really useful in all scenarios, but requires practice
    [=] start with (50) plasma, (30) per [plasma] pickup
    [-] does splash damage which can hurt you
    [=] can be used to scale walls (plasma climbing)
    
    =====================
    | BFG10K / BFG ammo |
    =====================
    
    This gun is basically a rapid-fire version of the rocket launcher, it carries many of
    the same characteristics, but its rounds move faster than rockets. Typically, this would
    NOT be a good choice to include in a tournament level, as it makes the game quite unfair.
    
    [+] does an extreme amount of damage
    [-] does splash damage which can hurt you
    [=] can be used to do the same thing as rocket jumping
    [=] start with (10) BFG ammo, (15) per [BFG ammo] pickup
    
    ===================
    | Nailgun / Nails |
    ===================
    
    The nailgun is only available in [Quake III Team Arena], but it is pretty useful.
    It's only application in any tournament level that I am aware of, is [Temple of Pain].
    
    [+] does an extreme amount of damage if all nails hit the target
    [+] best for close range, but...
    [-] not so much for mid-long range
    [=] start with (10) nails, (15) per [nails] pickup
    
    =============================================
    | Proximity Mine Launcher / Proximity Mines |
    =============================================
    
    The proximity mine launcher is only available in [Quake III Team Arena], and not applicable
    to a tournament level, so I won't talk about it in this document.
    
    =====================
    | Chaingun / Rounds |
    =====================
    
    The chaingun is only available in [Quake III Team Arena], and not exactly applicable to a 
    tournament level, however- with custom maps this COULD be pretty useful in tournament mode.
    
    Still, since that would drastically change the dynamics of [1v1], I won't cover that in this document.
      __________________ 
     //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
     || Item Mechanics ||
     \\________________//
      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
    In [Quake III (Arena/Team Arena)], there are a number of items:
    ________________________________________
    | Note: <= means less than or equal to |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ==========
    | Health |
    ==========
    
    [+]  small health: adds   (5) <= (200)
    [+] medium health: adds  (25) <= (100)
    [+]  large health: adds  (50) <= (100)
    [+]    megahealth: adds (100) <= (200)
    
    =========
    | Armor |
    =========
    
    [+]   armor shard: adds   (5) <= (200)
    [+]  yellow armor: adds  (50) <= (200)
    [+]     red armor: adds (100) <= (200)
    
    ==========
    | Usable |
    ==========
    
    [+]       teleporter: activate to transport to a random spawn point
    [+]           medkit: raises health to (125)
    [+] *invulnerability: activate to freeze position + deflect all attacks for 10s
    [+]        *kamikaze: can be detonated, or self detonates if killed but not gibbed
    
    ============
    | Powerups |
    ============
    
    [+]  battle suit: reduces direct damage, deflects splash damage
    [+]       flight: ignore gravity
    [+]        haste: move and shoot a lot faster
    [+] invisibility: become harder to see
    [+]  quad damage: increases all outgoing damage by 3x (by default, not 4x)
    [+] regeneration: adds health for every second (25) <= (100), (5) <= (200)  
    
    =========
    | Runes |
    =========
    
    [+]      scout: similar to haste, cannot pick up armor
    [+]    doubler: increases all outgoing damage by 2x
    [+]      guard: sets (health + armor) to (200), regenerates health to (200) if damaged
    [+] ammo-regen: regenerates ammunition and increases fire rate
                                                                                                            ___________/
\__________________________________________________________________________________________________________/ Mechanics  
  Strategies /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                           

    There are a number of strategies that can be used in [Quake III (Arena/Team Arena)] that aren't
    readily apparent, and I will not go into great depth about them, because the geometry of the maps
    actually change the strategies that can be used in a variety of ways.
    
    Choke points are pretty good to use, bunny hopping and strafe jumping are also good to use.
    Rocket jumps can be useful.
    
    Plasma wall boosting can also be useful... but there are a lot of other strategies which just won't
    be visually apparent unless the [shape] of the map has a distinct scenario.
    
    Now, I'm going to cover some of the strategies that I used in the videos I already listed.
    
    ============================================================================
    | Date       | Title           | Name       | Link                         |
    ============================================================================
    | 08/26/2023 | Evil Playground | mptourney4 | https://youtu.be/HBde-PjqTF4 |
    ============================================================================
    
    ...one of the strategies that I used is mimicing the enemy's movements to pelt [James] with
    a barrage of machinegun bullets in the beginning of the match. This is a general strategy.
    
    Another strategy that I used was switching weapons to get combination hits, another general strategy.
    
    Another strategy that I used was positioning myself in certain locations of the map so that I could
    hear where [James] was spawning, another general strategy.
    
    Another strategy that I used was using the railgun and then shooting predictive rockets at an item
    I knew [James] was running to, another general strategy.
    
    These strategies wouldn't necessarily work against a human opponent, but they'll work for a bot
    because they typically run the same patterns.
    
    ============================================================================
    | Date       | Title           | Name       | Link                         |
    ============================================================================
    | 08/26/2023 | House of Decay  | mptourney1 | https://youtu.be/y-SgDVzWdGw |
    ============================================================================
    
    Using the combination weapon strategy is harder to pull off because the rocket launcher is sorta slow,
    and the lightning and plasmagun do a somewhat equivalent rate of damage.
    
    Using the spawn location positioning strategy is harder to pull off, because in certain positions it
    is impossible to hear where [Fritzkrieg] is spawning. Generally speaking, there is a formula to it,
    but it is still rather random and depends on where the player is on the map when they kill the bot,
    as well as where the bot is when they die... and I think it randomly selects that location depending
    on where the player is at the time of respawn.
    
    However, using choking strategies is far more effective in this map because of the tight hallways.
    This is able to be seen quite a lot in that video.
    
    ============================================================================
    | Date       | Title           | Name       | Link                         |
    ============================================================================
    | 08/26/2023 | Death Factory   | mptourney2 | https://youtu.be/7_Jh6HLvjBE |
    ============================================================================
    
    [Pi]'s movement is incredibly predictable, but her spawning location is completely random, and there
    are a LOT more spawn points in these (2) maps, than the (2) I just covered.
    
    First off, if it is true that [Death Factory] has a lot of spawn points, the best thing to do, is
    to guard items.
    
    In all (4) of these levels, there is a consistent amount of effort going into picking up health and armor.
    That is a general strategy, and it is a core central focus to this game, just like collecting [minerals] and
    [vespene gas] is in [Starcraft]. [Health] and [armor] are basically resources in this game.
    
    What is not readily apparent, is that [time] is ALSO a resource in this game.
    
    With that said, having a collection route is pretty important.
    You want to be able to guarantee that you control the items, and that the enemy does not.
    
    If you are able to do this, then you will always have an advantage over the opponent, because they will
    have to struggle to keep up... but if they are just a lot more accurate and deadly than you, then even
    item control may not necessarily guarantee a win.
    
    In [Death Factory], [Pi] is constantly going up the jump pads, and sort of lingers around the same areas.
    Using that as a known fact, that allows me to collect the necessary weapons, and then guard certain
    areas... particularly the [rocket launcher] area.
    
    Going for the [railgun] in this level is a bit of a chore.
    So is going for the [shotgun] and even the [grenade launcher] if I'll be perfectly honest.
    
    However, all it takes is to collect the (2) [yellow armors] and the [rocket launcher], in order to be at a
    serious advantage. Then, depending on the approach, collect the [railgun], [shotgun] and [grenade launcher]
    in a syncopated rhythm, that way [Pi] will constantly be on the [backfoot].
    
    The [backfoot], or [backpedaling] is a term for having to run away from a confrontation, rather than to engage
    in one. This can actually be a [very effective strategy] for [psychological manipulation] of an opponent that
    has [item control], though... a bot will NOT know how to do this to attain an advantage. Only a human will.
    
    Despite all of this, even though [Death Factory] is NOT a favorite level of mine, I still know how to navigate
    the map in order to have some knowledge of where [Pi] will go, or won't go. Or, what situations I'll be at a
    disadvantage to put myself in. One such disadvantage is allowing [Pi] to collect the [railgun], because all bots
    
    on [nightmare] have an incredibly deadly level of accuracy with the [railgun].
    
    Short of that, collecting items and then posting up in certain locations is an incredibly useful strategy.
    
    ============================================================================
    | Date       | Title           | Name       | Link                         |
    ============================================================================
    | 08/26/2023 | Temple of Pain  | mptourney3 | https://youtu.be/g6W5opegQ3Y |
    ============================================================================
    
    So, in [Temple of Pain], [Janet] is pretty predictable.
    However, the [item placement] is really crowded on (1) side of the map, and pretty sparse on the other.
    
    With [Death Factory], a couple of stairwells from the middle tier to the top tier would make all the
    difference in the world to make it a far more competitive [tournament] level.
    
    In [Temple of Pain], a lot more geometry should've been used to make the level feel more [vertical].
    
    [Multi-tiered] levels are a lot more enjoyable, because it gives the players more real estate to cover
    in order to retain [item control].
    
    In this particular map, [item control] is pretty easy to do...
    ...what is NOT so easy, is avoiding [railgun] shots from [Janet]...
    ...because she will occasionally spawn next to the [railgun], and there's only a [yellow armor] and
    some [armor shards] in the level that give any player a way to protect themselves from up to (2) shots.
    
    In this level, it is [EXTREMELY DIFFICULT] to avoid being railed twice in a row by a bot on nightmare,
    if they happen to have the [railgun].
    
    So what that means, is that the entire focus of the level is to prevent [Janet] from getting it.
    Or, if she does get it... then, use the geometry of the level that is essentially only 1.5 tiers tall.
    
    I would NOT call this a multi-tiered level at all, even though there clearly are (2) tiers.
    
    The reason I would prefer not to call it a (2) tier level, is because the first tier is really short.
    
    Whereas in [House of Decay], there are definitely (3) tiers...
    Though, the bottom tier is limited to a pool of water, that's where the armor is.
    Nobody will WANT to go there, if it is not there, because of how [VULNERABLE] they will be in that
    position.
    
    However, in [Temple of Pain], the only real vertical gameplay you get is if you use the jump pads...
    And on one side of the map, the vertical gameplay is limited to the room with the [nailgun].
                                                                                                           ____________/
\_________________________________________________________________________________________________________/ Strategies  
  Vertical Gameplay /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                                                    

    I may have mentioned numerous times that multi-tiered levels are pretty clutch, and essential to
    a map having a replayability factor to it. When taking a closer look at the tournament levels
    from [Quake III Arena]...
    
    ================================================================
    | Title                   | Name                      | Rating |
    ================================================================
    | Powerstation 0218       | q3tourney1                |   5/10 |
    | The Proving Grounds     | q3tourney2                |   9/10 |
    | The Camping Grounds     | q3dm6/pro-q3dm6           |   9/10 |
    | Hell's Gate             | q3tourney3                |   6/10 |
    | Vertical Vengeance      | q3tourney4/pro-q3tourney4 |  10/10 |
    | Lost World              | q3dm13/pro-q3dm13         |   9/10 |
    | Fatal Instinct          | q3tourney5                |   6/10 |
    | The Very End Of You     | q3tourney6                |   4/10 |
    ================================================================
    
    ================================
    | Powerstation 0218/q3tourney1 |
    ================================
    
    This map has NO vertical gameplay, and it would really benefit from having some.
    Might even be pretty easy to implement a way for that to be a thing.
    
    Otherwise, the level LOOKS really nice, which goes a long way in receiving a mediocre score, but the
    general flow if the map feels very, very [flat]. That's because [the gameplay certainly is].
    
    [Sarge] is not a tough opponent, even on [nightmare] difficulty.
    
    ==================================
    | The Proving Grounds/q3tourney2 |
    ==================================
    
    This map HAS vertical gameplay, especially in the rocket launcher area, but also the stairwells.
    
    This map was part of Q3Test, and left a pretty deep impression on be long before the full game was
    released. This map looks great, plays great, and is pretty tough against [Hunter].
    
    There's really not a whole lot more to ask for, from a competitive level.
    
    =========================================
    | The Camping Grounds/(q3dm6/pro-q3dm6) |
    =========================================
    
    The default [q3dm6] isn't even a tournament level, but it definitely plays like one.
    The [item placement] is different in [pro-q3dm6], which IS a tournament map.
    
    It has a lot of vertical gameplay, and... I would encourage people to take inspiration from this
    map, how it's made, how it flows, and how it plays... if you want to build a really great level.
    
    ==========================
    | Hell's Gate/q3tourney3 |
    ==========================
    
    While [q3tourney3] DOES have a couple of tiers, it feels a lot like [Temple of Pain].
    
    It has [death pits] which I don't particularly care for, and isn't a very competitive tournament level.
    
    With some changes, it probably could be made to be more enjoyable, but I doubt anyone's going to give it
    a touch up after (24) years.
    
    ==================================================
    | Vertical Vengeance/(q3tourney4/pro-q3tourney4) |
    ==================================================
    
    This map, has vertical in the name of the map.
    
    Both versions are geared for tournament play, and they differ to a great degree with the addition of the 
    teleporter in the pro version, as well as items being placed in different locations.
    
    This is, by far, one of my favorite tournament levels...
    But- the texturing in this level hasn't aged well.
    
    ==================================
    | Lost World/(q3dm13/pro-q3dm13) |
    ==================================
    
    This map is really, really good.
    
    It has a lot of vertical gameplay to it, it also boasts a slew of alcoves, hallways, and ways to navigate
    from one end to the other without feeling like you HAVE to go a specific route to get from point A to B.
    
    This was played a lot in [Quake Live], and it's a staple to the game.
    
    =============================
    | Fatal Instinct/q3tourney5 |
    =============================
    
    This level does have multiple tiers, but it feels a lot like [Dead Simple] from [Doom].
    
    This level design philosophy with the fog preventing someone from being able to see an opponent that's too
    far away DOES give the map some charming dynamics that are rather unique. However, it's a bit of a gimmick,
    and it takes away from the enjoyment of the map as far as professional tournament play is concerned.
    
    Also, [quad damage] should not be used in tournament levels.
    
    ==================================
    | The Very End Of You/q3tourney6 |
    ==================================
    
    This level is also rather gimmicky, has a BFG in it, and it's pretty easy to fall off into the void.
    
    I would never think to play this on a server against a human player in tournament mode... but it does look
    pretty cool and it is pretty cool as a final boss level.
    
    While it does have some vertical gameplay, it doesn't have the type of vertical gameplay that the other
    (4) space maps have...
    
    ======================================
    | Title            | Name   | Rating |
    ======================================             
    | Bouncy Map       | q3dm16 |   8/10 |
    | The Longest Yard | q3dm17 |  10/10 |
    | Space Chamber    | q3dm18 |   8/10 |
    | Apocalypse Void  | q3dm19 |   7/10 |
    ======================================
    
    I'm not going to discuss these levels at great length, but they all have plenty of vertical gameplay.
    
    Multi-tiered combat isn't everything, however.
    Item placement is pretty important, but also...
    So is the bot behavior, or just general all around mechanics going on in the map.
    
    [Bouncy Map] is fun, but the lighting is pretty flat.
    [The Longest Yard] is fun, but the bots are pretty tough when they have the [railgun].
    [Space Chamber] is fun, but it is wicked annoying because of how many ways you can fall into the void.
    [Apocalypse Void] feels really gimmicky and the platforms aren't much different than jump pads.
    
    While I really like [The Longest Yard], it is not a very competitive tournament level at all.
    None of them really are.
    
    However, [Space Station 1138] is a pretty competitive space based tournament level with vertical
    gameplay... I don't think it ever received a title or designation to where people would play it.
    
    Typically speaking, most community maps that are made for the game don't get a lot of credit or acclaim,
    and that's just how it's always been in the Quake community. Even really well made levels that got high
    ratings on [..::LvL] don't have a place where people flock to it and play it in a standard rotation.
    
    That's mainly because, in order to play custom levels, you have to fulfill a lot of instructions.
    All things considered, I made that level when I was (15) years old for a mapping competition, and the
    limitations were like (100) brushes I think.
    
    Whereas the tournament levels in [Quake III Arena] and [Quake III Team Arena], those were part of an
    official game released by [id Software], so they're not going to pull any punches in publishing them.
    
    Now, in order to build any level that will be a total success...?
    It relies on the initial shape of the map...
    ...which requires some [graph paper], and drawing it out.
                                                                                                    ___________________/
\__________________________________________________________________________________________________/ Vertical Gameplay  
  Shape /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
/¯¯¯¯¯¯¯                                                                                                                

    The [shaping] process can actually take days, but the end result will be something highly polished, and
    this can be seen in a number of levels that were made for [Quake Live], like... [Heavy Rain].
    
    [Heavy Rain] is one of the coolest maps I've ever played, it has a general shape.
    There's also [Aerowalk], though I believe that is a take on a [Quakeworld] level... that has a shape too.
    Then there's also [Blood Run], which is the most official tournament level I can think of that was
    never a part of the game itself. That too, has a shape.
    
    But even if we take a look at [Quake II], and even [Quake I], there are plenty of examples of great maps
    there, too.
    
    ==================================
    | Title         | Name  | Rating |
    ==================================
    | The Edge      | q2dm1 |  10/10 |  
    | Tokays Towers | q2dm2 |   8/10 |
    | The Frag Pipe | q2dm4 |   8/10 |
    | The Sewers    | q2dm7 |   7/10 |
    | The Warehouse | q2dm8 |  10/10 |
    ==================================
    
    There are even more from [Quake I] that I cannot remember for the life of me...
    ...but [Tim Willits] really knew what the hell he was doin', because I think he was responsible for
    many of these maps, especially [q2dm1].
    
    People still play [q2dm1] competitively, it's a great example of a map that works for tournament and
    free-for-all, but every adaptation to [Quake III Arena] has been less than exhilirating than the
    original. It has a lot of vertical gameplay to it, multiple tiers, a pretty balanced layout, and it
    has a really unique shape to it that I've never seen be reproduced in a manner to where I was as
    impressed or blown away.
    
    [q2dm1] is by far, one of the best maps I've ever seen.
    And even the rest of the maps I just listed, they're really good.
    Even [The Pits/q2dm5] is good... it's just that some of these maps really delve into being a bit of a
    breathing entity itself, with an environment.
    
    But NOW, the question is, how does one go about creating the shape for these maps...?
    
    Well, imagine if you would, that you could have a conversation with [Carl Sagan] himself, and ask him how
    to build a 4 dimensional tesseract, and then build a level off of that.
    
    That's sort of the process involved in making a really good level like the ones I just described.
    There are a lot of others that I haven't mentioned, but I can't remember all of the really well made
    levels I've played.
    
    The bottom line, is that a good map has to have a general flow to it where players can traverse the map
    in multiple ways, and further to that point, it has to be really polished, have a good amount of flow
    to it, have the items placed in ways where it makes perfect sense and is advantageous to the players,
    and then you have to top it all off with well executed aesthetics, geometry, and lighting.
    
    All of these things are reasons why I really like [House of Decay], and [Evil Playground].
    Cause they tick every single box, repeatedly.
    
    Fact of the matter is, this process is different in its chronological execution as the map is being built.
    There's really no one size fits all approach, as every approach is rather unique and changes from one idea
    to the next.
    
    Graph paper is a pretty great way to start out, because then you can layer the graph paper with additional
    shapes and such, and overlay them in order to get a "feel" for how the map is going to flow.
    
    [Tokays Towers] is a great example of a level that has vertical gameplay down pat, and... to this day, I
    sometimes think about how I would go from one end of the map to the other, top to bottom, et cetera. The
    only thing I never liked about it is swimming through the water.
    
    Swimming through water is NOT a good design philosophy in ANY tournament level...
    Using jump pads is NOT a good design philosophy all the time, but it does allow the level creator to make
    better use of space.
    
    Using little alcoves from one end of a map to another to tuck away ammo boxes doesn't make a lot of sense
    in many cases unless those boxes of ammo just so happen to be conveniently placed along a path between
    armor, health, and specific weapons.
    
    Lastly, before I talk about applying all of these things in conjunction, I can't stress this enough...
    ...but even if a map is shaped perfectly, and it is textured great, the aesthetics are awesome, the
    lighting is superb, and the item placement seems to be well executed...
    
    ...a map can still suffer from not being all that fun to play.
    
    If people feel like the map is a chore to play...?
    Then, all of that hard work will have been for nothing.
    
    As a general rule of thumb for shaping the level, think of really basic shapes like squares, rectangles,
    beveled surfaces and curves, and incorporate them into the bottom line structure of the map before adding
    things like trim, edges, light fixtures, models, and things of that nature.
    
    Because, a rough draft of a level doesn't even need to be textured or lit all that well, for a map to have
    some REALLY promising gameplay to it. The point being, creating the structure of the map AROUND the item
    placement, and item control... is a really good idea.
                                                                                                                _______/
\______________________________________________________________________________________________________________/ Shape  
#>

$Doc = New-Document -Name "Game Design (Part I)" -Date 08/27/2023

$Doc.Add("Introduction",@"
In order to design games, it is important to note what avenue of [game design] you wish to pursue,
as there are multiple paths that can be taken, and are required, to design a game.

Some of those avenues are:

=============================================================================================
| application development  | computer science |  mathematics | physics  | assets | graphics |
| content | design philosophy | gameplay mechanics | publication | marketing | distribution |
=============================================================================================

In this particular study, we will be focusing on a study sample called [Quake III Arena],
which was developed by [id Software] and released in [December 1999].

This game had [(cutting/bleeding) edge] graphics that pushed the limits of what computer games could do.
It required a special piece of PC hardware called a [graphics card] which in 1999, would utilize either
a (PCI/peripheral component interconnect) slot, or an (AGP/accelerated graphics port) slot.

We won't be covering the history of [id Software], nor the number of games it has made that led
to the creation of [Quake III Arena], however... as stated, the game pushed the limits of what 
computer games could do in many various ways.

It is worth mentioning that the game retains quite a lot of charm and character that has prevailed
over the course of the last (24) years.
"@)

$Doc.Add("Objective",@"
The objective of this document, is to cover the many things that go into creating a level for 
[Quake III Arena], as well as the necessary tools and skills to build a level with [replayability],
and [competitiveness] to it.

First and foremost, I covered a lot of concepts related to [Quake III Arena] and [GtkRadiant], here.
https://github.com/mcc85s/FightingEntropy/tree/main/Video/GtkRadiant

[GtkRadiant] is the level editor for [Quake III Arena], though I will be covering additional level
design concepts with an alternative that is based on [GtkRadiant], called [NetRadiant].

As for the link above, what I did NOT cover, was [HOW] gameplay mechanics are the reason why the game
has retained its charm and character over the course of the last (24) years or so.

Unlike its predecessors [Doom I+II], and [Quake I+II], the game can be configured to utilize custom
resolutions and high graphics settings that allow it to run in HD without modifying the game or its
content.

While there have been many games released by [id Software] since 1999 that have better graphics, 
lighting, shading, animations, and et cetera... every single one of them is based on a very heavily
modified version of the [Quake III Arena] engine, such as [Wolfenstein (long list)], [Doom III + ROE],
[Rage], [Doom 2016 + Eternal], and [Quake IV + Champions].

Given its age, the game runs relatively well on older hardware, and still retains quite a lot of 
chess-like characteristics. It's many modes of play range from [Free-for-all/Deathmatch], [Tournament/1v1],
and [Capture the flag/CTF]. 

There is plenty of debate on which mode is the most popular or the "best"...
...but make no mistake, its' [Tournament/1v1] cemented its position at a large number of yearly [QuakeCon]
events, and is synonymous with [Quake Live]... since it is the [same exact game]. It also resurfaced as
a staple of [Quake Champions] with the advent of [Overwatch], [Fortnite], and [Player Unknown Battlegrounds].

To narrow the objective even further, we'll be focusing on [Tournament/1v1] mode, as well as how to make a
really cool + fun level for it that focuses on aspects of the mode and the game, in order to produce
something that is incredibly polished.

In order to complete the objective, we should first analyze a number of tournament maps and describe them
all in a way where their strengths and weaknesses can evoke a sense of "common denominators" that will be
key in shaping, desigining, and developing the level in the editor.
"@)

$Doc.Add("Analysis",@"
While the original [Quake III Arena] has a lot of tournament maps in it, [Quake III Team Arena] introduced
a handful of maps that I think really illustrates what to do, and what NOT to do, in desigining levels for
the particular mode in question.

==============================================================================================
| Date       | Title           | Name       | Link                         | Record | Rating |
==============================================================================================
| 08/26/2023 | House of Decay  | mptourney1 | https://youtu.be/y-SgDVzWdGw | 1m 19s |  10/10 |
| 08/26/2023 | Death Factory   | mptourney2 | https://youtu.be/7_Jh6HLvjBE | 1m 45s |   5/10 |
| 08/26/2023 | Temple of Pain  | mptourney3 | https://youtu.be/g6W5opegQ3Y | 1m 47s |   7/10 |
| 08/26/2023 | Evil Playground | mptourney4 | https://youtu.be/HBde-PjqTF4 | 1m 09s |  10/10 |
==============================================================================================

So, allow me to explain each levels strengths and weaknesses, and at some point I will talk about
each map in further detail, by providing commentary in a video that focuses on the layout and
item placement.

=============================
| House of Decay/mptourney1 |
=============================

This map is without a doubt, [extremely well made]. It is small enough to have a strong focus on (3)
different weapons, and provides a really strong emphasis on aesthetics and geometry to allow the gameplay
to swing in either direction.

This map was remade for [Quake Live], and has other items added to it which take away from the charm of
the original. It probably goes without saying... but this is one of my favorite maps, above ALL of the
original pro-q3(dm|tourney) maps.

============================
| Death Factory/mptourney2 |
============================

Reminds me of (Base Siege/mpteam1), and feels like a recycled version of that map.

While that's not exactly a bad thing as it is common for a game developer to recycle assets and attempt to
reuse those assets with a slightly different twist... in this instance, there are a lot of shortcomings to
this map that I don't particularly care for, given that it is a tournament map.

It is too big to be a tournament map, it has too many spawn points, and is better suited for FFA/deathmatch.
If it were an FFA map...? This map would get about a 7-8 out of 10.

As it stands, the middle tier is disconnected from the top tier. 
This forces the players to have to use jump pads to traverse from tier to tier, which exposes a player to
be quite vulnerable when they use them... which can be seen in the video link above.

The jump pads is a serious sticking point, here... because this map would actually score a LOT higher as
a tournament map if there were stairs on both sides to connect the middle tier to the top tier, because at
that point, the multi-tiered combat would be far more cohesive and a lot less predictable.

This point alone, though incredibly small... can be the difference between whether it makes or breaks a
level. Simply put, the map isn't badly made at all, but considering that it is named mptourney2... 
...it does not feel like a great 1v1 map.

I have to tank its score a lot because it would've made more sense to add some stairs to connect the middle
and top tier, or instead, use another map in the rotation.

=============================
| Temple of Pain/mptourney3 |
=============================

I have mixed feelings about this map because it has areas that feel very claustrophobic, and it has a rather
simple item placement which does not promote a healthy multi-tiered experience. 

However, the map [looks really awesome]. Problem is, [looks aren't everything], because there's just some
things about this map that don't make much practical sense in a tournament map.

The rocket launcher, nailgun, and shotgun are all very close to each other, and the railgun is the only
weapon on that side of the map. This would've been a much better map if it made better use of the courtyard
area by adding some stairs and ledges and a bridge to where the armor is... in addition to providing other
ways to get to either side of the map from that higher tier, as this would've given the map a lot more depth.

Eliminating the hallway to the nailgun ammunition, OR, providing an alternate way to access traverse from
the railgun tower to that hallway would've made perfect sense.

==============================
| Evil Playground/mptourney4 |
==============================

This map is without a doubt, extremely well made. It isn't as small as
[House of Decay], but it has a really well thought out approach to multi-tiered combat, which is a signature
of extremely well made maps. The only thing that I do not like about this map, is the fact that it has death
pits, and they're pretty annoying. 

However, that's just a pet peeve at this point, because I'm not going to tank its score based on that...
the combat is extremely fun, challenging, and the pendulum of fairness can swing in either direction- which
is an indication of an extremely well made tournament map.
"@)

$Doc.Add("Common Denominators",@"
So, what ARE the common denominators in the levels I discussed...?

[+] multi-tiered combat
[+] effective use of geometry
[+] effective use of texturing
[+] effective use of space
[+] effective use of lighting
[+] effective item placement

What I will do, is talk about these concepts in great detail BEFORE coming up with a design philosophy to
create a map and then to texture, shape, sculpt, modify, populate, light, and (compile/render) the map.

If any of these things aren't up to snuff or are out of place...?
It will adversely impact it's performance.

The mapping process takes a while to complete, and typically speaking, without a lot of experience, you
won't be able to create a really good map in a single day. Even the map that I made in a single day in
this particular video... 

============================================================================================
| Date       | Title                 | Name                 |  Link                        |
============================================================================================
| 07/17/2023 | 07/17/2023 - Test Map | 2023_0717-(testmap3) | https://youtu.be/cbdJ-rWJbVI |
============================================================================================

...isn't finished. Ever since I created that level, I've thought about changing things in it to make it
more fun to play. As it stands, it has some issues that stem from being incomplete. I wouldn't expect
it to get a 10/10 like [mptourney1] or [mptourney4].

However, there is an issue about that map which leads me to believe that no amount of changes will be able
to make it a viable competitive level. And, the issue that leads me to believe as such, stems from...

https://github.com/mcc85s/FightingEntropy/raw/main/Video/GtkRadiant/2023_0717-(mapdiagram).jpg

...the structure of the map.
"@)

$Doc.Add("The Edge of Forever",@"
A man by the name of [Carl Sagan], a famed science communicator that won a [Pulitzer prize] for his 
books [The Dragons of Eden], and for [Cosmos: A Personal Voyage] once raised an analogy called...

[Flatland].
And in this [Flatland] analogy from his show [Cosmos: A Personal Voyage]...

============================================================================
| Date       | Title                        | Link                         |
============================================================================
| 11/30/1980 | Cosmos - The Edge of Forever | https://youtu.be/UnURElCzGc0 |
============================================================================

...the man talks about how inhabitants of [Flatland] are about as [flat] as can be.

They go about their [flat business].
They go in and out of their [flat houses].
Driving around in their [flat cars].

They take part in [flat parties] and [eat flat food], they [breathe flat air].
All of their friends are [flat], too.

[Everything they do, is about as flat, as flat could possibly even be].
Sounds pretty [flat], doesn't it...?

Yeah, well, [John Carmack] and [John Romero] probably grew up playing [Atari] for years, 
watching [Carl Sagan] in this show [Cosmos: A Personal Voyage], until they eventually said 
to each other...

=============
| (2) Johns |
=============

[Carmack] : Hey [John]...
[Romero]  : What's up, [John]...?
[Carmack] : Ya know, I was thinking a lot about making a game.
[Romero]  : Oh yeh...?
[Carmack] : Yeh.
[Romero]  : Buddy, there's a LOT of games out there.
[Carmack] : Oh, I know, [John].
            But- they all have (1) thing in common.
[Romero]  : ...oh yeh...?
[Carmack] : Yeh.
[Romero]  : Well, [John]...
            Do tell.
            What do they all have in common...?
[Carmack] : They're all pretty [flat].
[Romero]  : ...I was thinking the same thing, dude...
[Carmack] : ...and I want to make a game that's NOT [flat].
[Romero]  : ...really...?
[Carmack] : Yeh.
[Romero]  : ...nobody has ever done that before.
[Carmack] : I know.
            What if we made the [first game in existence], that wasn't [flat]...?
[Romero]  : *long hard stare* 
            ...dude...
[Carmack] : I could totally do it, bro.
[Romero]  : Nobody's ever done it before, though.
[Carmack] : Oh, I know, [John].
            I know.
            But- I believe in myself, [John].
[Romero]  : Well, buddy, I believe in you too, but-
[Carmack] : *long hard stare*
            It'll change the entire way games are played, [John].
[Romero]  : Yeh.
            But, you would need to be a genius to pull that off...
[Carmack] : You sayin' I'm not a genius or somethin'...?
            *adjusts glasses, long hard stare*
[Romero]  : Nah, never said that.
            Just sayin', you'd have your work cut out for you, [John].
[Carmack] : I was thinkin', [Wolfenstein 3D].
[Romero]  : ...that'd be pretty cool.
[Carmack] : Yeh, escaping from the clutches of the nazi's.
            [B.J. Blazkowicz].
[Romero]  : That sounds intense.
            Count me in.

And from that day forward, [(2) Johns] took an oath to embark on a journey to make a game that
had [depth], as they went about changing the entire way that games were played by people all
around the world. (It's worth noting that there were ALSO [(2) Carmacks]...)

They actually did this with the games [Hovertank 3D] and [Catacombs 3D], but that wasn't enough...
They did this again with [Wolfenstein 3D], but that wasn't enough, either...
Then, they did it AGAIN, with [Doom].

[Doom] raised the bar to such an immensely high level, that the game actually had horizontal
AND vertical depth.

But then, in (1996), with the release of a cool game called [Quake], they permanently impacted
the world by making the first FPS that was truly [3D], and wasn't [flat]... (though [Descent]
from (1995) officially holds that title, [Descent]'s gameplay was quite disorienting.)

Because in it, there were rooms above and below other rooms, which [Doom] was unable to do.

In [Doom], and [Doom clones] like [Duke Nukem 3D], [Shadow Warrior], [Dark Forces], et cetera...
there had been a limitation to where the z-buffer could not allow multiple rooms to be stacked
above or below one another without some sort of [hacky view portal magic].

With [Quake], [hacky view portal magic] became a thing of the past.

=========================
| Comparing to Flatland |
========================= 

In reference to [Flatland], the same sort of thing happened.

One day, a 3-dimensional creature represented by a sphere, decided to pass through [Flatland]...
...not unlike the idea that [John Carmack] had, to create the first 3-dimensional game...
...and that's when the 2-dimensional flatlanders saw slices of the 3-dimensional sphere...
...not unlike when [id Software] made multiple games that capitalized on more aspects of [depth]...

Now remember, [flatlanders] can't actually see the full, third dimension of [depth].
Not unless they remember each prior layer of the sphere.

Because, what [they] see, are individual layers of that sphere...
Not unlike when people saw each individual game that [id Software] made.

At first, the circle appeared as a little dot.
But after a while... the circle got bigger and bigger.
Not unlike how the games [id Software] kept making, got bigger and bigger....

If a circle appears out of thin [flat] air, grows to a pretty large size.
Not unlike how [id Software] grew into an industry giant...

At which point, the [flatlanders] who saw the sphere pass through their dimension, they began 
to question their [flat] sanity, asking each other: 

[Flatlanders]: Just what the [flat] is goin' on around here...?

The answer, is that nobody in [Flatland] really knew what the hell was going on...
Because, they didn't understand [depth].

But in [Quake III Arena]...?
[That's what the game was designed to take advantage of].
"@)

$Doc.Add("Mechanics",@"
In order to understand how to make the best use of the space in a particular map...

...well, a lot of trial and error is in order, before anyone has a great idea of how to do that, 
as well as how to arrange the items in that map.

For instance, in [House of Decay/mptourney1], there's a lot of areas and choke points that
allow each weapon to be better suited for the situation.

You wouldn't want to use the rocket launcher if you're IN the hallway...
...unless you're aiming the rockets a fair distance away.

You wouldn't want to use the plasmagun from a fair distance away...
...unless you know the opponent is running in a predictable manner.

You wouldn't want to use the lightning gun from a fair distance away...
...unless you can close in that particular distance.

There are strengths and weaknesses to each particular gun that aren't readily apparent.
So, let's talk about [weapon mechanics].
 ____________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
|| Weapon Mechanics ||
\\__________________//
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
In [Quake III (Arena/*Team Arena)], there are a number of weapons:
[+] gauntlet
[+] machinegun
[+] shotgun
[+] grenade launcher
[+] rocket launcher
[+] lightning gun
[+] plasmagun
[+] BFG10K
[+] *nailgun
[+] *proximity mine launcher
[+] *chaingun

Here's a guide about the weapon mechanics: [https://strategywiki.org/wiki/Quake_III_Arena/Weapons],
as well as [below].

================
| Gauntlet / ∞ |
================

This is only useful if you're in close proximity to the opponent, otherwise it isn't.
While you do not need any ammunition for this gun (since it isn't a gun)...
...it does not do ANY damage at all, unless you're literally touching an opponent with it.

[+] good for close up fights, does (50) damage
[+] unlimited uses
[-] can only use in close proximity

========================
| Machinegun / Bullets |
========================

This is extremely useful, in basically any scenario, but it does not do a lot of damage
unless you are accurate and consistently hitting the target.

[+] good for general purpose, does (7) damage
[=] spawn with (100) rounds each time
[-] not great against more powerful weapons

====================
| Shotgun / Shells |
====================

This is moderately useful in scenarios from low to mid range.
It shoots (10) pellets per [shell], which each do (10) damage.

[+] great for low range
[=] start with (10) rounds on pickup, (10) for [shell] pickup
[=] less great for mid range
[-] poor for long range

===============================
| Grenade Launcher / Grenades |
===============================

This is not very useful for most situations, but is extremely useful in close proximity.
The grenades bounce and linger until they explode, or they explode if they land on an enemy.
They do splash damage to enemies, OR they will do (100) damage upon impact.

[+] pretty useful if you have nothing better
[+] can be used for a grenade jump (not exactly easy)
[+] great for close quarters, but...
[-] they do splash damage which can hurt you
[=] start with (10) grenades, (10) per [grenade] pickup

=============================
| Rocket Launcher / Rockets |
=============================

This is basically the main weapon in the game, and it is the staple of the [Quake] series.
This shoots a rocket which does either splash damage, or (100) direct damage if they hit an enemy.
This can be used mid-long range, but short range is risky.

[+] mainstay of the game, staple of the series
[+] great for mid-long range
[+] can be used to rocket jump, but...
[-] does splash damage which can hurt you
[=] start with (10) rockets, (10) per [rocket] pickup

=============================
| Lightning Gun / Lightning |
=============================

This gun does a lot of damage in short-mid range, but is completely useless long range.
Does not do any splash damage, nor can it provide any movement advantage

[+] extremely useful in tight situations
[+] does a lot of damage fast
[-] uses a lot of ammo fast
[=] start with (100) lightning, (60) per [lightning] pickup

======================
| Plasmagun / Plasma |
======================

This gun is really useful for mid range, though it can also be used effectively in
short or long range, depending on whether the user can sufficiently track the movement
of a target.

[+] does a lot of damage pretty fast
[+] really useful in all scenarios, but requires practice
[=] start with (50) plasma, (30) per [plasma] pickup
[-] does splash damage which can hurt you
[=] can be used to scale walls (plasma climbing)

=====================
| BFG10K / BFG ammo |
=====================

This gun is basically a rapid-fire version of the rocket launcher, it carries many of
the same characteristics, but its rounds move faster than rockets. Typically, this would
NOT be a good choice to include in a tournament level, as it makes the game quite unfair.

[+] does an extreme amount of damage
[-] does splash damage which can hurt you
[=] can be used to do the same thing as rocket jumping
[=] start with (10) BFG ammo, (15) per [BFG ammo] pickup

===================
| Nailgun / Nails |
===================

The nailgun is only available in [Quake III Team Arena], but it is pretty useful.
It's only application in any tournament level that I am aware of, is [Temple of Pain].

[+] does an extreme amount of damage if all nails hit the target
[+] best for close range, but...
[-] not so much for mid-long range
[=] start with (10) nails, (15) per [nails] pickup

=============================================
| Proximity Mine Launcher / Proximity Mines |
=============================================

The proximity mine launcher is only available in [Quake III Team Arena], and not applicable
to a tournament level, so I won't talk about it in this document.

=====================
| Chaingun / Rounds |
=====================

The chaingun is only available in [Quake III Team Arena], and not exactly applicable to a 
tournament level, however- with custom maps this COULD be pretty useful in tournament mode.

Still, since that would drastically change the dynamics of [1v1], I won't cover that in this document.
  __________________ 
 //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
 || Item Mechanics ||
 \\________________//
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
In [Quake III (Arena/Team Arena)], there are a number of items:
________________________________________
| Note: <= means less than or equal to |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
==========
| Health |
==========

[+]  small health: adds   (5) <= (200)
[+] medium health: adds  (25) <= (100)
[+]  large health: adds  (50) <= (100)
[+]    megahealth: adds (100) <= (200)

=========
| Armor |
=========

[+]   armor shard: adds   (5) <= (200)
[+]  yellow armor: adds  (50) <= (200)
[+]     red armor: adds (100) <= (200)

==========
| Usable |
==========

[+]       teleporter: activate to transport to a random spawn point
[+]           medkit: raises health to (125)
[+] *invulnerability: activate to freeze position + deflect all attacks for 10s
[+]        *kamikaze: can be detonated, or self detonates if killed but not gibbed

============
| Powerups |
============

[+]  battle suit: reduces direct damage, deflects splash damage
[+]       flight: ignore gravity
[+]        haste: move and shoot a lot faster
[+] invisibility: become harder to see
[+]  quad damage: increases all outgoing damage by 3x (by default, not 4x)
[+] regeneration: adds health for every second (25) <= (100), (5) <= (200)  

=========
| Runes |
=========

[+]      scout: similar to haste, cannot pick up armor
[+]    doubler: increases all outgoing damage by 2x
[+]      guard: sets (health + armor) to (200), regenerates health to (200) if damaged
[+] ammo-regen: regenerates ammunition and increases fire rate
"@)

$Doc.Add("Strategies",@"
There are a number of strategies that can be used in [Quake III (Arena/Team Arena)] that aren't
readily apparent, and I will not go into great depth about them, because the geometry of the maps
actually change the strategies that can be used in a variety of ways.

Choke points are pretty good to use, bunny hopping and strafe jumping are also good to use.
Rocket jumps can be useful.

Plasma wall boosting can also be useful... but there are a lot of other strategies which just won't
be visually apparent unless the [shape] of the map has a distinct scenario.

Now, I'm going to cover some of the strategies that I used in the videos I already listed.

============================================================================
| Date       | Title           | Name       | Link                         |
============================================================================
| 08/26/2023 | Evil Playground | mptourney4 | https://youtu.be/HBde-PjqTF4 |
============================================================================

...one of the strategies that I used is mimicing the enemy's movements to pelt [James] with
a barrage of machinegun bullets in the beginning of the match. This is a general strategy.

Another strategy that I used was switching weapons to get combination hits, another general strategy.

Another strategy that I used was positioning myself in certain locations of the map so that I could
hear where [James] was spawning, another general strategy.

Another strategy that I used was using the railgun and then shooting predictive rockets at an item
I knew [James] was running to, another general strategy.

These strategies wouldn't necessarily work against a human opponent, but they'll work for a bot
because they typically run the same patterns.

============================================================================
| Date       | Title           | Name       | Link                         |
============================================================================
| 08/26/2023 | House of Decay  | mptourney1 | https://youtu.be/y-SgDVzWdGw |
============================================================================

Using the combination weapon strategy is harder to pull off because the rocket launcher is sorta slow,
and the lightning and plasmagun do a somewhat equivalent rate of damage.

Using the spawn location positioning strategy is harder to pull off, because in certain positions it
is impossible to hear where [Fritzkrieg] is spawning. Generally speaking, there is a formula to it,
but it is still rather random and depends on where the player is on the map when they kill the bot,
as well as where the bot is when they die... and I think it randomly selects that location depending
on where the player is at the time of respawn.

However, using choking strategies is far more effective in this map because of the tight hallways.
This is able to be seen quite a lot in that video.

============================================================================
| Date       | Title           | Name       | Link                         |
============================================================================
| 08/26/2023 | Death Factory   | mptourney2 | https://youtu.be/7_Jh6HLvjBE |
============================================================================

[Pi]'s movement is incredibly predictable, but her spawning location is completely random, and there
are a LOT more spawn points in these (2) maps, than the (2) I just covered.

First off, if it is true that [Death Factory] has a lot of spawn points, the best thing to do, is
to guard items.

In all (4) of these levels, there is a consistent amount of effort going into picking up health and armor.
That is a general strategy, and it is a core central focus to this game, just like collecting [minerals] and
[vespene gas] is in [Starcraft]. [Health] and [armor] are basically resources in this game.

What is not readily apparent, is that [time] is ALSO a resource in this game.

With that said, having a collection route is pretty important.
You want to be able to guarantee that you control the items, and that the enemy does not.

If you are able to do this, then you will always have an advantage over the opponent, because they will
have to struggle to keep up... but if they are just a lot more accurate and deadly than you, then even
item control may not necessarily guarantee a win.

In [Death Factory], [Pi] is constantly going up the jump pads, and sort of lingers around the same areas.
Using that as a known fact, that allows me to collect the necessary weapons, and then guard certain
areas... particularly the [rocket launcher] area.

Going for the [railgun] in this level is a bit of a chore.
So is going for the [shotgun] and even the [grenade launcher] if I'll be perfectly honest.

However, all it takes is to collect the (2) [yellow armors] and the [rocket launcher], in order to be at a
serious advantage. Then, depending on the approach, collect the [railgun], [shotgun] and [grenade launcher]
in a syncopated rhythm, that way [Pi] will constantly be on the [backfoot].

The [backfoot], or [backpedaling] is a term for having to run away from a confrontation, rather than to engage
in one. This can actually be a [very effective strategy] for [psychological manipulation] of an opponent that
has [item control], though... a bot will NOT know how to do this to attain an advantage. Only a human will.

Despite all of this, even though [Death Factory] is NOT a favorite level of mine, I still know how to navigate
the map in order to have some knowledge of where [Pi] will go, or won't go. Or, what situations I'll be at a
disadvantage to put myself in. One such disadvantage is allowing [Pi] to collect the [railgun], because all bots
on [nightmare] have an incredibly deadly level of accuracy with the [railgun].

Short of that, collecting items and then posting up in certain locations is an incredibly useful strategy.

============================================================================
| Date       | Title           | Name       | Link                         |
============================================================================
| 08/26/2023 | Temple of Pain  | mptourney3 | https://youtu.be/g6W5opegQ3Y |
============================================================================

So, in [Temple of Pain], [Janet] is pretty predictable.
However, the [item placement] is really crowded on (1) side of the map, and pretty sparse on the other.

With [Death Factory], a couple of stairwells from the middle tier to the top tier would make all the
difference in the world to make it a far more competitive [tournament] level.

In [Temple of Pain], a lot more geometry should've been used to make the level feel more [vertical].

[Multi-tiered] levels are a lot more enjoyable, because it gives the players more real estate to cover
in order to retain [item control].

In this particular map, [item control] is pretty easy to do...
...what is NOT so easy, is avoiding [railgun] shots from [Janet]...
...because she will occasionally spawn next to the [railgun], and there's only a [yellow armor] and
some [armor shards] in the level that give any player a way to protect themselves from up to (2) shots.

In this level, it is [EXTREMELY DIFFICULT] to avoid being railed twice in a row by a bot on nightmare,
if they happen to have the [railgun].

So what that means, is that the entire focus of the level is to prevent [Janet] from getting it.
Or, if she does get it... then, use the geometry of the level that is essentially only 1.5 tiers tall.

I would NOT call this a multi-tiered level at all, even though there clearly are (2) tiers.

The reason I would prefer not to call it a (2) tier level, is because the first tier is really short.

Whereas in [House of Decay], there are definitely (3) tiers...
Though, the bottom tier is limited to a pool of water, that's where the armor is.
Nobody will WANT to go there, if it is not there, because of how [VULNERABLE] they will be in that
position.

However, in [Temple of Pain], the only real vertical gameplay you get is if you use the jump pads...
And on one side of the map, the vertical gameplay is limited to the room with the [nailgun].
"@)

$Doc.Add("Vertical Gameplay",@"
I may have mentioned numerous times that multi-tiered levels are pretty clutch, and essential to
a map having a replayability factor to it. When taking a closer look at the tournament levels
from [Quake III Arena]...

================================================================
| Title                   | Name                      | Rating |
================================================================
| Powerstation 0218       | q3tourney1                |   5/10 |
| The Proving Grounds     | q3tourney2                |   9/10 |
| The Camping Grounds     | q3dm6/pro-q3dm6           |   9/10 |
| Hell's Gate             | q3tourney3                |   6/10 |
| Vertical Vengeance      | q3tourney4/pro-q3tourney4 |  10/10 |
| Lost World              | q3dm13/pro-q3dm13         |   9/10 |
| Fatal Instinct          | q3tourney5                |   6/10 |
| The Very End Of You     | q3tourney6                |   4/10 |
================================================================

================================
| Powerstation 0218/q3tourney1 |
================================

This map has NO vertical gameplay, and it would really benefit from having some.
Might even be pretty easy to implement a way for that to be a thing.

Otherwise, the level LOOKS really nice, which goes a long way in receiving a mediocre score, but the
general flow if the map feels very, very [flat]. That's because [the gameplay certainly is].

[Sarge] is not a tough opponent, even on [nightmare] difficulty.

==================================
| The Proving Grounds/q3tourney2 |
==================================

This map HAS vertical gameplay, especially in the rocket launcher area, but also the stairwells.

This map was part of Q3Test, and left a pretty deep impression on be long before the full game was
released. This map looks great, plays great, and is pretty tough against [Hunter].

There's really not a whole lot more to ask for, from a competitive level.

=========================================
| The Camping Grounds/(q3dm6/pro-q3dm6) |
=========================================

The default [q3dm6] isn't even a tournament level, but it definitely plays like one.
The [item placement] is different in [pro-q3dm6], which IS a tournament map.

It has a lot of vertical gameplay, and... I would encourage people to take inspiration from this
map, how it's made, how it flows, and how it plays... if you want to build a really great level.

==========================
| Hell's Gate/q3tourney3 |
==========================

While [q3tourney3] DOES have a couple of tiers, it feels a lot like [Temple of Pain].

It has [death pits] which I don't particularly care for, and isn't a very competitive tournament level.

With some changes, it probably could be made to be more enjoyable, but I doubt anyone's going to give it
a touch up after (24) years.

==================================================
| Vertical Vengeance/(q3tourney4/pro-q3tourney4) |
==================================================

This map, has vertical in the name of the map.

Both versions are geared for tournament play, and they differ to a great degree with the addition of the 
teleporter in the pro version, as well as items being placed in different locations.

This is, by far, one of my favorite tournament levels...
But- the texturing in this level hasn't aged well.

==================================
| Lost World/(q3dm13/pro-q3dm13) |
==================================

This map is really, really good.

It has a lot of vertical gameplay to it, it also boasts a slew of alcoves, hallways, and ways to navigate
from one end to the other without feeling like you HAVE to go a specific route to get from point A to B.

This was played a lot in [Quake Live], and it's a staple to the game.

=============================
| Fatal Instinct/q3tourney5 |
=============================

This level does have multiple tiers, but it feels a lot like [Dead Simple] from [Doom].

This level design philosophy with the fog preventing someone from being able to see an opponent that's too
far away DOES give the map some charming dynamics that are rather unique. However, it's a bit of a gimmick,
and it takes away from the enjoyment of the map as far as professional tournament play is concerned.

Also, [quad damage] should not be used in tournament levels.

==================================
| The Very End Of You/q3tourney6 |
==================================

This level is also rather gimmicky, has a BFG in it, and it's pretty easy to fall off into the void.

I would never think to play this on a server against a human player in tournament mode... but it does look
pretty cool and it is pretty cool as a final boss level.

While it does have some vertical gameplay, it doesn't have the type of vertical gameplay that the other
(4) space maps have...

======================================
| Title            | Name   | Rating |
======================================             
| Bouncy Map       | q3dm16 |   8/10 |
| The Longest Yard | q3dm17 |  10/10 |
| Space Chamber    | q3dm18 |   8/10 |
| Apocalypse Void  | q3dm19 |   7/10 |
======================================

I'm not going to discuss these levels at great length, but they all have plenty of vertical gameplay.

Multi-tiered combat isn't everything, however.
Item placement is pretty important, but also...
So is the bot behavior, or just general all around mechanics going on in the map.

[Bouncy Map] is fun, but the lighting is pretty flat.
[The Longest Yard] is fun, but the bots are pretty tough when they have the [railgun].
[Space Chamber] is fun, but it is wicked annoying because of how many ways you can fall into the void.
[Apocalypse Void] feels really gimmicky and the platforms aren't much different than jump pads.

While I really like [The Longest Yard], it is not a very competitive tournament level at all.
None of them really are.

However, [Space Station 1138] is a pretty competitive space based tournament level with vertical
gameplay... I don't think it ever received a title or designation to where people would play it.

Typically speaking, most community maps that are made for the game don't get a lot of credit or acclaim,
and that's just how it's always been in the Quake community. Even really well made levels that got high
ratings on [..::LvL] don't have a place where people flock to it and play it in a standard rotation.

That's mainly because, in order to play custom levels, you have to fulfill a lot of instructions.
All things considered, I made that level when I was (15) years old for a mapping competition, and the
limitations were like (100) brushes I think.

Whereas the tournament levels in [Quake III Arena] and [Quake III Team Arena], those were part of an
official game released by [id Software], so they're not going to pull any punches in publishing them.

Now, in order to build any level that will be a total success...?
It relies on the initial shape of the map...
...which requires some [graph paper], and drawing it out.
"@)

$Doc.Add("Shape",@"
The [shaping] process can actually take days, but the end result will be something highly polished, and
this can be seen in a number of levels that were made for [Quake Live], like... [Heavy Rain].

[Heavy Rain] is one of the coolest maps I've ever played, it has a general shape.
There's also [Aerowalk], though I believe that is a take on a [Quakeworld] level... that has a shape too.
Then there's also [Blood Run], which is the most official tournament level I can think of that was
never a part of the game itself. That too, has a shape.

But even if we take a look at [Quake II], and even [Quake I], there are plenty of examples of great maps
there, too.

==================================
| Title         | Name  | Rating |
==================================
| The Edge      | q2dm1 |  10/10 |  
| Tokays Towers | q2dm2 |   8/10 |
| The Frag Pipe | q2dm4 |   8/10 |
| The Sewers    | q2dm7 |   7/10 |
| The Warehouse | q2dm8 |  10/10 |
==================================

There are even more from [Quake I] that I cannot remember for the life of me...
...but [Tim Willits] really knew what the hell he was doin', because I think he was responsible for
many of these maps, especially [q2dm1].

People still play [q2dm1] competitively, it's a great example of a map that works for tournament and
free-for-all, but every adaptation to [Quake III Arena] has been less than exhilirating than the
original. It has a lot of vertical gameplay to it, multiple tiers, a pretty balanced layout, and it
has a really unique shape to it that I've never seen be reproduced in a manner to where I was as
impressed or blown away.

[q2dm1] is by far, one of the best maps I've ever seen.
And even the rest of the maps I just listed, they're really good.
Even [The Pits/q2dm5] is good... it's just that some of these maps really delve into being a bit of a
breathing entity itself, with an environment.

But NOW, the question is, how does one go about creating the shape for these maps...?

Well, imagine if you would, that you could have a conversation with [Carl Sagan] himself, and ask him how
to build a 4 dimensional tesseract, and then build a level off of that.

That's sort of the process involved in making a really good level like the ones I just described.
There are a lot of others that I haven't mentioned, but I can't remember all of the really well made
levels I've played.

The bottom line, is that a good map has to have a general flow to it where players can traverse the map
in multiple ways, and further to that point, it has to be really polished, have a good amount of flow
to it, have the items placed in ways where it makes perfect sense and is advantageous to the players,
and then you have to top it all off with well executed aesthetics, geometry, and lighting.

All of these things are reasons why I really like [House of Decay], and [Evil Playground].
Cause they tick every single box, repeatedly.

Fact of the matter is, this process is different in its chronological execution as the map is being built.
There's really no one size fits all approach, as every approach is rather unique and changes from one idea
to the next.

Graph paper is a pretty great way to start out, because then you can layer the graph paper with additional
shapes and such, and overlay them in order to get a "feel" for how the map is going to flow.

[Tokays Towers] is a great example of a level that has vertical gameplay down pat, and... to this day, I
sometimes think about how I would go from one end of the map to the other, top to bottom, et cetera. The
only thing I never liked about it is swimming through the water.

Swimming through water is NOT a good design philosophy in ANY tournament level...
Using jump pads is NOT a good design philosophy all the time, but it does allow the level creator to make
better use of space.

Using little alcoves from one end of a map to another to tuck away ammo boxes doesn't make a lot of sense
in many cases unless those boxes of ammo just so happen to be conveniently placed along a path between
armor, health, and specific weapons.

Lastly, before I talk about applying all of these things in conjunction, I can't stress this enough...
...but even if a map is shaped perfectly, and it is textured great, the aesthetics are awesome, the
lighting is superb, and the item placement seems to be well executed...

...a map can still suffer from not being all that fun to play.

If people feel like the map is a chore to play...?
Then, all of that hard work will have been for nothing.

As a general rule of thumb for shaping the level, think of really basic shapes like squares, rectangles,
beveled surfaces and curves, and incorporate them into the bottom line structure of the map before adding
things like trim, edges, light fixtures, models, and things of that nature.

Because, a rough draft of a level doesn't even need to be textured or lit all that well, for a map to have
some REALLY promising gameplay to it. The point being, creating the structure of the map AROUND the item
placement, and item control... is a really good idea.
"@)

$Doc.GetOutput() -join "`n" | Set-Clipboard
