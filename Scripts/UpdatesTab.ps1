Class UpdateFile
{
    Hidden [String] $Path
    [String] $Name
    Hidden [String] $File
    Hidden [String[]] $Content
    [Object] $AppliesTo
    [Object] $BuildDate
    [Object] $Company
    [Object] $FileVersion
    [Object] $InstallationType
    [Object] $InstallerEngine
    [Object] $InstallerVersion
    [Object] $KBArticle
    [Object] $Language
    [Object] $PackageType
    [Object] $ProcessorArchitecture
    [Object] $ProductName
    [Object] $SupportLink
    UpdateFile([String]$File)
    {
        $This.Path                  = $File
        $This.Name                  = $File | Split-Path -Leaf
        $This.File                  = $This.Path -Replace "(_.+\.msu)", "-pkgProperties.txt"
        $Parent                     = $This.Path | Split-Path
        Start-Process -Filepath "$env:Windir\System32\expand.exe" -ArgumentList ("-F:*properties.txt `"$($This.Path)`" `"$($Parent)`"") -Wait
        $This.Content               = Get-Content $This.File
        Remove-Item $This.File
        $This.AppliesTo             = $This.Content | ? { $_ -match "^Applies to" }             | % { $_.Split("=")[1].Replace('"',"") }
        $This.BuildDate             = $This.Content | ? { $_ -match "^Build Date" }             | % { $_.Split("=")[1].Replace('"',"") }
        $This.Company               = $This.Content | ? { $_ -match "^Company"    }             | % { $_.Split("=")[1].Replace('"',"") }
        $This.FileVersion           = $This.Content | ? { $_ -match "^File Version" }           | % { $_.Split("=")[1].Replace('"',"") }
        $This.InstallationType      = $This.Content | ? { $_ -match "^Installation Type" }      | % { $_.Split("=")[1].Replace('"',"") }
        $This.InstallerEngine       = $This.Content | ? { $_ -match "^Installer Engine" }       | % { $_.Split("=")[1].Replace('"',"") }
        $This.InstallerVersion      = $This.Content | ? { $_ -match "^Installer Version" }      | % { $_.Split("=")[1].Replace('"',"") }
        $This.KBArticle             = $This.Content | ? { $_ -match "^KB Article Number" }      | % { $_.Split("=")[1].Replace('"',"") } | % { "KB$_" }
        $This.Language              = $This.Content | ? { $_ -match "^Language" }               | % { $_.Split("=")[1].Replace('"',"") }
        $This.PackageType           = $This.Content | ? { $_ -match "^Package Type" }           | % { $_.Split("=")[1].Replace('"',"") }
        $This.ProcessorArchitecture = $This.Content | ? { $_ -match "^Processor Architecture" } | % { $_.Split("=")[1].Replace('"',"") }
        $This.ProductName           = $This.Content | ? { $_ -match "^Product Name" }           | % { $_.Split("=")[1].Replace('"',"") }
        $This.SupportLink           = $This.Content | ? { $_ -match "^Support Link" }           | % { $_.Split("=")[1].Replace('"',"") }
    }
}

$Updates    = Get-ChildItem $UpdatePath *.msu -Recurse | ? PSIsContainer -eq 0 | % FullName
$Output     = @( )
Write-Progress -Activity "Processing" -Status "[File list]" -PercentComplete 0
ForEach ($X in 0..($Updates.Count - 1))
{
    Write-Progress -Activity "Processing" -Status "[File: $($X+1)/$($Updates.Count)]" -PercentComplete ([Long]($X * 100 / $Updates.Count))
    $Output += [UpdateFile]($Updates[$X])
}
Write-Progress -Activity "Processed" -Status "[File list]" -Completed

$Info = Get-ComputerInfo

Import-Module PSWindowsUpdate

Add-WUServiceManager -MicrosoftUpdate -ComputerName dsc0
Get-WUServiceManager
