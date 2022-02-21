# DeploymentResearch / https://github.com/DeploymentResearch/DRFiles/blob/master/Scripts/Final%20Configuration%202013/FinalConfig.hta
# MDT PSD method as of 1/5/2022->2/20/2022 seems to halt before cleanup... probably because the solution is not finalizing after reboot...
# Prolly cause I've been modifying the standard PSD process... 
# Anyway, this class allows modification of the default admin account, domain, password, and has methods that allow for enabling and disabling autologin
Class AdminAutoLogin 
{
    [String]      $Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    [String[]]    $Keys = "AutoAdminLogon AutoLogonCount DefaultUserName DefaultDomainName DefaultPassword ForceAutoLogon DisableCAD" -Split " "
    [String]  $Username
    [String]    $Domain
    Hidden [String]  $Password
    Hidden [Object[]]  $En
    Hidden [Object[]] $Dis
    AdminAutoLogin([String]$Username,[String]$Domain,[String]$Password)
    {
        $This.Username = $Username
        $This.Domain   = $Domain
        $This.Password = $Password
        $This.En       = 1, 999, $Username, $Domain, $Password, 1, 1
        $This.Dis      = 0, 0, $Username, $Domain, $Password, 0, 0
    }
    Set([UInt32]$Mode)
    {
        ForEach ($X in 0..($This.Keys.Count-1))
        {
            Set-ItemProperty -Path $This.Path -Name $This.Keys[$X] -Value @($This.Dis,$This.En)[$Mode][$X] -Verbose
        }
    }
    Disable()
    {
        $This.Set(0)
    }
    Enable()
    {
        $This.Set(1)
    }
}

# Example 
# $Admin = [AdminAutoLogin]::New("Administrator","DOMAIN","password")
# $Admin.Enable()
# ------[Verbose output, changes each key]-----
# $Admin.Disable()
# ------[Verbose output, changes each key]-----
