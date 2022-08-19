Function Write-ScriptNotes
{
    [CmdLetBinding()]Param(
    [Parameter(Position=0)][String] $FileName = $Null,
    [Parameter(Position=1)][String] $Solution = $Null,
    [Parameter(Position=2)][String] $Purpose  = $Null,
    [Parameter(Position=3)][String] $Author   = $Null,
    [Parameter(Position=4)][String] $Contact  = $Null,
    [Parameter(Position=5)][String] $Primary  = $Null,
    [Parameter(Position=6)][String] $Created  = $Null,
    [Parameter(Position=7)][String] $Modified = $Null,
    [Parameter(Position=8)][String] $Demo     = "N/A",
    [Parameter(Position=9)][String] $Version  = "0.0.0 - () ",
    [Parameter(Position=10)][String] $TODO    = $Null)

    Class Notes 
    {
        [String] $FileName
        [String] $Solution
        [String] $Purpose
        [String] $Author
        [String] $Contact
        [String] $Primary
        [String] $Created
        [String] $Modified
        [String] $Demo
        [String] $Version
        [String] $TODO
        Notes([String] $FileName,
            [String] $Solution,
            [String] $Purpose,
            [String] $Author,
            [String] $Contact,
            [String] $Primary,
            [String] $Created,
            [String] $Modified,
            [String] $Demo,
            [String] $Version,
            [String] $TODO) {
            $This.FileName = $FileName       
            $This.Solution = $Solution 
            $This.Purpose  = $Purpose 
            $This.Author   = $Author 
            $This.Contact  = $Contact 
            $This.Primary  = $Primary 
            $This.Created  = $Created 
            $This.Modified = $Modified 
            $This.Demo     = $Demo
            $This.Version  = $Version 
            $This.TODO     = $TODO 
        }
    }

    [Notes]::New($FileName,$Solution,$Purpose,$Author,$Contact,$Primary,$Created,$Modified,$Demo,$Version,$TODO)
}
