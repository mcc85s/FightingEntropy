#\__________________________________________________________________________________________________
# Classes/Lesson plan for being able to convert standard scripts to advanced class types /¯¯¯¯¯¯¯¯¯¯
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Greetings PowerShell Community,
#
# Over the last month and a half, I've been slowly working on a utility that implements a combination
# of PowerShell class structures, (XAML/Extensible Application Markup Language), Multithreading &
# PowerShell Runspaces that can automatically throttle itself and synchronize the window with the GUI
# dispatcher, but that is a rather complicated project to try and dive into without the utility being
# complete and testing well. I'll talk about it briefly and then begin this explanation into building
# class structures in PowerShell, and how to translate an existing series of variables into a class.
# 
# Last night I decided to take a break from the threading stuff, and dive into the topic of converting
# scripts to .Net class types, and teach people why classes are really... incredibly useful and 
# underused. If people only knew that I look for ways to turn C# code into PowerShell code... 
# Sometimes it's possible. Sometimes it's not without a lot of additional code.
#
# In C#, classes are definitely not underused at all. In PowerShell, they definitely are.
# 
# Now, I've tried to teach some people in the community before about how to go write classes in 
# PowerShell, as it isn't exactly intuitive. But, I figured this one HERE is unlike any other 
# lesson plan I've done before, where I show people how I take an idea like pulling:
# "Get-WMIObject -ClassName Win32_Product"
#
# And then building a custom class off of that. 
# Not just writing a class off of it either, but writing a tutorial on how to build yourself a
# class that can produce OTHER class templates and stuff. 
# 
# This one may not necessarily have an associated video, but- it will probably cause a few people to
# chuckle and even draw up comparisons between how they CURRENTLY write their code, and what the
# benefits may be to going all out with a full-blown, class structure approach that can be pipelined 
# by functions, or cmdletbindings.
# 
# Anyway, this utility I've been working on is no joke. I wrote a lesson plan for it, but I decided 
# to hold off on completing and distributing it because I kept making changes to the code.
#
# It uses synchronized hashtables, classes, session state objects, function/assembly/variable entries, 
# BOTH runspace factories, separate objects to control groups of threads, sends progress information 
# to the GUI console, stopwatch, timing, reports, percentage of completion, passes stuff back and 
# forth, handles hundreds of thousands of event logs, uses native System.IO.Compression classes, has
# a lot of error handling, and it really is all coordinated from the controller classes that drive 
# the GUI. But strategically assigning properties and values at a specific location at a specific time,
# is pretty stressful sometimes. 
#
# Now, some people out there have some content where they've exhibited portions of what I'm attempting
# to do. Such as, Jim Moyle, he's got excellent tutorials about XAML/Runspaces on YouTube. His work 
# is good. And, who would be surprised that I'd say... Boe Prox (in addition to 1RedOne). 
#
# While Boe has plenty of work out there in the wild, such as PoshRSJobs (very useful module btw),
# I've run into many limitations with it that I had no idea how to troubleshoot. A veteran MVP's 
# work like his...? I'm not gonna try to reinvent the wheel. But, I did keep runspaces in the back
# of my mind. 
# 
# It is one of the most challenging tasks I've ever decided to take on. The takeaway will be that I
# found a way to integrate the threading of multiple runspaces via many custom classes that I wrote 
# to drive the backend of the utility. It is rather thorough in the information it collects, and it 
# formats itself and saves a running system configuration and ALL event logs to a .zip file that the
# program never actually decompresses. Sorta like John Carmack decided to do with Q3A via .pk3 files.
# 
# Then, the utility can import those files back into the GUI on another system if need be.
# However, that utility isn't quite ready to show off yet. So without further ado, here's a new 
# lesson plan I wrote on how to turn a trivial task into classes that make life easier.
#
#\__________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

#\__________________________________________________________________________________________________
# Get Programs - Just collect the first object from Get-WMIObject Win32_Product /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

  $WMIList        = (Get-WMIObject Win32_Product)[0] # or... 
# $WMIList        = Get-WMIObject Win32_Product | Select-Object -First 1   # ...does the same thing

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Get properties from PSObject whose names don't start with either _ or PS. The regex code at the   /
# end prevents unnecessary PS and WMI class properties from being included in the class definition. \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Properties      = $WMIList.PSObject.Properties | ? Name -notmatch "(^_|^PS)"

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# We want to format the class with the right spacing between elements, cause we're OCD and precise. /
# Get the max TypeNameOfValue string length | Some of my Voodoo 3 5000 applied to $Types variable.  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Types           = ($Properties.TypeNameOfValue | % { 
                    @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })

$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, get max Name string length. No Voodoo 3 5000 action goin' on here... sorry.                  /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length )[-1].Length

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Declare a hash table with 1) CLASSNAME, 2) PROPERTY TYPES/NAMES (top portion of class),           /
# 3) TYPE+PARAMETER (main method), and DEFAULT CONSTRUCTOR DEFINITIONS (main portion of the class)  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Def             = @{ 
    Name         = "Win32_Product"; 
    Type         = @( ); 
    Param1Type   = "[Object]"; 
    Param1Value  = "`$WMIObject"; 
    Const        = @( ) 
}

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Run through all 1) property types, 2) property names, and 3) set the property values to the       /
# corresponding property value of the input parameter. Add each TYPE+NAME to $Def.Type array,       \
# and then, add each $Name in $Names with proper spacing to the $Def.Const array in this (1) loop.  /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

ForEach ($X in 0..($Names.Count-1)) 
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param1Value
}

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, we can write it all to a class definition, and either copy it to the clipboard, or write it  /
# to the console, and copy paste it that way back into the editor. (...or, option 3)                \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$ClassDefinition = @("Class $($Def.Name)",
    "{",
        ($Def.Type -join "`n"), 
        "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))",
        "    {",
        ($Def.Const -join "`n"),
        "    }",
    "}") -join "`n"

#\_________________________________________________________________________________________________
# All of the above variables produced a class definition /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
<# $ClassDefinition | Set-Clipboard -> Pasting -> Complete.

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
#>
#\________
# Summary \_________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Above, the newly constructed class has been cleanly formatted, and procedurally spaced out. But,  /
# if it is no different than selecting all of the properties on the default command output, then    \
# there's no point in doing all of this work unless you're planning on adding custom methods or     /
# properties. Otherwise, you could get the same output from the default command with far less work. \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Instantiate the class definition - this enables the class to be used without having to explicitly /
# write the $Classdefinition output to the clipboard or the editor. (AKA option 3)                  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Invoke-Expression $ClassDefinition | Set-Clipboard

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, to collect ALL of those WMI objects, this may or may not take more time than the first time  /
# (Get-WMIObject Win32_Product) was accessed above.                                                 \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

  $Collect       = Get-WMIObject Win32_Product | % { [Win32_Product]$_ }    # or...
# $Collect       = [Win32_Product[]]@(Get-WMIObject Win32_Product)          # They do the same thing.

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# xkln.net/blog/please-stop-using-win32product-to-find-installed-software-alternatives-inside       /
#                                                                                                   \
# These guys say: Don't use Get-WMIObject Win32_Product anymore... it's slow, incomplete,           /
# problematic, not optimized, it's just a bad way to go about getting that information anyway.      \
#                                                                                                   /
# If you wanna go pro...? Use the REGISTRY, and look in the following keys/paths:                   \
# HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 64-bit                    /
# HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall             | 32-bit                    \
#                                                                                                   /
# The PROS/EXPERTS actually use a WAY (cooler/faster) method of accessing the REGISTRY down below.  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Apps = "\Wow6432Node","" | % { # Checks both (32-bit/64-bit) paths
    Get-Item "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*"
} | Get-ItemProperty

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Console Interaction                                                                               /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> $Apps

# DisplayName     : Visual Studio Community 2022
# InstallDate     : 20220402
# InstallLocation : C:\Program Files\Microsoft Visual Studio\2022\Community
# DisplayVersion  : 17.1.6
# Publisher       : Microsoft Corporation
# DisplayIcon     : C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe
# UninstallString : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" uninstall..
# ModifyPath      : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify --..
# RepairPath      : "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" repair --..
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Mi..
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Mi..
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
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Wind..
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Wind..
# PSChildName     : CCleaner
# PSProvider      : Microsoft.PowerShell.Core\Registry

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# However, they all have differing properties/entries in the registry - they're very different from /
# (Get-WMIObject Win32_Product). WAY different. So, defining a class may be difficult to do, UNLESS \
# theres a way to determine which TYPE of registry entry each of them may be, or we could even pull /
# a template object and use that to draft the class. Then, we can provide an abstract way to force  \
# all of the items in $Apps to fit within the same class.                                           /
#                                                                                                   \
# To do this, lets start with a common application that was installed via MSI, since that has       /
# standard options and the most consistency (so, like Microsoft Edge, or Google Chrome...)          \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$|^Google Chrome$)" 

# PS Prompt:\> $Edge

# DisplayName     : Microsoft Edge
# DisplayVersion  : 101.0.1210.39
# Version         : 101.0.1210.39
# NoRemove        : 1
# ModifyPath      : "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" /install..
# UninstallString : "C:\Program Files (x86)\Microsoft\Edge\Application\101.0.1210.39\Installer\set..
# InstallLocation : C:\Program Files (x86)\Microsoft\Edge\Application
# DisplayIcon     : C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0
# NoRepair        : 1
# Publisher       : Microsoft Corporation
# InstallDate     : 20220507
# VersionMajor    : 1210
# VersionMinor    : 39
# PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Mi..
# PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\Software\Wow6432Node\Mi..
# PSChildName     : Microsoft Edge
# PSProvider      : Microsoft.PowerShell.Core\Registry

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# This time, we want to add a property for NON-DEFAULT registry keys in this uninstall path folder. /
#\_________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [Analogy]: Entries with NON-DEFAULT registry keys are similar to when somebody doesn't fit into   \
# the typical mold that most people in society fit into since they're different than everyone else. /
# They have WAY different properties, and, they're hard to expect. People might get upset and say:  \
#                                                                                                   /
# Default: Hey buddy... why you always gotta be WAY different than everybody else?                  \
# Non-Default: Cause, I don't fit into the typical mold most people in society fit into...          /
# Default: *Everybody shakes their head* That's obnoxious.                                          \
# Non-Default: No way buddy, *points back at em* YOU'RE the obnoxious one, pal... askin me why I    /
# gotta be different...? That's about the most obnoxious thing anybody could even SAY or DO...      /
# Default: I could literally ask all of the people here, in this room, what they're properties are. \
# They're gonna tell me that they have the same properties that we each seem to have.               /
# Non-Default: Not me though.                                                                       \
# Default: Yeah. I know. That's why we're all collectively sighing at you for being WAY different.  /
# Non-Default: It's cause I'm advanced... you can't even expect what properties I contain.          \
# Default: Yeah. That's... why we can't stand ya sometimes, pal.                                    /
# Non-Default: Just cause I'm advanced, doesn't mean I'm a bad person, dude...                      \
# Default: Well, nobody ever said that you were a bad person...                                     /
# Non-Default: Sounded like it though...                                                            \
# Default: On any given day, your name could change to Kevin, and you'll be older or heavier...?    /
# You're like a shape shifter...                                                                    \
# Non-Default: ...it's cause I'm advanced. I have more properties than you.                         /
# Default: Yeah buddy... Sure. It's cause you're "advanced". Next week your name'll be Jeff.        \
# Non-Default: Yeah...? Maybe it WILL be Jeff... You act like it's such a heavy burden.             /
# Default: It is! *shakes head* This dude really is unbelievable... *everyone collectively agrees*  \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, NON-DEFAULT registry keys in these uninstall paths (64-bit/32-bit) may contain some very old /
# school entries that aren't updated anymore. So, whether those entries are ADVANCED, or just OLD.  \
# Don't get down on registry keys in this folder if their properties aren't the same as everybody   /
# elses. Because, we can actually implement a DESIGN CHANGE to the CLASS that ACCOMMODATES any      \
# *unexpected properties*. They won't be a part of the BASE class properties, but they'll still be  /
# visible and accessible. So, everybody actually wins.                                              \
#                                                                                                   /
# There's a few ways we could do this, we could ADD a member to each class for EACH property.       \
# However, that isn't a great idea. That will make many of them TOO DIFFERENT, and not adhere to a  /
# TABLE, as they'll be TOO unique in some cases. Then, everybody will have to collectively sigh at  \
# the "advanced" guy's properties. So, the best option would be to create a property that can host  /
# those "extraneous" properties, and that property's value will be an object that can host an array \
# of ADDITIONAL properties and values that are NON-DEFAULT. That is the best way to go, actually.   /
#                                                                                                   \
# Now, lets choose a property name like "EntryUnique". If we add this property BEFORE we access the /
# PSObject.Properties, the addition will form to the format of the previously written stuff above.  \
#                                                                                                   /
# We'll also need to ADD a few METHODS to this class (methods are nested functions), so it can      \
# refer to itself, provide self referencing brevity, and convert each individual NON-DEFAULT        /
# property, into an object array for each property. Then, we want to have a method that can format  \
# all of those objects and properties and write the output.                                         /
#\__________________________________________________________________________________________________\
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/
# We'll run through the script again... but with a few added steps and more explanations.           \
#                                                                                                   /
# Get $Edge.PSObject.Properties where the name doesn't start with either "_" or "PS"                \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# For the script that applies spacing/formatting to include the new property, and not need an added /
# script at the end, we can inject the new property into the variable $Properties.                  \
# But FIRST, we need to understand what TYPE of object it is, to instantiate that TYPE.             /
#                                                                                                   \
# What does this variable $Properties, get us back in the console...?                               /
#\_________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Console Interaction                                                                               /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> $Properties

# Value                                 MemberType   IsSettable IsGettable TypeNameOfValue Name     
# -----                                 ----------   ---------- ---------- --------------- ----     
# Microsoft Edge                        NoteProperty       True       True System.String   Display..
# 101.0.1210.39                         NoteProperty       True       True System.String   Display..
# 101.0.1210.39                         NoteProperty       True       True System.String   Version..
# 1                                     NoteProperty       True       True System.Int32    NoRemov..
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   ModifyP..
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   Uninsta..
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   Install..
# "C:\Program Files (x86)\Microsoft\E." NoteProperty       True       True System.String   Display..
# 1                                     NoteProperty       True       True System.Int32    NoRepai..
# Microsoft Corporation                 NoteProperty       True       True System.String   Publish..
# 20220507                              NoteProperty       True       True System.String   Install..
# 1210                                  NoteProperty       True       True System.Int32    Version..
# 39                                    NoteProperty       True       True System.Int32    Version..
# {}                                    NoteProperty       True       True System.Object[] EntryUn..

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Looks like a standard, ordinary, run-of-the-mill, object collection table.                        /
# In order to INSERT a NEW PROPERTY to this list of properties, we have to figure out what each of  \
# these objects actually are.                                                                       /
#                                                                                                   \
# Now you could also use the Add-Member cmdlet, but there's another way.                            /
# The $Properties.GetType() method will return the "Object Type" object as seen below.              \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> $Properties.GetType()

# IsPublic IsSerial Name                                     BaseType
# -------- -------- ----                                     --------
# True     True     Object[]                                 System.Array

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# So, it's an object array, which is easy to spot because of the ol' double square brackets there.  /
# We sorta knew this from the object collection table up above.                                     \
# But, in order to ADD a new object to it, we have to determine what TYPE these objects in the      /
# array actually are, and then... instantiate that TYPE.                                            \
#                                                                                                   /
# Select the first item of the array to determine what type of object array it is.                  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> $Properties[0].GetType()

# IsPublic IsSerial Name                BaseType
# -------- -------- ----                --------
# True     False    PSNoteProperty      System.Management.Automation.PSPropertyInfo

# ___________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Alright, so it's a PSNoteProperty array.                                                          /|
# We knew that from the object table, but now we aren't making assumptions.                         \|
# We can attempt to directly access the underlying base type.                                       /|
#                                                                                                   \|
# Now, is PSNoteProperty an object that anybody could instantiate in PowerShell, without calling    /|
# an assembly or adding a type definition...?                                                       \|
#\__________________________________________________________________________________________________/|
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> New-Object PSNoteProperty
# New-Object: A constructor was not found. Cannot find an appropriate constructor for type PSNoteP..

# ___________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Apparently it is, because it wouldn't have come back with a specific error message that says to   /|
# add a constructor... Otherwise, it would've said:                                                 \|
#\__________________________________________________________________________________________________/|
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# New-Object: Cannot find type [PSNoteProperty]: verify that the assembly containing this type is...

# ___________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Since the cmdlet New-Object PSNoteProperty doesn't provide an idea for the PARAMETERS we need to  /|
# feed it without help, lets call the .NET base type, via [PSNoteProperty]::New but, with a twist.  \|
#                                                                                                   /|
# BTW: "[PSNoteProperty]::New()" literally does the same thing as "New-Object PSNoteProperty"       \|
# __________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# [CLR/.Net Tricks Explained]: Auto Completion, and Overload Definitions                            /|
#\_________________________________________________________________________________________________//|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯¯¯¯¯\|
# Trick #1 : Auto Completion                                                                         |

# [PSNoteProperty]::      <- Press CTRL+SPACE here in the [Console], to show default static methods

# PS Prompt:\> [PSNoteProperty]::new(
# Equals           new              ReferenceEquals

#\___________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯¯¯¯¯¯
# Trick #2 : Overload Definitions                                                                   

# [PSNoteProperty]::New   <- Press ENTER here (NO parenthesis/params) to show overload definitions   

# OverloadDefinitions
# -------------------
# PSNoteProperty New(String Name, System.Object Value)

#\__________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [Parallel Study]: Looks like some standard-issue C# up above. Convert to PowerShell like so...    /
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\|
# [C# Notation (w/ Haskell Casing)]                                                                 |
#                                                                                                   |
# PSNoteProperty New(String Name, System.Object Value)                                              |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\|
# [PowerShell Notation]                                                                             |
#                                                                                                   |
# [PSNoteProperty]::New($Name,$Value)        <- $Name and $Value each need to be defined, for this. |
# [PSNoteProperty]::New("EntryUnique",@( ))  <- Direct value entry, no predefined variables needed. |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# [Compare/Contrast]: Q: Why's PowerShell similar to C#? A: Cause they're both made by Microsoft   /|
#\________________________________________________________________________________________________//
#/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯ 
#
# C-Sharp/C# Ex #1 | PSNoteProperty New( String Name, System.Object Value )
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯1 ¯¯2  ¯¯¯¯¯3 ¯¯¯4  ¯¯¯¯¯¯¯¯¯¯¯¯3 ¯¯¯¯4
# C-Sharp/C# Ex #2 | PSNoteProperty Variable = New PSNoteProperty( Name, Value )
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯1 ¯¯¯¯¯¯¯X   ¯¯2 ¯¯¯¯¯¯¯¯¯¯¯¯¯1  ¯¯¯4  ¯¯¯¯4
# PowerShell Ex #1 | [PSNoteProperty]::New( [String] $Name, [Object] $Value )
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯1  ¯¯2  ¯¯¯¯¯¯¯3 ¯¯¯¯¯4 ¯¯¯¯¯¯¯3 ¯¯¯¯¯4
# PowerShell Ex #2 | New-Object PSNoteProperty -ArgumentList $Name, $Value
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ¯¯¯¯¯¯¯¯¯2 ¯¯¯¯¯¯¯¯¯¯¯¯¯1 ¯¯¯¯¯¯¯¯¯¯¯¯X ¯¯¯¯4  ¯¯¯¯¯4
# PowerShell Ex #3 | New-Object PSNoteProperty [String] $Name, [Object] $Value
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   ¯¯¯¯¯¯¯¯¯2 ¯¯¯¯¯¯¯¯¯¯¯¯¯1 ¯¯¯¯¯¯¯3 ¯¯¯¯4  ¯¯¯¯¯¯¯5 ¯¯¯¯¯6
#\_______                                                                                          
# Labels \__________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# 1: (Class/Type Name)                                                                              |
# 2: (Static Method/Function Invocation)                                                            |
# 3: (Parameter Type)                                                                               |
# 4: (Parameter Variable)                                                                           |
#\__________                                                                                        |
# Breakdown \______________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Each entry is Haskell-Cased. That means they all look Proper with Capitalized Letters.            |
#                                                                                                   |
# Not every entry on the list will actually WORK if you go to use it as is.                         |
# Because, they are each atypically split to provide a comparison chart.                            |
# Some of these WILL work though, but testing them all, and knowing WHY which ones work...          |
# ...and which ones don't, is an important skill to have. Hence, why I made the chart.              |
#                                                                                                   |
# While there ARE very subtle differences and variations here, they ALL draw some parallel          |
# structure AND more than just abstract similarity to one another. Can you spot the similarities?   |
#\_________________________________________                                                         |
# PowerShell Class/Type Engine Assumptions \_______________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Not all of the labels appear in each instance. With PowerShell, the console is pretty good about  |
# ASSUMING (classes/types) for each variable. That's because of the PowerShell Class/Type engine.   |
# C# has no such 'making assumptions about any given variable' functionality, because it requires   |
# some hefty-handed specificity and NEEDS to be strongly typed... Otherwise, expect many failures.  |
#                                                                                                   |
# In PowerShell, the engine was made to make a lot of assumptions, and it was designed SO well,     |
# that it gets it right quite consistently. It's easy to take what it does, for granted.            |
#\____________________________________________________________________                              |
# CSharp #1 => PSNoteProperty New( String Name, System.Object Value ) \____________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# CSharp #1 has spacing that would cause compilation failures right off the bat (I believe), they   |
# were added to examine the components of each line. Typically each C# entry needs a semicolon at   |
# the (end of line/EOL), but not after method invocation. In PS, EOL semicolons are NOT necessary.  |
#\_________________________________________________________________________                         |
# CSharp #2 => PSNoteProperty Variable = New PSNoteProperty( Name, Value ) \_______________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# I don't work with C# often enough to remember the specifics of calling types for each variable    |
# name and etc... But- I still read it every day, as I implement a lot of it in PowerShell.         |
#                                                                                                   |
# I DO know that C# is a *very* strongly typed language, and CSharp #2 is technically invalid, and  |
# won't work as is. The parameters within the parenthesis do not have the types before them.        |
#                                                                                                   |
# However, it CAN work, as long as it is part of a code block where those variables are already     |
# declared with types. In other words, by itself it would fail. But, if those variables just so     |
# happened to be declared already in a larger block, it would work.                                 |
#\__________________________________________________________________________                        |
# PowerShell #1 => [PSNoteProperty]::New( [String] $Name, [Object] $Value ) \______________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# PS Example #1 shows you that if you use the .Net Class/Type [SquareBrackets]::New() instantiation |
# approach, you'll need to wrap them in square brackets and call a static method with the double    |
# colon. #                                                                                          |
#                                                                                                   |
# Translating static methods from C# to PowerShell requires a little finagling, because in C#, the  |
# methods are called with "::". Another difference between C# and PS, are [SquareBrackets] around   |
# [Types] or [Classes].                                                                             |
#\________                                                                                          |
# Example \________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#  System.Security.Principal.WindowsPrincipal  <- This is a class/type. That fails in the console.  |
# [System.Security.Principal.WindowsPrincipal] <- That is ALSO a class/type. That succeeds.         |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Most of the time, using the double colon after the square brackets will cause the engine to query |
# the object with Intellisense or AutoComplete... which brings up its method suggestions.           |
#\__________________________________________________________________________                        |
# Object Instantiation: Consider replacing <classname> with an actual class \______________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> New-Object <classname>  <- (CmdLet/Function) invocation approach
# PS Prompt:\> [<classname>]::New()    <- (Type/Class) instantiation approach

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Now, these altering variations are nearly identical to double clicking on a shortcut to launch an |
# app. You're typically not starting a program with these functions/classes, but you really could.  |
#                                                                                                   |
# This parallel is suggesting that object instantiation is like launching an executable.            |
#\_______________________________________________________________________                           |
# PowerShell #2 => New-Object PSNoteProperty -ArgumentList $Name, $Value \_________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Combine the previous block info with the notion that PowerShell example #2 uses:                  |
#                                                                                                   |
# New-Object <classname> -ArgumentList $Param1, $Param2                                             |
# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ |
# ...you can actually EXCLUDE the -ArgumentList and the cmdlet will assume that the following       |
# entries are ArgumentList parameters...                                                            |
#¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯ ¯|
# New-Object <classname> $Param1, $Param2#                                                          |
#                                                                                                   |
# ...although, not all cmdlets allow you to omit the -Parameter, all cmdlets are different, too.    |
#\___________________________________________________________________________                       |
# PowerShell #3 => New-Object PSNoteProperty [String] $Name, [Object] $Value \_____________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# PS Example #3 will not work without wrapping [String]$Name in ([String]$Name)                     |
#                                                                                                   |
# That's because assumed parameters work a little differently. The Class/Type engine is awesome,    |
# but it's not Superman, bro... it can't do everything. As such, wrapping parenthesis around        |
# ([String]$Name) causes the engine to resolve the entry in the parenthesis as it relates to maths' |
# order of operations. If using [Type]$Variable as parameter input, they're absolutely necessary.   |
#\____________________________________________                                                      |
# Using non-quoted strings as parameter input \____________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# A worthy thing to note here, is that using non-quoted strings as command parameters may not need  |
# quotes, at least if there are no spaces in the string. For example...                             |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> New-Object PSNoteProperty Michael, Awesome

# Value           : Awesome
# MemberType      : NoteProperty
# IsSettable      : True
# IsGettable      : True                                                                            
# TypeNameOfValue : System.String         
# Name            : Michael
# IsInstance      : True

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
# ...but that only works for strings that have NO spaces. Still, any tip or trick that can whittle  |
# away at character counts actually aids in making scripts easier to read, clearer, more concise,   |
# plus, knowing some of these tricks can help you during the conceptualization and design process.  |
#                                                                                                   |
# Like for instance, if you wanted to name something "Cool Name", you could cast a variable, and    |
# that may keep the space, and you use that as a parameter. But, lets say you run into a different  |
# scope, as that is often the case with class structures. Man. The name "Cool Name" may cause you   |
# to have to write a fair amount MORE code, than not using the space at all.                        |
#                                                                                                   |
# Also, on another note, this trick also works as pipeline property input, like so:                 |
#\_________________________________________________________________________________________________//
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> Get-ChildItem "$Env:SystemDrive\" | ? Name -match Windows      # <- See, no quotes
# PS Prompt:\> Get-ChildItem "$Env:SystemDrive\" | ? Name -match ^\w+         # <- Works w/ Regex

#\__________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\
# The reason why these work, is because the pipeline is accessing properties in a similar manner   /|
# to how (Get-Item $Path | Select-Object Name, Fullname, <etc>) works, so long as the pipeline is  \|
# not within a literal scriptblock or curly braces where the ($_ / Null) variable works, then this /|
# naked string input will work just fine... as long as you're not using exotic chars, or spaces.   \|
#\_________________________________________________________________________________________________/|
# Extended Takeaway from making comparisons between C# and PowerShell /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                              |
# The take away from all of this explanation, is that PowerShell is *LITERALLY* the same exact      |
# thing as C# under the skin, though I'm sure someone from Microsoft will pop out, and say "Nope."  |
# Fine. There are caveats with them being basically identical. Microsoft guy will say "Yup."        |
#                                                                                                   |
# So, in order to adhere to the holy sacred art, of knowing what the hell I'm talking about, then   |
# calling it IDENTICAL to C# is NOT correct. That said, the fact of the matter is that PowerShell   |
# is basically written with C# constructs, and has the same Common Language Runtime/CLR Framework.  |
#                                                                                                   |
# So, it stands to reason they use many (if not all) of the same components. MS Guy: "Maybe..."     |
# So, I have to expect that this Microsoft guy is gonna watch my words like a hawk.                 |
# Because, after so many years of snappin' necks and cashin' checks... he's used to all of that     |
# strongly written type... and he's not the type of dude who plays games. MS Guy: "Nope. I'm not."  |
#                                                                                                   |
# So, specificity matters to him. MS Guy: "Yup. It does."                                           |
# Well, alright MS Guy... Maybe PowerShell and C# aren't exactly the same. MS Guy: "They're not."   |
# But, if they use the same components, then they have similarities that aren't readily apparent.   |
# MS Guy: "I can agree with that..."                                                                |
#                                                                                                   |
# So if that's the case, some experimentation and expanding upon those observations/similarities,   |
# will inevitably evoke (strengths/weaknesses) of one over the other, as they all find their way    |
# into processes that people hadn't used before... MS Guy: "Interesting."                           |
#                                                                                                   |
# At least, not until some dude with his obnoxiously written section headers had his sights on a    |
# checkered flag somewhere in the future. Somewhere. Cause, so is the guy from Microsoft. The both  |
# of these two dudes, day in, day out... constantly looking for an edge in performance. Waiting     |
# for the day that they'd be first person to blast past that checkered flag. MS Guy: "Yeh."         |
#                                                                                                   |
# Anyway, now the new guy came along, looking for ways to break Microsoft's most sophisticated      |
# language... MS Guy: "I too... do this." But, maybe break is the wrong term here...                |
#                                                                                                   |
#\_____________________________                                                                     |
# Embrace, Extend, and Enhance \___________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# When is the last time you've ever heard anybody say:                                              |
# Someone: Hey, buddy. You better not go make something even cooler than it already was...~!        |
#                                                                                                   |
# Probably never... right? But, people do it all the time. I could provide many, many examples, but |
# I'm going to whip out one pretty specific example... When Microsoft combined Edge and Chrome.     |
#                                                                                                   |
# Google originally made Google Chrome... Microsoft originally made Internet Explorer.              |
# Commodore originally made the Commodore64. Paul Allen and Bill Gates made BASIC for the Altaire.  |
#                                                                                                   |
# The point, a lot of people have made stuff... and when everyone kept saying "This is the best",   |
# Well, somebody said "I can do better than that. Check this out..." Boom. New version of Basic.    |
# Paul Allen and Bill Gates spent a fortune renting access to the supercomputers back in the 70's.  |
# Look what they started...?                                                                        |
#                                                                                                   |
# Microsoft has a very detailed history of "showing people how it's done..."                        |
# Sometimes they'll roll up their sleeves when they say this. Other times, they're done before they |
# even have the chance to roll up their sleeves. So, they don't even say anything... Job's done.    |
#                                                                                                   |
# Anyway, this is what they did to Google Chrome... They went ahead and improved Google Chrome.     |
# Just like they do to everything they decide to do. Not really sure why people are shocked by it,  |
# but they have a really long history of just going right ahead, and making something even better.  |
#                                                                                                   |
# Some people might say "How DO they manage to do that?"                                            |
# Well, the answer is because they have the best software engineers in the world, and,              |
# the world's best software is engineered at One Microsoft Way, Redmond WA 98052. Always has been.  |
# That's cause they invented the idea of software. So, when they decide to do something...?         |
# They don't play games. One day they got together and said to Google...                            |
#                                                                                                   |
#\_________________________________________________________________________________________________/|
# Internet Explorer vs. Chrome vs. Edge /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                            |
#                                                                                                   |
# Microsoft: Hey Google. Let us show you how to build a better web browser.                         |
#    Google: Chrome is the best, pal.                                                               |
# Microsoft: No, we know that it WAS at one point. But, we made Internet Explorer. That was the     |
#            best at one point in time too. You built Google Chrome off of Internet Explorer.       |
#    Google: *scoffs* That's absurd. We didn't build it off of Internet Explorer... ActiveX? Lol.   |
# Microsoft: Nah. Not you, right? You couldn't have done that... could you have...?                 |
#    Google: I mean... we might've taken a few notes from Internet Explorer... ActiveX was cool.    |
# Microsoft: Prolly more than a few notes... Netscape Navigator and Mozilla Firefox too.            |
#    Google: Maybe we did, maybe we didn't. You'll never know...                                    |
# Microsoft: Well, we made an actual operating system called Windows. So...                         |
#    Google: *scoffs* Yeah, well, we made Android and smartphones.                                  |
# Microsoft: Apple did that first. Steve Ballmer also did that. Windows Phone was well built.       |
#    Google: Yeah, well most people in the world use Android, not Windows Phone.                    |
# Microsoft: Yeah, well, most businesses that (generate PROFIT/spend MONEY)... use Windows. So...   |
#    Google: Whatever bro. We made Google Chrome. And. Chrome OS.                                   |
# Microsoft: We know... We had to wait for you to show us a thing or two.                           |
#    Google: And, that's what we did.                                                               |
# Microsoft: Yeah, but we already did those things. Showing somebody a 'thing or two', who already  |
#            made those things a long time ago...? It's rather anticlimactic, to say the least.     |
#    Google: Yeah, well... everybody uses Google to search the web.                                 |
# Microsoft: Cool story bro. Look, we have so many complicated things we've already built, we had   |
#            to give Google Chrome a touch that only the experts could give.                        |
#    Google: Bro, we ARE experts.                                                                   |
# Microsoft: I mean... are you though? Not from our angle...                                        |
#    Google: Gonna pretend I didn't hear that. Besides, nobody who's ANYBODY, can just go ahead,    |
#            and build a WAY better version of Chrome than us. Not without our say.                 |
# Microsoft: We actually went ahead and did that though...                                          |
#    Google: *gulp* Yeh...? Well... it's still based on Chrome...                                   |
# Microsoft: It is. But- we did a lot more than just give it a facelift...                          |
#\_______________________________                                                                   |
# Dreaming Big - Building Bigger \_________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# The truth is, when Microsoft really wants to do something...? They will actually go right ahead,  |
# assign a whole football team worth of people that just so happen to be very bright individuals,   |
# and they'll spend all day and night conceptualizing about the thing they set out to do.           |
# Burning the midnight oil, making pot after pot of coffee, day in, day out...                      |
#                                                                                                   |
# Some of them might even run alongside a black guy on a bicycle, like in the game Mike Tyson's     |
# Punch Out on the NES. Just like Rocky Balboa, eating raw eggs? Push ups? Minimal sleep...?        |
# All the while, having dreams about the code. When they do this, they dream big.                   |
#                                                                                                   |
# Until one day finally comes, like a Rubiks cube that's just about to be solved...                 |
# The new kid comes in after this dream where finally finds the answer to the task.                 |
#                                                                                                   |
#  New Kid: Hey boss man... had a dream last night. Think I might've figured it out.                |
# Boss Man: Oh yeah?                                                                                |
#  New Kid: Yeh.                                                                                    |
# Boss Man: *Looks at the new kid suspensefully* Tell me about this dream you had, kid.             |
#           Sounds important.                                                                       |
#  New Kid: It was. It changed everything.                                                          |
#                                                                                                   |
# So then the kid whips out the napkin that he drew the idea onto.                                  |
# The napkin's all crumpled up, but that's ok... Kid was able to open the napkin, remember the      |
# idea, so he races over to the whiteboard. All these other ideas are on the whiteboard, but he     |
# knows he's got the answer they've been looking for. So he erases everything and starts from       |
# scratch.                                                                                          |
#                                                                                                   |
# Now he starts drawing it all up. The boss man intently watches. So does everybody else.           |
# Everybody on this team of people is on the edge of their seats.                                   |
# After a moment, the boss man starts to see this mathematical probability matrix taking shape...   |
# ...and immediately, he knows the kids idea is gonna work, at least theoretically.                 |
# Boss man's been around for a while. He knows when the math works out...                           |
#                                                                                                   |
# So, boss man tells everybody....                                                                  |
#  Boss Man: This is it guys. *points at the new kid* This kid's got the killer plan...             | 
# The boss man tells person after person what he wants them to build/do, and they all say           |
# Person: You got it boss man.                                                                      |
# After the boss man gives everybody their task, the new kid comes back up to the boss man.         |
#   New Kid: You really think this is gonna work, huh?                                              |
#  Boss Man: Kid... I can feel it in my bones. I think you just about licked the problem.           |
#   New Kid: Can't believe it all just came to me, in a dream like that...                          |
#  Boss Man: I can kid. That's how it works.                                                        |
#                                                                                                   |
# So, now it's time to write the code, and test it.                                                 |
# For the next 2 days, the entire team pounds away at their keyboards...                            |
# ...all because of an idea that the new kid had.                                                   |
#                                                                                                   |
# They knew that the math worked out before even writing a single line of code. They knew it        |
# could achieve some mysterious objective where it outperformed all of the ideas on their idea      |
# board. After 2 days go by, they finally have it ready to compile, so that their virtual           |
# machines could all concurrently test this piece of code.                                          |
#                                                                                                   |
# You wouldn't think that this story was really all that realistic, but... it probably is.          |
#                                                                                                   |
# Then the results came pouring in, and all of the tests and checks were positive, and nominal.     |
# Then the story became, "Microsoft does the impossible- again. Typical Microsoft behavior."        |
#\_____________________________                                                                     |
# The Two Titans of Technology \___________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# The end result, is that Microsoft was able to build a version of Chrome that uses less            |
# resources, is snappier, uses all of the same extensions Chrome does whereby making Edge have      |
# backward compatibility with other extensions, and now they've incorporated what made Edge v1      |
# actually pretty cool, useful, and performant. Google made the mistake they always make...         |
# ...they thought that Microsoft was just old news.                                                 |
#                                                                                                   |
# But, they thought wrong. Now, Google Chrome has all the cool additions of Edge from               |
# Windows 10. To be perfectly fair, it was a battle that both companies fought for many years...    |
# ...until the new kid with the idea came along, and changed the entire way that games were         |
# played between these two titans of technology. A masterpiece, unfolded. Written on a napkin.      |
# Decades in the making...                                                                          |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Continued, Language construction/similarities (Object-Oriented vs. Functional vs. String-based)   |
#\_________________________________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Some may say that PowerShell is a functional language, but it really is a lot more than that.     |
# I suppose for the people that only know how to use commands that come with the operating system,  |
# then it's pretty easy to think PowerShell is just a functional language.                          |
#                                                                                                   |
# However, PowerShell is an Object-Oriented language, just like C# is...                            |
# At least, whenever you do more than just use the default commands and functions.                  |
# Bash or (tsch/TCShell), are more functional based, or even heavily string based.                  |
# ¯¯¯¯     ¯¯¯¯ ¯¯¯¯¯¯¯                                                                             |
# Mainly because the output is a "stream" of individual bytes masked with characters, characters    |
# marked with encoding, encoding indexed with integers, collections of integers being thrown into   |
# floating points calculations, rounding the floating point calculations into percentages, then     |
# doubles getting calculated by multi-tiered hex values... Now, all of these things happen in C#    |
# and PowerShell too... but in PS? EVERYTHING is either a single object, or an array of objects.    |
#                                                                                                   |
# If it's a single object? Well, it could definitely be very detailed. But, it could also be a list |
# or a collection of objects. In that collection, each of those objects has an entire collection of |
# properties. Properties may contain single values, or multiple values. Values can actually be      |
# subproperties, keys, or additional values. Sometimes there may even be multiple objects that just |
# so happen to be marked as values... ...within a single property.                                  |
#                                                                                                   |
# Then, you'll have to face yourself in the mirror. "They could go on infinitely inward, huh?"      |
# Yeah. They could. Because, if there ARE values that represent objects, then... there may be some  | 
# recursive action going on, almost like Horton Hears a Who.                                        |
#                                                                                                   |
# Then what...? You might have an entire arsenal of nested objects each with THEIR own properties.  |
# Each of those objects might have properties which hold a value of an additional object...         |
# Probably sounds confusing... Objects, properties, values... But, values can be nested objects.    |
# Those nested objects might even have many properties with single values, or multiple values.      |
#                                                                                                   |
# Now you probably have no idea if I'm stating things metaphorically, or specifically... do you?    |
#\_________________________________________________                                                 |
# Quantum Physics, Entanglement, and Superposition \_______________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# The truth is, I could be stating one of those things. Or, the other.                              |
# However, what could ALSO be the truth, is that it really could be BOTH things simultaneously.     |
# Or, neither of em. That's how quantum physics, entanglement, and superposition explain reality.   |
#                                                                                                   |
# If that idea stretches your imagination a little too far...? Heh.                                 |
# PowerShell can keep on going buddy. Now, wrap your head around that.                              |
#                                                                                                   |
# Whether nested objects contain values that just so happen to be MORE nested objects, each with    |
# their own properties and values... the truth is, you really COULD go on for seemingly eternity,   |
# nesting objects within values, values within properties, properties within an object...           |
#                                                                                                   |
# Before you know it... you'll realize that basically PowerShell has a lot more control than string |
# based languages. That's why recursion is... mind boggling. C# has this control too, but... kinda  |
# needs to be planned out to control it. PowerShell has a lot more flexibility.                     |
#                                                                                                   |
# Also, string based languages aren't capturing objects with their properties and values            |
# recursively inward, not unless a program is running and happens to be doing that, but chances     |
# are, that the program is outputting some text based derivative, like (stdout/Standard Out).       |
#                                                                                                   |
# Whether that is/isn't the case, a master programmer has to build a construct that manages to do   |
# all of that, without breaking, or throwing an error. So, a master programmer has to be extremely  |
# considerate, and build the proper classes, set the proper constants, intialize the correct keys,  |
# and use mathematical models to build all of it... Or, they could just hope they get lucky.        |
#                                                                                                   |
# They have to keep in mind how many nested objects, properties, and values might be in there,      |
# lurking beneath the surface of it all. Because if they don't...?  Well, the whole program will    |
# inevitably break apart, crash, or shut down. Then it won't be a program anymore... It'll be an    |
# error. Or, a long list of errors. Can't exactly call it a program if it doesn't work...           |
#                                                                                                   |
# Suffice to say, this programmer, this keyboard warrior, whatever you want to call them...         |
# ...they have to find a way to perform such an impossible task, one that can contain every class,  |
# object, property, and value... and if it goes in additional levels... well, what then buddy?      |
#                                                                                                   |
# These are all of the things a developer has to keep in mind... all so that the the normal every   |
# day person can keep their sanity and wits. Probably doesn't sound fair, does it?                  |
#                                                                                                   |
# Them...? Thinking about how to reliably count the number of stars in the universe and not break.  |
#  You...? Probably just getting a coffee at Starbucks to start your day.                           |
#\_____________________                                                                             |
# Doing the impossible \___________________________________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# If that just blew your mind...? Sorry. It's easy to get carried away with how much control there  |
# is, especially when just casually stating these words in a single sentence: "objects, properties, |
# values, recursively, eternity" causes the speaker to start thinking about fractals,               |
# Rosen-Einstein condensates, and Mandlebrot sets. None of these things are really REQUIRED to      |
# build a program, or understand (PowerShell/any other language) but, they definitely help.         |
#                                                                                                   |
# Before I started getting carried away in explaining how PowerShell is FAR MORE than just a        |
# functional language, what I was alluding to is that a functional language isn't exactly descript  |
# about control over objects, properties, and values... An object oriented language IS, as every    |
# component may need to be able to be calculated, translated, and duplicated with precision.        |
#                                                                                                   |
# The possibilities don't stop there, either. But, Allow me to return to the subject of:            |
#\_________________________________________________________________________________________________/|
# (Object-Oriented vs. Functional vs. String-based) /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                |
# String based languages like tsch ARE reliable, however...                                         |
# It is very old, as it originates from UNICS.                                                      |
# While Bash isn't nearly as old, it takes a lot of inspiration from it.                            |
# Bash comes from the very widely authored realm of Unix/Linux/BSD.                                 |
# And, not all Bash shells are created equal...                                                     |
#                                                                                                   |
# Many old (DOS/CMD/COM) based components are ALSO string based.                                    |
# COM objects ARE CMD components, but- with the added kick of having some new functionality, since  |
# some wizards had the wireframe schematics, they chiseled in new accessiblility for PowerShell.    |
#                                                                                                   |
# Java and Python are BOTH string based, AND class/object based. Java/C# are virtually the same...  |
# ¯¯¯¯     ¯¯¯¯¯¯          ¯¯¯¯¯¯ ¯¯¯¯¯      ¯¯¯¯¯¯¯¯¯¯¯¯        ¯¯¯¯¯¯¯                            |
# I mean, they definitely aren't EXACTLY the same, because saying that would be ridiculous. But, in |
# appearance, logical construction, and format... it's pretty easy to see how similar they are.     |
#                                                                                                   |
# Python, is quite a different beast than anything else, but- it is very similar to standard C.     |
# ¯¯¯¯¯¯                                  ¯¯¯¯¯¯¯¯¯¯¯¯¯                             ¯¯¯¯¯¯¯¯¯¯      |
# Standard C has not a single plus, nor two of them, nor does it have a sharp.                      |
# That's what Python is, except it can do a lot more cool stuff than Standard C can.                |
#                                                                                                   |
# Python is ALSO a very good language, very extendable, flexible, powerful and capable, but it is   |
# not even remotely as flexible, powerful or capable as PowerShell... because it requires setup,    |
# multiple components to install, and its console experience is rather detached from the script     |
# editing. Unless you have a compiled executable. But, if it's an executable, then it doesn't       |
# matter if you have the tools or devkits installed to build with it... it's ready to run.          |
#                                                                                                   |
# If we're gonna grasp straws, PowerShell Core requires all of that on Linux/MacOSX/BSD too.        |
# So, if you're using Linux or Mac OSX, THEN... Python is a GREAT choice. But, so is PowerShell.    |
# On Windows, you have access to PowerShell Desktop AND Core. Then, it isn't much of a question.    |
#\_________________________________________________________________________________________________/|
# The Question: Should I install Python...? PowerShell is just way too convenient for me... /¯¯¯¯¯¯\|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯        |
# Should I use PowerShell (since it's already included on Windows) or, install Python...?           |
# Decisions, decisions. Do I use Python version 3.0.0, or 3.1.0? Maybe they're up to v4 now...      |
# Jeez. So many versions. What ever will I do? I want my code to work across multiple versions.     |
# I could totally goof up and install a version that might have a vulnerability included in the     |
# setup package. With PowerShell, Microsoft updates that constantly, so no Log4J type action.       |
# Man. What should I do...? You know, if I *really* wanted to, I'll bet ya that I could *totally*   |
# start working *right now*, and not have to install a single component at all. But, that would     |
# be just WAY too easy, too convenient. Not quite my style. I feel like I NEED to install at least  |
# a dozen components FIRST, before I even begin... Sorry PowerShell, you're WAY too convenient.     |
#                                                                                                   |
# Yeah, nobody has that conversation with themselves, do they?                                      |
# "Dudes at Microsoft being super considerate all the time. What the heck."                         |
# It's almost like the world's best software engineers knew what the hell they were doing when      |
# they built it... that's what I think when I hear "PowerShell".                                    |
#                                                                                                   |
# All jokes aside, Python IS extremely powerful. But- does Microsoft use it more than C# or         |
# PowerShell? Pretty sure that's a "negative". If they're not using C#, they may use C++ if         |
# anything. Perhaps some of them occasionally dabble and moonlight with some Python script          |
# kiddies, as it has seen a lot of increased popularity recently, but- so has PowerShell.           |
#                                                                                                   |
# All things considered, Python has some strengths that aren't anything to joke about at all.       |
# But, it's very taxing to keep up to date unless you're very involved in maintenance, it has       |
# security issues quite often as it is open source, very susceptible to CVE's after each version    |
# has been distributed... I know this because I use a derivative of FreeBSD for gateway appliances. |
#                                                                                                   |
# Python is the most targeted codebase by far. Maybe I'm wrong, PHP and OpenSSL get hit hard too.   |
# But, I see basically every version of python getting hit with CVE's, more than anything else.     |
# It's harder to maintain cross-compatibility AND security, if you release an update for Python,    |
# and within 1 hour of that update being distributed, there's a brand new CVE. Then the next        |
# version will need a few days at a bare minimum... to bug test and wrte. While Python is good      |
# in many cases, I think it is basically DOS on steroids. I'm sure that's an oversimplification,    |
# but Python causes me to feel as if it is the same thing that COM/CMD is.                          |
#                                                                                                   |
# Now, bringing it all back to comparing and contrasting with C#, since that's where this started.  |
#\____________________________________________                                                      |
# Comparing and Contrasting PowerShell and C# \____________________________________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#                                                                                                   |
# C# isn't your standard issue, do-it-in-a-jiffy type of programming language.                      |
# It requires a LOT more meticulousness than PowerShell, as it is specifically, and strongly typed. |
# Whereas PowerShell allows the common lad to relax a bit. Cause... PowerShell knows just how high  |
# C# sets its requirements. Consistently high too. That's how I know PowerShell was designed from   |
# the ground up by some guys at Microsoft who looked at each other one day, and said:               |
#                                                                                                   |
# MS Guy1: Hey, you know what bro...?                                                               |
# MS Guy2: Sup bro?                                                                                 |
# MS Guy1: I feel like C# needs to relax a little bit...                                            |
# MS Guy2: Bro. I've been thinking the same thing for a while now.                                  |
# MS Guy1: It's like... don't get me wrong. I love writing in C#. But-                              |
# MS Guy2: ...feels like somebody's breathing down your neck all the time, doesn't it?              |
# MS Guy1: Yep. Besides... we could totally make things easier on ourselves.                        |
# MS Guy2: Well... Some guy named Jeffrey Snover told Red Rover to move over...                     |
# MS Guy1: Oh yeh...?                                                                               |
# MS Guy2: Yeh. Now we have PowerShell.                                                             |
# MS Guy1: Is that the super-command prompt thing called Monad...?                                  |
# MS Guy2: That's the code name, yep.                                                               |
# MS Guy1: I'm already impressed by the way its name sounds. Sounds powerful.                       |
# MS Guy2: I heard that it is.                                                                      |
# MS Guy1: Very impressive.                                                                         |
# MS Guy2: Dude. We could TOTALLY help make this thing do some ninja-grade C# type stuff.           |
# MS Guy1: ...really? Because, that's something I could really get behind.                          |
# MS Guy2: Yeh man. This thing's got potential. CmdLets, functions, variables...                    |
# MS Guy1: It's almost like somebody cool has been up to something that can't be stopped.           |
# MS Guy2: Not even almost. That's definitely what's happenin', I can feel it.                      |
# MS Guy1: I'd be willing to bet that Google and Oracle will use it, too.                           |
# MS Guy2: Don't say that bro... you'll jinks it.                                                   |
# MS Guy1: *gulp* Dude. I... didn't mean to say it like that...                                     |
# MS Guy2: Great. What if this thing becomes way too powerful and useful now, huh?                  |
# MS Guy1: I don't know what I was thinking, to be honest...                                        |
# MS Guy2: Yeah, well... If it DOES happen to become TOO powerful? I'm blamin' you.                 |
# MS Guy1: Ah man, don't to that...                                                                 |
# MS Guy2: Oh, I'll tell everybody "MS Guy#1 just had to go jinxing PowerShell YEARS ago..."        |
# MS Guy1: Yeah, but this is where the worlds best software engineering takes place...              |
# MS Guy2: Obviously. Let's get it done. Fist bump on it?                                           |
# MS Guy1: Oh, you know it bro... *fist bump*                                                       |
#                                                                                                   |
# Then, they got to work.                                                                           |
# They (compared/contrasted) (C#/PowerShell), to build a new language in a way where dreams         |
# could become reality, visions could become artwork, and the sculptors of tomorrow...?             |
# *Chuckles* Obviously they'd be doing their work within a visual studio like none other.           |
# When other companies asked:                                                                       |
#                                                                                                   |
# Companies: Hey Microsoft, could we like, BUY PowerShell from you? It's really cool.               |
# Microsoft: *chuckles* Yeah, I'm sure you and everyone else would... But- too bad, it's ours.      |
# Companies: C'mon dude. Don't be so sheisty...                                                     |
# Microsoft: *sigh* We knew people would say that, but nah. It ain't happenin', cap'n.              |
# Companies: Well, Microsoft...? *pouts* Guess we'll just have to use Bash or Python...             |
# Microsoft: *scoffs* Fine. Have at it. We use those too.                                           |
# Companies: Yeah, but you have PowerShell...                                                       |
# Microsoft: Obviously. Python and Bash are fine.                                                   |
# Companies: But, we really wanna use PowerShell, cause we like it a lot...                         |
# Microsoft: Cool. You can USE it, but it's not for sale. It's our pride and joy, 20 years of work. |
# Companies: It didn't take you guys 20 years...                                                    |
# Microsoft: Look, all you other companies couldn't comprehend how much thought went into it.       |
# Companies: Well... if we can USE it, then... ...I GUESS that's good enough...                     |
# Microsoft: Fine. Go ahead. Thought you wanted us to just flat out sell the platform...            |
# Companies: I mean... is it for sale...?                                                           |
# Microsoft: *sigh* No.                                                                             |
# Companies: Will you ever let us know if it ever DOES become something you'd sell...?              |
# Microsoft: Surely, you can't be serious...                                                        |
# Companies: Oh, I AM serious... And, don't call me Shirly. That's rude.                            |
# Microsoft: Oh, alright there Mr. Naked Gun 33 1/3.                                                |
# Companies: Airplane.                                                                              |
# Microsoft: What airplane...?                                                                      |
# Companies: That quote is from Airplane, not Naked Gun 33 1/3...                                   |
# Microsoft: Dude. We're Microsoft. We obviously know which movie that quote is from.               |
# Companies: *hangs head in shame* Alright, Microsoft... You win.                                   |
#                                                                                                   |
# Now, I am pretty sure the above conversations have never actually happened, but I do know that    |
# the (men/women) at One Microsoft Way, Redmond WA 98052...? They were under a lot of pressure to   |
# build this thing so that it'd be perfect.                                                         |
# What did they already have on hand, that was fierce, versatile, powerful, and sorta flexible?     |
# Standard-issue C-Sharp. The thing that C++ has so many things in common with.                     |
#                                                                                                   |
# Anyway, (comparing/contrasting) (C#/PowerShell) actually put Microsoft in a position, where they  |
# really can't even sell it. Why...? Cause it'd be like asking someone to sell their kids.          |
#                                                                                                   |
# I would say it is sort of akin to asking General Motors if they know how to make a GOOD vehicle   |
# that doesn't actually use any gasoline... The answer is that yes, General Motors DOES know how    |
# to make a good electric vehicle... the problem is that they will never actually do that.          |
#                                                                                                   |
# So, Microsoft selling PowerShell is a lot like General Motors making a good electric vehicle.     |
# It's unfathomable. The truth is, General Motors has made FAR MORE electric vehicles... than       |
# any other car company on the planet. They just don't have any incentive to make them all that     |
# *well*. I'm sure if they tried, they could definitely make these things as well as Tesla does.    |
# The problem is, finding any reason at all, to convince them to do such a thing.                   |
#                                                                                                   |
# I'm sure if you twisted Microsoft's arm, they could sell PowerShell and then build something to   |
# replace it. But, they're not gonna do that, just like General Motors will never make a good       |
# electric vehicle that uses no gasoline, whatsoever. It actually cannot be expected, at any time.  |
# GM has ALMOST made a good electric vehicle many, many times... but each time those "vehicles"     |
# ALMOST made it to market... they somehow *vanished*.                                              |
#                                                                                                   |
#\_________________________________________________________________________________________________/|
# The terrible magician /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                            |
# So, in reference to electric vehicles, GM makes a better magician, or story teller, than a        |
# vehicle manufacturer....                                                                          |
#                                                                                                   |
#   GM: Here kids, watch this highly rated electric vehicle get 400 miles per charge...             |
#       *Kids wait around for like a year*                                                          |
# Kids: Hey, GM... where's that highly rated electric vehicle that gets 400 miles per charge...?    |
#   GM: It'll be out next year. Had a few issues.                                                   |
# Kids: What kind of issues...?                                                                     |
#   GM: Burning through R&D cash reserves, researching how to make good batteries n stuff.          |
# Kids: But, Tesla has been doing it for a while now...                                             |
#   GM: That's Tesla though.                                                                        |
# Kids: But, you guys get so many awards for the best vehicles in the industry...                   |
#   GM: Gasoline powered. That's why.                                                               |
# Kids: Thought you guys could make electric vehicles that were competetive...                      |
#   GM: Hell no kids. We just SAY stuff like that to SOUND like we're experts.                      |
# Kids: That's... messed up. So, does the vehicle which gets 400 miles per charge exist...?         |
#   GM: On paper it most certainly does.                                                            |
# Kids: On paper...? What does that even mean?                                                      |
#   GM: It means that we printed a piece of paper with the facts and figures of this thing.         |
#       It definitely exists alright. We just ran out of EV R&D money and built more gas cars.      |
# Kids: So, why even tell people you're building an electric vehicle at all...?                     |
#   GM: Look kids. We would really prefer to build gasoline cars. That's what we do best.           |
# Kids: But, what will you do when all of the oil on the planet is gone...?                         |
#   GM: We'll worry about it then, alright...? Now scram. I need to go take a nap.                  |
# Kids: Wow. I've never met such an obnoxious magician in my entire life.                           |
#   GM: Look, I feel bad. Here's some pictures of the 2022 Chevy Corvette.                          |
# Kids: It does LOOK cool, but-                                                                     |
#   GM: No, it's not electric powered.                                                              |
# Kids: Then, why would anyone want this thing...?                                                  |
#   GM: WHAT DO YOU MEAN, why would anyone want this thing...? It's got a lot of horsepower...      |
# Kids: Does it have as much horsepower as the Tesla Model S Plaid...?                              |
#   GM: ...no.                                                                                      |
# Kids: How much does it cost...?                                                                   |
#   GM: Like, $120K.                                                                                |
# Kids: I could buy a Tesla Model S Plaid for that much.                                            |
#   GM: LISTEN KIDS... All you guys wanna do, is talk about the Model S Plaid, don't ya...?         |
# Kids: Yeah. It's cooler looking, and WAY faster than this 2022 Chevy Corvette...                  |
#   GM: But, actual experts designed this thing... We invested a lot of R&D money into it.          |
# Kids: Weird. Actual experts made something that uses gasoline and is still slower than            |
#       the Tesla Model S Plaid...? Doesn't make a lot of sense there Mr. Magician...               |
#       Probably could've spent that money making an electric car. But, a GOOD one.                 |
#   GM: Could've, should've, would've. So what...?                                                  |
# Kids: Maybe you guys just aren't very good at making cars anymore...                              |
#   GM: *scoffs* We'll ALWAYS be good at making cars there kids. Don't be ridiculous...             |
# Kids: C'mon guys, lets go. President Obama might have to give this guy another bailout check.     |
#                                                                                                   |
# Now, would GM ever openly state these things? No. That'd be WAY too honest.                       |
# Besides, they could've used that bailout check that they got, to finally do right by the          |
# American people, in the form of making GOOD vehicles, right here in America.                      |
# But, *checks watch* they, still haven't gotten around to it. I wonder why that is...              |
# Much like how Tucker Carlson and Sean Hannity have never been interesting to watch...?            |
# GM has never been an interesting vehicle manufacturer, since... like, ever.                       |
#                                                                                                   |
# Microsoft doesn't have this issue where they perform magic tricks or tell stories...              |
# Not only do THEY know how real climate change is, but they never sound moronic, like, ever.       |
# Also..? If they say they're gonna do something, or they say they know HOW to do something,        |
# then... they *definitely* keep to their word. No "vaporware" like GM and their Electric cars.     |
# When GM and AIG needed a bailout check, Microsoft didn't need one at all. Might be because        |
# Steven Ballmer never put the company in a position to ever NEED one... Ballmer worked his ass     |
# off to make so many good things and ideas. The Slate PC, Windows 8, Windows Phone, I think Zune.  |
# I don't know why... but a lot of those ideas just landed on the market, terribly. Ballmer had     |
# a lot of stiff competition as the CEO of Microsoft... And none of those products were even bad.   |
# Even still... Ballmer never asked Obama for a bailout check. And, that says a million words.      |
#                                                                                                   |
# The truth is, in a similar way to how GM would never be caught dead making a good electric car,   |
# these experts at Microsoft would never even think about selling their 1) kids, nor 2) PowerShell. |
#\_________________________________________________________________________________________________/|
# Microsoft's Golden Standards /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                     |
# The comparison with General Motors doesn't even really compare... Bob Lutz would have to be       |
# humbled enough and finally ask Elon Musk for advice on "how to make a good vehicle that doesn't   |
# use any gasoline". I'd be happy with Lutz even learning how to make a good gasoline powered car.  |
# I mean, lets face it. Anyone could buy a European car, and that will automatically be worth more  |
# than any American car. Right off the lot. It doesn't LOSE as much value as an American car. Why?  |
# Because them Germans and Italians are a lot better at making cars than Americans. Seriously.      |
# Even the Koreans, Japanese, and Chinese folks can make HIGHER QUALITY VEHICLES for LESS MONEY.    |
# What that actually means, is that people in America don't really care if they do a good job.      |
# Some Americans take offense to this... and I don't know why. They should be getting offended by   |
# people that don't pay any attention to the mistakes they make, because they ultimately cost       |
# everybody more more in the long run.                                                              |
#                                                                                                   |
# I really shouldn't say anything negative about Ford or even Chrysler, cause it's not exactly      |
# their fault that they don't make most American cars. The ones they DO make, are typically better  |
# than anything GM makes, hands down. Here's what GM does very well... Selling things that break.   |
# Selling things that break is definitely a lucrative business- GM is the best there is, at that.   |
#                                                                                                   |
# That really isn't something you really want people to consider your company to be the "best" at.  |
# But, maybe that's just my opinion. They found success selling convoys of vehicles that get thrown |
# together with parts that someone intentionally made poorly. Because, if it breaks a lot? That     |
# generates more profit, and to them, if it generates more profit because it broke more often, then |
# that is actually a genius plan. So, their eating-leaded-paint-chips mentality, where they made    |
# more money, caused them to believe they did an AMAZING job. Stupidity will do that to ya...       |
#                                                                                                   |
# Those automatic window controllers need to be replaced every other winter on one of the doors.    |
# Doesn't matter if you had the driver rear door fixed last year, what matters is that this year,   |
# the other one will also suddenly break. You might feel like the boogeyman is just swinging around |
# from one part to the next, randomly breaking these things. Heh. That's what they're very good at  |
# making people think. Now that the other rear window motor is broken... each time you drive it in  |
# the winter, you'll feel like your air conditioner is on in the middle of the winter, but that's   |
# mainly cause the rear window motor is broke, and the window is wide open. So, that real familiar  |
# blast of arctic air you feel...? It's genuine. Because... you're like everyone else who owns a GM |
# vehicle. "There's no way that they make this car to break like this..." Yeah there is, actually.  |
#                                                                                                   |
# They don't actually care how ignorant the manner of generating more profit is, what matters is    |
# whether the garbage they made generates a net profit at any cost whatsoever. Even the Germans     |
# would never do something this moronic to something they put a lot of time, and effort into.       |
# GM just does not care about the customer's opinion at all... Even if you are really cool or,      |
# important. Why...? As soon as the really important person says something to their buddy, someone  |
# at GM will wait for that person to leave, and the moment they shut the door, they'll say "Yeah    |
# right pal. Take a hike. There's just no real money in making cars that don't constantly break     |
# down. My grandfather tried that for like 50 years... he was constantly broke. Now look at him.    |
# That dude may have built this company with his bare hands, but if he had only figured out how to  |
# source consistently lower quality parts that break  more often? He would've been a billionaire."  |
# And now that person or those people happen to be living quite comfortably. They make damn certain |
# that THEIR vehicles aren't equipped with the defective products. Nah. Not theirs.                 |
#                                                                                                   |
# Microsoft would never, ever, not in their entire existence, implement intentional design flaws.   |
#\_______________________________________________________________________                           |
# General Motors, and how to insult someone that deserves to be insulted \_________________________/|
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\|
# Seriously. That's because they have ACTUAL gold standards... not "quote unquote gold standards".  |
# When the FBI guys drive around in the State issued Yukon Denalis, they may say "Man, why does     |
# this thing always smell like burning oil...?" Well, it could be because, that's what it's doing.  |
# And then they'll try to tell me "There's no way, this is a deluxe edition Yukon Denali, brand     |
# new, and it has like 10K miles on it." Yeah, if GM made it, then there IS a way that it's burning |
# oil, because every GM vehicle does that. So, someone who thinks they're driving a good vehicle,   |
# they'll give the manufacturer the benefit of a doubt because of how much money they spent on it.  |
# With a name like General Motors, the more money people spend, the more innocent they look. But,   |
# the oil filters will ALWAYS have a slight groove on the thread where the filter screws into place |
# and that's right where the oil starts to leak/burn, so the truth is "nah, it's not burning oil... |
# it's just burning AND leaking oil. Big difference. When it doesn't leak, it burns. When it won't  |
# burn, it'll just leak. Can't have one without the other, the best of qualty GM craftsmanship."    |
#                                                                                                   |
# The reason why it sounds ridiculous, is because sometimes the truth is stranger than fiction.     |
# There's a combination of leakage AND burning occurring simultaneously. Maybe it only happens on 7 |
# out of 8 GM vehicles, and the 1 out of 8 vehicles that doesn't leak, it just burns the oil faster |
# than it can leak. So, someone might try to tell me that makes them an exception. But, it doesn't. |
# Literally 100% of their vehicles do this. They don't make a single vehicle that doesn't burn oil, |
# or if it strangely does not leak, burning the oil. Suppose someone actually asked GM executives,  |
# "Hey, do all GM vehicles leak/burn oil...?" Cause I'll tell you right now, they will say no, and  |
# if you ask them to prove it... They will say they're too busy. That's cause they're not busy at   |
# all, and they just lied about whether their vehicles all burn/leak oil. That's how they operate.  |
#                                                                                                   |
# The truth is, it doesn't matter WHO spends WHAT amount. If a GM vehicle is involved when someone  |
# smells oil or something burning, that's because the engine of that vehicle is doing just that.    |
#                                                                                                   |
# Believe it or not, but a Chevrolet Impala, uses the same exact chassis as a Cadillac CTS.         |
# Even if the Cadillac has leather seats and a much more powerful engine... After $20K miles? The   |
# transmission will occasionally start slipping into 3rd gear. Why? Intentional design flaw, helps  |
# to make certain that the transmission is on track to fall out right after the warranty expires.   |
#                                                                                                   |
# If you think I'm kidding, I'm not. I might sound like I'm making some of this stuff up, but the   |
# only thing I am making up are these various conditions... Every vehicle has these problems        |
# intentionally implemented. My 2004 Pontiac Grand Prix had a 3.8L V6, bumper to bumper warranty,   |
# and when driving the vehicle, my car would make these POPPING noises every time I would hit the   |
# accelerator, and then again when I'd hit the brakes. That's because the dealership I bought the   |
# vehicle from, Northstar Chevrolet...? They would claim to do work on my car. When I'd leave, the  |
# noise was actually still there. I kept saying to myself "What if they're not actually doing any   |
# work on my vehicle...? Every single time I bring it in for warranty work, it has the same exact   |
# problems it did before I dropped it off. Virtually identical."                                    |
#                                                                                                   |
# Then when you ACCUSE them of not doing the work, they'll try to make you feel bad like            |
# "Oh, I thought you and I were cool, buddy... Can't believe you're actin' all psycho now..."       |
# That person is trying to blame YOU for being RIGHTFULLY pissed off at THEM, for lying to you.     |
# I was just too young to realize that I should capitalize on my gut instincts like that, because   |
# so many people make a living off of being completely dishonest. This would include the police.    |
#                                                                                                   |
# That's because I was charged for a warranty that they made no effort to provide. They SAID that   |
# they did all of this work (allegedly), but if the vehicle still makes the same noises before it   |
# got dropped off, and continues to make those same exact noises AFTER it's picked up, the simlest  |
# explanation is that someone expects that their personality appears to be trustworthy LOOKING.     |
# Yeah. That's right. Some people don't care if you catch them lying to you, as long as they LOOK   |
# like they are a trustworthy person, they can 1) say, or 2) do whatever.                           |
#                                                                                                   |
# My engine died and needed to be replaced at 107K miles, just 7,000 miles outside of the warranty. |
# I sorta told these useless bastards at Northstart that the vehicle had some problems. The one guy |
# said to me one time "Sometimes a vehicle just, it gets in an accident or something, and it never  |
# drives right after that." But that dude would probably have said "It's not actually gay if you're |
# like me, and you put another mans penis in your mouth." It's not like I have something against a  |
# dude who prefers to do that, but it's too much information for the given situation... Ya know?    |
#                                                                                                   |
# I told this dude that my engine AND transmission kept making strange vibrating noises, and he's   |
# trying to tell me about his sexual fantasies... Doesn't make a whole lot of sense, right? An      |
# ASE certified technician from Northstar Chevrolet, named Alex...? But, surprisingly, everyone     |
# thought he was cool as all hell. I thought he was an idiot that pretended to do actual work.      |
# Anyway, had this feeling for a loooong time, that the engine and the transmission had serious     |
# issues. I felt the transmission making some strange vibrations when it had like, 29K on it.       |
# All the way til 130K when the transmission died on me too. Still had another year of payments     |
# to make on it.                                                                                    |
#                                                                                                   |
# But guess what...? GM sucks at making cars. They make ok trucks, but even they break down a lot.  |
# My friend had a 2005 Chevy Silverado, guess what failed in it about a year before he was done     |
# paying it off...? ...the transmission. Yeah. I don't know why people say they make good stuff,    |
# especially when their "awesome dependable vehicle" just so happens to ALSO break down frequently. |
# So, not only do they suck at making cars, but they also suck at providing necessary services for  |
# the warranties. Because if you're like me, you'll notice that they don't actually do any work.    |
# I actually feel bad for the dude Andy, because I actually believed him, but sometimes even with   |
# him, i'd get the damn car back and magically, I would realize that if they did something at all,  |
# it was barely noticeable. They probably did do portions of the things they told me, but I spent   |
# an additional $11K on replacing the engine+transmission, so they were definitely being lazy.      |
#                                                                                                   |
# Each time, I had a feeling that they literally charged me a lot more money to do no additional    |
# service to my vehicle. I financed a $17K car, and wound up paying about $35K when all was said    |
# and done with replacing the engine 3.5 years in, and then the transmission 6 months later. Still  |
# owed another 18 months worth of payments when I had to shell out $5K for a new engine. Then 12    |
# months left when the transmission failed, that was an additional $6K. I chose to buy this vehicle |
# because I had hoped that buying a new car from a dealership, was a good idea, not a stupid idea.  |
#                                                                                                   |
# So, I realize people might say "Why do you seem to think Bob Lutz is the problem...?"             |
# It's literally cause he was the director of GM for about 50 years, and all of my GM vehicles      |
# have had similar problems. Something ridiculous? Bob Lutz probably had something to do with it.   |
#                                                                                                   |
# Sometimes the high beam switches are like $400 bucks, and they'll break after like the first      |
# 15K miles sometimes. Bob Lutz probably told everybody that makes them, "Hey, use cheap plastic,   |
# but... keep charging for like gold plated ones. That'll show everybody..."                        |
#                                                                                                   |
# What I've realized, is that in order to purchase a GOOD vehicle that GM claims to have made, it   |
# has to have been made in some totally different continent, for instance, Australia. The Pontiac   |
# G8 was a really sweet car. But, Bob Lutz had nothing to do with that vehicle being made. Nah.     |
# Holden actually made it. GM took credit for building it, cause why not? The 2003+ Pontiac GTO and |
# the Pontiac G8 were both made in Australia. Not America. That's the ONLY reason why they were     |
# both really good cars. Had they been made here in the United States, then they would've never     |
# been as well made.                                                                                |
#                                                                                                   |
# You gotta figure, even vehicles that wind up getting fitted with bulletproof glass to protect     |
# former-governor Cuomo, the former governor of New York that somehow had 11 women accuse him of    |
# something he supposedly would never do... If GM made that thing? It's got many design flaws too.  |
# Maybe if you throw a tennis ball at Cuomo's Yukon Denali, it could cause the transmission to fall |
# out. So, throwing it into 4 wheel drive, and going off roading with it, it's a pretty extreme     |
# activity... but a tennis ball in the right spot will cause that transmission to immediately fail. |
#                                                                                                   |
# Then what? A lot of people will overlook stuff like that, a little tennis ball versus a $12K      |
# transmission... the tennis ball somehow wins. At that point it's more than just dumb luck.        |
# Maybe the hood won't stay up, the hydraulic pumps that are supposed to automatically holding the  |
# hood up, they have a seal that breaks because of a design flaw. They'll work for like 18 months   |
# reliably, and then magically one day, the seals met a condition where they matched equilibrium    |
# with the environment. After that point, it's gonna hit ya in the head. So, if you want the hood   |
# to stay up without the pole...?                                                                   |
#                                                                                                   |
# GM: That'll be $500 bucks.                                                                        |
# You: I don't wanna pay that.                                                                      |
# GM: Don't wanna pay us $500? Oh. Looks like you'll need that pole then, chump...                  |
#                                                                                                   |
# Even if people get them fixed, that's another $250 each, and they may last 18 months, if you're   |
# lucky. But I have a way better idea... what if the people who made them, actually built them to   |
# last a lot longer than that...? Ya know? I would've thought that they could last like 10 years.   |
# Or more. Sorta like parts on a German car, they like, last a lot longer for some strange reason.  |
# On a GM though... Oh, no. You get like 6 months max before something else falls apart.            |
#                                                                                                   |
# Sometimes they design brake rotors and calipers so that even a brand new set of brake pads        |
# will sound like the pads are scraping the rotor, but that's because the calipers have a slight    |
# bend in the hydraulic line which is meant to cause the brake pads to pinch in at a slight angle,  |
# and that causes the pads and rotors to get malformed and start warping right off the bat,         |
# causing the vehicle to feel 'dog legged' when coming to a stop... You'll say "I literally just    |
# changed the god damn brakes on this..." But, they don't care. You need to buy more already...     |
# Or else you're not cool in their book. They weren't installed correctly. The calipers are good.   |
# The problem is that they make these things poorly, rather consistently.                           |
#                                                                                                   |
# While they really could make things easier on everybody...? Well, making all of these things with |
# no flaws implemented off the rip, puts a lot less money in their pockets... they don't like that. |
# As soon as they hear something like "less money", their voice starts trailing off. Cause you said |
# something like "less money for them", and now they're trying to stay positive, drowning you out.  |
# Less money for them sounds like a traumatic experience. They may even bawl at the eyes.           |
#                                                                                                   |
# If their business isn't generating enough profit from parts made for that vehicle, then to them?  |
# That means it was actually poorly designed. If it gets better gas mileage, sustains an impact in  |
# an accident, way better than their typical vehicle, AND it has NO recalls or defective parts...?  |
# They will actually consider that a failure on their part. Yeah. 5 star crash safety rating? Bad.  |
# These factors just don't generate the type of profit they like to see. We're talking, they look   | 
# for any stupid flaw that seems to happen a lot... and when they notice this problem being super   | 
# widespread across their entire fleet of vehicles, they will actually track down that manufacturer |
# and they'll offer to award them with a contract in order to mass produce those defective parts.   | 
#                                                                                                   |
# In order for a product to be successful in GM's eyes? It can only be considered successful if it  |
# breaks a lot. If a car has a lot of these parts, then they will heavily promote that vehicle. A   |
# lot of ridiculous things that suddenly go bad for next to no reason at all, they all get their    |
# hopes up. Mainly because they have eyes for this kind of thing. They know a poorly developed part |
# when they see one, and when OTHER car companies would avoid using these parts? They double down.  |
# Their eyes light up with delight. They move heaven and earth to convince the part manufacturers,  |
# to live a little. It has to be fairly believable when these parts "randomly" break, that it's no  |
# coincidence at all when it happens. That's why they're industry leaders.                          |
#                                                                                                   |
# The sad truth is, that is why Bob Lutz was the director of GM for over 50 years. He was very      |
# gifted at tracking down these terribly made parts, and then flooding every vehicle he could with  | 
# THOSE consistently terrible parts... It might sound ridiculous, but this dude actually has a lot  |
# more experience than Elon Musk or Tesla, at making electric vehicles. And, making terrible cars.  |
# Even with Elon Musk AND Tesla BOTH having a LOT less experience than General Motors, Ford, or     |
# Chrysler... all of that is irrelevant. Why...?                                                    |
#                                                                                                   |
# American car corporations worry more about profit, and less about the quality of their products.  |
# With other corporations and industries, you get a lot less of an "evil bastard" vibe.             |
# Too worried about burning and leaking oil... not about gas mileage or sustainability. The more    |
# money they can convince people to waste...? The better. That means they have more to give Sean    |
# Hannity or Tucker Carlson, which works great for them. To them? They don't care about wildfires   |
# nor the plastic in the oceans. Nor the cancer people contract from exhaust and smog, nor the many |
# tornado outbreaks, nor the hurricanesm, nor the ocean levels rising. Nah. All of that stuff is a  |
# lot less important to them. Actually, all of those things are a lot less important than these     |
# people, in their eyes. So, if many animals and plant species keep going extinct...? They          |
# obviously rationalize with themselves that those animals or plants probably didn't have what it   |
# takes to exist in THEIR world. Because they figure, if those animal or plant species were worth   |
# a damn, they'd still be around... and that's what they say to themselves. Keeps em optimistic     |
# about the future...                                                                               |
#                                                                                                   |
# I realize, some people might think it's alarming that the car companies that keep building gas    |
# powered cars think all of these things, but what's worse is how they say nothing or even deny it, |
# when their actions consistently prove otherwise. To them, they just don't have what it takes to   |
# do what Elon Musk is doing with Tesla. What Musk/Tesla is doing primarily considers that oil will |
# eventually all run out. If that happened TODAY, how screwed would we be? Very. If we ran out of   |
# oil, right now? A lot of people would die, very quickly. So, if the world ran out of oil TODAY,   |
# The question then becomes, are we currently prepared for that much loss of life...? Well, no. The |
# Doomsday clock has been ticking the whole entire time, and people just have no earthly idea how   |
# close we are to an extinction level event. We cannot moderate ourselves, even the smartest people |
# on the planet have nothing at their disposal to restore order.                                    |
#                                                                                                   |
# So then the question should really be, will GM still try to sell these 2022 Chevy Corvettes when  |
# there's no oil or gas left...? Yeah. They will. They will know that there's no way to enjoy or do |
# anything with a vehicle that has a 20th century power source, gasoline. So these idiots just keep | 
# making/selling the 2022 Chevy Corvette, even when ALL of the gas is gone. Why...? I think it is   |
# because they're mentally handicapped. It's a pretty good explanation... isn't it?                 |
#                                                                                                   |
# If they aren't mentally handicapped, then my next best suggestion is that they should consider    |
# buying the vehicle, instead of selling it... As the effort might allow them to catch on to how    |
# moronic the idea is. Ya know?                                                                     |
# Them: Hey, wanna buy a 2022 Chevy Corvette...? It looks insanely cool.                            |
# Them: Oh wait, I gotta pretend to be the guy buying it... who's gonna sell it to me though?       |
# Them: Damnit. Maybe this was actually a really stupid idea, to try and sell this car now.         |
# Them: OoOhh, just sell myself a 2022 Chevy Corvette when there's no more gas left on the planet.  |
# Them: How dumb am I... My god. I can only imagine how many other people felt when I asked em...   |
# Them: They probably thought. "Wow. This dude is a total moron... isn't he?"                       |
#                                                                                                   |
# Maybe everyone on the planet should consider that these people lie to themselves every single     |
# day. Standard issue Tucker Carlson and Sean Hannity. They might say climate change isn't real,    |
# NOW, but later on when they're all alone, and they realize that it's a lot colder during the      |
# summer months, than they'll have this startling idea...                                           |
# Them: You know... climate change probably WAS real that whole entire time and I was just some     |
# overpaid shill whining on national television about everything...                                 |
# Them: Ah, god. That IS what I did. Wow. I feel like a complete idiot...                           |
#                                                                                                   |
# For the longest time, they invested so much energy into lying to themselves, now they're telling  |
# themselves the truth, and it sounds so foreign. They didn't realize just how moronic they sounded |
# to so many people... Not only do they lie to themselves, but they lie to everyone else too. They  |
# lack the ability to tell a single truth about anything at all.                                    |
# Because if they could tell anybody the truth, they                                                |
# would have all decided to help Elon Musk build Tesla, and the batteries.                          |
# Why not sooner...? Just cause. Gasoline used to be extremely abundant.                            |
# And then one day, it was all gone.                                                                |
# Why don't they do that, help an actual professional get the job done... ya know?                  |
# Well... it'd be wishful thinking, that's why.                                                     |
# Because, these people are in absolute denial.                                                     |
# Just like Tucker Carlson and Sean Hannity say "climate change isn't real..."                      |
# I'm not going to assume that they know any better, because they might not at all.                 |
# Sometimes you have to masterfully explain to some dude that gets paid millons                     |
# of dollars every month, that all the money they keep getting paid won't do them any good          |
# if the shit his the fan, and they declare martial law... or if they get themselves killed.        |
# Or even both.#                                                                                    |
#                                                                                                   |
# Trying to make suggestions to either of them is bound to cause some confusion.                    |
# As they may think someone is stating intent, rather than through the same sort of rhetoric        |
# they EACH use to sound increasingly more moronic, each additional appearance they make...         |
# someone should tell them, it is a true statement... doesn't matter who says it about anybody.     |
# It's still true. From what I know about death, nobody has ever been able to live                  |
# comfortably, and maintain their finances really well, if at some point, they became a corpse.     |
# Sorta puts a damper on being able to live comfortably... or manage finances. Or really, anything. |
# But you know, it can't hurt for someone to use some poetry and descriptive scenes,                |
# in order to comfront their own mortality from time to time.                                       |
#                                                                                                   |
# In reality, Steve Jobs did that quite a lot.                                                      |
# He was a better presenter and public speaker, than these Fox boys ever were...                    |
# and could phrase an entire life story, as rhetoric...                                             |
# When he told people that he didn't want to be the richest guy in the graveyard,                   |
# I'm pretty sure he put a lot of thought into the phrase before he ever said those words out loud  |
#                                                                                                   |
# So, even though the dudes on Fox News constantly spam people with THEIR rhetoric,                 |
# they may not get it if someone else does that same exact thing in return.                         |
# What if everybody just showed up on their set, and just started phrasing rhetoric too.            |
#                                                                                                   |
#     Guy: Steve Jobs "You've baked a very lovely cake, but you've used dog shit for frosting."     |
# Carlson: Well, why would anybody do that...?                                                      |
#     Guy: I don't know, I think it's a metaphor.                                                   |
# Carlson: What do you think it's a metaphor for?                                                   |
#     Guy: I could ask you the same question... you know?                                           |
# Carlson: Well... to me? Sorta sounds like maybe people shouldn't shit where they eat...           |
#     Guy: Hey~! That's- quite the interpretation~!                                                 |
# Carlson: Yeh. *chuckles* Pretty good one eh?                                                      |
#     Guy: *chuckles* Nah, not at all lol.                                                          |
# Carlson: But it makes perfect sense to me...                                                      |
#     Guy: I suppose people shouldn't shit where they eat, but that's not what it's about at all.   |
# Carlson: Well... I tried pal. I don't know what it is supposed to mean.                           |
#     Guy: It means that if you're gonna do something phenomenal, go the full measure.              |
#          Otherwise, people are gonna detect such a really poor choice when they (taste/smell)     |
#          the dog shit                                                                             |
# Carlson: Alright. I can see how that makes sense.                                                 |
#     Guy: Yeah, but like usual, you needed to have it explained to you to have an opinion about    |
#          something.                                                                               |
# Carlson: ...I have my own opinions sometimes...                                                   |
#     Guy: Yeah. You thought the metaphor was for not shitting where you eat...                     |
# Carlson: It's a good bit of advice...                                                             |
#     Guy: Why don't you follow something like that...? Ya know?                                    |
# Carlson: I do not shit where I eat...                                                             |
#     Guy: Could've fooled me, buddy.                                                               |
#                                                                                                   |
# Steve Jobs was a smart bastard for a number of reasons, not just cause he started Apple and       |
# invented the iPod, iPhone, and iPad... though they definitely helped.                             |
# He just truly didn't understand the sense of hoarding everything he could,                        |
# and just keepin' all that stuff to himself. Nah. Not him.                                         |
# He didn't care to be the richest man man in the graveyard...                                      |
# But the quote really means that people can't use money if they get themselves killed.             |
# So, when someone does something for years in exchange for millions of dollars, and the shit       |
# his the fan...? Then, people may no longer be able to purchase amenities, gas, supplies, or food. |
# Cause it's all gone... Then whoever didn't prepare for the situation...? They're all screwed.     |
#                                                                                                   |
# It stands to reason, that this idiot might actually be surprised when he tries to go to the       |
# store and use some of those millions, when the world is in a state of martial law.                |
#                                                                                                   |
#  Carlson: Ah, man. Didn't realize just how moronic it would be, to assume that the shit would     |
#           Never ACTUALLY hit the fan... Jeez. I really am not a smart dude, am I?                 |
# Soldier1: *pointing rifle at Carlson* Are you Tucker Carlson or some shit...?                     |
#  Carlson: Yeah, that's me.                                                                        |
# Soldier1: What the hell are you doin' here...? It ain't safe buddy.                               |
#  Carlson: I ... forgot I can't spend any money now.                                               |
# Soldier1: That's... gotta be the dumbest thing I've ever heard a man say.                         |
#  Carlson: You know, how was I supposed to know ahead of time, that this was gonna happen...?      |
# Soldier1: *stops pointing the rifle at this guy* You really are a helpless idiot... aren't ya?    |
#  Carlson: Look pal, you don't have to be so mean about it...                                      |
# Soldier1: *turns to his buddy who's a fair distance away* Hey dude~! Guess who I found~!?         |
# Soldier2: *voice from a slight distance* Who? Who'd ya find?!                                     |
# Soldier1: Friggen, Tucker Carlson, man.                                                           |
# Soldier2: *distant* Tucker Carlson... isn't that like, the guy from Fox News, Tucker Carlson...?  |
# Soldier1: Yep. It's him alright... You're not gonna believe it either..                           |
# Soldier2: *distant* I don't believe you. Dudes' a friggen millionaire.                            |
# Soldier1: Come check him out. See for your yourself.                                              |
# Soldier2: *distant* Alright, be there in a minute.                                                |
# Soldier1: Heh. You hear that Tucker? He's comin'. He's not gonna believe it either...             |
#  Carlson: Are you guys gonna kill me...?                                                          |
# Solider1: Well, that depends.                                                                     |
#  Carlson: *gulp* ...on what...?                                                                   |
# Soldier1: Buddy, you don't just go runnin around town tryin' to buy supplies after martial law    |
#           is declared. Not without some consequences for makin' such a dumb decision, are readily |
#           apparent to you, anyway.                                                                |
#  Carlson: I don't wanna die...                                                                    |
# Soldier1: Buddy, you really think I wanna be this guy...? A soldier at war, paranoid as hell...?  |
#  Carlson: *sniffles* this feels like a really bad dream~!                                         |
# Soldier1: Man, shut your mouth. You're a grown ass man. Can't be cryin' like that...              |
#  Carlson: *sniffles*                                                                              |
# Soldier2: *approaches* Wow! I thought you were bullshittin' me...                                 |
# Soldier1: See? Told ya. Straight up millionaire LL Cool J-Thompson, Action-Jackson right there.   |
# Soldier2: ... that's not LL Cool J bro. It aint Thompson or Action Jackson either.                |
# Soldier1: I didn't literally mean all that pal.                                                   |
# Soldier2: ...Alright. Well, that's definitely Tucker Carlson right there.                         |
#           What do we do with him then...?                                                         |
# Soldier1: I don't know yet, still trying to figure that out... Can't just let him GO...           |
# Soldier2: Obviously, he's a millionaire.                                                          |
#           He's gotta be worth *something* right now other than money...                           |
# Soldier1: I got a feeling he didn't prepare a god damn thing, though.                             |
#  Carlson: *sniffles* I've got some property                                                       |
# Soldier1: Weapons, dipshit. And supplies.                                                         |
#  Carlson: *whispers* This is a nightmare...                                                       |
# Soldier2: Heh. Dude said "this is a nightmare"... You're a straight up noob, aren't ya?           |
#  Carlson: I guess. I don't know what that is...                                                   |
# Soldier1: Chum, it means you're a straight-up, brand new player in a game you ain't never played. |
#  Carlson: Yeah. I am. So what...?                                                                 |
# Soldier2: *looks at the soldier* At least he admits it. Can't be all that bad...                  |
# Soldier1: He's basically helpless. Doesn't even have a weapon on him, nothin'.                    |
#           Not sure we can even trust him either, cause of how many times the man has lied         |
#           on national broadcast television...                                                     |
#  Carlson: I don't lie on Fox News.                                                                |
# Soldier1: Yeah, you most definitely do, and have, many times dipshit. Now shut your mouth.        |
# Soldier2: What the hell was he doing out there, anyway...? It's dangerous out...                  |
# Soldier1: Yeh. This idiot thought he could spend his money whenever.                              |
#           Didn't realize money's no good now.                                                     |
# Soldier2: I mean, that's not completely true...                                                   |
# Soldier1: Yeah? where could he go, right now, and spend that damn money of his...?                |
# Soldier2: The army base sells supplies, still.                                                    |
# Soldier1: Ah yeh. They'll still take this ddues' money, won't they...?                            |
# Soldier2: That is, if it's not stuck in his bank or something...                                  |
# Soldier1: Is that true Tucker...? You got real fat stacks of cash on hand somewhere...? Hm...?    |
#  Carlson: *sniffles* Yeh. I might.                                                                |
# Soldier2: How much you figure...?                                                                 |
#  Carlson: I've got a few million in cash money.                                                   |
#           Some of the fattest stacks you'll ever lay your eyes on.                                |
# Soldier1: Like, for real...? Not in the bank or whatever...?                                      |
#  Carlson: Yeah. For real. Real fat stacks of cash...                                              |
# Soldier1: Buddy... *turns to Soldier* Dude might make himself useful after all...                 |
#           Get ourselves some weapons from the army supplies store...                              |
# Soldier2: We could try it. It'll be dangerous...                                                  |
# Soldier1: Extra dangerous. But, he's talkin' about some sky high stacks or somethin'              |
#  Carlson: How dangerous...?                                                                       |
#           And I said some of the fattest stacks of cash you'll ever lay your eyes on...           |
#           I didn't say sky-high stacks...                                                         |
# Soldier1: Dangerous to the point where you need a kevlar vest to be out the open,                 |
#           at a bare minumum, just to stay alive.                                                  |
#           But I mean, if you've got some real fat stacks of cash layin' around,                   |
#           ...you could prolly use them, too....                                                   |
#  Carlson: *sniffling* Yeah? Just use some straight up cash, for body armor...?                    |
# Soldier1: I mean, it's definitely a better idea then gettin' shot dead                            |
#           by somebody's random bullet...                                                          |
#  Carlson: *stops sniffling* I'm ready.                                                            |
#           Lets do this...                                                                         |
#           I'm not gonna keep crying like a little girl.                                           |
# Soldier1: Alright.                                                                                |
#           You just earned some respect from me by sayin' that.                                    |
#           You got some kevlar or somethin'...?                                                    |
#                                                                                                   |
# Maybe none of these things will happen.                                                           |
# Maybe everybody that pays all of their bills, and listens to Tucker Carlson,                      |
# Maybe they do it because he's just a floating voice that echos and bounces off of the walls.      |
# Like a pinball.                                                                                   |
# But, like an idiot... neither Carlson nor Hannity put much thought to climate change              |
# possibly showing up at their doorstep someday.                                                    |
#                                                                                                   |
# Maybe for most people, climate change felt like it COULD be one giant hoax,                       |
# Perpetuated by all those pesky scientists that Carlson and Hannity basically undermined           |
# for years as they were handed some of the fattest stacks of cash that anybody whose ever          |
# worked at Fox News, has ever been personally handed.                                              |
# They both lived the dream... being on modern every day network television.                        |
# Repeating the gospels of fools, while also foreshadowing the certain inevitable arrival...        |
# ...of the day where everything began to fall apart.                                               |
# That's because, the day of reckoning finally arrived, with the skies torched and blackened, a     |
# and the sun drowned out like a faint glimmer in a seemingly endless void, an oasis in the         |
# desert... Climate change was in everybody's face that whole entire time...                        |
# it just had to roll up it's sleeves after the day of reckoning finally came...                    |
#                                                                                                   |
# The question remains, what will that day actually bring forth...?                                 |
# Will it be hordes of angry mobs, each with a flaming pitchfork and a molotov cocktail...?         |
# Under martial law, seems pretty likely.                                                           |
# Gotta say, I'd be terrified of even hearing about this story if I were either 1) Carlson, or      |
# 2) Hannity. Why? Cause I'm certain that some militia has been waiting for the day to visit em'.   |
#                                                                                                   |
# If it gets to that point, I am gonna feel bad for those guys.                                     |
# They're gonna have to face the music. It won't be very fun...                                     |
# ...and not a soul will be willing to protect these guys...                                        |
# ...even if they paid a security team a real nice fat stack of cash.                               |
# Because the cash sorta loses it's appeal when the military and the government officially declare: |
# Martial Law.                                                                                      |
# Cause that's when they'll scatter like cockroaches and say "Ha. Never like your ass anyway bro"   |
# Then again, maybe not.                                                                            |
# Regardless, for the every day person who isn't a millionaire, even if you happen to me one...?    |
# Once martial law is declared, the state of the world immediately becomes a dreaded nightmare.     |
# At that point, you better hope you have 1) weapons, 2) ammunition, 3) armor, 4) supplies,         |
# and 5) food.                                                                                      |
#                                                                                                   |
# If you don't, you're already basically dead.                                                      |
# Money will eventually lose all of it's value if these things happen.                              |
# Everything will spiral out of control so fast, people won't realize how grave the situation is... |
# ...until it's too late.                                                                           |
#                                                                                                   |
# However, the truth is... Guys like Elon Musk exist, and, it stands to reason that he is the       |
# only person in the world, who is working a lot harder than everybody else is, at preventing       |
# all of those nightmares from happening in the first place.                                        |
#                                                                                                   |
# All of those worst case scenarios could theoretically be completely avoided if people help him,   |
# but even if people all jump on the bandwagon, start now, and act fast...? Time is very slim.      |
#                                                                                                   |
# There will come a day where people won't even care to complain about the car or oil industry      |
# anymore. It'll just be a lot like the show "The Walking Dead".                                    |
# Everyone's just trying to survive.                                                                |
# Groups of people sticking together, working in colonies, as one.                                  |
# Some aspects of normal life will try to seep back in...                                           |
# but society as we currently know it...?                                                           |
# it'll be permanently gone.                                                                        |
#                                                                                                   |
# We could blame the American car and oil industry long before any of that happens...               |
# There ARE plenty of other industries to call out... but it all goes right back to GM, being a     |
# lousy magician...                                                                                 |
#                                                                                                   |
# GM used to be the poster child for American car manufacturing, at least it used to be,            |
# about 30-40 years ago. Then, this guy Bob Lutz came along.                                        |
# He's probably highly regarded by so many of the people that have come and gone...                 |
#                                                                                                   |
# But even the Germans and Italians over in Europe never really had the problem of being unable to  |
# make good cars... they were very surprised when Bob came along and just started making things a   |
# lot easier for the Europeans to dominate the market.                                              |
# They just maintained the idea of "quality" and high standards.                                    |
# The word "quality" was just never a part of Bob Lutz vocabulary, not for 50 years.                |
# Not unless it was prefixed by the word "low".                                                     |
# The one word by itself...? Oblivious. But together...?                                            |
# Heh. They were words that he lived by. Even today.                                                |
# "Low Quality" ... GM just became a totally different company after that.                          |
#                                                                                                   |
# The Germans were intrigued by how effortlessly this man made their lives, exporting vehicles to   |
# the United States. Since before the age of Hitler, even. Germany has made nothing but good        |
# vehicles. Even their most garbage vehicles last a LOT longer than American cars.                  |
# The reason why, is because Bob Lutz really did change the entire market, single handedly.         |
# Germany just knows everything about making high quality vehicles.                                 |
# Same with Italy, with their Ferarri's, Lambo's, Porsches... If there's one word that describes    |
# European vehicles... it's "Good". "Bad" isn't really a word that ever comes up unless you         |
# start talking about American cars. But, only certain American cars.                               |
#                                                                                                   |
# European vehicles are durable no matter how hard they try to screw them up.                       |
# That's saying something. Not only are they durable and last a long time...                        |
# But, they're also worth more money, like even if you bought one, and drove it off the lot.        |
# European cars lose a hell of a lot less value. With an American car, it's as if 30% of the money  |
# spent on them, is immedately thrown into a barrel, soaked with gasoline, and lit on fire.         |
# That's because, Bob Lutz knew how to do something like that, from his very first day at GM.       |
#                                                                                                   |
# What I just said, is REALLY BAD. Spend MORE, Get less. That's the age of internal                 |
# combustion engine companies and the way they took over a hundred years to stop destroying the     |
# environment and cause climate change. Lazy/greedy car companies, a handful of morons on Fox News, |
# and oil companies that assisted in the controlled demolition of 3 buildings...                    |
# ...in Manhattan, New York. On September 11, 2001                                                  |
#                                                                                                   |
# Yeah, they know Osama Bin Laden planned the airplane attacks. But, Big Oil probably planned the   |
# controlled demolition, and the collapse of those towers caused people to believe that the         |
# AIRPLANES caused the towers to collapse... not the explosive charges and additional 1000 degrees  |
# fahrenheit that would've been required to demolish the builing in the exact fashion that it was   |
# destroyed. But that's because, many morons exist.                                                 |
#                                                                                                   |
# When using a sifter to sift through ash of roasted skeletons, what gets sifted out of the rubble, |
# are details that make the official story that NIST told, ABSOLUTELY IMPOSSIBLE.                   |
# It's why WTC 7 wasn't hit by a single plane, and yet, anyone who watches videos of these          |
# buildings collapsing, they will inevitably realize... Robert Korol was correct that whole entire  |
# time. Never was incorrect, actually. Kept being correct from the very first day, and continued to |
# be correct, as well as Leeroy Hulset, Xili Quan, and Feng Xiao.                                   |
#                                                                                                   |
# Wanna know who was never correct at all...? The National Institute of Standards and Technology.   |
# Especially the report that Shayam Sundar signed off on, for former president, George W. Bush.     |
# At which point, the story could go forward in time and talk about violations to the Constitution, |
# committed by President Bush, Michael Hayden, the NSA/CIA/FBI, PRISM, Technology, xKeyScore,       |
# Mystic, but ultimately, all of that leads to a thing called: CyberTerrorism, a thing that police  |
# don't appear to investigate only civilians.                                                       |
#                                                                                                   |
# Until I see *any* indication of otherwise? I remain firm with this assessment.                    |
# They are absolutely terrible at it. Just as terrible at investigating technology based attacks,   |
# as Bob Lutz has always been at making good vehicles at GM for 50 years. A long chapter of time    |
# where some blindfolded noob just swung wildly at whatever, and called THAT....                    |
# "being a role model citizen".                                                                     |
#                                                                                                   |
# But it could also branch back to global warming and climate change. Al Gore. Leonardo DiCaprio.   |
# The two met way back in the year 2000... Al Gore told young Leonardo...                           |
#                                                                                                   |
# AG:  This global warming thing is gonna get real bad, kid.                                        |
# LD:  Yeah...?                                                                                     |
# AG:  Oh yeh, it's gonna change everything.                                                        |
# LD:  Well, what can we like, DO about it...?                                                      |
# AG:  You could vote for me.                                                                       |
#      Everyone could.                                                                              |
#      I can't explain how bad the problem is in a single minute,                                   |
#      but it would be worthy of it's own documentary...                                            |
#      because it's the greatest challenge of our time.                                             |
# LD:  *gulp* The... greatest...                                                                    |
# AG:  -Challenge of our time. An existential threat, for certain.                                  |
#                                                                                                   |
# All of these things, when combined into a total narrative that sounds more intelligent than       |
# Tucker Carlson ever does on any given day, are the reasons why the wildfires are really bad,      |
# AND the droughts are getting a lot worse (look at Lake Mead, less than 1/3 of it's normal         |
# capacity). But also, the hurricanes are getting worse. And, the deadly tornado outbreaks. And,    |
# houses and coastal towns slowly receding. I could probably continue with the story many           |
# different ways.                                                                                   |
#                                                                                                   |
# The truth is, America has too many people that blindly believe whatever they're told.             |
# Which immediately causes them to become fools. Effortlessly.                                      |
# If some important person lies to everyone on a press conference...?                               |
# 80% of the people will believe the lie that they are told.                                        |
# Then when you TELL them the actual truth, it is extremely difficult to match the criteria where   |
# they will consider entertaining a much better, more accurate story, without offending them.       |
# Because if you lose out on getting through to them within this window, they will go right ahead,  |
# and prove that they're just too ignorant or careless to dislodge the notion, ...that they've      |
# been lied to so many times, the truth is stranger than fiction.                                   |
#                                                                                                   |
# Not just (1) time either. But, repeatedly.                                                        |
# That is why the car industry is still as dominant as it is, Americans don't actually care if      |
# they waste their money on a vehicle that was poorly made, or if they waste $1T on a bunch of      |
# weapons, equipment, vehicles, helicopters, armaments, and other investments in Afghanistan.       |
# So, many Americans fail to grasp, that every single penny that they gave the government for X     |
# amount of time, was thrown into a barrel, soaked with gasoline, and the set on fire.              |
# But, they don't get it.                                                                           |
# So many people died, and so many of everybody's hard earned tax dollars, they're being pissed     |
# away, by people in the government that are CARELESS. When I say careless, I would go so far as    |
# to say "brain dead". Or like, "someone that spent 50 years making terrible vehicles at GM."       |
#                                                                                                   |
# When the F-35 Lightning was boasted about being the next heavy contender for the skies...?        |
# I knew that Lockheed Martin already made the best fighter jet ever built by a single country,     |
# it was the best thing George Bush ever committed to building, as President. Bush has so many      |
# stains on his legacy, that it is literally unsafe to write about those stains at all. Because,    |
# someone will censor anybody for discussing those very clear, and real stains. F-22 Raptor,        |
# wasn't a stain at all. The war in Iraq...? Not a bad idea. The war in Afghanistan...?             |
# Literally the worst idea our military has ever committed to, by far.                              |
#                                                                                                   |
# But, even considering all of those things...?                                                     |
# Former President George W. Bush, is a saint, of all sainthood, in comparison to this moron        |
# named Bob Lutz who ran GM for 50 years. I realize someone will probably tell Bob Lutz about       |
# this entire document, and if he reads it... he will probably cry. Elon just went right ahead,     |
# and upended everything this man Bob Lutz ever did for 50 years straight... Elon had the (1)       |
# company he owns/runs, one who doesn't make a single bad vehicle... make a Tesla Roadster.         |
# Then he had another company he owns/runs, outfit a dummy with a prototype SpaceX suit, and        |
# then had them load that vehicle into a payload fairing to send the thing into space. Then...      |
# The man asked some people who work for him, to spend a lot of time being very creative about      |
# Starman, the adventures of Starman,  comic books, stories, and making this website that can       |
# https://spacein3d.com/where-is-starman-live-tracker/ show Bob Lutz, or anybody else really...     |
# where that car he sent into space... happens to be right now. The whole entire thing... just      |
# proves to me, that some people don't actually whip out an actual middle finger, nor do they       |
# say a single word. Nah. They do something that everyone will remember throughout human history.   |
# Elon Musk, gave a guy Bob Lutz, the BIGGEST middle finger, in the history of middlefingerhood...  |
# ...and to be fair, giving entire industries full of people that sat around and did nothing...     |
# ...a huge middle finger to them ALL for doubting him immensely, Elon Musk set out to do what no   |
# man has ever tried to do before him. It's what he was born to do. Dude might crack some jokes     |
# that piss a lot of people off even more... but they never sent a vehicle into space with their    |
# own fully paid for rocket, fully paid for car, unique power plant, nah.                           |
#                                                                                                   |
# To say that I happen to be highly impressed by the principle...?                                  |
# That's an understatement. Some people are just going to be miserable no matter what, because,     |
# they're just as lazy as Bob Lutz always has been. And that's fine. So it really isn't Elons       |
# fault, that the world is full of so many negative people, who couldnt do a fifth of what he's     |
# done, if they all tried together.                                                                 |
#                                                                                                   |
# Yeah. George Bush was a perfect president, when compared to this moron, Bob Lutz.                 |
# Bob made lot of really bad vehicles.                                                              |
# When I say BAD, I mean...                                                                         |
# ...in his entire 50 year tenure, the man never completed (1) single thing to be proud of...       |
# The truth is- he just about ALMOST did, millions of times over.  People would tell him too...     |
# "Wow, look at you go, Bob~! You really are phenomenal at ALMOST making good cars~!!"              |
# Bob would always hear that, be annoyed, and say "Whaddya mean ALMOST...?"                         |
# But- those people would say 'A valiant effort.', shrug their shoulders, then leave the room.      |
# All the while, every single time people did this, it eroded his sanity.                           |
#                                                                                                   |
# Even poor Bob knew that ALMOST only counts in 1) horseshoes and 2) handgrenades.                  |
# Otherwise, ALMOST is when you need a minimum of 1.0, but- you can't get past 0.9999999999999      |
# That is *exactly* what the term ALMOST is ALL about.                                              |
# General Motors has come vert close to ALMOST making millions of GOOD vehicles.                    |
# The problem is in the way they design the vehicles.                                               |
# There are only (2) conditions where a General Motors vehicle can be called a GOOD vehicle.        |
# [Condition #1]                                                                                    |
# When a mechanic installs parts that GM never 1) made, or 2) touched even once, in that vehicle.   |
# NOW... the vehicle may theoretically meet GOOD vehicle minimum requirements, like magic.          |
# That's because, technically it's not a GM vehicle if the mechanic uses quality parts.             |
# GM doesn't make quality parts. Never has, doesn't know how to, and never will.                    |
# So, if it has parts in it that came from the factory? It *automatically* fails the test.          |
# But, if it meets the requirements, and it passes the test? It can legally be considered GOOD.     |
# This is actually extremely rare.                                                                  |
# [Condition #2]                                                                                    |
# The vehicle was GOOD for a few seconds at the factory up until it found out who made it.          |
# ...which is when it suffered a traumatic event, sustaining permanent engine damage.               |
# This is by design. The vehicle may sound fine whenever it is started.                             |
# At the moment the vehicle is completed and attributed to Bob Lutz in any small way whatsoever?    |
# ...that's when the car itself says "Wow, Bob Lutz made my ass...?"                                |
# ...the guys at the factory respond, "Yep. Sure did, pal..."                                       |
# ...and that's when the car blows a protected head gasket that Bob had the engineers design into   |
# the process, as if it were a person suffering a mini-stroke from the stress involved in being     |
# given such bad information.                                                                       |
#                                                                                                   |
# Every single GM vehicle ever made, under Bob Lutz leadership...?                                  |
# ...they each endured this traumatic process...                                                    |
# What makes it all actually work, is the specialized head gasket didn't COMPLETELY blow itself,    |
# But it will remember the location where it ALMOST blew that gasket.                               |
# Remember how I said ALMOST only counts in horseshoes and handgrenades...?                         |
# Well, the engine ALMOST suffered permanent damage that THEY would've had to pay to fix.           |
# Since it only ALMOST blew the engine, it'll practically DEFINITELY happen at some later point.    |
# While Bob Lutz himself didn't make that car, the car wasn't impressed when it was told that he    |
# happened to be the guy in charge of General Motors when it was marked complete at the factory.    |
# That's all it takes. The vehicle tries to commit suicide, but it's just a car so it ends there.   |
#                                                                                                   |
# Luckily for Bob Lutz, people never seem to catch on. Why...? I really have no idea.               |
# To analogize, it's like someone sitting in a room, farting repeatedly, and can't stop...          |
# And, people being impressed, not disgusted... "Wow. Dude keeps rippin' farts, that's awesome~!"   |
# These aren't your standard-issue farts either, apparently they're WAY more impressive.            |
# Even Barack Obama will chime in... impressed by such consistently, above-average fartknockery.    |
# Though I'm not fooled at all...? Everyone says "It's just your opinion dude, get over yourself."  |
#                                                                                                   |
# As for Elon Musk, this (1), single, non-plural dude, I'd imagine that he didn't think the chain   |
# of nasty farts in rapid succession, was anything to be all that impressed with either. How could  |
# he be? Dude makes the Tesla Model S Plaid, Starship, and just bought Twitter. So, if he knows     |
# something is up, then he and I both know what the hell is going on. He and I are both equally     |
# perturbed by this disgusting stench. If anything ? Elon probably could tell that there's a        |
# medical emergency goin' on. Just two like minded individuals that both feel a threat looming      |
# from the other side of the room where Bob Lutz is endlessly rippin some friggen farts. When I     |
# knew something wasn't right? All of these people were saying "You need to grow up bro~! You're    |
# the only one smelling these 'farts'" But- that's how the "grouped dementia" got em all. They      |
# don't know whats happening, but Elon and I sure as hell do.                                       |
#                                                                                                   |
# If Elon Musk and I see the same exact problem that nobody else does...? Well, great minds think   |
# alike. That problem is Bob Lutz rippin' an endless array of the nastiest farts any man ever       |
# smelled, and this process went on for about 50 years straight over at GM Headquarters. Right      |
# under people's noses too. I came into the world being very well aware of my surroundings...       |
# Bob thought he was being super slick. Wasn't that slick at all. I knew that somebody, somewhere   |
# would also be able to detect the problem...                                                       |
#                                                                                                   |
# That problem being, Bob Lutz, showing up on the news, and saying "Hey Elon Musk, how about you    |
# show us mere mortals how to run a car company.", after having pooped in his pants for over 50     |
# years straight at GM Headquarters. Maybe it wasn't 50 years straight. Coud've been 30. Or 40.     |
# Maybe he never actually pooped in his pants at all... maybe Bob Lutz *started* pooping his pants  |
# quite *regularly* every day AFTER he went on the news... Who the hell really knows? Whatever      |
# the case may be, I cannot help but envision the fact, that this man has spent more time           |
# attempting to build many electric vehicles at GM, than Elon Musk or Tesla has. But, Bob never     |
# had the incentive, nor the talent to do it well...? Maybe Bob should take his own advice.         |
# Ya know?                                                                                          |
#                                                                                                   |
# As for Elon Musk, the man did a lot more than just show Bob Lutz how a car company could be       |
# run, at least, whenever someone with talent decides to take a break from running several other    |
# companies, and then show him how to do just that. But, it's as if this one guy has many talents,  |
# and I hate to be the bearer of news... But, unlike Bob's 50 years of consistently above-average   |
# fartnkockery...? This dude 1) conceptualized, 2) financed, 3) tested, and 4) invented, refillable |
# rockets that can land themselves safely without exploding. That's more difficult than anything    |
# Bob Lutz did for over 50 years at GM Headquarters. By the way, the newest rocket this dude made,  |
# it ALSO happens to be 25ish stories high, and meets the requirements of "first reuseable flying   |
# building". NASA never even did that. Did Bob Lutz do that...? No. Not in the first 20 years he    |
# ran GM, nor in the entire 50. That right there, says quite a lot.                                 |
#                                                                                                   |
# The fact of the matter is that Bob had a lot more time and experience to set a precedent, but-    |
# sometimes people think that doing the bare minimum for 50 years is 'leading by example'. Other    |
# people like me might hear or read that, and just start laughing profusely. Not laughing cause     |
# the man was trying to be funny, but laughing cause he was trying to be serious. That'll get ya    |
# each and every time. Dude actually had the nerve to say "Why don't you come down and show us      |
# mortals how to run a car company...?" And it was at a point in time where Bob Lutz went from      |
# a credible person to so many many people... to an absolute disgrace. That's actually pretty sad.  |
# But, Bob didn't realize that those words would come back to bite him in the ass. Here's how...    |
#                                                                                                   |
# If anyone actually sat down and carefully studied what Elon Musk has accomplished on paper alone, |
# it's easily 20 times the total amount of things Bob Lutz did in the 50 years he ran a company,    |
# one that's almost made a good vehicle millions of times over. They know how to make good          |
# vehicles, they just don't do that. They prefer to sucked ass at making cars, nobody knows why.    |
# And that's actualy ok. Some people like GM and Bob Lutz, they accept their limitations, and move  |
# on with their life. And Bob Lutz isn't the only out out there in many American industries that    |
# prefer to rest on their laurels. Bob Lutz is one of those people through and through, instead of  |
# finally making some decent vehicles that could finally me considered GOOD ? This dude never       |
# realized that he ALMOST made a lot of really nice vehicles. With the problem being that none of   |
# them ever made it past the 0.99999 part of the 1.0 you'd need, to have made so many decent cars.  |
#                                                                                                   |
# Bob Lutz was the director of General Motors for like, 50 years. GM's  made many attempts to build |
# an (electric/gas) vehicle worth a damn. They can't do it successfully. Not only have they made so |
# many more EV's than Tesla, but also, all of their gas powered cars too. A LOT MORE of both. So,   |
# it stands to reason that some guy like Bob with a lot of experience wasn't worthy of a response   |
# from Elon. "Hey, how many electric cars have you tried to build, over# the last 50 years...?"     |
# Probably at least 40. They didn't have this conversation though. Wanna know why...? Cause Elon    |
# would rather one-up Bob Lutz in the form of using a SpaceX rocket, to launch a Tesla Roadster     |
# into space, with StarMan inside... and that whole process, being the biggest middle finger, to    |
# any man throughout human history... squarely directed right at Bob Lutz.                          |
#                                                                                                   |
# I don't know if Bob Lutz watches stuff like the news or whatever... but Elon Musk sent a god damn |
# car into space. Anybody can go to https://spacein3d.com/where-is-starman-live-tracker/, and find  |
# out for themselves "Where is Starman...?"                                                         |
#                                                                                                   |
# I'm gonna repeat what Starman, that website, Tesla, and SpaceX's combined success, means for Bob  |
# Lutz... This dude is running like 5 companies at the same time, and literally sent an electric    |
# vehicle that was actually well built, into space... using a well built rocket that his OTHER      |
# company made... to give Bob Lutz the biggest middle finger in human history.                      |
#                                                                                                   |
# Here's what Bob has to be proud of. Causing guys like me to think that sometimes, old people      |
# don't realize how outmatched they are. Even if they were an industry leader for 50 years...       |
# it actually just makes the embarassment factor even larger.                                       |
#                                                                                                   |
# So, the idea of purchasing a vehicle from General Motors, brand new, with a bumper to bumper      |
# warranty, its a total waste of anyone's money. Why...? Bob Lutz created a lasting company culture |
# that sucks ass at making good cars. Because, even if you were to buy a BRAND NEW car from GM,     |
# right now...? Chances are, the engine and the transmission might both break down a few thousand   |
# miles after that warranty is up. Even if you bring it to the people at the dealership.            |
# Tell em: Hey. My car is making noises...                                                          |
#                                                                                                   |
# Well, the ASE certified technicians might be good for (1) potential day out of (5), so, the       |
# certified technicians might just be there for show, not to do actual work. Because the other (4)  |
# days of the week, they may prefer to lie to the customers about any warranty work on these        |
# vehicles. That makes things easier and a lot cheaper for them... They got paid to provide a       |
# warranty, but... they reserve the right to not service the vehicle if they choose. Maybe the      |
# customer should be told about that and like, get their friggen money back so actual experts can   |
# service the vehicle. But, then they start hemming/hawing, not realizing how moronic they sound.   |
# Then, after the engine and the transmission break down, you have to hire an actual mechanic       |
# that knows what they're doing, in order to fix it. Which means, spend another $10-15 grand on a   |
# car that the dealership "fixed". But if they say they "fixed" it, and it still has the same       |
# problems from BEFORE you dropped it off...? Maybe you'll start to see the "air quotes" more       |
# readily when people talk.                                                                         |
#                                                                                                   |
# Simply put, I don't believe that GM is capable of making a single vehicle that isn't a total      |
# waste of money. And, I definitely blame Bob Lutz 100%. Maybe even Bill Cass. From what I've       |
# observed, General Motors lacks 1) talent, 2) good engineers, 3) actual mechanics. They sure as    |
# hell appear to have portions of those things, but the consistency is substandard. Because, if     |
# they did...? Anybody could buy a brand new car from them and expect that they'll honor the        |
# warranty/repair it.                                                                               |
#                                                                                                   |
# After owning 8 vehicles that General Motors made, the verdict is in. They are ALL terribly made.  |
# That is the gods honest truth, the people at GM don't know how to make GOOD vehicles. It's not    |
# the fault of the engineers, they probably know what they're doing. It's not the executives, they  |
# might know what they're doing too. It's not the technicians that build the cars, nor the dealers. |
# It literally, all boils down to the craftsmanship of the PARTS they use. That's Start -> Finish.  |
# They never have, and they never will. They've had like a 100 year head start over Tesla. But,     |
# they didn't realize the clock was ticking, and it's too bad, and so sad. They know how to make    |
# SOME of them LOOK good, but a car has to do more than just LOOK good, to be considered a good     |
# product by actual intelligent people.                                                             |
#                                                                                                   |
# These are all of the things I think about when I hear the name "Bob Lutz".                        |
# 1) Spend all your money, 2) get a terrible product, 3) they'll get a Bailout check from Obama.    |
# No problem. I wouldn't feel a need to call out a large conglomerate corporation if it had people  |
# who knew how to reliably build parts for their car correctly. But, they are terrible at it.       |
# I know I'm coming across very differently than I have throughout the rest of this document,       |
# but sometimes people have done more than enough to deserve being openly insulted.                 |
#                                                                                                   |
# Just like how peanut butter goes hand in hand with jelly...?                                      |
# Bob Lutz goes hand in hand with "not very innovative or creative", or "sucks at making cars".     |
#                                                                                                   |
# With C# and PowerShell, that's not the case. You have the best there is in the industry.          |
#                                                                                                   |
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Returning to the $Properties variable                                                             /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# PS Prompt:\> $Properties[0]

# Value           : Microsoft Edge
# MemberType      : NoteProperty
# IsSettable      : True
# IsGettable      : True
# TypeNameOfValue : System.String
# Name            : DisplayName
# IsInstance      : True

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# In this instance, we don't care about the Membertype, IsSettable, IsGettable, or IsInstance       /
# properties... but we'll adhere to those values anyway if we use the underlying base type.         \
#                                                                                                   /
# So, like I covered above, we can use "[PSNoteProperty]::New($Name, $Value)" to create an object   \ 
# that adheres to PSObject.Properties, and this will ADD a NEW custom property named "EntryUnique"  /
# to the custom classes property list, and then it'll cast an empty object array to its value.      \
#                                                                                                   / 
# This will allow one of the methods we have to write, to return NON-DEFAULT properties to it.      \
# Doing so adheres to the standard class properties, while allowing additional NON-DEFAULT entries  /
# to coexist peacefully, and be clean and accessible. Who doesn't like that idea...?                \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

  $Properties   += [PSNoteProperty]::New("EntryUnique",@( ))                   # or... 
# $Properties   += New-Object PSNoteProperty -ArgumentList EntryUnique, @( )   # or...
# $Properties   += New-Object PSNoteProperty EntryUnique, @( )

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# We want the class to format itself with the right spacing.                                        /
# So, to do that, we need to get the maximum TypeNameOfValue string length.                         \
# Again, here's some of my "Voodoo 3 5000" action being applied to the $Types variable.             /
#                                                                                                   \ 
# To explain, it's a multifaceted one-liner involving:                                              /
# - ForEach-Object haphazardly piping itself into an array                                          \
# - $_ token with the property length being greater than 0 in square brackets acts as a switch      /
# - $False selects slot 0 in the array returning the string "String", cause that's binary for ya.   \
# - $True selects slot 1 in the array returning ($_ -Replace "System\.","")                         /
#                                                                                                   \
# Now, PowerShell does an amazing job of being able to understand when it's dealing with a default  / 
# system types like [System.Object], or [System.String]. So, the word System being thrown all over  \
# the place is unnecessary. Removing it makes the code shorter and less complicated/messy looking.  /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Types           = ($Properties.TypeNameOfValue | % { @("String",$_ -Replace "System\.","")[$_.Length -gt 0] })
$TypesMaxLength  = ($Types | Sort-Object Length)[-1].Length

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, get maximum Name string length. Also, I'm sorry, but the Voodoo 3 5000 action is all over.   /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Names           = $Properties.Name
$NamesMaxLength  = ($Names | Sort-Object Length)[-1].Length

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Declare a hash table with 1) CLASSNAME, 2) PROPERTY TYPES/NAMES (top portion of class), 3) PARAM  /
# TYPE+VALUE (main method), 4) DEFAULT CONSTRUCTOR DEFINITIONS (main portion of the class), and 5)  \
# METHODS for self-rereferencing, brevity, processing each individual NON-DEFAULT property, as well /
# as writing some output.                                                                           \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Def             = @{ Name = "Uninstall"; Type = @( ); Param1Type = "[Object]"; Param1Value = "`$Registry"; Const = @( ); Method  = @( ) }

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Run through all types, property names, and establish the code to set the class values to the      /
# properties of the (input object/parameter). Add each TYPE+NAME to $Def.Type array, and then each  \
# $Name in $Names with spacing for the $Def.Const array in the same loop.                           /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

ForEach ($X in 0..($Names.Count-1))
{ 
    $Type        = $Types[$X]
    $Name        = $Names[$X]
    $TypeBuffer  = " " * ($TypesMaxLength - $Type.Length + 1)
    $NameBuffer  = " " * ($NamesMaxLength - $Name.Length + 1)
    $Def.Type   += "    [{0}]{1}{2}`${3}" -f $Type , $TypeBuffer, $NameBuffer, $Name
    $Def.Const  += "        `$This.{0}{1} = {2}.{0}" -f $Name, $NameBuffer, $Def.Param1Value
}

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Get the rank of the line where it matches the PSNoteProperty we added, EntryUnique, then replace. /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$X               = 0..($Def.Const.Count-1) | ? { $Def.Const[$_] -match "EntryUnique" }
$Def.Const[$X]   = $Def.Const[$X] -Replace '= .+', '= $This.GetEntryUniqueProperties($Registry)'

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now we have to write methods (Chunked out for readability). This FIRST method will shorten the    /
# process of calling the DEAFULT property names in this class, whereby filtering out "EntryUnique"  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Method1         = @(
'    [String[]] Properties()',
'    {',
'        Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name',
'    }'
)
$Def.Method      += $Method1

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# This second method will return the properties of the base class that aren't standard property     /
# names that we pulled from the $Edge object template.                                              \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Method2          = @(
'    [Object[]] GetEntryUniqueProperties([Object]$Param)',
'    {',
'        Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value'
'    }'
)
$Def.Method      += $Method2

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now we will create a way for the extended properties to show themselves in a way that is          /
# consumable, while still adhering to the default properties.                                       \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Create the Class definition value, this joins together the multiple chunks of the class so that   /
# it can be instantiated by the PowerShell (Type/Class) engine.                                     \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))", "    {",($Def.Const -join "`n"),"    }",( $Def.Method -join "`n"),"}") -join "`n"

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Instantiate the class definition - Using this command below instantiates the class without having /
# to explicitly get the variable output                                                             \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

Invoke-Expression $ClassDefinition

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Alright, now declare a variable that collects all of the $Apps objects in the registry paths like /
# the pros suggested up above. Then, look for the longest NON-DEFAULT property name length, and     \
# then format ALL of the classes with that integer to get a steady stream of formatted output.      /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Output  = $Apps | % { [Uninstall]::New($_) }
$Buffer  = ($Output.EntryUnique.Name | Sort-Object Length)[-1].Length
$Output.Output($Buffer)

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# We should probably use an exterior container class to collect all of these items and format them  /
# accordingly. This will include all variables we assigned BEFORE the class definition, and then    \
# there will be NO chance, that an object will be formatted with an inconsistent buffer value.      /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

Class UninstallStack
{
    [UInt32] $Buffer
    [Object] $Output
    UninstallStack()
    {
        # We can use some of these variables without assigning them to the class. 
        # This optimizes the System.IO stream since it's not tugging along unnecessary data, and does automatic garbage cleanup

        # Apps found in the uninstall registry paths (64-bit/32-bit)
        $Apps        = "\Wow6432Node","" | % { GCI "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty
        $Edge        = $Apps | ? DisplayName -match "(^Microsoft Edge$)"       # Pulls MSI object template Edge/Chrome installation
        $Properties  = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)" # Ignores WMI/PS related properties
        $Properties += [PSNoteProperty]::New("EntryUnique",@( ))               # Add property to include within format 

        # Allow the Uninstall class to be instantiated via the above work
        # We will make a class that integrates ALL of these components, soon.
        $This.Output     = $Apps | % { [Uninstall]::New($_) }
        $This.Buffer     = ($This.Output.EntryUnique.Name | Sort-Object Length)[-1].Length
    }
    [Object[]] GetOutput()
    {
        Return @( $This.Output.Output($This.Buffer) )
    }
}

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now, cast the variable with UninstallStack, which is the class up above. This will automatically  /
# do the same things that all of those separate variables were able to do.                          \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Output = [UninstallStack]::New()
$Output.GetOutput()

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# You won't want to format the output as a table, but even if you do, everything in the NON-DEFAULT /
# properties will be caught within an array. There's really no way to get inconsistent properties   \
# to work across a bunch of entries in a table that have varying property types, unless maybe you   /
# have a monitor that spans about a football field, then I guess maybe that might actually work at  \
# fitting all of the possible properties that any class might have, into an incredibly convenient   /
# view. But, I gotta say... I don't think those types of monitors actually exist yet.               \
#                                                                                                   /
# Then again, maybe somebody who's been working on just that exact thing I said doesn't exist...?   \
# Well... they just heard me loudly and clearly, and so they felt like letting me know...           /
#                                                                                                   \
# Football-Field-Monitor-Dude: Look buddy... Those things DO exist.                                 /
# Me: Oh yeh...?                                                                                    \
# FFMD: Yeh. And you call yourself some type of expert or something...? *scoffs* Unbelievable...    /
# Me: I didn't know they did.                                                                       \
# FFMD: Yeah pal. They most certainly do. Everybody knows that...                                   /
# Me: I didn't know that they actually made a monitor that spans a whole entire football field...   \
# FFMD: Yeah well... now you know. What, have you been livin' under a rock or somethin...?          /
# Me: Nah.                                                                                          \
# FFMD: Well buddy... nice tutorial... But I'm offended about the monitor thing.                    /
# Me: Alright...? I'm sorry...?                                                                     \
# FFMD: Wait... you're... sorry?                                                                    /
# Me: Yeah man, didn't realize I offended you by not knowing a monitor that long actually exists... \
# FFMD: Yeah, they do. You should totally get one, very convenient, you can see the entire screen   /
# no problem...                                                                                     \
# Me: Alright buddy. Duly noted. Well, I still have one more phase of this tutorial left to go.     /
# FFMD: Oh yeah...?                                                                                 \
# Me: Yep. Gonna throw all of that stuff into a class that generates... classes.                    /
# FFMD: A class that generates classes...? What are ya, some type of magician or somethin'?         \
# Me: No...                                                                                         /
# FFMD: Buddy, you've got a lot of tricks.                                                          \
# Me: Well, cool. I appreciate that.                                                                /
# FFMD: I guess I'll stick around and keep reading.                                                 \
# Me: Alright fine. Take care, buddy.                                                               /
# FFMD: You too. Get one of those monitors...                                                       \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Those types of monitors don't exist. I was being facetious about the convenient viewing angle.    /
# Even if they did make them, what practical purpose would anyone use them for? There's only (1)    \
# thing I can think of... to join a bunch of classes that have no matching properties at all.       /
#                                                                                                   \
# It's not unlike buying an Nvidia GTX 3090, so you could play Pogo.com and then brag about it.     /
# "Check it out, I've got an Nvidia GTX 3090, and I am unbeatable at Pop-It." Wow. Impressive...    \
# Or, taking your paycheck, and then just throwing it in the trash because... why not?              /
#                                                                                                   \
# These things probably sound like they make no sense at all, and that's the point.                 /
# That's how much sense it makes to try and use classes that have no matching properties at all.    \
#                                                                                                   /
# You won't really have a hard time NOT noticing when they don't match up either.                   \
# You'll see empty cells, and values that extend about 50 miles into the horizon.                   /
# Having SOME varying property types from class to class is ok, but try to minimize that.           \
#                                                                                                   /
# Allowing just any old class to settle down in the table...? You're just asking to be confused.    \
# You might find yourself staring at the monitor trying to make sense of what you're seeing...      /
# But the truth is, there's no sense or pattern involved after some point. So, maybe you'll get     \
# confused that none of the classes match up in the table anymore... Then what...? Start over...?   / 
#                                                                                                   \
# Well, I'll tell ya. If the properties don't match up, then there's not a whole lot you can do.    /
# It's gonna be a while before anyone is able to readily make use of such an incredibly useful      \
# arrangement of class types that USED to have matching properties... until one day they didn't.    /
#                                                                                                   \
# That's just the way the story goes, of every old man that ever lived, who, at the top of their    /
# game...? He made certain that HIS classes always had matching properties. Until he slipped up.    \
#                                                                                                   /
# Of course, I'm shooting for dramatic story telling. But, one way that we could turn the entire    \
# script into a useful tool that would help anybody custom build their own classes in a jiffy, is   /
# the script. Couldn't be more serious about that actually.                                         \
#                                                                                                   /
# Sometimes I build custom (classes/structs) in either PowerShell or C#, and then I am able to      \
# cast some of those classes/structs to PowerShell/.Net type objects, and they work in literally    /
# the same way. The only difference is that the PowerShell code doesn't need to be compiled by      \
# MSBuild or anything like that. That's because PowerShell can compile C# code on the fly. It's not /
# all-encompassing like MSBuild is, sometimes C# code that works in an MSBuild process doesn't work \
# with the Add-Type cmdlet... I think it's just an issue with Roslyn or something.                  /
#                                                                                                   \
# However, writing a bunch of classes/structs in C# and then initializing and instantiating them    /
# into PowerShell is incredibly useful. It's the only way to get structs into PowerShell, I think.  \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# What I'm going to do NOW, is, build a class that puts all of this stuff together.                 /
# I'll start by stripping away the comments that I made on some of the above content, and then      \
# edit it until it's literally picture perfect, and reproduces the same output as above.            /
#                                                                                                   \
# This time, I'll have to develop this as (2) separate classes, one for the container, one for the  /
# class object, and the class object needs to be written FIRST so that the type can be used in the  \
# container class. Even though the variables are right below, they will likely have to be arranged  /     
# differently in order to work as a pair of classes.                                                \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# So, here it is. This class is just a current derivative, if I were to keep working on it, I would /
# implement various changes to more finely tune the capabilities, properties, values, etc.          \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The NAME of this class, is essentially "DefinitionTemplate", because the name of this class       /
# doesn't NEED to be COOL, because it's job is to produce a class that includes various elements    \
# that would be needed to perform the same exact activity as the variables listed directly above.   /
#                                                                                                   \
# However, this class has implemented many changes to the code it's based on up above, while still  /
# producing the same output. Some of those changes are details that wouldn't even be seen when      \
# using it. But if you were to debug what it does, you'd see how it molds and shapes the output,    /
# and you'd easily see how OTHER techniques were applied, to produce the same result.               \
#                                                                                                   /
# Sometimes this process can make the code longer, but other times it can make the code much more   \
# responsive or even give it more features so other elements can be added/amended whereby boosting  /
# flexibility, capability, or scope.                                                                \
#                                                                                                   /
# The fully written class is below, as is.                                                          \
# AFTER this stint, I will break it down and explain the differences between the variables above,   /
# and the properties and variables in the class.                                                    \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Class DefinitionTemplate                                                                          /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now that the class is declared, instantiate the class and use its methods to reproduce the result /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp            = [DefinitionTemplate]::New("Uninstall","[Object]",'$Registry')

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now load the properties by using the method LoadPropertySet($Properties)                          /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp.LoadPropertySet($Properties)

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now change property named "EntryUnique", new value "$This.GetEntryUniqueProperties($Registry)"    /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp.ChangeProperty("EntryUnique","`$This.GetEntryUniqueProperties(`$Registry)")

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now add method #1                                                                                 /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp.AddMethod(@('[String[]] Properties()','{',
'Return $This.PSObject.Properties | ? Name -notmatch EntryUnique | % Name','}'))

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now add method #2                                                                                 /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp.AddMethod(@('[Object[]] GetEntryUniqueProperties([Object]$Param)',
'{','Return @($Param.PSObject.Properties | ? Name -notmatch "(^PS|$($This.Properties() -join "|"))") | Select-Object Name, Value','}'))

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Now add method #3                                                                                 /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$Temp.AddMethod(@('[Object[]] Output([UInt32]$Buff)','{','$X  = @( )',
'$X += ("-" * 120 -join ""), "[$($This.DisplayName)]", ("-" * 120 -join ""), " "',
'$This.Properties() | % { $X += "{0}{1} : {2}" -f $_, (" " * ($Buff - $_.Length + 1) -join ""), $This.$_ }',
'$X += (" " * $Buff -join "")',
'$This.EntryUnique  | % { $X += "{0}{1} : {2}" -f $_.Name, (" " * ($Buff - $_.Name.Length + 1 ) -join ""), $_.Value }',
'$X += (" " * $Buff -join "")',
'Return $X','}'))

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Run the method ReturnDefinition(), and cast it's output to variable $ClassDefinition              /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

$ClassDefinition = $Temp.ReturnDefinition()

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# Copy the variable output to the clipboard, and THEN, let's take a look at the output...           /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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
# Whether you use one of the StringWriter class types, or I think the Xmlwriter class                \
# also does it, can't think off the top of my head what other default classes automatically indent   /
# stuff for you, but they're out there. Things become harder to do when you're writing CODE that does\
# what you as a human would do when editing the content, and that's when design choices might change./
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

#\___________
# Comparison \______________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\

# [ Before : Part 1 ]

$Apps            = "\Wow6432Node","" | % { Get-ChildItem "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" } | Get-ItemProperty
$Edge            = $Apps | ? DisplayName -match "(^Microsoft Edge$)" 
$Properties      = $Edge.PSObject.Properties | ? Name -notmatch "(^_|^PS)"
$Properties     += [PSNoteProperty]::New("EntryUnique",@( ))

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The BEFORE stuff is actually all the variables starting from where the pros suggested that using  /
# Get-WMIObject Win32_Product to get installed applications, is not the best way to get that info.  \
#                                                                                                   /
# Looking through the registry is actually a WAY snappier way to do the job, and any pro would tell \
# you that. The thing is, the registry and the WMI objects don't have the same values. So, we had   /
# to make some serious changes after writing the WMIClass at the top. Not to mention, the WMIClass  \
# reaches into the HKEY_CLASSES_ROOT for GUIDs and stuff that isn't automatically available to      /
# PowerShell without opening a new PSDrive to HKCR:\*. Pretty sure anyway.                          \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ After : Part 1 ]                                                                                /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class UninstallStack2 # It's named with a 2 because it has a naming conflict with the previous copy
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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The AFTER stuff is essentially the same code, largely. Except, there are (2) properties that      /
# replace a couple of the variables, like $This.Output and $This.Buffer. The other variables are    \
# still written the same way.                                                                       /
#\_________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ Before : Part 1 ]                                                                              /
#\________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The Before stuff right here is doing a lot of the work in processing the values in the            /
# $Properties variable. The $Properties variable is an object array of PSNoteProperties based off   \
# of the $PSObject.Properties variable. The hash table is there reserving some collection           /
# containers for properties Type, Const, and Method.                                                \
#                                                                                                   /
# Then the loop just goes right ahead and starts processing every item in the $Names array.         \
# It is also calculating the length of the buffer strings so that it formats the code neatly.       /
#\_________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ After : Part 2 ]                                                                                /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The After stuff right here looks a lot like the individuals up above.                             /
# However, there are many things that have been moved around to make the process more structurally  \
# sound. Mainly because the hash table that was named $Def, was a good idea to turn into the        / 
# default constructor and class properties.                                                         \
#                                                                                                   /
# The intitial constructor requests (3) parameters, the 1) name of the class, 2) Parameter1Type,    \
# and 3) Parameter1Value, which can be seen up in the before section, except now the class can      /
# accommodate a much more broad range of input without doing a heck of a lot different. The same    \
# can also be done with the hash table. But- if I want to make multiple copies of the class, each   /
# with a different set of values, that's a lot easier. With the hashtable, I'd have to copy and     \ 
# paste the hashtable, and then manually enter new values for those new hashtables, otherwise       / 
# they'll have the same information.                                                                \ 
#                                                                                                   /
# Which is... rather anticlimactic in all honesty. Nothing like seeing thousands of the same exact  \
# hash table cause a token variable somewhere wasn't being changed.                                 /
#                                                                                                   \
# The hashtables also don't scale well as a table like the classes do. They CAN, but the class      /
# doesn't lose any of it's key arrangements or positioning, so the class is more consistent and     \
# reliable. That's not ALWAYS the case, but in this case, it most certainly is.                     /
#                                                                                                   \
# The method LoadPropertySet($Properties) does the same job as the individual variables in the      /
# before stuff above. However, there are some KEY DIFFERENCES to note here. For starters, the way   \
# in which the variables were moved around, allowed the hashtable stuff to be put in it's own       /
# constructor.                                                                                      \
#                                                                                                   /
# Then, shifting the remaining variables from that particular block around, allowed moving the      \
# type length determination process, the type buffer, type buffer to string, as well as the name    /
# length determination process, name buffer, and name buffer to string... not only to the same      \
# block, but- there was a perfect opportunity to create a couple of new methods that cleaned up     /
# the way that code looked, while also providing some more control. Maybe it's a matter of          \
# preference...? Idk.                                                                               /
#                                                                                                   \
# But I like the way that portion of the code looks a LOT better than the individual variables.     /
# Suffice to say, adding those methods makes a lot of sense as they're adding properties, and then  \
# setting the property values... having a method with a name gives anybody a better sense of what   /
# is actually happening behind the code.                                                            \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ Before : Part 3 ]                                                                               /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The Before stuff here, generally looks a lot like the after stuff, but, the class has methods     /
# where these values are just being changed directly. Like, the first couple of variables are       \
# pulling an index number to specifically recall the index of the property that's about to be       /
# changed, and then it changes it with some regex. The after stuff is doing that too... albeit with \
# changes.                                                                                          /
#                                                                                                   \
# The variables named $Method1, $Method2, and $Method3 really aren't all that different from the    / 
# after stuff either, except here, there's no actual method that's inserting those variable values  \
# into the hashtable property named Method. Which is fine...? But, having a method name that        /
# describes the function is really what makes a class even more useful than a slew of variables all \
# taped together. There really is no way to get away from that feeling where using many variables   /
# that aren't connected to a larger container object, starts to feel as if they're all operating    \ 
# on their own accord.                                                                              / 
#                                                                                                   \
# Obviously, this process is required to build the class types, it's just that if a script writer   / 
# doesn't make the effort to implement class types and stuff, they may never be able to write code  \
# that is able to describe itself a lot more clearly and coherently, and methods and even loop      /
# labels go a long way to assist with breaking portions of code off into trunks or branches, rather \
# than one giant soup bowl of variables. Just, variable soup. I don't see people using many loop    /
# labels these days, because it's essentially the same thing as a method, or a switch block.       /
#\________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ After : Part 3 ]                                                                              /
#\_______________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The after stuff here is a lot longer, no question about it.                                       /
# Nothing seen in this group of methods is actually reproducing the code above, however-            \
# It's doing additional things that make the code easier to throw OTHER values at, making           /
# it even more flexible than it already was.                                                        \
# I'm going to paste the portion of code where the class is instantiated and then the methods       /
# that produce the same content as the variables up above, will be more readily comparable.         \
#\__________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# The first two lines here instantiate the class, and then the method LoadPropertySet injects the   / 
# PSObject.Properties information. The third method ChangeProperty is performing the same activity  \
# as the first two variables in the before section directly above. Now I can explain why the code   / 
# in the class is longer, but- achieves a better end result...                                      \ 
#                                                                                                   /
# The method ChangeProperty looks for the property in the constructor "EntryUnique", and then sets  \  
# its value to what is written in the quotes as the second parameter. It's doing almost the         /
# identical thing under the hood as above, however the method ChangeProperty is providing a little  \
# bit of error handling, so if the property parameter finds no result, then it doesn't just NOT     /
# tell you that nothing was done, it'll say that. But also, it uses a double not true boolean       \
# statement where if the token $X is returned via the double negative check, then that means it     /
# found the thing and it made the change. Otherwise it didn't, and will say "failed..."             \
#                                                                                                   /
# As for the method AddMethod(), it is generally identical to the previous variable method, but-    \
# I was able to implement spacing changes so that the input strings don't need to include those     /
# spaces. Even if they do, they're gonna get ripped out and then reinserted from the ground up.     \
#                                                                                                   /
# Why? Because it made more sense to do it that way. However, it did mess with the way I like my    \
# code to be indented from nested code block to nested code block within a method. But, that's      /
# really a matter of preference and it's not a structural defect or anything. Also, the methods     \
# could also be added in the same way as the naked variables, where there was $Method1, $Method2,   /
# and $Method3 and then those values were added... It could be done that way here as well.          \
#                                                                                                   /
# The main difference is that the method is NAMED, rather than just having some property named      \
# Method that allows items to be added to it. Yeah, naming a property "method" that isn't actually  /
# a method might cause some confusion somewhere...? But then again, maybe it won't... Either way,   \
# it's better to have a legitimate, actual-factual method named "AddMethod" rather than wingin' it  /
# with a property named Method then a plus sign and an equals sign, then a variable value.          \
#                                                                                                   /
# I know somebody somewhere is going to say "That's not an actual method..."                        \
# It's a property named method, that just so happens to be inserting a value that represents the    /
# string version of a method for a class. A wolf in sheeps clothing, essentially.                   \
#                                                                                                   /
# It's not unlike showing up to a party in a shirt that says "I'm wearing a black shirt", but...    \
# your shirt is actually white. Everyone's that takes their time to read your shirt is going to     /
# think... "That dude's wearing a white shirt that says 'I'm wearing a black shirt'..."             \
# Then THEIR buddy is gonna say "Wow. That dude's shirt definitely says that, and it IS white..."   /
# Then 10 other buddies are gonna join in, scratching their heads, "Dude's wearin' a white shirt,   \
# but then the shirt says "I'm wearing a black shirt"...                                            /
# Then somebody will eventually say "So, is it like the SHIRT that's wearing a shirt...? Or like-   \
# I don't even know dude... that shirt is blowing my mind right now..."                             /
#                                                                                                   \
# Maybe it won't be that dramatic though.                                                           /
#\_________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ Before : Part 4 ]                                                                               /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$ClassDefinition = @("Class $($Def.Name)","{",($Def.Type -join "`n"), "    $($Def.Name)($($Def.Param1Type)$($Def.Param1Value))", "    {",($Def.Const -join "`n"),"    }",( $Def.Method -join "`n"),"}") -join "`n"

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# There's not much left to go over. It's literally just the class definition variable, the thing    /
# that's supposed to capture the output of the variables up above, so that the class can be loaded  \
# into memory, and then it can be instantiated.                                                     /
#                                                                                                   \
# There's no question, that having blobs of code written all over the place like what's directly    /
# above this paragraph, are a headache to look at. It's long, it's mean looking, doesn't even       \
# remotely feel like a cool dude that just so happens to be hanging out at the park during the      /
# summer... The reason for that is because whenyoutrytostuffabunchofthingsintosomethinglikethat-    \
# itkindalookslikeascarymessthatnobodywantstobenearoraroundcauseitslongcomplicatedlookingandnotfun. /
#                                                                                                   \
# I realize, it probably doesn't look THAT BAD... but that whole "throwing away the spacebar"       /
# comment is sorta the vibe that it gives me. All it's doing is generating the single output string \
# that just so happens to be the output of the entire set of variables. But, there's so many ways   /
# it can be optimized. String interpolation, directly embedding the values without so many quotes,  \
# it's not bad for a first attempt when you're conceptualizing something, but at some point, this   /
# will cause anybody that respects well written code, to say (1) word. "Ahhh!"                      \
#                                                                                                   /
# Do you want somebody who's always been known for respecting well written code, to say "Ahhh!"...  \
# ...when they look at YOURS...? Probably not, right? Cause "Ahhh!" isn't even a word really.       /
# At which point, who's the person who feels most insulted...? You...?                              \
# Or some guy that has always been known for respecting well written code... that said "Ahhh!"...   /
# ...when they looked at yours...?                                                                  \
#                                                                                                   /
# Maybe Linus Torvalds may have to come out from somewhere, and say "I've seen FAR worse code than  \
# that, pal. And, I've always been known for respecting well written code..."                       /
# Then I guess I'm gonna have to put my hands up... and be like "Alright... cant argue with ya."    \
# Cause who's gonna argue with Linus Torvalds... the man who wrote linux? Nobody. Everyone reading  /
# this will probably agree with me "*shakes head* Yeah. that Linus Torvalds guy...? He literally    \
# knows the ins and outs of well written code... and in that case, it's settled... MAYBE the code   /
# above isn't THAT bad. But, personally... I feel as if it appears that the # author lost track of  \
# their space bar, or enter key. Maybe that's fine sometimes. What do I know?                       /
#                                                                                                   \
# Whether I AM THE GUY THAT WROTE THAT or not...? It's irrelevant. Gives me the heebie jeebies.     /
# And that's why I rewrote it in the class and that whole mess became this thing below...           \
#\__________________________________________________________________________________________________/
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# [ After : Part 4 / Final ]                                                                        /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

# __________________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
# People may look at this and think... But- you had all of that in one line... This is like (12+).  /
# Yep. I know, it's a lot more information, but sometimes I ask myself how the highway guys can     \
# stand working on the highway all day in the heat, those tenth of a mile markers being the thing   /
# they gotta drop a bunch of asphalt between, and they'll occasionally look at these markers to     \
# gauge their progress. They probably live for each and every one of those things too.              /
#                                                                                                   \
# Highway guy: Ah man. Just another ... 4 miles to go. Not bad. It's only Monday though. Damnit.    /
#                                                                                                   \
# You know that they're walking... and they look at these things like a clock or a watch.           /
# Pouring, and laying down some asphalt all day long... living through hell, paycheck to paycheck.  \
#                                                                                                   /
# Here's why I prefer the thing above. If I want to make it shorter, that's easy. Highway guy can't \
# make his job any shorter if he even wanted to. With 4 miles of asphalt to lay, there's nothing    /
# he can do to make his job less difficult on himself. But, I definitely CAN make MY job easier on  \
# myself. So, if I want to examine a problem with the output, then I've made it incredibly easy to  /
# track down what could be causing an issue, adjust it, and then I totally avoid feeling like that  \
# dude on the highway in the blistering heat, just pouring asphalt all day long...                  /
#                                                                                                   \
# Cause even though those guys typically get paid pretty well...? I don't think a single one of     /
# them dudes really love doing that job... Maybe some of them do, I don't know. From what some of   \
# my friends tell me they say it's ONLY fun AFTER you get paid.                                     /
#\_________________________________________________________________________________________________/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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
