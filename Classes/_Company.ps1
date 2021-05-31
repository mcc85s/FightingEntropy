Class _Company
{
    [String] $Name
    [String] $Branch
    [Object] $Background
    [Object] $Logo
    [String] $Phone
    [String] $Website
    [String] $Hours

    _Company([String]$Name,[String]$Branch,[String]$Phone,[String]$Website,[String]$Hours) 
    {
        $This.Name       = $Name
        $This.Branch     = $Branch
        $This.Phone      = $Phone
        $This.Website    = $Website
        $This.Hours      = $Hours
    }

    GetLogo([String]$Path)
    {
        If ( ! ( Test-Path -Path $Path ) )
        {
            Throw "Invalid Path"
        }

        $This.Logo       = $Path
    }

    GetBackground([String]$Path)
    {
        If ( ! ( Test-Path -Path $Path ) )
        {
            Throw "Invalid Path"
        }

        $This.Background = $Path
    }
}
