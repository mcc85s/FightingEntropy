
Function Install-BossModeISE
{
    Class BossModeISE
    {
        [String] $Name
        [String] $Tag
        [String] $Url
        BossModeISE()
        {
            $This.Name = "BossMode"
            $This.Tag  = "StorableColorTheme.ps1xml"
            $This.Url  = $This.Source()
            $This.Install()
        }
        [String] Repository()
        {
            Return "https://github.com/mcc85s/FightingEntropy"
        }
        [String] Source()
        {
            Return "{0}/blob/main/Theme/ISETheme/{1}.{2}?raw=true" -f $This.Repository(), $This.Name, $This.Tag
        }
        [String] GetRegistryPath()
        {
            Return "HKCU:\Software\Microsoft\PowerShell\3\Hosts\PowerShellISE\ColorThemes"
        }
        [UInt32] CheckInternet()
        {
            Return !!(Test-Connection -ComputerName 1.1.1.1 -Count 1)
        }
        CheckRegistryPath()
        {
            $Registry = $This.GetRegistryPath()

            If (!(Test-Path $Registry))
            {
                $List = $Registry -Split "\\"
                $Path = $List[0]
                ForEach ($Item in $List[1..($List.Count-1)])
                {
                    $Path = $Path, $Item -join "\"
                    If (!(Test-Path $Path))
                    {
                        New-Item -Path $Path | Out-Null
                    }
                }
            }
        }
        [String] Download()
        {
            Return Invoke-WebRequest -Uri $This.Url -UseBasicParsing | % Content
        }
        Install()
        {
            If (!$This.CheckInternet())
            {
                Throw "[!] No internet connection"
            }

            $This.CheckRegistryPath()

            $Registry = $This.GetRegistryPath()

            $Item = Get-ItemProperty -Path $Registry

            If ($This.Name -in $Item.PSObject.Properties.Name)
            {
                Remove-ItemProperty -Path $Registry -Name $This.Name
            }

            $Content = $This.Download()
            If (!$Content)
            {
                Throw "[!] Unable to download {0}.{1}" -f $This.Name, $This.Tag
            }

            Set-ItemProperty -Path $Registry -Name $This.Name -Value $Content -Verbose
        }
    }

    [BossModeISE]::New()
}
