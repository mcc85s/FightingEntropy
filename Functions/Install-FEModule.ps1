Function Install-FEModule
{
    [CmdLetBinding()]
    Param(

    [ValidateSet("2021.1.0","2021.1.1","2021.2.0","2021.3.0","2021.3.1","2021.4.0")]
    [Parameter(Mandatory)]
    [String]$Version)

    $Install = @( )
    
    ForEach ( $Item in "OS Root Manifest RestObject Hive Install" -Split " " )
    {
        $Install += Invoke-RestMethod https://raw.githubusercontent.com/mcc85sx/FightingEntropy/master/$Version/Classes/_$Item.ps1
    }
    
    Invoke-Expression ( $Install -join "`n" )
    
    [_Install]::New($Version)
}
