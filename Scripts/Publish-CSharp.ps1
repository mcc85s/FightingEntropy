<#
Originally written by a man named...
Jeffrey Snover [MSFT] https://devblogs.microsoft.com/powershell/pinvoke-or-accessing-win32-apis/

#######################################################################
#  This is a general purpose routine that I put into a file called
#   LibraryCodeGen.msh and then dot-source when I need it.
#######################################################################
function Compile-Csharp ([string] $code, $FrameworkVersion="v2.0.50727",
[Array]$References)
{
    #
    # Get an instance of the CSharp code provider
    #
    $cp = new-object Microsoft.CSharp.CSharpCodeProvider

    #
    # Build up a compiler params object…
    $framework = Combine-Path $env:windir "Microsoft.NET\Framework\$FrameWorkVersion"
    $refs = new Collections.ArrayList
    $refs.AddRange( @("${framework}\System.dll",
        "${mshhome}\System.Management.Automation.dll",
        "${mshhome}\System.Management.Automation.ConsoleHost.dll",
        "${framework}\system.windows.forms.dll",
        "${framework}\System.data.dll",
        "${framework}\System.Drawing.dll",
        "${framework}\System.Xml.dll"))
    if ($references.Count -ge 1)
    {
        $refs.AddRange($References)
    }

    $cpar = New-Object System.CodeDom.Compiler.CompilerParameters
    $cpar.GenerateInMemory = $true
    $cpar.GenerateExecutable = $false
    $cpar.OutputAssembly = "custom"
    $cpar.ReferencedAssemblies.AddRange($refs)
    $cr = $cp.CompileAssemblyFromSource($cpar, $code)

    if ( $cr.Errors.Count)
    {
        $codeLines = $code.Split("`n");
        foreach ($ce in $cr.Errors)
        {
            write-host "Error: $($codeLines[$($ce.Line – 1)])"
            $ce |out-default
        }
        Throw "INVALID DATA: Errors encountered while compiling code"
    }
}

###########################################################################
#  Here I leverage one of my favorite features (here-strings) to define
# the C# code I want to run.  Remember – if you use single quotes – the
# string is taken literally but if you use double-quotes, we’ll do variable
# expansion.  This can be VERY useful.
###########################################################################
$code = @'
using System;
using System.Runtime.InteropServices;

namespace test
{
    public class Testclass
    {
        [DllImport("msvcrt.dll")]
        public static extern int puts(string c);
        [DllImport("msvcrt.dll")]
        internal static extern int _flushall();

        public static void Run(string message)
        {
            puts(message);
            _flushall();
        }
    }
}
'@

##################################################################
# So now we compile the code and use .NET object access to run it.
##################################################################
compile-CSharp $code
[Test.TestClass]::Run("Monad ROCKS!")
#>

# // _______________________________________________________________________________________________________________
# // | Ok, that's all of the official Jeffrey Snover [MSFT] code up above, from 2006.                              |
# // | NOW what I'm going to do, is TRANSLATE the entire thing he wrote. In 2006.                                  |
# // | Which is like, *checks watch* uh...                                                                         |
# // |                                                                                                             |
# // | ...lets not make any assumptions here, and think like a computer processor would.                           |
# // | Jeff Snover's article says April 25th, 2006, but we can't make any assumptions.                             |
# // | April is the FOURTH month. If we put it into this format: "YYYY/mm/dd", we can                              |
# // | get a real nice and clean object back from the console.                                                     |
# // |                                                                                                             |
# // | Let's use PowerShell, some [DateTime] objects as well as a [Timespan] object...                             |
# // | ...to figure out just how LONG AGO cool guy 5000 wrote this article.                                        |
# // |                                                                                                             |
# // | PS Prompt:\> $Then = [DateTime]"2006/04/25"                                                                 |
# // | PS Prompt:\> $Then                                                                                          |
# // |                                                                                                             |
# // | Tuesday, April 25, 2006 12:00:00 AM                                                                         |
# // |                                                                                                             |
# // | It says 12:00:00 AM. He probably did not submit this article at that exact time..                           |
# // | Shame on you, cool guy 5000...                                                                              |
# // | ...for not including the specific time of day in this article you wrote a real long time ago.               |
# // | I'm just kidding.                                                                                           |
# // |                                                                                                             |
# // | PS Prompt:\> $Now = [DateTime]::Now                                                                         |
# // | PS Prompt:\> $Now                                                                                           |
# // |                                                                                                             |
# // | Thursday, October 13, 2022 6:23:46 AM                                                                       |
# // |                                                                                                             |
# // | PS Prompt:\> $Span = [Timespan]($Now-$Then)                                                                 |
# // | PS Prompt:\> $Span                                                                                          |
# // |                                                                                                             |
# // | Days              : 6015                                                                                    |
# // | Hours             : 6                                                                                       |
# // | Minutes           : 31                                                                                      |
# // | Seconds           : 1                                                                                       |
# // | Milliseconds      : 56                                                                                      |
# // | Ticks             : 5197194610561714                                                                        |
# // | TotalDays         : 6015.27154000198                                                                        |
# // | TotalHours        : 144366.516960048                                                                        |
# // | TotalMinutes      : 8661991.01760286                                                                        |
# // | TotalSeconds      : 519719461.056171                                                                        |
# // | TotalMilliseconds : 519719461056.171                                                                        |
# // |                                                                                                             |
# // | Wow.                                                                                                        |
# // | That LOOKS like a pretty long time... But, how can we make this information more CONSUMABLE...?             |
# // | I know what we could do... We can use MATHEMATICS to calculate this stuff, real easily.                     |
# // | The problem is that you can't just divide a floating point number like the property TotalDays,              |
# // | 6015.27154000198, without error messages pointing their finger in your face... Nah.                         |
# // |                                                                                                             |
# // | However- we can get the REMAINDER by doing this cool little operation:                                      |
# // |                                                                                                             |
# // | PS Prompt:\> $Remain = $Span.TotalDays % 365                                                                |
# // | PS Prompt:\> $Remain                                                                                        |
# // |                                                                                                             |
# // | 175.271540001983                                                                                            |
# // |                                                                                                             |
# // | Good. Now we can SUBTRACT that value from the TOTAL DAYS to get a number that can be cleanly                |
# // | divided by (THREE-HUNDRED-AND-SIXTY-FIVE/365)...                                                            |
# // |                                                                                                             |
# // | PS Prompt:\> $Days = $Span.TotalDays - $Remain                                                              |
# // | PS Prompt:\> $Days                                                                                          |
# // |                                                                                                             |
# // | 5840                                                                                                        |
# // |                                                                                                             |
# // | Alright, so, NOW we can use the value 365 to divide THAT number, cleanly.                                   |
# // |                                                                                                             |
# // | PS Prompt:\> $Years  = $Days / 365                                                                          |
# // | PS Prompt:\> $Years                                                                                         |
# // |                                                                                                             |
# // | 16                                                                                                          |
# // |                                                                                                             |
# // | Oh boy. Ohhhhhhh boy.                                                                                       |
# // | It says 16. (16), full, entire, 365-day (sometimes 366), earth-years ago.                                   |
# // |                                                                                                             |
# // | When you're doing RESEARCH AND DEVELOPMENT, you TYPICALLY want to AVOID stuff that is THAT old.             |
# // | UNLESS OF COURSE, there is something REALLY IMPORTANT and NOTEWORTHY...                                     |
# // | ...about the thing you found. Cause, it could be a CRITICAL VULNERABILITY AND EXPOSURE, or it could         |
# // | lead to IDENTITY THEFT and CYBERCRIME...                                                                    |
# // |                                                                                                             |
# // | In this case...? It just leads to an article written by a really cool guy who has dutifully worked at       |
# // | the Microsoft Corporation, for AT LEAST (16) years... who wrote an article about Platform Invocation        |
# // | (16) years ago from PowerShell, which allows PowerShell to (COMPILE/USE), CSharp code within PowerShell.    |
# // |                                                                                                             |
# // | Which, is a REALLY COOL FEATURE of PowerShell... being able to (compile/use) C# code natively.              |
# // | (That's probably about AS COOL, as programming your very own, homebrew version of BASIC on an Altair 8800.) |
# // |                                                                                                             |
# // | In this particular case...?                                                                                 |
# // | (THAT/Platform Invocation) is what's WICKED IMPORTANT and NOTEWORTHY about this article.                    |
# // | Cause it means that PowerShell can access UNMANAGED CODE and C# as well as C++ structs/elements/etc.        |
# // |                                                                                                             |
# // | But- it JUST SO HAPPENS TO BE THE CASE... that there's SOMETHING ELSE, that is JUST AS WICKED IMPORTANT     |
# // | and NOTEWORTHY about the CONTENT of this article. This article wasn't just written by any regular,          |
# // | standard, every-day, run-of-the-mill guy from Microsoft. Nah.                                               |
# // |                                                                                                             |
# // | The guy who wrote it happens to be the (1) guy among a team of guys...                                      |
# // | ...a guy who dutifully worked at the Microsoft Corporation for a number of years...                         |
# // | ...until eventually, one day...?                                                                            |
# // | The man basically told red rover to move over.                                                              |
# // | And now we have PowerShell 7.                                                                               |
# // |                                                                                                             |
# // | I'll add CmdLetbinding() to take care of the (Function+Parameters),                                         |
# // |                                                                                                             |
# // | Note: Probably don't NEED to have the FrameworkVersion anymore, but I'll leave it there for added           |
# // | (flexibility/functionality). It's not being used at all by the function right now, it's purely cosmetic.    |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# // _____________________________________________________________________________________________________________
# // | I'm going to change the name of the function to Publish-CSharp, because "Compile" isn't an approved verb. |
# // | Note: To see the list of approved verbs, use the command "Get-Verb". I've looked at this thing hundreds   |
# // | of times, and really... some verbs that should exist (like "Compile"), don't. But- that's ok.             |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Function Publish-CSharp 
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory,Position=0)][String] $code, 
    [Parameter()][String] $FrameworkVersion="v2.0.50727",
    [Parameter(Mandatory)][String[]]$References)

    # // _______________________________________________________________________________________________
    # // | Note: Jeff used a number of paths that use a base like ${mshhome} and ${framework} here.    |
    # // | The language (Monad) has changed DRAMATICALLY since 2006 when he wrote this article, but-   |
    # // | there's still something worth understanding if it can help avoid having to install a module |
    # // | like PowerShell PInvoke. While I have nothing bad to say about Adam Driscoll (smart dude),  |
    # // | I did not want to add the installation of an entire module to this particular application.  |
    # // |                                                                                             |
    # // | Regardless, people have been asking me...                                                   |
    # // |                                                                                             |
    # // | Q: How do you know Jeffrey Snover [MSFT] told red rover to move over...?                    |
    # // | A: I don't. I just say it a lot cause it rhymes, and cause Jeffrey Snover is a smart dude.  |
    # // |    Otherwise, PowerShell wouldn't be the kick-ass language that it is today. So...          |
    # // |                                                                                             |
    # // | Q: Yeah, well... why do you like PowerShell so much, anyway...? Hm...?                      |
    # // | A: Uh- cause PowerShell is HANDS DOWN... the best there is.                                 |
    # // |    At some point in time...?                                                                |
    # // |    People used tools to chisel into rocks to write stuff down, to get the job done.         |
    # // |    At some point a real smart dude came along and invented PAPYRUS/PAPER, and INK.          |
    # // |    That's when they started ripping feathers off of birds, to dip them and write stuff.     |
    # // |    Then a guy eventually invented the Gutenberg press.                                      |
    # // |    Then a legion of guys eventually invented the modern computer.                           |
    # // |    Then an assortment of guys eventually invented the Altair 8800.                          |
    # // |    Then (2) wicked smart dudes eventually invented a version of BASIC for that Altair 8800. |
    # // |    Then those same (2) dudes created an industry that still exists today.                   |
    # // |    At each interval, some real smart guys had to tell red rover to move over... upgrades.   |
    # // |    Now...?                                                                                  |
    # // |    People can just type keys on a keyboard into a PowerShell console, to get the job done.  |
    # // |    Is PowerShell backward compatible with stone tablets and heiroglyphics...? Uh- nah.      |
    # // |    But, it is damn close, in terms of how highly compatible it is.                          |
    # // |    PowerShell...                                                                            |
    # // |    For cross-compatibility...?                                                              |
    # // |    Backward compatibility...?                                                               |
    # // |    Forward compatibility...?                                                                |
    # // |    More compatibility than you can shake a stick at.                                        |
    # // |    That's saying something, isn't it...?                                                    |
    # // |    Now, I might be overselling this thing...?                                               |
    # // |    But- I don't think I am.                                                                 |
    # // |    PowerShell. The best there is.                                                           |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If ($PSVersionTable.PSEdition -ne "Desktop")
    {
        Throw "Must use Windows PowerShell v5.1 (until dependencies are implemented for PowerShell Core)"
    }

    # // ___________________________________________________________________________________
    # // | Individual assembly items from AppDomain, to pull some of the paths dynamically |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class AssemblyItem
    {
        [Int32]      $Index
        [UInt32] $Available
        [Bool]         $GAC
        [String]   $Version
        [String]      $Name
        [String]    $Parent
        [String]  $Location
        AssemblyItem([Int32]$Index,[Object]$Assembly)
        {
            $This.Index        = $Index
            $This.GAC          = $Assembly.GAC
            $This.Version      = $Assembly.ImageRuntimeVersion
            $Path              = $Assembly.Location
            If ([System.IO.File]::Exists($Path))
            {
                $This.Name     = Split-Path $Path -Leaf
                $This.Parent   = Split-Path $Path -Parent
                $This.Location = $Path
            }
        }
        AssemblyItem([Int32]$Index,[String]$Name)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Version  = "N/A"
            $This.Parent   = "N/A"
            $This.Location = "N/A"
        }
        [String] ToString()
        {
            Return $This.Location
        }
    }

    # // _________________________________
    # // | Assembly items from AppDomain |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class AssemblyList
    {
        [Object] $Domain
        [Object] $Output
        AssemblyList()
        {
            $This.Output = @( ) 
            ForEach ($Assembly in [System.Appdomain]::CurrentDomain.GetAssemblies())
            {
                $This.Output += [AssemblyItem]::New($This.Output.Count,$Assembly)
            }
        }
        [Object] Get([String]$Name)
        {   
            $Item = $This.Output | ? Name -match $Name
            If ($Item)
            {
                $Item.Available = 1
            }
            Else
            {
                $Item = [AssemblyItem]::New(-1,$Name)
            }            

            Return $Item
        }
    }

    # // ______________________________________________
    # // | Meant to (handle/track) compilation errors |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class CodeError
    {
        [UInt32] $Index
        [UInt32] $Line
        [UInt32] $Column
        [String] $Label
        [String] $Message
        [UInt32] $Rank
        [Object] $Content
        CodeError([UInt32]$Index,[Object]$Line,[Object]$xError)
        {
            $This.Index   = $Index
            $This.Line    = $xError.Line
            $This.Column  = $xError.Column
            $This.Label   = $xError.ErrorNumber
            $This.Message = $xError.ErrorText
            $This.Rank    = $Line.Index
            $This.Content = $Line.Content
        }
        [String] ToString()
        {
            Return $This.Error
        }
    }

    # // _____________________________________
    # // | Divides the input code into lines |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class CodeLine
    {
        [UInt32] $Index
        [String] $Content
        CodeLine([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }

    # // _______________________________________
    # // | Container for the code line objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class CodeObject
    {
        Hidden [Hashtable] $Hash
        [String] $Input
        [Object] $Output
        CodeObject([String]$Code)
        {
            $This.Hash   = @{ }
            $This.Input  = $Code
            $this.Input -Split "`n" | % { $This.CodeLine($_) }
            $This.Output = $This.Hash[0..($This.Hash.Count-1)]
        }
        CodeLine([String]$Content)
        {
            $This.Hash.Add($This.Hash.Count,[CodeLine]::New($This.Hash.Count,$Content))
        }
    }
    
    # // ___________________________________________________________
    # // | A class to facilitate/orchestrate the compiling process |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class CodeFactory
    {
        [Object] $Code
        [Object] $Errors
        [Object] $Assembly
        [Object[]] $References
        [Object] $Provider
        [Object] $Parameters
        [Object] $Result
        CodeFactory([String]$Code,[String[]]$References)
        {
            $This.Code       = [CodeObject]$Code
            $This.Errors     = @( )
            $This.Assembly   = [AssemblyList]::New()
            $This.References = $References | % { $This.Assembly.Get("$_.dll") }
            $This.Provider   = [Microsoft.CSharp.CSharpCodeProvider]::New()
            $This.Parameters = [System.CodeDom.Compiler.CompilerParameters]::New()
            $This.Parameters.GenerateInMemory   = 1
            $This.Parameters.GenerateExecutable = 0
            $This.Parameters.OutputAssembly     = "Custom"
            $List            = $This.References | ? Available
            $This.Parameters.ReferencedAssemblies.AddRange($List)
            $This.Result     = $This.Provider.CompileAssemblyFromSource($This.Parameters, $This.Code.Input)

            If ($This.Result.Errors.Count)
            {
                $xErrors     = @{ }
                Switch ($This.Result.Errors.Count)
                {
                    {$_ -gt 1}
                    {
                        ForEach ($X in 0..($This.Result.Errors.Count-1))
                        {
                            $This.Result.Errors[$X] | % { $xErrors.Add($xErrors.Count,[CodeError]::new($xErrors.Count,$This.Code.Output[$_.Line-1],$_)) }
                        }
        
                        $This.Errors = @($xErrors[0..($xErrors.Count-1)])
                    }

                    {$_ -eq 1}
                    {
                        $This.Errors = @($This.Result.Errors[0] | % { [CodeError]::New(0,$This.Code.Output[$_.Line],$_) })
                    }
                }

                Write-Warning "Errors occurred, see property <Errors>"
            }
        }
    }

    [CodeFactory]::New($Code,$References)
}

# // ___________________________________________________________________________________________
# // | Alright. So, All of that stuff above is pretty WEIGHTY and EXCESSIVE for what is really |
# // | going on in the original script. However, a LOT of functionality has been added, mostly |
# // | to (track/format) the (output + errors)                                                 |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Code = @"
[DllImport("wlanapi.dll", EntryPoint="WlanOpenHandle")]
public static extern uint WlanOpenHandle( [In] UInt32 clientVersion, [In, Out] IntPtr pReserved, [Out] out UInt32 negotiatedVersion, [Out] out IntPtr clientHandle);

[DllImport("wlanapi.dll", EntryPoint="WlanCloseHandle")]
public static extern uint WlanCloseHandle( [In] IntPtr ClientHandle, IntPtr pReserved);

[DllImport("wlanapi.dll", EntryPoint="WlanFreeMemory")]
public static extern void WlanFreeMemory( [In] IntPtr pMemory);

[DllImport("wlanapi.dll", EntryPoint="WlanEnumInterfaces", SetLastError=true)]
public static extern uint WlanEnumInterfaces( [In] IntPtr hClientHandle, [In] IntPtr pReserved, [Out] out IntPtr ppInterfaceList);

[DllImport("wlanapi.dll", EntryPoint="WlanGetProfileList", SetLastError=true, CallingConvention=CallingConvention.Winapi)]
public static extern uint WlanGetProfileList( [In] IntPtr clientHandle, [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid, [In] IntPtr pReserved, [Out] out IntPtr profileList);

[DllImport("wlanapi.dll", EntryPoint="WlanGetProfile")]
public static extern uint WlanGetProfile( [In] IntPtr clientHandle, [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid, [In, MarshalAs(UnmanagedType.LPWStr)] string profileName, [In, Out] IntPtr pReserved, [Out, MarshalAs(UnmanagedType.LPWStr)] out string pstrProfileXml, [In, Out, Optional] ref uint flags, [Out, Optional] out uint grantedAccess);

[DllImport("wlanapi.dll", EntryPoint="WlanDeleteProfile")]
public static extern uint WlanDeleteProfile( [In] IntPtr clientHandle, [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid, [In, MarshalAs(UnmanagedType.LPWStr)] string profileName, [In, Out] IntPtr pReserved);

[DllImport("wlanapi.dll", EntryPoint="WlanSetProfile", SetLastError=true, CharSet=CharSet.Unicode)]
public static extern uint WlanSetProfile( [In] IntPtr clientHandle, [In] ref Guid interfaceGuid, [In] uint flags, [In] IntPtr ProfileXml, [In, Optional] IntPtr AllUserProfileSecurity, [In] bool Overwrite, [In, Out] IntPtr pReserved, [In, Out] ref IntPtr pdwReasonCode);

[DllImport("wlanapi.dll", EntryPoint="WlanReasonCodeToString", SetLastError=true, CharSet=CharSet.Unicode)]
public static extern uint WlanReasonCodeToString( [In] uint reasonCode, [In] uint bufferSize, [In, Out] StringBuilder builder, [In, Out] IntPtr Reserved);

[DllImport("wlanapi.dll", EntryPoint="WlanGetAvailableNetworkList", SetLastError=true)]
public static extern uint WlanGetAvailableNetworkList( [In] IntPtr hClientHandle, [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid, [In] uint dwFlags, [In] IntPtr pReserved, [Out] out IntPtr ppAvailableNetworkList);

[DllImport("wlanapi.dll", EntryPoint="WlanConnect", SetLastError=true)]
public static extern uint WlanConnect( [In] IntPtr hClientHandle, [In] ref Guid interfaceGuid, [In] ref WLAN_CONNECTION_PARAMETERS pConnectionParameters, [In, Out] IntPtr pReserved);

[DllImport("wlanapi.dll", EntryPoint="WlanDisconnect", SetLastError=true)]
public static extern uint WlanDisconnect( [In] IntPtr hClientHandle, [In] ref Guid interfaceGuid, [In, Out] IntPtr pReserved);

[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct WLAN_CONNECTION_PARAMETERS
{
    public WLAN_CONNECTION_MODE wlanConnectionMode;
    public string strProfile;
    public DOT11_SSID[] pDot11Ssid;
    public DOT11_BSSID_LIST[] pDesiredBssidList;
    public DOT11_BSS_TYPE dot11BssType;
    public uint dwFlags;
}

public struct DOT11_BSSID_LIST
{
    public NDIS_OBJECT_HEADER Header;
    public ulong uNumOfEntries;
    public ulong uTotalNumOfEntries;
    public IntPtr BSSIDs;
}

public struct NDIS_OBJECT_HEADER
{
    public byte Type;
    public byte Revision;
    public ushort Size;
}

public struct WLAN_PROFILE_INFO_LIST
{
    public uint dwNumberOfItems;
    public uint dwIndex;
    public WLAN_PROFILE_INFO[] ProfileInfo;
    
    public WLAN_PROFILE_INFO_LIST(IntPtr ppProfileList)
    {
        dwNumberOfItems = (uint)Marshal.ReadInt32(ppProfileList);
        dwIndex = (uint)Marshal.ReadInt32(ppProfileList, 4);
        ProfileInfo = new WLAN_PROFILE_INFO[dwNumberOfItems];
        IntPtr ppProfileListTemp = new IntPtr(ppProfileList.ToInt64() + 8);
    
        for (int i = 0; i < dwNumberOfItems; i++)
        {
            ppProfileList = new IntPtr(ppProfileListTemp.ToInt64() + i * Marshal.SizeOf(typeof(WLAN_PROFILE_INFO)));
            ProfileInfo[i] = (WLAN_PROFILE_INFO)Marshal.PtrToStructure(ppProfileList, typeof(WLAN_PROFILE_INFO));
        }
    }
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct WLAN_PROFILE_INFO
{
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
    public string strProfileName;
    public WlanProfileFlags ProfileFlags;
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct WLAN_AVAILABLE_NETWORK_LIST
{
    public uint dwNumberOfItems;
    public uint dwIndex;
    public WLAN_AVAILABLE_NETWORK[] wlanAvailableNetwork;
    public WLAN_AVAILABLE_NETWORK_LIST(IntPtr ppAvailableNetworkList)
    {
        dwNumberOfItems = (uint)Marshal.ReadInt64 (ppAvailableNetworkList);
        dwIndex = (uint)Marshal.ReadInt64 (ppAvailableNetworkList, 4);
        wlanAvailableNetwork = new WLAN_AVAILABLE_NETWORK[dwNumberOfItems];
        for (int i = 0; i < dwNumberOfItems; i++)
        {
            IntPtr pWlanAvailableNetwork = new IntPtr (ppAvailableNetworkList.ToInt64() + i * Marshal.SizeOf (typeof(WLAN_AVAILABLE_NETWORK)) + 8 );
            wlanAvailableNetwork[i] = (WLAN_AVAILABLE_NETWORK)Marshal.PtrToStructure (pWlanAvailableNetwork, typeof(WLAN_AVAILABLE_NETWORK));
        }
    }
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct WLAN_AVAILABLE_NETWORK
{
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
    public string ProfileName;
    public DOT11_SSID Dot11Ssid;
    public DOT11_BSS_TYPE dot11BssType;
    public uint uNumberOfBssids;
    public bool bNetworkConnectable;
    public uint wlanNotConnectableReason;
    public uint uNumberOfPhyTypes;
    
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
    public DOT11_PHY_TYPE[] dot11PhyTypes;
    public bool bMorePhyTypes;
    public uint SignalQuality;
    public bool SecurityEnabled;
    public DOT11_AUTH_ALGORITHM dot11DefaultAuthAlgorithm;
    public DOT11_CIPHER_ALGORITHM dot11DefaultCipherAlgorithm;
    public uint dwFlags;
    public uint dwReserved;
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
public struct DOT11_SSID
{
    public uint uSSIDLength;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
    public string ucSSID;
}

public enum DOT11_BSS_TYPE
{
    Infrastructure = 1,
    Independent    = 2,
    Any            = 3,
}

public enum DOT11_PHY_TYPE
{
    DOT11_PHY_TYPE_UNKNOWN = 0,
    DOT11_PHY_TYPE_ANY = 0,
    DOT11_PHY_TYPE_FHSS = 1,
    DOT11_PHY_TYPE_DSSS = 2,
    DOT11_PHY_TYPE_IRBASEBAND = 3,
    DOT11_PHY_TYPE_OFDM = 4,
    DOT11_PHY_TYPE_HRDSSS = 5,
    DOT11_PHY_TYPE_ERP = 6,
    DOT11_PHY_TYPE_HT = 7,
    DOT11_PHY_TYPE_VHT = 8,
    DOT11_PHY_TYPE_IHV_START = -2147483648,
    DOT11_PHY_TYPE_IHV_END = -1,
}

public enum DOT11_AUTH_ALGORITHM
{
    DOT11_AUTH_ALGO_80211_OPEN = 1,
    DOT11_AUTH_ALGO_80211_SHARED_KEY = 2,
    DOT11_AUTH_ALGO_WPA = 3,
    DOT11_AUTH_ALGO_WPA_PSK = 4,
    DOT11_AUTH_ALGO_WPA_NONE = 5,
    DOT11_AUTH_ALGO_RSNA = 6,
    DOT11_AUTH_ALGO_RSNA_PSK = 7,
    DOT11_AUTH_ALGO_WPA3 = 8,
    DOT11_AUTH_ALGO_WPA3_SAE = 9,
    DOT11_AUTH_ALGO_OWE = 10,
    DOT11_AUTH_ALGO_WPA3_ENT = 11,
    DOT11_AUTH_ALGO_IHV_START = -2147483648,
    DOT11_AUTH_ALGO_IHV_END = -1,
}

public enum DOT11_CIPHER_ALGORITHM
{
    DOT11_CIPHER_ALGO_NONE = 0,
    DOT11_CIPHER_ALGO_WEP40 = 1,
    DOT11_CIPHER_ALGO_TKIP = 2,
    DOT11_CIPHER_ALGO_CCMP = 4,
    DOT11_CIPHER_ALGO_WEP104 = 5,
    DOT11_CIPHER_ALGO_BIP = 6,
    DOT11_CIPHER_ALGO_GCMP = 8,
    DOT11_CIPHER_ALGO_GCMP_256 = 9,
    DOT11_CIPHER_ALGO_CCMP_256 = 10,
    DOT11_CIPHER_ALGO_BIP_GMAC_128 = 11,
    DOT11_CIPHER_ALGO_BIP_GMAC_256 = 12,
    DOT11_CIPHER_ALGO_BIP_CMAC_256 = 13,
    DOT11_CIPHER_ALGO_WPA_USE_GROUP = 256,
    DOT11_CIPHER_ALGO_RSN_USE_GROUP = 256,
    DOT11_CIPHER_ALGO_WEP = 257,
    DOT11_CIPHER_ALGO_IHV_START = -2147483648,
    DOT11_CIPHER_ALGO_IHV_END = -1,
}

public enum WLAN_CONNECTION_MODE
{
    WLAN_CONNECTION_MODE_PROFILE,
    WLAN_CONNECTION_MODE_TEMPORARY_PROFILE,
    WLAN_CONNECTION_MODE_DISCOVERY_SECURE,
    WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE,
    WLAN_CONNECTION_MODE_AUTO,
    WLAN_CONNECTION_MODE_INVALID,
}

[Flags]
public enum WlanConnectionFlag
{
    Default = 0,
    HiddenNetwork = 1,
    AdhocJoinOnly = 2,
    IgnorePrivacyBit = 4,
    EapolPassThrough = 8,
    PersistDiscoveryProfile = 10,
    PersistDiscoveryProfileConnectionModeAuto = 20,
    PersistDiscoveryProfileOverwriteExisting = 40
}

[Flags]
public enum WlanProfileFlags
{
    AllUser = 0,
    GroupPolicy = 1,
    User = 2
}

public class ProfileInfo
{
    public string ProfileName;
    public string ConnectionMode;
    public string Authentication;
    public string Encryption;
    public string Password;
    public bool ConnectHiddenSSID;
    public string EAPType;
    public string ServerNames;
    public string TrustedRootCA;
    public string Xml;
}

public struct WLAN_INTERFACE_INFO_LIST
{
    public uint dwNumberOfItems;
    public uint dwIndex;
    public WLAN_INTERFACE_INFO[] wlanInterfaceInfo;
    public WLAN_INTERFACE_INFO_LIST(IntPtr ppInterfaceInfoList)
    {
        dwNumberOfItems = (uint)Marshal.ReadInt32(ppInterfaceInfoList);
        dwIndex = (uint)Marshal.ReadInt32(ppInterfaceInfoList, 4);
        wlanInterfaceInfo = new WLAN_INTERFACE_INFO[dwNumberOfItems];
        IntPtr ppInterfaceInfoListTemp = new IntPtr(ppInterfaceInfoList.ToInt64() + 8);
        for (int i = 0; i < dwNumberOfItems; i++)
        {
            ppInterfaceInfoList = new IntPtr(ppInterfaceInfoListTemp.ToInt64() + i * Marshal.SizeOf(typeof(WLAN_INTERFACE_INFO)));
            wlanInterfaceInfo[i] = (WLAN_INTERFACE_INFO)Marshal.PtrToStructure(ppInterfaceInfoList, typeof(WLAN_INTERFACE_INFO));
        }
    }
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct WLAN_INTERFACE_INFO
{
    public Guid Guid;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
    public string Description;
    public WLAN_INTERFACE_STATE State;
}

public enum WLAN_INTERFACE_STATE
{
    NOT_READY = 0,
    CONNECTED = 1,
    AD_HOC_NETWORK_FORMED = 2,
    DISCONNECTING = 3,
    DISCONNECTED = 4,
    ASSOCIATING = 5,
    DISCOVERING = 6,
    AUTHENTICATING = 7
}

[DllImport("wlanapi.dll", EntryPoint="WlanScan", SetLastError=true)]
public static extern uint WlanScan( IntPtr hClientHandle, ref Guid pInterfaceGuid, IntPtr pDot11Ssid, IntPtr pIeData, IntPtr pReserved);
"@

$Refs    = "^System","System.Management.Automation","ConsoleHost","System.Windows.Forms","System.Data","System.Drawing","System.Xml"
$Factory = Publish-CSharp -Code $Code -References $Refs
