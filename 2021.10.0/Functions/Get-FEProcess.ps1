<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEProcess.ps1
          Solution: FightingEntropy Module
          Purpose: For collecting the currently running processes
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-07
          Modified: 2021-10-07
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEProcess
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1,Mandatory)][Switch]$Text)
    
    Class FEProcess
    {
        [String]      $NPM
        [String]       $PM
        [String]       $WS
        [String]      $CPU
        [String]       $ID
        [String]       $SI
        [String]     $Name
        FEProcess([Object]$Process)
        {
            $This.NPM  = "{0:n2}" -f ($Process.NonpagedSystemMemorySize/1KB)
            $This.PM   = "{0:n2}" -f ($Process.PagedMemorySize/1MB)
            $This.WS   = "{0:n2}" -f ($Process.WorkingSet/1MB)
            $This.CPU  = "{0:n2}" -f $Process.TotalProcessorTime.TotalSeconds
            $This.ID   = $Process.Id
            $This.SI   = $Process.SessionID
            $This.Name = $Process.ProcessName
        }
    }

    Class FEProcesses
    {
        [Object]$Output
        FEProcesses()
        {
            $This.Output = @( Get-Process | % { [FeProcess]$_ })
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                NPM  { 10 }
                PM   { 10 }
                WS   { 10 }
                CPU  { 10 }
                ID   {  7 }
                SI   {  4 }
                Name { 35 }
            }
            If ($String.Length -gt $Buffer)
            {
                Return $String.Substring(0,($Buffer-3)) + "..."
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @(
            "NPM       PM        WS        CPU       ID     SI  Name                               "
            "---       --        --        ---       --     --  ----                               "
            ForEach ($Item in $This.Output)
            {
                $This.Buffer("NPM",$Item.NPM),
                $This.Buffer( "PM",$Item.PM),
                $This.Buffer( "WS",$Item.WS),
                $This.Buffer("CPU",$Item.CPU),
                $This.Buffer( "ID",$Item.ID),
                $This.Buffer( "SI",$Item.SI),
                $This.Buffer("Name",$Item.Name) -join ''
            })
        }
    }

    $Object = [FeProcesses]::New()
    Switch($PSCmdLet.ParameterSetName)
    {
        0 { $Object.Output }
        1 { $Object.ToString() }
    }
}
