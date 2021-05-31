Function New-FECompany 
{
    [CmdLetBinding()][OutputType("_Company")]Param(

        [Parameter(Mandatory,Position=0)][String] $Name    ,
        [Parameter(Mandatory,Position=1)][String] $Branch  ,
        [Parameter(Mandatory,Position=2)][String] $Phone   ,
        [Parameter(Mandatory,Position=3)][String] $Website ,
        [Parameter(Mandatory,Position=4)][String] $Hours   )

    [_Company]::New($Name,$Branch,$Phone,$Website,$Hours)
}
