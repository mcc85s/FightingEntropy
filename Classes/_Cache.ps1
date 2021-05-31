Class _Cache
{
    [String] $Path
    [Object] $File

    _Cache([Object]$Image)
    {
        Switch -Regex ($Image)
        {
            "http[s]*://" 
            {
                [Net.ServicePointManager]::SecurityProtocol = 3072
                $This.Path            = $Image
                $This.File            = "$Env:Temp{0}" -f (Split-Path -Leaf $Image)
                Invoke-WebRequest -URI $This.Path -OutFile $This.File #| ? StatusDescription -ne OK | % { Throw "Exception" }
                $This.Path            = "file:///{0}" -f $This.File.Replace("\","/")
            }
                
            "(\w+:\\\w+)"
            {
                If ( ! ( Test-Path $Image ) )
                {
                    Throw "Invalid path to image" 
                }

                $This.Path            = "file:///{0}" -f $Image.Replace("\","/")
            }

            "(ms-app)+([x|data])+(:///)"
            {
                Throw "ms-app* Not yet implemented"
            }
        }
    }
}
