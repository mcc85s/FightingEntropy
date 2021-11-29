Class SwapItem
{
    [String]$InputString
    [String]$OutputString
    SwapItem([String]$InputString,[String]$OutputString)
    {
        $This.InputString = $InputString
        $This.OutputString = $OutputString
    }
}

Class SwapList
{
    [Object] $Pairs
    SwapList()
    {
        $This.Pairs   = ForEach ($Item in 
        ('cscript.exe "%SCRIPTROOT%\ZTIDrivers.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDDrivers.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIGather.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDGather.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIValidate.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDValidate.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIBIOSCheck.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIDiskpart.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDPartition.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIUserState.wsf" /capture','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1" /capture'),
        ('cscript.exe "%SCRIPTROOT%\ZTIBackup.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTISetVariable.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDSetVariable.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTINextPhase.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDNextPhase.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\LTIApply.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDApplyOS.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIWinRE.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIPatches.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIApplications.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDApplications.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIWindowsUpdate.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDWindowsUpdate.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIBde.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIBDE.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'),
        ('cscript.exe "%SCRIPTROOT%\ZTIGroups.wsf"','PowerShell.exe -file "%SCRIPTROOT%\PSDTBA.ps1"'))
        {
            $This.NewPair($Item[0],$Item[1])
        }
    }
    [Object] NewPair([String]$InputString,[String]$OutputString)
    {
        Return [SwapItem]::New($InputString,$OutputString)
    }
}

Class Template
{
    [String] $Path
    [Object] $Content
    [Object] $Output
    Template([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }

        $This.Path    = $Path
        $This.Content = Get-Content $This.Path
        $This.Output  = $This.Content
        ForEach ($Pair in $This.Workspace().Pairs)
        { 
            $This.Swap($Pair.InputString,$Pair.OutputString)   
        }   
    }
    [Object] Workspace()
    {
        Return [SwapList]::New()
    }
    Swap([String]$InputString,[String]$OutputString)
    {
        $This.Output = $This.Output -Replace $InputString,$OutputString
    }
}
