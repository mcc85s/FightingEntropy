# WinRM stuff -> https://rakhesh.com/windows/how-to-undo-changes-made-by-winrm-quickconfig

Class WinRMRegistry
{
    [String] $Path
    [String] $Name
    [Object] $Value
    WinRMRegistry()
    {
        $This.Path  = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        $This.Name  = "LocalAccountTokenFilterPolicy"
        $This.Value = $Null
    }
}

Class WinRMService
{
    [String]        $Name
    [String]      $Status
    [String] $StartupType
    [String] $DisplayName
    WinRMService()
    {
        $This.Name = "winrm"
    }
    [Object] Get()
    {
        $Item             = Get-Service $This.Name
        $This.Status      = $Item.Status
        $This.StartupType = $Item.StartupType
        $This.DisplayName = $Item.DisplayName
        
        Return $Item
    }
    Set([String]$StartupType)
    {
        Set-Service $This.Name -StartupType $StartupType -Verbose
    }
}

Class WinRMFirewall
{
    Hidden [Object] $Entry
    [String]         $Name
    [String]  $DisplayName
    [String] $DisplayGroup
    [Object]      $Enabled
    [Object[]]    $Profile
    [String]    $Direction
    WinRMFirewall()
    {
        $This.Entry = $This.Get()
    }
    [String] GetDisplayName()
    {
        Return "Windows Remote Management (HTTP-In)"
    }
    [Object] Get()
    {
        $Item               = Get-NetFirewallRule | ? Displayname -eq $This.GetDisplayName()
        $This.Name          = $Item.Name
        $This.DisplayName   = $Item.DisplayName
        $This.DisplayGroup  = $Item.DisplayGroup
        $This.Enabled       = $Item.Enabled
        $This.Profile       = $Item.Profile
        $This.Direction     = $Item.Direction

        Return $Item
    }
}

Class WinRM
{
    [Object] $Registry
    [Object] $Service
    [Object] $Firewall
    [Object] $Listener
    WinRM()
    {
        $This.Registry = [WinRMRegistry]::New()
        $This.Service  = [WinRMService]::New()
        $This.Firewall = [WinRMFirewall]::New()
    }
    [Object] EnumerateListener()
    {
        Return winrm enumerate winrm/config/listener
    }
    [Void] DeleteListener()
    {
        winrm delete winrm/config/Listener?Address=*+Transport=HTTP
    }
}
