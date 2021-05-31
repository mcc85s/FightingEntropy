Function New-FEShare
{
    [CmdLetBinding()]
    Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)][String]             $Path ,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory)][String]        $ShareName ,
    [Parameter()]         [String]      $Description = "[FightingEntropy($([Char]960))]:\\Development Share",
    [Parameter(Mandatory)][PSCredential] $Credential ,
    [Parameter(Mandatory)][Object]              $Key )

    Class _Share
    {
        Hidden [Object] $Shares
        [String]          $Path
        [String]      $Hostname
        [String]         $Label
        [String]          $Name
        [Object]          $Root
        [String]     $ShareName
        [String]   $NetworkPath
        [String]   $Description
        [String]      $Comments = "$(Get-Date -UFormat "[%Y-%m%d(MCC/SDP)]")"
        [Object]           $Key

        _Share([String]$Path,[String]$Name,[String]$Description,[Object]$Key)
        {
            $This.Key         = $Key

            If (!(Test-Path $Path))
            {
                 New-Item -Path $Path -ItemType Directory -Verbose
            }

            $This.Root         = Get-Item -Path $Path
        
            If ($This.Root)
            {
                $This.Path     = $Path
            }

            $This.Description  = $Description
         
            Import-Module (Get-MDTModule)

            $This.Shares       = Get-MDTPersistentDrive
            $This.Label        = Switch($This.Shares.Count) { 0 { "FE001" } Default { "FE{0:d3}" -f ($This.Shares.Count + 1) } }
            $This.Hostname     = Resolve-DNSName ([Environment]::MachineName) | % Name | Select-Object -Unique
            $This.ShareName    = "{0}$" -f $Name.TrimEnd("$")
            $This.NetworkPath  = "\\{0}\{1}" -f $This.HostName, $This.ShareName
        }

        [Object] CheckPath()
        {
            Return @( If ( $This.Root -in $This.Shares.Path )
            {
                $This.Shares | ? Path -eq $This.Root    
            }

            ElseIf ( $This.Name -in $This.Shares.Name )
            { 
                $This.Shares | ? Name -eq $This.Name
            })
        }

        NewSMBShare()
        {
            If ( $This.ShareName -notin ( Get-SMBShare | % Name ) )
            {
                Write-Host "New-SMBShare $($This.ShareName)"

                @{ 
                    Name        = $This.ShareName
                    Path        = $This.Root
                    Description = $This.Description 
                   
                }               | % { New-SMBShare @_ -FullAccess Administrators -Verbose }
            }
        }

        NewPSDrive()
        {
            If ( $This.Name -notin ( Get-PSDrive | % Name ) )
            {
                Write-Host "New-PSDrive $($This.Name)"
                @{  
                    Name           = $This.Label
                    PSProvider     = "MDTProvider"
                    Root           = $This.Root
                    Description    = $This.Description
                    NetworkPath    = $This.NetworkPath 
                }                  | % { New-PSDrive @_ | Add-MDTPersistentDrive -Verbose }
            }

            Else
            {
                Throw "Drive exists"
            }
        }
    }

    Import-Module (Get-MDTModule)
    $Share   = [_Share]::New($Path,$ShareName,$Description,$Key)
    $Share.NewSMBShare()
    $Share.NewPSDrive()
    
    Get-MDTPersistentDrive | % { 

        If ((Get-PSDrive -Name $_.Name -EA 0 -Verbose) -eq $Null )
        {
            New-PSDrive -Name $_.Name -PSProvider MDTProvider -Root $_.Path -Verbose
        }
    }

    # Load Module / Share Drive Mount
    $Module                = Get-FEModule
    $Root                  = "$($Share.Label):\"
    $Control               = "$($Share.Path)\Control"
    $Script                = "$($Share.Path)\Scripts"

    ForEach ($File in $Key.Background, $Key.Logo)
    {
        Copy-Item -Path $File -Destination $Script -Verbose
    }

    ForEach ( $File in $Module.Control | ? Extension -eq .png )
    {
        Copy-Item -Path $File.Fullname -Destination $Script -Force -Verbose
    }

    ForEach ( $File in $Module.Control | ? Name -match Mod.xml )
    {
        Copy-Item -Path $File.FullName -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
    }
}
