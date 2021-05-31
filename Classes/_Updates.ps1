Class _Updates
{
    [String]          $Root = ("{0}\Images" -f ( Get-FEModule | % Path ) )
    Hidden [String]  $Drive = ([Char]( [Int32]( Get-Volume | Sort-Object DriveLetter | % DriveLetter )[-1] + 1 ))
    Hidden [String[]] $Tags = ("DC2016 10E64 10H64 10P64 10E86 10H86 10P86" -Split " ")
    [Object]         $Files

    _Updates()
    {
        "$($This.Root)\Updates" | % { 
            
            If ( ! ( Test-Path $_ ) ) 
            {
                New-Item $_ -ItemType Directory -Verbose
            }
            
            "$_\Server","$_\Client" | % { "$_\x64","$_\x86" } | % {

                If ( ! ( Test-Path $_ ) )
                {
                    New-Item $_ -ItemType Directory -Verbose

                }
            }
        }

        $This.Files         = $This.Tags | % { Get-ChildItem "$($This.Root)\$_" | ? Extension -eq .wim }
    }

    GetServer_x64([String[]]$KB)
    {
        # Throw some get-update logic here...
    }

    GetServer_x86([String[]]$KB)
    {
        # Throw some get-update logic here...
    }

    GetClient_x64([String[]]$KB)
    {
        # Throw some get-update logic here...
    }

    GetClient_x86([String[]]$KB)
    {
        # Throw some get-update logic here...
    }

    UpdateServer_x64([String[]]$KB)
    {
        # Throw some apply-update logic here...
    }

    UpdateServer_x86([String[]]$KB)
    {
        # Throw some apply-update logic here...
    }

    UpdateClient_x64([String[]]$KB)
    {
        # Throw some apply-update logic here...
    }

    UpdateClient_x86([String[]]$KB)
    {
        # Throw some apply-update logic here...
    }
}
