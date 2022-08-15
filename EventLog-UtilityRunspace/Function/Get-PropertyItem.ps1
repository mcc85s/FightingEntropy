Function Get-PropertyItem
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0,ValueFromPipeline)][Object[]]$InputObject,
        [Parameter(Mandatory,ParameterSetName=1,ValueFromPipeline)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1,ValueFromPipeline)][String]$Value
    )

    Begin 
    {
        Class PropertyItem
        {
            [String] $Name
            [Object] $Value
            PropertyItem([String]$Name,[Object]$Value)
            {
                $This.Name  = $Name
                $This.Value = $Value
            }
        }
        $Output  = @( )
    }
    Process 
    {
        $Output += Switch ($PsCmdLet.ParameterSetName)
        {
            0 { [PropertyItem]::New($InputObject.Name,$InputObject.Value) }
            1 { [PropertyItem]::New($Name,$Value) }
        }
        
    }
    End
    {
        $Output
    }
}