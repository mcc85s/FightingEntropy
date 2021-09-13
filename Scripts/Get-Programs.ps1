Function Get-Programs
{
    Class DGList
    {
        [String] $Name
        [Object] $Value
        DGList([String]$Name,[String]$Object)
        {
            $This.Name  = $Name
            $This.Value = $Object
        }
    }

    Class Program
    {
        Static Hidden [String[]] $Default = ("ChildName Drive ParentPath Path Provider" -Split " " | % { "PS$_" })
        [String] $DisplayName
        [String] $Type
        [Object] $Object
        [Object] $Uninstall
        Program([Object]$Program)
        {
            $This.DisplayName = $Program.DisplayName
            $This.Type        = @("MSI","WMI")[$Program.UninstallString -imatch "msiexec"]
            $This.Uninstall   = $Program.UninstallString
            $This.Object      = ForEach ( $Item in $Program | Get-Member | ? MemberType -eq NoteProperty | ? Name -notin ([Program]::Default) )
            {
                $Name         = $Item.Name
                $Value        = $Item.Definition -Replace "^\w+\s",""
                $Value        = $Value.Replace($Name+"=","")
                [DGList]::New($Name,$Value)
            }
        }
    }

    $Path = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" }
    $Type = @{ AMD64 = $Path[0,1] ; x86 = $Path[0] }[$Env:Processor_Architecture]
    $Reg  = $Type | % { Get-ItemProperty "$_\*" } | % { [Program]$_ }
}
