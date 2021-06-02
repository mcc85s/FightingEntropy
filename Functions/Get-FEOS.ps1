Function Get-FEOS
{
    Class _Enum
    {
        [String] $Name
        [Object] $Value

        _Enum([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class _OS
    {
        [Object] $Env
        [Object] $Var
        [Object] $PS
        [Object] $Ver
        [Object] $Major
        [Object] $Type

        _OS()
        {
            $This.Env   = Get-ChildItem Env:\      | % { [_Enum]::New($_.Key,$_.Value) }
            $This.Var   = Get-ChildItem Variable:\ | % { [_Enum]::New($_.Name,$_.Value) }
            $This.PS    = $This.Var | ? Name -eq PSVersionTable | % Value | % GetEnumerator | % { [_Enum]::New($_.Name,$_.Value) }
            $This.Ver   = $This.PS | ? Name -eq PSVersion | % Value
            $This.Major = $This.Ver.Major
            $This.Type  = $This.GetOSType()
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
    }

    [_OS]::New()
}
