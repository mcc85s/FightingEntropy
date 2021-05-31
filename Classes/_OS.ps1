Class _OS
{
    [Object[]] $Environment
    [Object[]] $Variable
    [Object]   $PSVersionTable
    [Object]   $PSVersion
    [Object]   $Major
    [Object]   $Type

    [Object] GetItem([String]$Item)
    {
        $Return = @{ }

        ForEach ( $X in ( Get-Item -Path $Item | % GetEnumerator ) )
        { 
            $Return.Add($X.Name,$X.Value)
        }

        Return $Return
    }

    [String] GetWinType()
    {
        Return @( Switch -Regex ( Invoke-Expression "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption" )
        {
            "Windows 10" { "Win32_Client" } "Windows Server" { "Win32_Server" }
        })
    }

    [String] GetOSType()
    {
        Return @( If ( $This.Major -gt 5 )
        {
            If ( Get-Item Variable:\IsLinux | % Value )
            {
                "RHELCentOS"
            }

            Else
            {
                $This.GetWinType()
            }
        }

        Else
        {
            $This.GetWinType()
        })
    }

    _OS()
    {
        $This.Environment    = Get-ChildItem Env:\
        $This.Variable       = Get-ChildItem Variable:\
        $This.PSVersionTable = Get-Item Variable:\PSVersionTable | % Value
        $This.PSVersion      = Get-Item Variable:\PSVersionTable | % Value | % PSVersion
        $This.Major          = $This.PSVersion.Major
        $This.Type           = $This.GetOSType()
    }
}
