Class _Branding
{
    [String[]]        $Names = ("{0};{0}Style;Logo;Manufacturer;{1}Phone;{1}Hours;{1}URL;LockScreenImage;OEMBackground") -f "Wallpaper","Support" -Split ";"
    [Object]          $Items
    [Object]         $Values

    [Object]         $Output
    [Object]    $Certificate

    [String]       $Provider = "Secure Digits Plus LLC"
    [String]       $SiteLink = "CP-NY-US-12065"
    [String]     $Background = "C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2020.10.0\Graphics\OEMbg.jpg"
    [String]           $Logo = "C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2020.10.0\Graphics\OEMlogo.bmp"
    [String]          $Phone = "(518)406-8569"
    [String]        $Website = "securedigitsplus.com"
    [String]          $Hours = "24h/d;7d/w;365.25d/y;"

    [String[]]     $FilePath = ("{0}\{1};{0}\{1}\{2};{0}\{1}\{2}\Backgrounds;{0}\Web\Screen;{0}\Web\Wallpaper\Windows;C:\ProgramData\Microsoft\" + 
                                "User Account Pictures") -f "C:\Windows" , "System32" , "OOBE\Info" -Split ";"

    [String[]] $RegistryPath = @(("HKCU:\{0}\{1}\Policies\System;HKLM:\{0}\{1}\OEMInformation;HKLM:\{0}\{1}\Authentication\LogonUI\Background;" +
                                  "HKLM:\{0}\Policies\Microsoft\Windows\Personalization") -f "Software","Microsoft\Windows\CurrentVersion" -Split ";")

    _Branding([String]$Background,[String]$Logo)
    {
        If ( ! ( Test-Path -Path $Background ) )
        {
            Throw "Invalid Path"
        }

        $This.Background     = Get-Item $Background | % FullName

        If ( ! ( Test-Path -Path $Logo ) )
        {
            Throw "Invalid Path"
        }

        $This.Logo           = Get-Item $Logo | % FullName

        ForEach ( $I in 0..5 )
        {
            $This.FilePath[$I] | % {
                
                If ( ! ( Test-Path $_ ) )
                {
                    New-Item -Path $_ -Verbose
                }

                Copy-Item -Path @( $This.Logo, $This.Background )[[Int32]( $I -in 2..4 )] -Destination $_ -Verbose -Force
            }
        }

        $This.RegistryPath    | % {
                
            @{  Path          = $_ | Split-Path -Parent
                Name          = $_ | Split-Path -Leaf   } | % {
                    
                If ( ! ( Test-Path $_.Path ) )
                {
                    New-Item -Path $_.Path -Name $_.Name -Verbose
                }
            }
        }
            
        $This.Items           = $This.RegistryPath[0,0,1,1,1,1,1,3,2]
        $This.Values          = @($This.Background,2,$This.Logo,$This.Provider,$This.Phone,$This.Hours,$This.Website,$This.Background,1)
        $This.Output          = @( )

        ForEach ( $I in 0..8 ) 
        {
            $This.Output     += [_Brand]::New($This.Items[$I],$This.Names[$I],$This.Values[$I])

            $This.Output[$I]  | % { Set-ItemProperty -Path $_.Path -Name $_.Name -Value $_.Value -Verbose }
        }
    }
}
