Class _Target
{
    [String] $Path
    [String] $ComputerName 
    [String] $Architecture
    [String] $SystemDrive 
    [String] $SystemRoot
    [String] $System32
    [String] $Resources
    [String] $ProgramData
        
    _Target([String]$Path)
    {
        $This.Path         = $Path
        $This.ComputerName = $env:ComputerName
        $This.Architecture = $env:Processor_Architecture
        $This.SystemDrive  = $env:SystemDrive
        $This.SystemRoot   = $env:SystemRoot
        $This.System32     = "$env:SystemRoot\System32"
        $This.Resources    = "$Path\Resources"
        $THis.ProgramData  = $env:programdata
    }
}
