
# // ____________________________________________________
# // | Property object which includes source and index  |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class OSProperty
{
    [String] $Source
    [UInt32] $Index
    [String] $Name
    [Object] $Value
    OSProperty([UInt32]$Source,[UInt32]$Index,[String]$Name,[Object]$Value)
    {
        $This.Source = @("Environment","Variable","Host","PowerShell")[$Source]
        $This.Index  = $Index
        $This.Name   = $Name
        $This.Value  = $Value
    }
    [String] ToString()
    {
        Return @($This.PSObject.Properties | % { "{0}: [{1}]" -f $_.Name, $_.Value }) -join ', '
    }
}

# // _______________________________________________________
# // | Collects various details about the operating system |
# // | specifically for cross-platform compatibility       |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class OS
{
    [Object] $Version
    [Object]    $Type
    [Object]  $Output
    OS()
    {
        $H          = @{ }

        # Environment
        Write-Host "Collecting [~] Environment"
        Get-ChildItem Env: | % { $This.Add($H,0,$_.Key,$_.Value) }
        
        # Variable
        Write-Host "Collecting [~] Variable"
        Get-ChildItem Variable: | % { $This.Add($H,1,$_.Name,$_.Value) }

        # Host
        Write-Host "Collecting [~] Host"
        (Get-Host).PSObject.Properties  | % { $This.Add($H,2,$_.Name,$_.Value) }
        
        # PowerShell
        Write-Host "Collecting [~] PowerShell"
        (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add($H,3,$_.Name,$_.Value) }

        # Assign hashtable to output array
        $This.Output  = $H[0..($H.Count-1)]
        $This.Version = [Version]($This.Output | ? Name -eq PSVersion | % Value)
        $This.Type    = $This.GetOSType()
    }
    Add([Object]$Hashtable,[UInt32]$Type,[String]$Name,[Object]$Value)
    {
        $Hashtable.Add($Hashtable.Count,[OSProperty]::New($Type,$Hashtable.Count,$Name,$Value))
    }
    [String] GetWinType()
    {
        Return @( Switch -Regex ( Invoke-Expression "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption" )
        {
            "Windows (10|11)" { "Win32_Client" } "Windows Server" { "Win32_Server" }
        })
    }
    [String] GetOSType()
    {
        Return @( If ($This.Major -gt 5)
        {
            If (Get-Item Variable:\IsLinux | % Value)
            {
                (hostnamectl | ? { $_ -match "Operating System" }).Split(":")[1].TrimStart(" ")
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
    [String] ToString()
    {
        Return ("[{0}/{1}]" -f $This.Type, $This.Version)
    }
}

$OS = [OS]::New()
