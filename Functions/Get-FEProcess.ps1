Function Get-FEProcess
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1,Mandatory)][Switch]$Output)
    
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
            }
            Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
        }
        [String[]] ToString()
        {
            Return @(
            "NPM       PM        WS        CPU       ID     SI  Name                               "
            "---       --        --        ---       --     --  ----                               "
            ForEach ($Item in $This.Output)
            {
                If ($Item.Name.Length -gt 35)
                { 
                    $Item.Name = $Item.Name.Substring(0,32) + "..." 
                }

                $This.Buffer("NPM",$Item.NPM),
                $This.Buffer( "PM",$Item.PM),
                $This.Buffer( "WS",$Item.WS),
                $This.Buffer("CPU",$Item.CPU),
                $This.Buffer( "ID",$Item.ID),
                $This.Buffer( "SI",$Item.SI),
                $Item.Name -join ''
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
