# ----------------------------------------
# Classes/Lesson plan for building classes
# ----------------------------------------

# --------------------------------------------------------------------------------------------------
# Get Programs - Just collect the first object from Get-WMIObject Win32_Product
# --------------------------------------------------------------------------------------------------

$WMIList         = (Get-WMIObject Win32_Product)[0]

# --------------------------------------------------------------------------------------------------
# Get properties from PSObject whose names don't start with either _ or PS. The regex code at the 
# end prevents standard PS and WMI class properties from being included in the class definition
# --------------------------------------------------------------------------------------------------

$Properties      = $WMIList.PSObject.Properties | ? Name -notmatch "(^_|^PS)"

# --------------------------------------------------------------------------------------------------
# We want to format the class with the right spacing. So, get the maximum TypeNameOfValue string length
# There's some of my "Voodoo 3 5000" action being applied to the $Types variable. 
# --------------------------------------------------------------------------------------------------

$Types           = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length

# --------------------------------------------------------------------------------------------------
# Now, get maximum Name string length. No "Voodoo 3 5000" action goin' on here.
# --------------------------------------------------------------------------------------------------

$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length )[-1].Length

# --------------------------------------------------------------------------------------------------
# Declare a hash table with 1) CLASSNAME, 2) PROPERTY TYPES/NAMES (top portion of class), 
# 3) TYPE+PARAMETER (main method), and DEFAULT CONSTRUCTOR DEFINITIONS (main portion of the class)
# --------------------------------------------------------------------------------------------------

$Def             = @{ 
    Name         = "Win32_Product" 
    Type         = @( ) 
    Param        = "[Object]`$WMIObject"
    Const        = @( )
}

# --------------------------------------------------------------------------------------------------
# Run through all types, property names, and establish the code to set the class values to the 
# properties of the (input object/parameter). Add each TYPE+NAME to $Def.Type array, and then each 
# $Name in $Names with spacing for the $Def.Const array in the same loop.
# --------------------------------------------------------------------------------------------------

ForEach ($X in 0..($names.Count-1)) 
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param
}

# --------------------------------------------------------------------------------------------------
# Now, we can write it all to a class definition, and either copy it to the clipboard, or write it 
# to the console, and copy paste it that way back into the editor.
# --------------------------------------------------------------------------------------------------

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param))", "    {",($Def.Const -join "`n"),"    }","}") -join "`n"

# --------------------------------------------------------------------------------------------------
# Instantiate the class definition - this enables the class to be used without having to explicitly 
# write the $Classdefinition output to the clipboard or the editor.
# --------------------------------------------------------------------------------------------------

Invoke-Expression $ClassDefinition

# --------------------------------------------------------------------------------------------------
# Now, to collect ALL of those WMI objects, this may or may not take more time than the first time 
# (Get-WMIObject Win32_Product) was accessed above.
# --------------------------------------------------------------------------------------------------

$Collect         = Get-WMIObject Win32_Product | % { [Win32_Product]$_ }    # Or...
# $Collect       = [Win32_Product[]]@(Get-WMIObject Win32_Product)          # They do the same thing.

# --------------------------------------------------------------------------------------------------
# https://xkln.net/blog/please-stop-using-win32product-to-find-installed-software-alternatives-inside/ 
# These guys say: Don't use Get-WMIObject Win32_Product anymore... it's slow, incomplete, problematic, 
# not optimized, it's just a bad way to go about getting that information anyway. If you wanna go pro...? 
# Use the registry and look for the following keys/paths...
# --------------------------------------------------------------------------------------------------
# 64-bit | HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
# 32-bit | HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall
# --------------------------------------------------------------------------------------------------
# So, the PROS/EXPERTS actually use this way faster/cooler method, of accessing the registry
# --------------------------------------------------------------------------------------------------

$Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty

# PS Prompt:\> $Apps

# DisplayName     : Visual Studio Community 2022
# InstallDate     : 20220402
# InstallLocation : C:\Program Files\Microsoft Visual Studio\2022\Community
# DisplayVersion  : 17.1.6
# Publisher       : Microsoft Corporation
# DisplayIcon     : C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe
# UninstallString : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" uninstall --installPath "C:\Program Files\Microsoft Visual Studio\2022\Community"
# ModifyPath      : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Community"
# RepairPath      : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" repair --installPath "C:\Program Files\Microsoft Visual Studio\2022\Community"
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\889e9450
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
# PSChildName     : 889e9450
# PSProvider      : Microsoft.PowerShell.Core\Registry

# DisplayName     : CCleaner
# UninstallString : "C:\Program Files\CCleaner\uninst.exe"
# Publisher       : Piriform
# InstallLocation : C:\Program Files\CCleaner
# VersionMajor    : 6
# VersionMinor    : 0
# DisplayVersion  : 6.00
# DisplayIcon     : C:\Program Files\CCleaner\CCleaner64.exe
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\CCleaner
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall
# PSChildName     : CCleaner
# PSProvider      : Microsoft.PowerShell.Core\Registry

# --------------------------------------------------------------------------------------------------
# However, they all have differing properties/entries in the registry - they're very different from 
# (Get-WMIObject Win32_Product). WAY different. So... defining a class may be difficult to do, UNLESS
# there's a way to determine which TYPE of registry entry each of them may be, or we could even pull a
# template object and use that to draft the class... then we can provide an abstract way to force
# all of the items in $Apps to fit within the same class.
# --------------------------------------------------------------------------------------------------
# To do this, lets start with a common application that was installed via MSI, since that has standard 
# options and the most consistency (so, like Microsoft Edge, or Google Chrome...)
# --------------------------------------------------------------------------------------------------

$Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$|^Google Chrome$)" 

# PS Prompt:\> $Edge

# DisplayName     : Microsoft Edge
# DisplayVersion  : 101.0.1210.39
# Version         : 101.0.1210.39
# NoRemove        : 1
# ModifyPath      : "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" /install appguid={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}&appname=Microsoft%20Edge&needsadmin=true&repairtype=windowsonlinerepair /installsource windows      
# UninstallString : "C:\Program Files (x86)\Microsoft\Edge\Application\101.0.1210.39\Installer\setup.exe" --uninstall --msedge --channel=stable --system-level --verbose-logging
# InstallLocation : C:\Program Files (x86)\Microsoft\Edge\Application
# DisplayIcon     : C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0
# NoRepair        : 1
# Publisher       : Microsoft Corporation
# InstallDate     : 20220507
# VersionMajor    : 1210
# VersionMinor    : 39
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
# PSChildName     : Microsoft Edge
# PSProvider      : Microsoft.PowerShell.Core\Registry

# --------------------------------------------------------------------------------------------------
# This time, we want to add a property for NON-DEFAULT registry keys in this uninstall path folder. 
# --------------------------------------------------------------------------------------------------
# Entries with NON-DEFAULT registry keys are similar to when somebody doesn't fit into the typical 
# mold that most people in society fit into. Cause, they're different than everybody else. They have
# WAY different properties, and they're hard to expect. People might get upset and say:
# --------------------------------------------------------------------------------------------------
# Default: Hey buddy... why you always gotta be WAY different than everybody else?
# Non-Default: Cause, I don't fit the typical mold most people in society fit into...
# Default: *Everybody shakes their head* That's obnoxious.
# Non-Default: No way buddy, *points back at em* YOU'RE the obnoxious one, pal... askin me why I 
# gotta be different...? That's about the most obnoxious thing anybody could even SAY or DO...
# Default: I could literally ask all of the people here, in this room, what they're properties are...
# ...and they're gonna tell me that they have default properties that we all seem to have.
# Non-Default: Not me though.
# Default: Yeah. I know. That's why we're all collectively sighing at you being way different...
# Non-Default: It's cause I'm advanced... you can't even expect what properties I contain...
# Default: Yeah. That's... why we can't stand ya sometimes pal.
# Non-Default: Just cause I'm advanced, doesn't mean I'm a bad person, dude...
# Default: Well, nobody ever said that you were a bad person...
# Non-Default: Sounded like it though...
# Default: On any given day, your name could change to Kevin, and you somehow change in age and weight,
# you're like a shape shifter...
# Non-Default: ...it's cause I'm advanced, isn't it...?
# Default: Yeah buddy... Sure. It's cause you're advanced. Next week your name'll be Jeff.
# Non-Default: Yeah...? Maybe it WILL be. Oh well. You act like it's such a heavy burden...
# Default: It is! *shakes head* This dude really is unbelievable... *everyone collectively agrees*
# --------------------------------------------------------------------------------------------------
# Now, NON-DEFAULT registry keys in these uninstall paths (64-bit/32-bit) may contain some very old
# school entries that aren't updated anymore. So, whether those entries are ADVANCED, or just OLD...
# Don't get down on registry keys in this folder if their properties aren't the same as everybody 
# elses. Because, we can actually implement a DESIGN CHANGE to the CLASS that ACCOMMODATES any 
# *unexpected properties*. They won't be a part of the BASE class properties, but they'll still be
# visible and accessible. So, everybody actually wins.
# --------------------------------------------------------------------------------------------------
# There's a few ways we could do this, we could ADD a member to each class for EACH property.
# However, that isn't a great idea. That will make many of them TOO DIFFERENT, and not adhere to a 
# TABLE, as they'll be TOO unique in some cases. Then, everybody will have to collectively sigh at 
# the "advanced" guy's properties. So, the best option would be to create a property that can host 
# those "extraneous" properties, and that property's value will be an object that can host an array
# of ADDITIONAL properties and values that are NON-DEFAULT. That is the best way to go, actually.
# --------------------------------------------------------------------------------------------------
# Now, lets choose a property name like "EntryUnique". If we add this property BEFORE we access the 
# PSObject.Properties, this won't mess with the formatting of the previously written stuff above. 
# --------------------------------------------------------------------------------------------------
# We're also gonna need to ADD a few METHODS to this class (methods are nested functions), so it can
# refer to itself, provide self referencing brevity, and process/convert each individual "extraneous" 
# property, into an object array for each property. Then, we want to have a method that can format 
# all of those objects and properties and write the output.
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# We'll run through the script again... but with a few added steps and more explanations.
# 
# Get properties from $Edge.PSObject.Properties where the name doesn't start with either "_" or "PS"
# --------------------------------------------------------------------------------------------------

$Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"

# --------------------------------------------------------------------------------------------------
# To adhere to the script that applies spacing and formatting, and NOT have to include an additional 
# script at the end that adds the new property, we can inject an additional property into the variable, 
# $Properties. But FIRST, we need to understand what TYPE of object it is, to instantiate that TYPE.
# --------------------------------------------------------------------------------------------------
# What does this variable get us back in the console...?
# --------------------------------------------------------------------------------------------------

# PS Prompt:\> $Properties

# Value                                 MemberType   IsSettable IsGettable TypeNameOfValue Name            IsInstance
# -----                                 ----------   ---------- ---------- --------------- ----            ----------
# Microsoft Edge                        NoteProperty       True       True System.String   DisplayName           True
# 101.0.1210.39                         NoteProperty       True       True System.String   DisplayVersion        True
# 101.0.1210.39                         NoteProperty       True       True System.String   Version               True
# 1                                     NoteProperty       True       True System.Int32    NoRemove              True
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   ModifyPath            True
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   UninstallString       True
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   InstallLocation       True
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   DisplayIcon           True
# 1                                     NoteProperty       True       True System.Int32    NoRepair              True
# Microsoft Corporation                 NoteProperty       True       True System.String   Publisher             True
# 20220507                              NoteProperty       True       True System.String   InstallDate           True
# 1210                                  NoteProperty       True       True System.Int32    VersionMajor          True
# 39                                    NoteProperty       True       True System.Int32    VersionMinor          True
# {}                                    NoteProperty       True       True System.Object[] EntryUnique           True

# --------------------------------------------------------------------------------------------------
# Looks like your standard, ordinary, run-of-the-mill object collection table. In order to add a NEW 
# property to this list of properties, we have to figure out what each of these objects actually are.
# The $Properties.GetType() method will return the "Object Type" object as seen below.
# --------------------------------------------------------------------------------------------------

# PS Prompt:\> $Properties.GetType()

# IsPublic IsSerial Name                                     BaseType
# -------- -------- ----                                     --------
# True     True     Object[]                                 System.Array

# --------------------------------------------------------------------------------------------------
# So, it's an object array, which is easy to spot because of the ol' double square brackets there.
# We sorta knew this from the object collection table up above. But, in order to ADD a new object to
# it, we have to determine what TYPE these objects in the array actually are, and then add that TYPE.
# --------------------------------------------------------------------------------------------------
# Select the first item of the array to determine what type of object array it is.
# --------------------------------------------------------------------------------------------------

# PS Prompt:\> $Properties[0].GetType()

# IsPublic IsSerial Name                                     BaseType
# -------- -------- ----                                     --------
# True     False    PSNoteProperty                           System.Management.Automation.PSPropertyInfo

# --------------------------------------------------------------------------------------------------
# Alright, so it's a PSNoteProperty array. We knew that from the object table, but now we can attempt 
# to directly access the underlying base type. Now, is PSNoteProperty an object that anybody could 
# easily instantiate in PowerShell, without calling an assembly or adding a type definition...?
# --------------------------------------------------------------------------------------------------

# PS Prompt:\> New-Object PSNoteProperty
# New-Object: A constructor was not found. Cannot find an appropriate constructor for type PSNoteProperty.

# --------------------------------------------------------------------------------------------------
# Apparently it is, because it wouldn't have come back with a specific error message that says to add
# a constructor... Otherwise, it would've said:
# --------------------------------------------------------------------------------------------------

# New-Object: Cannot find type [PSNoteProperty]: verify that the assembly containing this type is loaded.

# --------------------------------------------------------------------------------------------------
# Since the cmdlet New-Object PSNoteProperty doesn't provide an idea for the PARAMETERS we need to 
# feed it, lets call the .Net base type, via [PSNoteProperty]::New but, with a twist.
# "[PSNoteProperty]::New()" literally does the same thing as "New-Object PSNoteProperty"
# --------------------------------------------------------------------------------------------------

# [PSNoteProperty]::       <- Pressing CTRL+SPACE here in the console will reveal default static methods
# [PSNoteProperty]::New    <- Calling a METHOD without any PARAMETERS or PARENTHESIS will reveal overload definitions...

# OverloadDefinitions
# -------------------
# psnoteproperty new(string name, System.Object value)

# --------------------------------------------------------------------------------------------------
# That looks like some standard issue C# right there. Convert this to PowerShell like so...
# --------------------------------------------------------------------------------------------------

# [PSNoteProperty]::New($Name,$Value)        | The variables $Name + $Value need to be defined already.
# [PSNoteProperty]::New("EntryUnique",@( ))  | This is direct value entry.

# --------------------------------------------------------------------------------------------------
# Compare and Contrast - How is PowerShell nearly identical to C#?
# Calling this object in C# doesn't exactly work the same way, but it is pretty close.
# 
#             C# |  psnoteproperty new(string name, System.Object value)
#     PowerShell | [PSNoteProperty]::New([String]$Name,[Object]$Value)
#     PowerShell | New-Object PSNoteProperty -ArgumentList $Name, $Value
#
# In actuality, calling the above C# code won't work unless you cast it to a variable or the console.
# 
#             C# |  psnoteproperty variable = new psnoteproperty(name, value);
# 
# Now, there are other very subtle differences between the two, but that's another lesson entirely. 
# --------------------------------------------------------------------------------------------------
# Returning to the $Properties variable
# --------------------------------------------------------------------------------------------------

# PS Prompt:\> $Properties[0]

# Value           : Microsoft Edge
# MemberType      : NoteProperty
# IsSettable      : True
# IsGettable      : True
# TypeNameOfValue : System.String
# Name            : DisplayName
# IsInstance      : True

# --------------------------------------------------------------------------------------------------
# In this instance, we really don't care about the membertype, IsSettable, IsGettable, or the 
# IsInstance properties... but we'll adhere to those values anyway if we use the underlying base type.
# --------------------------------------------------------------------------------------------------
# So, much like I covered above, we can actually use "[PSNoteProperty]::New($Name, $Value)" to create
# an object that adheres to PSObject.Properties. Doing this, will ADD a NEW custom property named 
# "EntryUnique" to the custom classes property list, as well as cast an empty object array.
# --------------------------------------------------------------------------------------------------
# This will allow one of the methods we have to write, to return atypical class properties to it.
# Doing so adheres to the standard class properties, while allowing additional NON-DEFAULT entries to
# coexist peacefully, and be clean and accessible. Who in their right mind doesn't like that idea...?
# --------------------------------------------------------------------------------------------------

$Properties     += [PSNoteProperty]::New("EntryUnique",@( )) # Or 
# $Properties   += New-Object PSNoteProperty -ArgumentList EntryUnique, @( )

# --------------------------------------------------------------------------------------------------
# We want to format the class with the right spacing. So, get the maximum TypeNameOfValue string length
# Again, here's some of my "Voodoo 3 5000" action being applied to the $Types variable.
# --------------------------------------------------------------------------------------------------
# To explain, it's a multifaceted one liner involving a foreach-object piping itself into an array
# that determines the selection in the array based on whether the boolean condition within the square 
# brackets is $True or $False. $False means 0. $True means 1. 
# If its FALSE, the  FIRST item (in slot 0) is selected, which is "String".
# If its TRUE,  the SECOND item (in slot 1) is selected, which is ($_ -Replace "System\.","")
# --------------------------------------------------------------------------------------------------
# Now, PowerShell does an amazing job of being able to understand when it's dealing with a default 
# system like [System.Object], or [System.String]. So, having the word System all over the place is
# unnecessary. Removing it allows the code to be shorter and less complicated or messy looking.
# --------------------------------------------------------------------------------------------------

$Types           = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length

# --------------------------------------------------------------------------------------------------
# Now, get maximum Name string length. No "Voodoo 3 5000" action goin' on here.
# --------------------------------------------------------------------------------------------------

$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length)[-1].Length

# --------------------------------------------------------------------------------------------------
# Declare a hash table with 1) CLASSNAME, 2) PROPERTY TYPES/NAMES (top portion of class), 
# 3) PARAM TYPE+VALUE (main method), 4) DEFAULT CONSTRUCTOR DEFINITIONS (main portion of the class), 
# and 5) METHODS for self-rereferencing, brevity, processing each individual NON-DEFAULT property,
# as well as writing some output.
# --------------------------------------------------------------------------------------------------

$Def             = @{

    Name         = "Uninstall" 
    Type         = @( )
    Param1Type   = "[Object]"
    Param1Value  = "`$Registry"
    Const        = @( )
    Method       = @( ) 
}

# --------------------------------------------------------------------------------------------------
# Run through all types, property names, and establish the code to set the class values to the 
# properties of the (input object/parameter). Add each TYPE+NAME to $Def.Type array, and then each 
# $Name in $Names with spacing for the $Def.Const array in the same loop.
# --------------------------------------------------------------------------------------------------

ForEach ($X in 0..($Names.Count-1))
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param1Value
}

# --------------------------------------------------------------------------------------------------
# Get the rank of the line where it matches the PSNoteProperty we added, EntryUnique, then replace.
# --------------------------------------------------------------------------------------------------

$X               = 0..($Def.Const.Count-1) | ? { $Def.Const[$_] -match "EntryUnique" }
$Def.Const[$X]   = $Def.Const[$X] -Replace '= .+', '= $This.GetEntryUniqueProperties($Registry)'

# --------------------------------------------------------------------------------------------------
# Now we have to write methods (Chunked out for readability). This FIRSt method will shorten the 
# process of calling the DEAFULT property names in this class, whereby filtering out "EntryUnique"
# --------------------------------------------------------------------------------------------------

$Method1         = @(
'    [String[]] Properties()',
'    {',
'        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name',
'    }'
)
$Def.Method      += $Method1

# --------------------------------------------------------------------------------------------------
# This second method will return the properties of the base class that aren't standard property names 
# that we pulled from the $Edge object template.
# --------------------------------------------------------------------------------------------------

$Method2          = @(
'    [Object[]] GetEntryUniqueProperties([Object]$Param)',
'    {',
'        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value'
'    }'
)
$Def.Method      += $Method2

# --------------------------------------------------------------------------------------------------
# Now we will create a way for the extended properties to show themselves in a way that is consumable, 
# while still adhering to the default properties
# --------------------------------------------------------------------------------------------------
$Method3           = @(
'    [Object[]] Output([UInt32]$Buffer)',
'    {',
'        $Output  = @( )',
'        $Output += ("-" * 120 -join "")',
'        $Output += "[$($This.DisplayName)]"',
'        $Output += ("-" * 120 -join "")',
'        $Output += " "',
'',
'        $This.Properties() | % { ',
'',
'            $Output += "{0}{1} : {2}" -f $_, (" " * ($Buffer - $_.Length + 1) -join ""), $This.$_',
'        }',
'',
'        $Output += (" " * $Buffer -join "")',
'        $This.EntryUnique  | % { ',
'',
'            $Output += "{0}{1} : {2}" -f $_.Name, (" " * ($Buffer - $_.Name.Length + 1 ) -join ""), $_.Value',
'        }',
'        $Output += (" " * $Buffer -join "")',
'',
'        Return $Output',
'    }'
)
$Def.Method      += $Method3

# --------------------------------------------------------------------------------------------------
# Create the Class definition value, this joins together the multiple chunks of the class so that 
# it can be instantiated by the PowerShell (Type/Class) engine.
# --------------------------------------------------------------------------------------------------

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))", "    {",($Def.Const -join "`n"),"    }",( $Def.Method -join "`n"),"}") -join "`n"

# --------------------------------------------------------------------------------------------------
# Instantiate the class definition
# Using this command below instantiates the class without having to explicitly get the variable output 
# --------------------------------------------------------------------------------------------------

Invoke-Expression $ClassDefinition

# --------------------------------------------------------------------------------------------------
# Alright, now declare a variable that collects all of the $Apps objects that went into the registry
# paths like the pros suggested up above. Then, look for the longest NON-DEFAULT property name length,
# and then format ALL of the classes with that integer to get a steady stream of formatted output. 
# --------------------------------------------------------------------------------------------------

$Output  = $Apps | % { [Uninstall]::New($_) }
$Buffer  = ($Output.EntryUnique.Name | Sort-Object Length)[-1].Length
$Output.Output($Buffer)

# --------------------------------------------------------------------------------------------------
# We should probably use an exterior container class to collect all of these items and format them
# accordingly. This will include all variables we assigned BEFORE the class definition, and then
# there will be NO chance, that an output object will get formatted with inconsistent buffer values.
# --------------------------------------------------------------------------------------------------

Class UninstallStack
{
    [UInt32] $Buffer
    [Object] $Output
    UninstallStack()
    {
        # --------------------------------------------------------------------------------------------------
        # We can use the variables without assigning them to the class, this actually optimizes the input/output 
        # stream because it's not tugging along a lot of unnecessary data, and it's also doing automatic
        # garbage cleanup.
        # --------------------------------------------------------------------------------------------------

        # --------------------------------------------------------------------------------------------------
        # Apps found in the uninstall registry paths (64-bit+32-bit)
        # --------------------------------------------------------------------------------------------------

        $Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty
        
        # --------------------------------------------------------------------------------------------------
        # Pulls a template object from the Microsoft Edge or Google Chrome installation - use one or the other, not both.
        # --------------------------------------------------------------------------------------------------
        
        $Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 

        # --------------------------------------------------------------------------------------------------
        # Get the properties that aren't WMI or PS related
        # --------------------------------------------------------------------------------------------------
        
        $Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"

        # --------------------------------------------------------------------------------------------------
        # Add the extra property so that the script will include them when automatically formatting the spacing for properties, and assigning constructor values
        # --------------------------------------------------------------------------------------------------
        
        $Properties     += [PSNoteProperty]::New("EntryUnique",@( ))

        # --------------------------------------------------------------------------------------------------
        # Allow the Uninstall class to be created with the above work... We will make a class that integrates all of this stuff soon.
        # --------------------------------------------------------------------------------------------------

        $This.Output     = $Apps | % { [Uninstall]::New($_) }
        $This.Buffer     = ($This.Output.EntryUnique.Name | Sort-Object Length)[-1].Length
    }
    [Object[]] GetOutput()
    {
        Return @( $This.Output.Output($This.Buffer) )
    }
}

# --------------------------------------------------------------------------------------------------
# Now, cast the variable with UninstallStack, which is the class up above. This will automatically 
# do the same things that all of those separate variables were able to do.
# --------------------------------------------------------------------------------------------------

$Output = [UninstallStack]::New()
$Output.GetOutput()

# --------------------------------------------------------------------------------------------------
# You won't want to format the output as a table, but even if you do, everything in the NON-DEFAULT
# properties will be caught within an array. There's really no way to get inconsistent properties to
# work across a bunch of entries in a table that have varying property types, unless maybe you have a
# monitor that spans about a football field, then I guess maybe that might actually work at fitting
# all of the possible properties that any class might have, into an incredibly convenient view.
# But, I gotta say... I don't think those types of monitors actually exist yet.
# --------------------------------------------------------------------------------------------------
# Then again, maybe somebody who's been working on just that exact thing I said doesn't exist...?
# Well... they just heard me loudly and clearly, and so they felt like letting me know...
# --------------------------------------------------------------------------------------------------
# Football-Field-Monitor-Dude: Look buddy... Those things DO exist.
# Me: Oh yeh...?
# FFMD: Yeh. And you call yourself some type of expert or something...? *scoffs* Unbelievable...
# Me: I didn't know they did.
# FFMD: Yeah pal. They most certainly do. Everybody knows that...
# Me: I didn't know that they actually made a monitor that spans a whole entire football field...
# FFMD: Yeah well... now you know. What, have you been livin' under a rock or somethin...?
# Me: Nah.
# FFMD: Well buddy... nice tutorial... But I'm offended about the monitor thing.
# Me: Alright...? I'm sorry...?
# FFMD: Wait... you're... sorry?
# Me: Yeah man, didn't realize I offended you by not knowing a monitor that long actually exists...
# FFMD: Yeah, they do. You should totally get one, very convenient, you can see the entire screen
# no problem...
# Me: Alright buddy. Duly noted. Well, I still have one more phase of this tutorial left to go.
# FFMD: Oh yeah...?
# Me: Yep. Gonna throw all of that stuff into a class that generates... classes.
# FFMD: A class that generates classes...? What are ya, some type of magician or somethin'?
# Me: No...
# FFMD: Buddy, you've got a lot of tricks.
# Me: Well, cool. I appreciate that.
# FFMD: I guess I'll stick around and keep reading.
# Me: Alright fine. Take care, buddy.
# FFMD: You too. Get one of those monitors...
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Those types of monitors don't exist, and I was being facetious about the convenient viewing angle.
# But even if they did, the only real purpose for them would probably be, to join a bunch of classes
# that have varying property types from class to class. Then, you're just asking to be confused.
# So, maybe you'll get confused that none of the classes match up in the table... Then what...?
# Well, I'll tell ya. It's gonna be a while before anyone is able to readily make use of such an
# incredibly useful arrangement of mismatching class types and properties.
# --------------------------------------------------------------------------------------------------
# One way that we could turn the entire script into a useful tool that would help anybody custom
# build their own classes in a jiffy, is the script. Couldn't be more serious about that actually.
# Sometimes I build custom (classes/structs) in either PowerShell or C#, and then I am able to cast
# some of those classes/structs to PowerShell/.Net type objects, and they work in literally the same
# way. The only difference is that the PowerShell code doesn't need to be compiled by MSBuild or 
# anything like that. That's because PowerShell can compile C# code on the fly. It's not all 
# encompassing like MSBuild is, sometimes C# code that works in an MSBuild process doesn't work with
# the Add-Type cmdlet.
# --------------------------------------------------------------------------------------------------
# However, writing a bunch of classes or structs in C# and then importing them into PowerShell is 
# incredibly useful in many cases. 
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# What I'm going to do NOW, is, build a class that puts all of this stuff together.
# I'll start by stripping away the comments that I made on some of the above content, and then 
# edit it until it's literally picture perfect, and reproduces the same output as above.
# This time, I'll have to develop this as (2) separate classes, one for the container, one for the
# class object, and the class object needs to be written first so that the type can be used in the
# container class. So, even though the variables are right below, they have to be arranged 
# differently in order to work as a pair of classes.
# --------------------------------------------------------------------------------------------------

$Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty
$Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 
$Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"
$Properties     += [PSNoteProperty]::New("EntryUnique",@( ))

$Types           = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length
$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length)[-1].Length
$Def             = @{

    Name         = "Uninstall" 
    Type         = @( )
    Param1Type   = "[Object]"
    Param1Value  = "`$Registry"
    Const        = @( )
    Method       = @( ) 
}

ForEach ($X in 0..($Names.Count-1))
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param1Value
}

$X               = 0..($Def.Const.Count-1) | ? { $Def.Const[$_] -match "EntryUnique" }
$Def.Const[$X]   = $Def.Const[$X] -Replace '= .+', '= $This.GetEntryUniqueProperties($Registry)'

$Method1         = @(
'    [String[]] Properties()',
'    {',
'        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name',
'    }'
)
$Def.Method      += $Method1

$Method2          = @(
'    [Object[]] GetEntryUniqueProperties([Object]$Param)',
'    {',
'        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value'
'    }'
)
$Def.Method      += $Method2

$Method3           = @(
'    [Object[]] Output([UInt32]$Buffer)',
'    {',
'        $Output  = @( )',
'        $Output += ("-" * 120 -join "")',
'        $Output += "[$($This.DisplayName)]"',
'        $Output += ("-" * 120 -join "")',
'        $Output += " "',
'',
'        $This.Properties() | % { ',
'',
'            $Output += "{0}{1} : {2}" -f $_, (" " * ($Buffer - $_.Length + 1) -join ""), $This.$_',
'        }',
'',
'        $Output += (" " * $Buffer -join "")',
'        $This.EntryUnique  | % { ',
'',
'            $Output += "{0}{1} : {2}" -f $_.Name, (" " * ($Buffer - $_.Name.Length + 1 ) -join ""), $_.Value',
'        }',
'        $Output += (" " * $Buffer -join "")',
'',
'        Return $Output',
'    }'
)
$Def.Method      += $Method3

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))", "    {",($Def.Const -join "`n"),"    }",( $Def.Method -join "`n"),"}") -join "`n"

# --------------------------------------------------------------------------------------------------
# So, here it is. This class is just a current derivative, if I were to keep working on it, I would 
# implement various changes to more finely tune the capabilities, properties, values, etc.
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# The NAME of this class, is essentially "DefinitionTemplate", because the name of this class is 
# doesn't NEED to be COOL, because it's job is to produce a class that includes various elements
# that would be needed to perform the same exact activity as the variables listed directly above.
# --------------------------------------------------------------------------------------------------
# However, this class has implemented many changes to the code it is based on up above, while still 
# producing the same output. Some of those changes are details that wouldn't even be seen when using
# it, but if you were to debug what it's doing, and see how it molds and shapes the output, you would
# easily see how OTHER techniques were applied to produce the same result. Sometimes this process
# can make the code longer, but other times it can make the code much more responsive or even give
# it more features so other elements can be added, or amended. The fully written class is below, as is.
# AFTER this stint, I will break it down and explain the differences between the variables above,
# and the properties and variables in the class.
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Class DefinitionTemplate
# --------------------------------------------------------------------------------------------------

Class DefinitionTemplate
{
    [String] $Name
    [Object] $Property
    [Object] $Param1Type
    [Object] $Param1Value
    [Object] $Constructor
    [Object] $Method
    DefinitionTemplate([String]$Name,[String]$Param1Type,[String]$Param1Value)
    {
        $This.Name             = $Name
        $This.Property         = @( )
        $This.Param1Type       = $Param1Type
        $This.Param1Value      = $Param1Value
        $This.Constructor      = @( )
        $This.Method           = @( )
    }
    LoadPropertySet([Object[]]$Properties)
    {
        $Types                 = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
        $TypesMax              = ($Types | Sort-Object Length)[-1].Length
        $Names                 = $Properties.Name
        $NamesMax              = ($Names | Sort-Object Length)[-1].Length

        ForEach ($X in 0..($Names.Count-1))
        { 
            $TypeBuff          = " " * ($TypesMax - $Types[$X].Length + 1)
            $NameBuff          = " " * ($NamesMax - $Names[$X].Length + 1)
            
            $This.AddProperty($Types[$X],$TypeBuff, $NameBuff,$Names[$X])
            $This.SetProperty($Names[$X],$NameBuff)
        }
    }
    AddProperty([String]$Type,[String]$TypeBuff,[String]$NameBuff,[String]$Name)
    {
        $This.Property        += "    [{0}]{1}{2}`${3}" -f $Type, $TypeBuff, $NameBuff, $Name
    }
    SetProperty([String]$Property,[String]$NameBuff)
    {
        $This.Constructor     += "        `$This.{0}{1} = {2}.{0}" -f $Property, $NameBuff, $This.Param1Value
    }
    ChangeProperty([String]$Name,[String]$Value)
    {
        $X                     = 0..($This.Constructor.Count-1) | ? { $This.Constructor[$_] -match $This.Escape("`$This.$Name") }
        If (!!$X)
        {
            [Console]::WriteLine("Property [+] Found, altering...")
            $This.Constructor[$X]  = $This.Constructor[$X] -Replace "=.+","= $Value"
        }
        Else
        {
            [Console]::WriteLine("Property [!] Not found, skipping...")
        }
    }
    [String] AddIndent([UInt32]$Count)
    {
        Return "    " * $Count
    }
    AddMethod([String[]]$Body)
    {
        $Body   = $Body -Replace "^\s*",""  
        $I      = 0
        $Return = @( )
        ForEach ($X in 0..($Body.Count-1))
        {
            $Line = $Body[$X]
            If ($X -eq 0 -and $Line -match "(\s{0})")
            {
                $I ++
                $Line = $This.AddIndent($I) + $Line
            }
            ElseIf ($X -eq 1 -and $Line -match "(\s{0}\{)")
            {
                $Line = $This.AddIndent($I) + $Line
                $I ++
            }
            ElseIf ($X -eq ($Body.Count-1) -and $Line -match "(\s{0}\})")
            {
                $I --
                $Line = $This.AddIndent($I) + $Line
            }
            Else
            {
                $Line = $This.AddIndent($I) + $Line
            }

            $Return += $Line
        }

        $This.Method += $Return -join "`n"
    }
    [String] Escape([String]$Value)
    {
        Return [Regex]::Escape($Value)
    }
    [String] ReturnDefinition()
    {
        $X              = @{ 
            Name        = "Class {0}" -f $This.Name
            Property    = $This.Property -join "`n"
            Main        = "    {0}({1}{2})" -f $This.Name, $This.Param1Type, $this.Param1Value
            Constructor = $This.Constructor -join "`n"
            Method      = $This.Method -join "`n"
        } 
        
        Return @( $X.Name, "{", $X.Property, $X.Main, "    {", $X.Constructor, "    }", $X.Method, "}" ) -join "`n"
    }
}


# -------------------------------------------------------------------------------------------------- 
# Now that the class is declared, instantiate the class and use it's methods to reproduce the result
# --------------------------------------------------------------------------------------------------

$Temp            = [DefinitionTemplate]::New("Uninstall","[Object]",'$Registry')

# -------------------------------------------------------------------------------------------------- 
# Now load the properties by using the method LoadPropertySet($Properties)
# --------------------------------------------------------------------------------------------------
$Temp.LoadPropertySet($Properties)

# -------------------------------------------------------------------------------------------------- 
# Now change property named "EntryUnique", new value "$This.GetEntryUniqueProperties($Registry)"
# --------------------------------------------------------------------------------------------------
$Temp.ChangeProperty("EntryUnique","`$This.GetEntryUniqueProperties(`$Registry)")

# -------------------------------------------------------------------------------------------------- 
# Now add method #1
# --------------------------------------------------------------------------------------------------
$Temp.AddMethod(@('[String[]] Properties()','{',
'Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name','}'))

# -------------------------------------------------------------------------------------------------- 
# Now add method #2
# --------------------------------------------------------------------------------------------------
$Temp.AddMethod(@('[Object[]] GetEntryUniqueProperties([Object]$Param)',
'{','Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value','}'))

# -------------------------------------------------------------------------------------------------- 
# Now add method #3
# --------------------------------------------------------------------------------------------------
$Temp.AddMethod(@('[Object[]] Output([UInt32]$Buff)','{','$X  = @( )',
'$X += ("-" * 120 -join ""), "[$($This.DisplayName)]", ("-" * 120 -join ""), " "',
'$This.Properties() | % { $X += "{0}{1} : {2}" -f $_, (" " * ($Buff - $_.Length + 1) -join ""), $This.$_ }',
'$X += (" " * $Buff -join "")',
'$This.EntryUnique  | % { $X += "{0}{1} : {2}" -f $_.Name, (" " * ($Buff - $_.Name.Length + 1 ) -join ""), $_.Value }',
'$X += (" " * $Buff -join "")',
'Return $X','}'))

# -------------------------------------------------------------------------------------------------- 
# Run the method ReturnDefinition(), and cast it's output to variable $ClassDefinition
# --------------------------------------------------------------------------------------------------
$ClassDefinition = $Temp.ReturnDefinition()

# -------------------------------------------------------------------------------------------------- 
# Copy the variable output to the clipboard, and THEN, let's take a look at the output...
# --------------------------------------------------------------------------------------------------
$ClassDefinition | Set-Clipboard

#\_________________________________________________________________________________________________ 
# Output /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
#/¯¯¯¯¯¯¯

Class Uninstall
{
    [String]        $DisplayName
    [String]     $DisplayVersion
    [String]            $Version
    [Int32]            $NoRemove
    [String]         $ModifyPath
    [String]    $UninstallString
    [String]    $InstallLocation
    [String]        $DisplayIcon
    [Int32]            $NoRepair
    [String]          $Publisher
    [String]        $InstallDate
    [Int32]        $VersionMajor
    [Int32]        $VersionMinor
    [Object[]]      $EntryUnique
    Uninstall([Object]$Registry)
    {
        $This.DisplayName      = $Registry.DisplayName
        $This.DisplayVersion   = $Registry.DisplayVersion
        $This.Version          = $Registry.Version
        $This.NoRemove         = $Registry.NoRemove
        $This.ModifyPath       = $Registry.ModifyPath
        $This.UninstallString  = $Registry.UninstallString
        $This.InstallLocation  = $Registry.InstallLocation
        $This.DisplayIcon      = $Registry.DisplayIcon
        $This.NoRepair         = $Registry.NoRepair
        $This.Publisher        = $Registry.Publisher
        $This.InstallDate      = $Registry.InstallDate
        $This.VersionMajor     = $Registry.VersionMajor
        $This.VersionMinor     = $Registry.VersionMinor
        $This.EntryUnique      = $This.GetEntryUniqueProperties($Registry)
    }
    [String[]] Properties()
    {
        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name
    }
    [Object[]] GetEntryUniqueProperties([Object]$Param)
    {
        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value
    }
    [Object[]] Output([UInt32]$Buff)
    {
        $X  = @( )
        $X += ("-" * 120 -join ""), "[$($This.DisplayName)]", ("-" * 120 -join ""), " "
        $This.Properties() | % { $X += "{0}{1} : {2}" -f $_, (" " * ($Buff - $_.Length + 1) -join ""), $This.$_ }
        $X += (" " * $Buff -join "")
        $This.EntryUnique  | % { $X += "{0}{1} : {2}" -f $_.Name, (" " * ($Buff - $_.Name.Length + 1 ) -join ""), $_.Value }
        $X += (" " * $Buff -join "")
        Return $X
    }
}

#\_______
# Output \__________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# So, the output does look slightly different. At least the content of the method named Output does. \
# That's because I added a feature that would automatically indent lines within any given method fed /
# to the AddMethod([Object[]]$Object) method. But, then I realized that probably isn't a great use   \
# of my time to go the full mile there.                                                              /
# --------------------------------------------------------------------------------------------------/
# There are many things in the .Net framework that can actually indent some of this stuff FOR you,  \
# or anybody else really... but sometimes, learning how to do it without a tool like that can help   \
# bolster one's ability to do it themselves. When they do, they'll understand how the "pros" went    /
# ahead, and wrote a class that does all of that work, cause they're probably a real nice (guy/girl).\
# ---------------------------------------------------------------------------------------------------/
# Whether you use one of the streamreader/streamwriter class types, or I think the Xmlwriter class   \
# also does it, can't think off the top of my head what other default classes automatically indent   /
# stuff for you, but they're out there. Things become harder to do when you're writing CODE that does\
# what you as a human would do when editing the content, and that's when design choices might change./
#\__________________________________________________________________________________________________/

#\___________
# Comparison \______________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\

# [ Before : Part 1 ]

$Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty
$Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 
$Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"
$Properties     += [PSNoteProperty]::New("EntryUnique",@( ))

# ------------------------------------------------------------------------------------------------
# The BEFORE stuff is actually all the variables starting from where the pros suggested that using
# Get-WMIObject Win32_Product to get installed applications, is not the best way to get that info.
# ------------------------------------------------------------------------------------------------
# Looking through the registry is actually a WAY snappier way to do the job, and any pro would tell
# you that. The thing is, the registry and the WMI objects don't have the same values. So, we had 
# to make some serious changes after writing the WMIClass at the top. Not to mention, the WMIClass 
# reaches into the HKEY_CLASSES_ROOT for GUIDs and stuff that isn't automatically available to 
# PowerShell without opening a new PSDrive to HKCR:\* 
# ------------------------------------------------------------------------------------------------

# [ After : Part 1 ]

Class UninstallStack2
{
    [UInt32] $Buffer
    [Object] $Output
    UninstallStack2()
    {
        $Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty        
        $Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 
        $Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"
        $Properties     += [PSNoteProperty]::New("EntryUnique",@( ))
        $This.Output     = $Apps | % { [Uninstall]::New($_) }
        $This.Buffer     = ($This.Output.EntryUnique.Name | Sort-Object Length)[-1].Length
    }
    [Object[]] GetOutput()
    {
        Return @( $This.Output.Output($This.Buffer) )
    }
}

# ------------------------------------------------------------------------------------------------
# The AFTER stuff is essentially the same code, largely. Except, there are (2) properties that 
# replace a couple of the variables, like $This.Output and $This.Buffer. The other variables are
# still written the same way. 
# ------------------------------------------------------------------------------------------------

# [ Before : Part 2 ]

$Types           = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length
$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length)[-1].Length
$Def             = @{

    Name         = "Uninstall" 
    Type         = @( )
    Param1Type   = "[Object]"
    Param1Value  = "`$Registry"
    Const        = @( )
    Method       = @( ) 
}

ForEach ($X in 0..($Names.Count-1))
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param1Value
}

# ------------------------------------------------------------------------------------------------
# The Before stuff right here is doing a lot of the work in processing the values in the $Properties
# variable. The $Properties variable is an object array of PSNoteProperties based off of the 
# $PSObject.Properties variable. The hash table is there reserving some collection containers for
# properties Type, Const, and Method.
# ------------------------------------------------------------------------------------------------
# Then the loop just goes right ahead and starts processing every item in the $Names array.
# It is also calculating the length of the buffer strings so that it formats the code neatly.
# ------------------------------------------------------------------------------------------------

# [ After : Part 2 ]

Class DefinitionTemplate2
{
    [String] $Name
    [Object] $Property
    [Object] $Param1Type
    [Object] $Param1Value
    [Object] $Constructor
    [Object] $Method
    DefinitionTemplate2([String]$Name,[String]$Param1Type,[String]$Param1Value)
    {
        $This.Name             = $Name
        $This.Property         = @( )
        $This.Param1Type       = $Param1Type
        $This.Param1Value      = $Param1Value
        $This.Constructor      = @( )
        $This.Method           = @( )
    }
    LoadPropertySet([Object[]]$Properties)
    {
        $Types                 = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
        $TypesMax              = ($Types | Sort-Object Length)[-1].Length
        $Names                 = $Properties.Name
        $NamesMax              = ($Names | Sort-Object Length)[-1].Length

        ForEach ($X in 0..($Names.Count-1))
        { 
            $TypeBuff          = " " * ($TypesMax - $Types[$X].Length + 1)
            $NameBuff          = " " * ($NamesMax - $Names[$X].Length + 1)
            
            $This.AddProperty($Types[$X],$TypeBuff, $NameBuff,$Names[$X])
            $This.SetProperty($Names[$X],$NameBuff)
        }
    }
    AddProperty([String]$Type,[String]$TypeBuff,[String]$NameBuff,[String]$Name)
    {
        $This.Property        += "    [{0}]{1}{2}`${3}" -f $Type, $TypeBuff, $NameBuff, $Name
    }
    SetProperty([String]$Property,[String]$NameBuff)
    {
        $This.Constructor     += "        `$This.{0}{1} = {2}.{0}" -f $Property, $NameBuff, $This.Param1Value
    }
}

# ------------------------------------------------------------------------------------------------
# The After stuff right here looks a lot like the individuals up above, however, there are many things
# that have been moved around to make the process more structurally sound. Mainly because the hash table
# that was named $Def, was a good idea to turn into the default constructor and class properties.
# ------------------------------------------------------------------------------------------------
# The intitial constructor requests (3) parameters, the 1) name of the class, 2) Parameter1Type, and 
# 3) Parameter1Value, which can be seen up in the before section, except now the class can accommodate
# a much more broad range of input without doing a heck of a lot different. The same can also be done
# with the hash table. But- if I want to make multiple copies of the class, each with a different set
# of values, that's a lot easier. With the hashtable, I'd have to copy and paste the hashtable, and 
# then manually enter new values for those new hashtables, otherwise they'll have the same information.
# Which is... rather anticlimactic in all honesty. Nothing like seeing thousands of the same exact hash
# table cause a token variable somewhere wasn't being changed.
# ------------------------------------------------------------------------------------------------
# The hashtables also don't scale well as a table like the classes do. They CAN, but the class doesn't
# lose any of it's key arrangements or positioning, so the class is more consistent and reliable.
# That's not ALWAYS the case, but in this case, it most certainly is.
# ------------------------------------------------------------------------------------------------
# The method LoadPropertySet($Properties) does the same job as the individual variables in the 
# before stuff above. However, there are some KEY DIFFERENCES to note here. For starters, the way in
# which the variables were moved around, allowed the hashtable stuff to be put in it's own constructor.
# 
# Then, shifting the remaining variables from that particular block around, allowed moving the type 
# length determination process, the type buffer, type buffer to string, as well as the name length 
# determination process, name buffer, and name buffer to string... not only to the same block, but-
# there was a perfect opportunity to create a couple of new methods that cleaned up the way that 
# code looked, while also providing some more control. Maybe it's a matter of preference...? Idk.
# But I like the way that portion of the code looks a LOT better than the individual variables.
# Suffice to say, adding those methods makes a lot of sense as they're adding properties, and then
# setting the property values... having a method with a name gives anybody a better sense of what
# is actually happening behind the code.
# ------------------------------------------------------------------------------------------------

# [ Before : Part 3 ]

$X               = 0..($Def.Const.Count-1) | ? { $Def.Const[$_] -match "EntryUnique" }
$Def.Const[$X]   = $Def.Const[$X] -Replace '= .+', '= $This.GetEntryUniqueProperties($Registry)'

$Method1         = @('    [String[]] Properties()','    {','        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name','    }')
$Def.Method     += $Method1

$Method2         = @('    [Object[]] GetEntryUniqueProperties([Object]$Param)','    {',
'        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value''    }')
$Def.Method     += $Method2

$Method3         = @('    [Object[]] Output([UInt32]$Buffer)','    {','        $Output  = @( )','        $Output += ("-" * 120 -join "")',
'        $Output += "[$($This.DisplayName)]"','        $Output += ("-" * 120 -join "")','        $Output += " "','',
'        $This.Properties() | % { ','','            $Output += "{0}{1} : {2}" -f $_, (" " * ($Buffer - $_.Length + 1) -join ""), $This.$_',
'        }','','        $Output += (" " * $Buffer -join "")','        $This.EntryUnique  | % { ','',
'            $Output += "{0}{1} : {2}" -f $_.Name, (" " * ($Buffer - $_.Name.Length + 1 ) -join ""), $_.Value','        }',
'        $Output += (" " * $Buffer -join "")','','        Return $Output','    }')
$Def.Method      += $Method3

# ------------------------------------------------------------------------------------------------
# The Before stuff here, generally looks a lot like the after stuff, but, the class has methods 
# where these values are just being changed directly. Like, the first couple of variables are pulling
# an index number to specifically recall the index of the property that's about to be changed,
# and then it changes it with some regex. The after stuff is doing that too... albeit with changes.
# ------------------------------------------------------------------------------------------------
# The variables named $Method1, $Method2, and $Method3 really aren't all that different from the after
# stuff either, except here, there's no actual method that's inserting those variable values into the
# hashtable property named Method. Which is fine...? But, having a method name that describes the 
# function is really what makes a class even more useful that a slew of variables all taped together.
# There really is no way to get away from that feeling when using a lot of variables that aren't 
# connected to a larger container object, they feel like they're all operating on their own accord.
# ------------------------------------------------------------------------------------------------
# Obviously, this process is required to build the class types, it's just that if a script writer
# doesn't make the effort to implement class types and stuff, they may never be able to write code
# that is able to describe itself a lot more clearly and coherently, and methods and even loop 
# labels go a long way to assist with breaking portions of code off into trunks or branches, rather
# than one giant soup bowl of variables. Just, variable soup. I don't see people using many loop
# labels these days, because it's essentially the same thing as a method, or a switch block.
# ------------------------------------------------------------------------------------------------

# [ After : Part 3 ]

    ChangeProperty([String]$Name,[String]$Value)
    {
        $X                     = 0..($This.Constructor.Count-1) | ? { $This.Constructor[$_] -match $This.Escape("`$This.$Name") }
        If (!!$X)
        {
            [Console]::WriteLine("Property [+] Found, altering...")
            $This.Constructor[$X]  = $This.Constructor[$X] -Replace "=.+","= $Value"
        }
        Else
        {
            [Console]::WriteLine("Property [!] Not found, skipping...")
        }
    }
    [String] AddIndent([UInt32]$Count)
    {
        Return "    " * $Count
    }
    AddMethod([String[]]$Body)
    {
        $Body   = $Body -Replace "^\s*",""  
        $I      = 0
        $Return = @( )
        ForEach ($X in 0..($Body.Count-1))
        {
            $Line = $Body[$X]
            If ($X -eq 0 -and $Line -match "(\s{0})")
            {
                $I ++
                $Line = $This.AddIndent($I) + $Line
            }
            ElseIf ($X -eq 1 -and $Line -match "(\s{0}\{)")
            {
                $Line = $This.AddIndent($I) + $Line
                $I ++
            }
            ElseIf ($X -eq ($Body.Count-1) -and $Line -match "(\s{0}\})")
            {
                $I --
                $Line = $This.AddIndent($I) + $Line
            }
            Else
            {
                $Line = $This.AddIndent($I) + $Line
            }

            $Return += $Line
        }

        $This.Method += $Return -join "`n"
    }
    [String] Escape([String]$Value)
    {
        Return [Regex]::Escape($Value)
    }

# ------------------------------------------------------------------------------------------------
# The after stuff here is a lot longer, no question about it. 
# Nothing seen in this group of methods is actually reproducing the code above, however-
# It's doing additional things that make the code easier to throw OTHER values at, making
# it even more flexible than it already was.
# I'm going to paste the portion of code where the class is instantiated and then the methods
# that produce the same content as the variables up above, will be more readily comparable.
# ------------------------------------------------------------------------------------------------

$Temp            = [DefinitionTemplate]::New("Uninstall","[Object]",'$Registry')
$Temp.LoadPropertySet($Properties)

$Temp.ChangeProperty("EntryUnique","`$This.GetEntryUniqueProperties(`$Registry)")
$Temp.AddMethod(@('[String[]] Properties()','{',
'Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name','}'))
$Temp.AddMethod(@('[Object[]] GetEntryUniqueProperties([Object]$Param)',
'{','Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value','}'))
$Temp.AddMethod(@('[Object[]] Output([UInt32]$Buff)','{','$X  = @( )',
'$X += ("-" * 120 -join ""), "[$($This.DisplayName)]", ("-" * 120 -join ""), " "',
'$This.Properties() | % { $X += "{0}{1} : {2}" -f $_, (" " * ($Buff - $_.Length + 1) -join ""), $This.$_ }',
'$X += (" " * $Buff -join "")',
'$This.EntryUnique  | % { $X += "{0}{1} : {2}" -f $_.Name, (" " * ($Buff - $_.Name.Length + 1 ) -join ""), $_.Value }',
'$X += (" " * $Buff -join "")',
'Return $X','}'))

# ------------------------------------------------------------------------------------------------
# The first two lines here instantiate the class, and then the method LoadPropertySet injects
# the PSObject.Properties information. The third method ChangeProperty is performing the same
# activity as the first two variables in the before section directly above. Now I can explain
# why the code in the class is longer, but- achieves a better end result...
# ------------------------------------------------------------------------------------------------
# The method ChangeProperty looks for the property in the constructor "EntryUnique", and then
# sets it's value to what is written in the quotes as the second parameter. It's doing almost
# the identical thing under the hood as above, however the method ChangeProperty is providing
# a little bit of error handling, so if the property that is input into the method isn't there...?
# It doesn't just NOT tell you that nothing was done, it'll say that. But also, it uses a double
# !!boolean statement where if the token $X is returned via the double negative check, then that
# means it found the thing and it made the change. Otherwise it didn't, and will say "failed..."
# ------------------------------------------------------------------------------------------------
# As for the method AddMethod(), it is generally identical to the previous variable method, but-
# I was able to implement spacing changes so that the input strings don't need to include those
# spaces. Even if they do, they're gonna get ripped out and then reinserted from the ground up. 
# Why? Because it made more sense to do it that way. However, it did mess with the way I like my
# code to be indented from nested code block to nested code block within a method. But, that's
# really a matter of preference and it's not a structural defect or anything. Also, the methods
# could also be added in the same way as the naked variables, where there was $Method1, $Method2,
# and $Method3 and then those values were added... It could be done that way here as well. The
# main difference is that the method is NAMED, rather than just having some property named Method
# allow items to be added to itself. Yeah, naming a property "method" that isn't actually a method 
# might cause some confusion somewhere...? But then again, maybe it won't... Either way, it's
# better to have a legitimate, actual-factual method named "AddMethod" rather than wingin' it 
# with a property named Method then a plus sign and an equals sign, then a variable value.
#
# I know somebody somewhere is going to say "That's not an actual method..."
# It's a property named method, that just so happens to be inserting a value that represents the
# string version of a method for a class. A wolf in sheeps clothing, essentially.
# 
# It's not unlike showing up to a party in a shirt that says "I'm wearing a black shirt", but...
# your shirt is actually white. Everyone's that takes their time to read your shirt is going to
# think... "That dude's wearing a white shirt that says 'I'm wearing a black shirt'..."
# Then THEIR buddy is gonna say "Wow. That dude's shirt definitely says that, and it IS white..."
# Then 10 other buddies are gonna join in, scratching their heads, "Dude's wearin' a white shirt,
# but then the shirt says "I'm wearing a black shirt"... 
# Then somebody will eventually say "So, is it like the SHIRT that's wearing a shirt...? Or like- 
# I don't even know dude... that shirt is blowing my mind right now..."
#
# Maybe it won't be that dramatic though.
# ------------------------------------------------------------------------------------------------

# [ Before : Part 4 / Final thoughts ]

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))", "    {",($Def.Const -join "`n"),"    }",( $Def.Method -join "`n"),"}") -join "`n"

# ------------------------------------------------------------------------------------------------
# There's not much left to go over. It's literally just the class definition variable, the thing
# that's supposed to capture the output of the variables up above, so that the class can be loaded
# into memory, and then it can be instantiated.
# There's no question, that having blobs of code written all over the place like what's directly 
# above this paragraph, are a headache to look at. It's long, it's mean looking, doesn't even 
# remotely feel like a cool dude that just so happens to be hanging out at the park during the
# summertime... The reason for that is because whenyoutrytostuffabunchofthingsintosomethinglikethat,
# itkindalookslikeascarymessthatnobodywantstobenearoraroundcauseitslongcomplicatedlookingandnotfun.
# ------------------------------------------------------------------------------------------------
# I realize, it probably doesn't look THAT BAD... but that whole "throwing away the spacebar" 
# comment is sorta the vibe that it gives me. All it's doing is generating the single output string
# that just so happens to be the output of the entire set of variables. But, there's so many ways
# it can be optimized. String interpolation, directly embedding the values without so many quotes,
# it's not bad for a first attempt when you're conceptualizing something, but at some point, this
# will cause anybody that respects well written code, to say (1) word. "Ahhh!"
# ------------------------------------------------------------------------------------------------
# Do you want somebody who's always been known for respecting well written code, to say "Ahhh!"...
# ...when they look at YOURS...? Probably not, right? Cause "Ahhh!" isn't even a word really. 
# At which point, who's the person who feels most insulted...? You...?
# Or some guy that has always been known for respecting well written code... that said "Ahhh!"...
# ...when they looked at yours...?
# ------------------------------------------------------------------------------------------------
# Maybe Linus Torvalds may have to come out from somewhere, and say "I've seen FAR worse code than 
# that, pal. And, I've always been known for respecting well written code..."
# Then I guess I'm gonna have to put my hands up... and be like "Alright... cant argue with ya."
# Cause who's gonna argue with Linus Torvalds... the man who wrote linux? Nobody. Everyone reading
# this will probably agree with me "*shakes head* Yeah. that Linus Torvalds guy...? He literally 
# knows the ins and outs of well written code... and in that case, it's settled... MAYBE the code
# above isn't THAT bad. But, personally... I feel as if it appears that the # author lost track of 
# their space bar, or enter key. Maybe that's fine sometimes. What do I know?
# ------------------------------------------------------------------------------------------------
# Whether I AM THE GUY THAT WROTE THAT or not...? It's irrelevant. Gives me the heebie jeebies.
# And that's why I rewrote it in the class and that whole mess became this thing below...
# ------------------------------------------------------------------------------------------------

# [ After : Part 4 / Final ]

<# Continued #>
    [String] ReturnDefinition()
    {
        $X              = @{ 
            Name        = "Class {0}" -f $This.Name
            Property    = $This.Property -join "`n"
            Main        = "    {0}({1}{2})" -f $This.Name, $This.Param1Type, $this.Param1Value
            Constructor = $This.Constructor -join "`n"
            Method      = $This.Method -join "`n"
        } 
        
        Return @( $X.Name, "{", $X.Property, $X.Main, "    {", $X.Constructor, "    }", $X.Method, "}" ) -join "`n"
    }
}

$ClassDefinition = $Temp.ReturnDefinition()

# ------------------------------------------------------------------------------------------------
# People may look at this and think... But- you had all of that in one line... This is like (10)...
# Yep. I know, it's a lot more information, but sometimes I ask myself how the highway guys can 
# stand working on the highway all day in the heat, those tenth of a mile markers being the thing 
# they gotta drop a bunch of asphalt between, and they'll occasionally look at these markers to 
# gauge their progress. They probably live for each and every one of those things too. 
# Highway guy: Ah man. Just another ... 4 miles to go. Not bad. It's only Monday though. Damnit.
# You know that they're walking... and they look at these things like a clock or a watch.
# Pouring, and laying down some asphalt all day long... living through hell paycheck to paycheck.
# ------------------------------------------------------------------------------------------------
# Here's why I prefer the thing above. If I want to make it shorter, that's easy. Highway guy can't
# make his job any shorter if he even wanted to. But, I definitely can make mine shorter. If I 
# want to examine a problem with the output, then I've made it incredibly easy to track down what 
# could be causing an issue, adjust it, and then I totally avoid feeling like that dude on the 
# highway in the blistering heat, just pouring asphalt all day long... cause even though they get 
# paid pretty well...? I don't think a single one of them dudes really love doing that job...
# Maybe some of them do, I don't know. From what some of my friends tell me they say it's not fun.
# ------------------------------------------------------------------------------------------------

# Anyway, that's it for the lesson, hope you enjoyed it.
# I've gone ahead and pasted additional copies of the classes below in a comment block.

<#
Class Win32_Product
{
    [Guid]           $RunspaceId
    [UInt16]     $AssignmentType
    [String]            $Caption
    [String]        $Description
    [String]        $ElementName
    [String]           $HelpLink
    [String]      $HelpTelephone
    [String]  $IdentifyingNumber
    [String]        $InstallDate
    [String]       $InstallDate2
    [String]    $InstallLocation
    [String]      $InstallSource
    [Int16]        $InstallState
    [String]         $InstanceID
    [String]           $Language
    [String]       $LocalPackage
    [String]               $Name
    [String]       $PackageCache
    [String]        $PackageCode
    [String]        $PackageName
    [String]          $ProductID
    [String]         $RegCompany
    [String]           $RegOwner
    [String]          $SKUNumber
    [String]         $Transforms
    [String]       $URLInfoAbout
    [String]      $URLUpdateInfo
    [String]             $Vendor
    [String]            $Version
    [String]   $WarrantyDuration
    [String]  $WarrantyStartDate
    [UInt32]          $WordCount
    Win32_Product([Object]$WMIObject)
    {
        $This.RunspaceId         = $WMIObject.RunspaceId
        $This.AssignmentType     = $WMIObject.AssignmentType
        $This.Caption            = $WMIObject.Caption
        $This.Description        = $WMIObject.Description
        $This.ElementName        = $WMIObject.ElementName
        $This.HelpLink           = $WMIObject.HelpLink
        $This.HelpTelephone      = $WMIObject.HelpTelephone
        $This.IdentifyingNumber  = $WMIObject.IdentifyingNumber
        $This.InstallDate        = $WMIObject.InstallDate
        $This.InstallDate2       = $WMIObject.InstallDate2
        $This.InstallLocation    = $WMIObject.InstallLocation
        $This.InstallSource      = $WMIObject.InstallSource
        $This.InstallState       = $WMIObject.InstallState
        $This.InstanceID         = $WMIObject.InstanceID
        $This.Language           = $WMIObject.Language
        $This.LocalPackage       = $WMIObject.LocalPackage
        $This.Name               = $WMIObject.Name
        $This.PackageCache       = $WMIObject.PackageCache
        $This.PackageCode        = $WMIObject.PackageCode
        $This.PackageName        = $WMIObject.PackageName
        $This.ProductID          = $WMIObject.ProductID
        $This.RegCompany         = $WMIObject.RegCompany
        $This.RegOwner           = $WMIObject.RegOwner
        $This.SKUNumber          = $WMIObject.SKUNumber
        $This.Transforms         = $WMIObject.Transforms
        $This.URLInfoAbout       = $WMIObject.URLInfoAbout
        $This.URLUpdateInfo      = $WMIObject.URLUpdateInfo
        $This.Vendor             = $WMIObject.Vendor
        $This.Version            = $WMIObject.Version
        $This.WarrantyDuration   = $WMIObject.WarrantyDuration
        $This.WarrantyStartDate  = $WMIObject.WarrantyStartDate
        $This.WordCount          = $WMIObject.WordCount
    }
}

Class Uninstall
{
    [String]        $DisplayName
    [String]     $DisplayVersion
    [String]            $Version
    [Int32]            $NoRemove
    [String]         $ModifyPath
    [String]    $UninstallString
    [String]    $InstallLocation
    [String]        $DisplayIcon
    [Int32]            $NoRepair
    [String]          $Publisher
    [String]        $InstallDate
    [Int32]        $VersionMajor
    [Int32]        $VersionMinor
    [Object[]]      $EntryUnique
    Uninstall([Object]$Registry)
    {
        $This.DisplayName      = $Registry.DisplayName
        $This.DisplayVersion   = $Registry.DisplayVersion
        $This.Version          = $Registry.Version
        $This.NoRemove         = $Registry.NoRemove
        $This.ModifyPath       = $Registry.ModifyPath
        $This.UninstallString  = $Registry.UninstallString
        $This.InstallLocation  = $Registry.InstallLocation
        $This.DisplayIcon      = $Registry.DisplayIcon
        $This.NoRepair         = $Registry.NoRepair
        $This.Publisher        = $Registry.Publisher
        $This.InstallDate      = $Registry.InstallDate
        $This.VersionMajor     = $Registry.VersionMajor
        $This.VersionMinor     = $Registry.VersionMinor
        $This.EntryUnique      = $This.GetEntryUniqueProperties($Registry)
    }
    [String[]] Properties()
    {
        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name
    }
    [Object[]] GetEntryUniqueProperties([Object]$Param)
    {
        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value
    }
    [Object[]] Output([UInt32]$Buffer)
    {
        $Output  = @( )

        $This.Properties() | % { 

            $Output += "{0}{1} : {2}" -f $_, (" " * ($Buffer - $_.Length + 1) -join ""), $This.$_
        }

        $This.EntryUnique | % { 

            $Output += "{0}{1} : {2}" -f $_.Name, (" " * ($Buffer - $_.Name.Length + 1 ) -join ""), $_.Value
        }

        Return $Output
    }
}

Class UninstallStack
{
    [UInt32] $Buffer
    [Object] $Output
    UninstallStack()
    {
        $Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty        
        $Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 
        $Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"
        $Properties     += [PSNoteProperty]::New("EntryUnique",@( ))
        $This.Output     = $Apps | % { [Uninstall]::New($_) }
        $This.Buffer     = ($This.Output.EntryUnique.Name | Sort-Object Length)[-1].Length
    }
    [Object[]] GetOutput()
    {
        Return @( $This.Output.Output($This.Buffer) )
    }
}
#>
