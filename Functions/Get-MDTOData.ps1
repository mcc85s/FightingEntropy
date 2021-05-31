Function Get-MDTOData # Modified version of (Mykal Nystrom/Deployment Bunny)'s script found here...
{   # https://deploymentbunny.com/2016/03/07/powershell-is-king-get-mdt-monitor-data-using-the-odata-feed-using-a-powershell-function/
    [CmdLetBinding()]Param(
    [Parameter(Mandatory)][String] $Server ,
    [Parameter()][UInt32]$Port=9801) 

    Class _MDTODataObject
    {
        [String] $Name
        [String] $PercentComplete
        [String] $Warnings
        [String] $Errors
        [String] $Status
        [String] $DeploymentStatus
        [String] $StepName
        [String] $TotalSteps
        [String] $CurrentStep
        [String] $DartIP
        [String] $DartPort
        [String] $DartTicket
        [String] $VMHost
        [String] $VMName
        [String] $LastTime
        [String] $StartTime
        [String] $EndTime

        _MDTODataObject([Object]$Obj)
        {
            $This.Name             = $Obj.Name 
            $This.PercentComplete  = $Obj.PercentComplete.'#text' 
            $This.Warnings         = $Obj.Warnings.'#text'
            $This.Errors           = $Obj.Errors.'#text'
            $This.Status           = $Obj.Status.'#text'
            $This.DeploymentStatus = Switch($Obj.DeploymentStatus.'#text')
            { 
                1 { "Active/Running"} 
                2 { "Failed"} 
                3 { "Successfully completed"} 
                Default {"Unknown"} 
            }
            $This.StepName         = $Obj.StepName.'#text'
            $This.TotalSteps       = $Obj.TotalSteps.'#text'
            $This.CurrentStep      = $Obj.CurrentStep.'#text'
            $This.DartIP           = $Obj.DartIP.'#text'
            $This.DartPort         = $Obj.DartPort.'#text'
            $This.DartTicket       = $Obj.DartTicket.'#text'
            $This.VMHost           = $Obj.VMHost.'#text'
            $This.VMName           = $Obj.VMName.'#text'
            $This.LastTime         = $Obj.LastTime.'#text' -replace "T"," "
            $This.StartTime        = $Obj.StartTime.'#text' -replace "T"," "
            $This.EndTime          = $Obj.EndTime.'#text' -replace "T"," "
        }
        
        [String] ToString()
        {
            Return @( $This.Name )
        }
    }

    $URL                           = ("http://{0}:{1}/MDTMonitorData/Computers" -f $Server , $Port )
    $Data                          = Invoke-RestMethod $URL
    
    $Data.Content.Properties       | %  { [_MDTODataObject]::New($_) } 
}
