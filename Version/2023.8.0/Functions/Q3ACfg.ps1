Class Q3ACfgProperty
{
    [UInt32]   $Index
    [Uint32]    $Rank
    [String]    $Name
    [String]   $Value
    [String] $Comment
    Q3ACfgProperty([UInt32]$Rank,[String]$Name,[String]$Value,[String]$Comment)
    {
        $This.Rank    = $Rank
        $This.Name    = $Name
        $This.Value   = $value
        $This.Comment = $Comment
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class Q3ACfgSection
{
    [UInt32]    $Index
    [String]     $Name
    [Object] $Property
    Q3ACfgSection([UInt32]$Index,[String]$Name)
    {
        $This.Index    = $Index
        $This.Name     = $Name
        $This.Property = @( )
    }
    [Object] Q3ACfgProperty([UInt32]$Rank,[String]$Name,[String]$Value,[String]$Comment)
    {
        Return [Q3ACfgProperty]::New($Rank,$Name,$Value,$Comment)
    }
    Add([String]$Name,[String]$Value,[String]$Comment)
    {
        $Item = $This.Q3ACfgProperty($This.Property.Count,$Name,$Value,$Comment)
        
        [Console]::WriteLine("Added [+] $($Item.Name)/$($Item.Value)")

        $This.Property += $Item
    }
    [String] ToString()
    {
        Return "({0}) {1}" -f $This.Property.Count, $This.Name
    }
}

Class Q3ACfgFile
{
    [String]     $Path
    [UInt32] $Selected
    [Object]  $Section
    Q3ACfgFile([String]$Path)
    {
        $This.Path    = $Path
        $This.Section = @( )
    }
    [Object] Q3ACfgSection([Uint32]$Index,[String]$Name)
    {
        Return [Q3ACfgSection]::New($Index,$Name)
    }
    Add([String]$Name)
    {
        $Item = $This.Q3ACfgSection($This.Section.Count,$Name)

        [Console]::WriteLine("Added [+] $($Item.Name)")

        $This.Section += $Item
    }
    Select([UInt32]$Index)
    {
        If ($Index -gt $This.Section.Count)
        {
            Throw "Invalid selection"
        }

        $This.Selected = $Index
    }
    [Object] Current()
    {
        If ($Null -eq $This.Selected)
        {
            Throw "Invalid selection"
        }

        Return $This.Section[$This.Selected]
    }
    [Object[]] Output()
    {
        Return $This.Section.Property
    }
    [String] ToString()
    {
        Return $This.Path
    }
}

$Cfg = [Q3ACfgFile]::New("C:\Program Files (x86)\Quake III Arena\baseq3\autoexec.cfg")
$Cfg.Add("Engine Configuration")
$Cfg.Select(0)

<# 
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Engine Configuration [+]                                                                       ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta com_altivec","0","enables altivec support (0: off, 1: on)"),
("seta com_ansicolor","0","enable use of ansi escape codes"),
("seta r_smp","0","enables the use of multi processor acceleration code (0: off, 1: on)"),
("seta r_ignorefastpath","1","disables looking outside of the pak file first in case of duplicate file names (0: off, 1: on)"),
("seta vm_cgame","2","determines how a game module is loaded (0: load native, 1: load qvm and interpret it, 2: load qvm and compile it)"),
("seta vm_game","2","determines how a game module is loaded (0: load native, 1: load qvm and interpret it, 2: load qvm and compile it)"),
("seta vm_ui","2","determines how a game module is loaded (0: load native, 1: load qvm and interpret it, 2: load qvm and compile it)") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<# 
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Memory [+]                                                                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
    These values are set [before] any config file is loaded, therefore add the corresponding commands into a shortcut
    e.g. "x:\...\q3io\ioquake3_v1.33_intel.exe +set com_hunkmegs 77 +set com_soundmegs 16 +set com_zonemegs 24 ..."
#>

("seta com_hunkmegs","77","set the amount of memory you want your engine to reserve for the game"),
("seta com_soundmegs","16","set the amount of memory you want your engine to reserve for sounds (subtracted from com_hunkmegs)"),
("seta com_zonemegs","24","set the amount of memory you want your engine to reserve for map textures (subtracted from com_hunkmegs)") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Graphics Card/Drivers Configuration [+]                                                        ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta cm_playercurveclip","1","toggles the ability of the player bounding box to respect curved surfaces"),
("seta r_finish","1","enables synchronization of rendered frames, engine will wait for gl calls to finish (0: off, 1: on)"),
("seta r_ignoreglerrors","1","ignores opengl errors that occur (0: off, 1: on)"),
("seta r_allowextensions","0","enables all opengl extensions your card is capable of (0: off, 1: on)"),
("seta r_allowsoftwaregl","0","do not abort out if the pixelformat claims software (used for macos)"),
("seta r_primitives","0","set the rendering method (-1: skips drawing results in black screen, 0: uses glDrawElements if compiled vertex arrays are present or strips of glArrayElement if not present, 1: forces strips, 2: forces drawElements, 3: path for non-vertex array testing)") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ 3D Settings [+]                                                                                ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta cg_stereoseparation","0","the amount of stereo separation for 3d glasses, splits color channels (0.4: default)"),
("seta r_anaglyphmode","0","ioq3: enable rendering of anaglyph images (1-8)"),
("seta r_greyscale","0","ioq3: desaturate textures, useful for anaglyph (0 to 1)"),
("seta r_stereoenabled","0","ioq3: enable stereo rendering for techniques like shutter glasses (0: off, 1: on)"),
("seta r_stereoseparation","64","ioq3: control eye separation (resulting separation is r_zproj divided by this value in quake3 standard units"),
("seta r_zproj","64","ioq3: distance of observer camera to projection plane in quake3 standard units") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Sound Card/Drivers Configuration [+]                                                           ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta s_khz","22","set audio sample rate (11 or 22)"),
("seta s_doppler","1","enables a better recognition of rocket directions ('swoosh' sound)"),
("seta s_mixahead","0.2","sound delay in seconds (fixes stuttering problems on some sound cards)"),
("seta s_mixprestep","0.09","set the prefetching of sound on sound cards that have that power"),
("seta s_useopenal","1","enables openal library"),
("seta s_aldriver","OpenAL32.dll","used openal library"),
("seta s_aldevice","DirectSound Software","used openal device"),
("seta s_alsources","96","the total number of sources (memory) to allocate"),
("seta s_alcapture","1","opens an openal capture device on the audio layer (1: default)"),
("seta s_aldopplerfactor","1.0","the value passed to aldopplerfactor"),
("seta s_aldopplerspeed","13512","the value passed to aldopplervelocity (default: 2200)"),
("seta s_algain","1.0","the value of al_gain for each source"),
("seta s_almindistance",	"","the value of al_reference_distance for each source"),
("seta s_almaxdistance","1024","the maximum distance before sounds start to become inaudible"),
("seta s_algracedistance","512","after having passed maxdistance, length until sounds are completely inaudible"),
("seta s_alprecache","1","enables pre-caching of sounds"),
("seta s_alrolloff","2","the value of al_rolloff_factor for each source") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Voice Over IP [+]                                                                              ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta cl_voip","0","ioq3: enables client-side voip support"),
("seta cl_voipcapturemult","2.0","ioq3: sets the value the recorded audio is multiplied after denoising"),
("seta cl_voipgainduringcapture","0.2","ioq3: volume ('gain') of audio coming out of your speakers while you are recording sound for transmission"),
("seta cl_voipusevad","0","ioq3: automatic voice recognition (0: off = manual transmitting, 1: on)"),
("seta cl_voipvadthreshold","0.25","ioq3: treshhold volume of filtering noises, used with enabled cl_voipusevad (0 to 1)"),
("seta cl_voipshowmeter","1","ioq3: enables a microphone meter (0: off, 1: on)"),
("seta cl_voipsendtarget","all","ioq3: ?"),
("seta cl_usemumble","0","ioq3: enables mumble (see http://mumble.sourceforge.net)"),
("seta cl_mumblescale","0.0254","ioq3: ?") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Input Configuration [+]                                                                        ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta in_mouse","-1","initialization of the mouse as an input device (-1: windows grabbing, 0: off, 1: direct input); -1: the lower the q3 resolution and framerate the more clipping errors will appear, higher mouse sampling rates or r_finish should be used, cpl mouse fix (or alternative) must be usedto eliminate windows enabling pointer prescision automatically for games in windows xp; 1: applies ca. 12 ms worth of mouse smoothing automatically before reaching the sensitivity and acceleration part of the q3 code, adds latency and delay"),
("seta in_logitechbug","0","fixes bug with logitech mousewheel"),
("seta cl_freelook","1","use of freelook with the mouse (ability to look up and down)"),
("seta in_debugjoystick","0","set the debug level of direct input"),
("seta in_joystick","0","initialization of the joystick"),
("seta in_joystickthreshold","0.15","threshold of joystick moving dictance"),
("seta in_joystickdebug","0","print joystick debug info"),
("seta in_joyballscale","0.02","sets the scale of a joyball rotation to player model rotation"),
("seta cl_consolekeys","~  0x7e 0x60","ioq3: keys to toggle console"),
("seta in_keyboarddebug","0","print keyboard debug info")| % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}
<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Network Configuration [+]                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

("seta cl_curllib","libcurl-3.dll","filename of curl library to load"),
("seta net_enabled","3","enable networking (bitmask); - 1: enable ipv4 networking;- 2: enable ipv6 networking;- 4: prioritise ipv6 over ipv4;- 8: disable multicast support"),
("seta net_mcast6addr","ff04::696f:7175:616b:6533","multicast address to use for scanning for ipv6 servers on the local network"),
("seta net_mcast6iface","0","outgoing interface to use for scan"),
("seta net_socksenabled","0","toggle the use of network socks 5 protocol enabling firewall access"),
("seta net_socksserver","","set the address (name or ip number) of the socks server (firewall machine)"),
("seta net_socksport","1080","set proxy and/or firewall port (default: 1080)"),
("seta net_socksusername","","username for socks firewall access, supports no authentication and username/password authentication method (rfc-1929), it does not support gss-api method (rfc-1961) authentication"),
("seta net_sockspassword","","password for socks firewall access, supports no authentication and username/password authentication method (rfc-1929), it does not support gss-api method (rfc-1961) authentication") | % { 

    $Cfg.Current().Add($_[0],$_[1],$_[2])
}

<#
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Personal Configuration [+]                                                                     ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

<#
// generated by quake, do not modify
unbindall
bind TAB "+scores"
bind ENTER "messagemode"
bind ESCAPE "togglemenu"
bind SPACE "weapon 5"
bind + "sizeup"
bind - "sizedown"
bind 0 "weapon 10"
bind 1 "weapon 1"
bind 2 "weapon 2"
bind 3 "weapon 3"
bind 4 "weapon 4"
bind 5 "weapon 5"
bind 6 "weapon 6"
bind 7 "weapon 7"
bind 8 "weapon 8"
bind 9 "weapon 9"
bind = "sizeup"
bind \ "+button2"
bind _ "sizedown"
bind ` "toggleconsole"
bind d "+back"
bind e "+forward"
bind f "+moveright"
bind h "+button3"
bind j "toggle cg_draw2d"
bind q "weapon 6"
bind r "weapon 7"
bind s "+moveleft"
bind t "weapon 2"
bind w "weapon 4"
bind ~ "toggleconsole"
bind PAUSE "pause"
bind CTRL "+speed"
bind SHIFT "+movedown"
bind F1 "vote yes"
bind F2 "vote no"
bind F3 "ui_teamorders"
bind F11 "screenshot"
bind MOUSE1 "+attack"
bind MOUSE2 "+moveup"
bind MOUSE3 "+zoom"
bind MWHEELDOWN "weapprev"
bind MWHEELUP "weapnext"
seta g_allowVote "1"
seta g_filterBan "1"
seta g_banIPs ""
seta g_logSync "0"
seta g_log "games.log"
seta g_warmup "20"
seta g_teamForceBalance "0"
seta g_teamAutoJoin "0"
seta g_friendlyFire "0"
seta capturelimit "8"
seta g_maxGameClients "0"
seta sv_maxclients "8"
seta timelimit "0"
seta fraglimit "10"
seta dmflags "0"
seta net_noipx "0"
seta net_noudp "0"
seta server16 ""
seta server15 ""
seta server14 ""
seta server13 ""
seta server12 ""
seta server11 ""
seta server10 ""
seta server9 ""
seta server8 ""
seta server7 ""
seta server6 ""
seta server5 ""
seta server4 ""
seta server3 ""
seta server2 ""
seta server1 ""
seta cg_marks "1"
seta cg_drawCrosshairNames "1"
seta cg_drawCrosshair "4"
seta cg_brassTime "2500"
seta ui_browserShowEmpty "1"
seta ui_browserShowFull "1"
seta ui_browserSortKey "4"
seta ui_browserGameType "0"
seta ui_browserMaster "0"
seta g_spSkill "5"
seta g_spVideos "\tier1\1"
seta g_spAwards "\a4\15"
seta g_spScores5 "\l0\1\l24\1"
seta g_spScores4 ""
seta g_spScores3 ""
seta g_spScores2 ""
seta g_spScores1 ""
seta ui_ctf_friendly "0"
seta ui_ctf_timelimit "30"
seta ui_ctf_capturelimit "8"
seta ui_team_friendly "1"
seta ui_team_timelimit "20"
seta ui_team_fraglimit "0"
seta ui_tourney_timelimit "15"
seta ui_tourney_fraglimit "0"
seta ui_ffa_timelimit "0"
seta ui_ffa_fraglimit "20"
seta s_separation "0.5"
seta s_musicvolume "0.25"
seta s_volume "1"
seta vid_ypos "22"
seta vid_xpos "3"
seta r_lastValidRenderer "Intel(R) HD Graphics 3000"
seta r_railSegmentLength "32"
seta r_railCoreWidth "6"
seta r_railWidth "16"
seta r_facePlaneCull "1"
seta r_gamma "1"
seta r_swapInterval "0"
seta r_textureMode "GL_LINEAR_MIPMAP_NEAREST"
seta r_dlightBacks "1"
seta r_dynamiclight "1"
seta r_drawSun "0"
seta r_fastsky "0"
seta r_flares "0"
seta r_lodbias "0"
seta r_lodCurveError "250"
seta r_subdivisions "4"
seta r_vertexLight "0"
seta r_simpleMipMaps "1"
seta r_customaspect "1"
seta r_customheight "768"
seta r_customwidth "1366"
seta r_fullscreen "1"
seta r_mode "-1"
seta r_ignorehwgamma "1"
seta r_overBrightBits "1"
seta r_depthbits "0"
seta r_stencilbits "8"
seta r_stereo "0"
seta r_colorbits "0"
seta r_texturebits "0"
seta r_detailtextures "1"
seta r_roundImagesDown "1"
seta r_picmip "1"
seta r_ext_texture_env_add "1"
seta r_ext_compiled_vertex_array "1"
seta r_ext_multitexture "1"
seta r_ext_gamma_control "1"
seta r_ext_compressed_textures "0"
seta r_glDriver "opengl32"
seta cg_viewsize "100"
seta cg_predictItems "1"
seta cl_punkbuster "0"
seta cl_anonymous "0"
seta sex "male"
seta handicap "100"
seta color2 "5"
seta color1 "4"
seta g_blueTeam ""
seta g_redTeam ""
seta team_headmodel "doom/default"
seta team_model "doom/default"
seta headmodel "doom/default"
seta model "doom/default"
seta snaps "20"
seta rate "25000"
seta name "^1<^2|3FG^320^2K^1>"
seta cl_maxPing "800"
seta m_filter "0"
seta m_side "0.25"
seta m_forward "0.25"
seta m_yaw "0.022"
seta m_pitch "0.022000"
seta cg_autoswitch "1"
seta r_inGameVideo "1"
seta cl_allowDownload "0"
seta cl_mouseAccel "0"
seta sensitivity "2"
seta cl_run "1"
seta cl_packetdup "1"
seta cl_maxpackets "30"
seta cl_pitchspeed "140"
seta cl_yawspeed "140"
seta sv_strictAuth "1"
seta sv_lanForceRate "1"
seta sv_master5 ""
seta sv_master4 ""
seta sv_master3 ""
seta sv_master2 ""
seta sv_floodProtect "1"
seta sv_maxPing "0"
seta sv_minPing "0"
seta sv_maxRate "0"
seta sv_punkbuster "0"
seta sv_hostname "noname"
seta joy_threshold "0.150000"
seta in_mididevice "0"
seta in_midichannel "1"
seta in_midiport "1"
seta in_midi "0"
seta com_introplayed "1"
seta com_blood "1"
seta com_maxfps "0"
seta net_sockspassword ""
seta net_socksusername ""
seta net_socksport "1080"
seta net_socksserver ""
seta net_socksenabled "0"
seta net_mcast6iface "0"
seta net_mcast6addr "ff04::696f:7175:616b:6533"
seta net_enabled "3"
seta cl_curllib "libcurl-3.dll"
seta in_keyboarddebug "0"
seta cl_consolekeys "~  0x7e 0x60"
seta in_joyballscale "0.02"
seta in_joystickdebug "0"
seta in_joystickthreshold "0.15"
seta in_joystick "0"
seta in_debugjoystick "0"
seta cl_freelook "1"
seta in_logitechbug "0"
seta in_mouse "-1"
seta cl_mumblescale "0.0254"
seta cl_usemumble "0"
seta cl_voipsendtarget "all"
seta cl_voipshowmeter "1"
seta cl_voipvadthreshold "0.25"
seta cl_voipusevad "0"
seta cl_voipgainduringcapture "0.2"
seta cl_voipcapturemult "2.0"
seta cl_voip "0"
seta s_alrolloff "2"
seta s_alprecache "1"
seta s_algracedistance "512"
seta s_almaxdistance "1024"
seta s_almindistance ""
seta s_algain "1.0"
seta s_aldopplerspeed "13512"
seta s_aldopplerfactor "1.0"
seta s_alcapture "1"
seta s_alsources "96"
seta s_aldevice "DirectSound Software"
seta s_aldriver "OpenAL32.dll"
seta s_useopenal "1"
seta s_mixprestep "0.09"
seta s_mixahead "0.2"
seta s_doppler "1"
seta s_khz "22"
seta r_zproj "64"
seta r_stereoseparation "64"
seta r_stereoenabled "0"
seta r_greyscale "0"
seta r_anaglyphmode "0"
seta cg_stereoseparation "0"
seta r_primitives "0"
seta r_allowsoftwaregl "0"
seta r_allowextensions "0"
seta r_ignoreglerrors "1"
seta r_finish "1"
seta cm_playercurveclip "1"
seta com_soundmegs "16"
seta com_hunkmegs "77"
seta vm_ui "2"
seta vm_game "2"
seta vm_cgame "2"
seta r_ignorefastpath "1"
seta r_smp "0"
seta com_ansicolor "0"
seta com_altivec "0"
seta cg_shadows "1"
seta cg_drawGun "1"
seta cg_zoomfov "22.5"
seta cg_fov "100"
seta cg_gibs "1"
seta cg_draw2D "1"
seta cg_drawStatus "1"
seta cg_drawTimer "0"
seta cg_drawFPS "1"
seta cg_drawSnapshot "0"
seta cg_draw3dIcons "1"
seta cg_drawIcons "1"
seta cg_drawAmmoWarning "1"
seta cg_drawAttacker "1"
seta cg_drawRewards "1"
seta cg_crosshairSize "24"
seta cg_crosshairHealth "1"
seta cg_crosshairX "0"
seta cg_crosshairY "0"
seta cg_simpleItems "0"
seta cg_lagometer "1"
seta cg_railTrailTime "400"
seta cg_runpitch "0.002"
seta cg_runroll "0.005"
seta cg_bobpitch "0.002"
seta cg_bobroll "0.002"
seta cg_teamChatTime "3000"
seta cg_teamChatHeight "0"
seta cg_forceModel "0"
seta cg_deferPlayers "1"
seta cg_drawTeamOverlay "0"
seta cg_drawFriend "1"
seta cg_teamChatsOnly "0"
seta cg_noVoiceChats "0"
seta cg_noVoiceText "0"
seta cg_cameraOrbitDelay "50"
seta cg_scorePlums "1"
seta cg_smoothClients "0"
seta cg_noTaunt "0"
seta cg_noProjectileTrail "0"
seta ui_smallFont "0.25"
seta ui_bigFont "0.4"
seta cg_oldRail "1"
seta cg_oldRocket "1"
seta cg_oldPlasma "1"
seta cg_trueLightning "0.0"
seta com_zoneMegs "24"
#>
