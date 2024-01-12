<# Slightly improved version of...
https://github.com/mcc85s/FightingEntropy/blob/main/Scripts/2023_1214-(InstallCascadiaCode).ps1

May make this a function that is capable of automatically installing other fonts
#>

# [Declarations]
$Name        = "Cascadia"
$FontPath    = "$Env:Windir\Fonts"
$Fonts       = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts').PSObject.Properties | Sort-Object Name
$Installed   = $Fonts | ? Name -match $Name

$Source      = "https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip"
$Zip         = $Source.Split("/")[-1]
$Folder      = $Zip.Replace(".zip","")
$Destination = "$Home\Downloads\$Zip"
$Extract     = "$Home\Downloads\$Folder"

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.Filesystem

If ($Installed.Count -eq 0)
{
    Start-BitsTransfer -Source $Source -Destination $Destination -Verbose

    If ([System.IO.File]::Exists($Destination))
    {
        If (![System.IO.Directory]::Exists($Extract))
        {
            [System.IO.Directory]::CreateDirectory($Extract) > $Null
        }

        $Zip = [System.IO.Compression.ZipFile]::Open($Destination,"Read")

        $Select = $Zip.Entries | ? Fullname -match ^ttf\/Cascadia.+.ttf

        ForEach ($Item in $Select)
        {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($Item,"$Extract\$($Item.Name)")
        }

        $List        = @([System.IO.DirectoryInfo]::New($Extract).EnumerateFiles())
        $Target      = (New-Object -ComObject Shell.Application).Namespace(0x14)

        If ($List.Count -gt 1)
        {
            Write-Progress -Activity "Processing fonts..." -Status ("{0:p}" -f 0) -PercentComplete 100
    
            ForEach ($X in 0..($List.Count-1))
            {
                $Item    = $List[$X]
                $Percent = ($X+1)/$List.Count
                $Status  = "{0:p}" -f $Percent
                $Activity = "Processing: [{0}]" -f $Item.Name
                Write-Progress -Activity $Activity -Status $Status -PercentComplete ($Percent*100)

                $Target.CopyHere($Item.Fullname,0x10)
            }
    
            Write-Progress -Activity $Activity -Status Complete -Completed
        }

        If ([System.IO.Directory]::Exists($Extract))
        {
            [System.IO.Directory]::Delete($Extract,1)
        }

        Get-ChildItem "$Env:Windir\Fonts" | ? Name -in $Select.Name | Unblock-File -Verbose
    }
}
