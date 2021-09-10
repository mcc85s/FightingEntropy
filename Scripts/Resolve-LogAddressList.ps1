Function Resolve-LogAddressList
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$LogPath)

    If (!(Test-Path $LogPath))
    {
        Throw "Invalid path"
    }

    Class LogType
    {
        Hidden [Object] $Line
        [Object] $Date
        [Object] $Time
        [Object] $Type
        [String] $Message
        LogType([String]$Line)
        {
            $This.Line    = $Line -Split "\t"
            $This.Date    = $This.Line[0].Split("T")[0]
            $This.Time    = $This.Line[0].Split("T")[1]
            $This.Type    = $This.Line[1]
            $This.Message = $This.Line[2]
        }
    }

    Class IPResult
    {
        Hidden [Object] $Object
        [String] $IPAddress
        [String] $Status
        [String] $Name
        [String] $Tag
        [String] $Org
        [String] $City
        [String] $Date
        [String] $Time
        [String] $Offset
        IPResult([Object]$IPAddress)
        {
            $Obj                = Invoke-RestMethod "http://whois.arin.net/rest/ip/$Ipaddress" -Headers @{ Accept = "application/xml" } -EA 0
            $This.Object        = $Obj

            If ($Obj -ne $Null)
            {
                $Obj.Net         | % {

                    $This.IPAddress = $IPAddress
                    $This.Status    = "+"
                    $This.Name      = $_.Name
                    $This.Tag       = $_.OrgRef.Handle
                    $This.Org       = $_.OrgRef.Name
                    $This.Date      = $_.Updatedate.Split("T")[0]
                    $This.Time      = $_.UpdateDate.Split("T")[1]
                    $This.Offset    = $This.Time.Split("-")[1]
                }
            }

            If ($Obj -eq $Null)
            {
                $This.IPAddress     = $IPAddress
                $This.Status        = "-"
            }
        }
        GetCity()
        {
            If ($This.Object.Net -ne $Null)
            {
                $This.City = (Invoke-RestMethod $This.Object.Net.orgRef."#text").org.city
            }
        }
    }

    Class SystemLog
    {
        [Object] $Stack
        [Object] $IPList
        [Object] $Output
        SystemLog([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            $This.Stack  = Get-Content $Path | % { [LogType]$_ }
            $This.IPList = [Regex]::Matches($This.Stack.Message,"(\d+\.){3}\d+").Value | Select-Object -Unique
            $This.Output = @( )
        
            $Ct          = $This.IPList.Count

            Write-Progress -Activity "Processing [~] system.log" -Status "Scanning -> (0/$Ct)" -PercentComplete 0
        
            ForEach ( $X in 0..($This.IPList.Count-1))
            {
                Write-Progress -Activity "Processing [~] system.log" -Status "Scanning -> ($X/$Ct)" -PercentComplete (($X*100)/$Ct)

                $This.Output += [IPResult]($This.IPList[$X])
            }

            Write-Progress -Activity "Processing [~] system.log" -Status "Complete" -Completed
        }
    }

    $Log = [SystemLog]$LogPath 
    $Log.Output | % GetCity
    $Log.Output
}
