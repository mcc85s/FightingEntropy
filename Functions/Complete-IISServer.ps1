Function Complete-IISServer
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory)][String]     $Name = "MDT"       ,
        [Parameter(Mandatory)][String]  $AppPool = "MDTAppPool",
        [Parameter(Mandatory)][String] $HostName = "MDTService",
        [Parameter(Mandatory)][String]     $Path = "{0}\inetpub" -f [Environment]::GetEnvironmentVariables().SystemDrive )

    Import-Module -Name WebAdministration -Verbose -Force

    $Item = [_iis]::New($Name,$AppPool,$HostName,$Path)

    $Item.Root , $Item.AppData | % { If ( ! ( Test-Path $_ ) ) { New-Item -Path $_ -ItemType Directory -Force -Verbose } }

    $Site = Get-WebSite | ? Name -eq "Default Web Site"
    
    $Site | Stop-WebSite

    $Site.ServerAutoStart = $False

    Get-Service | ? Name -in ("MRxDAV WebClient WAS W3SVC" -Split " ") | ? Status -ne Running | % { 
    
        Write-Host ("Starting [~] {0}" -f $_.Name)
        Set-Service -Name $_.Name -StartupType Automatic -Status Running
    }

    Get-IISAppPool | ? Name -eq $Item.AppPool | Remove-WebAppPool

    New-WebAppPool -Name $Item.AppPool -Force

    ForEach ( $I in 0..2 )
    {
        $Name, $Value = ("Enable32BitAppOnWin64 True;ManagedRuntimeVersion v4.0;ManagedPipelineMode Integrated" -Split ";")[$I] -Split " "
        Set-ItemProperty -Path IIS:\AppPools\$($Item.AppPool) -Name $Name -Value $Value -Verbose
    }

    Restart-WebAppPool -Name $Item.AppPool

    Get-WebSite | ? Name -eq $Item.Name | Remove-Website

    If ( ! ( Test-Path $Item.Root ) ) 
    { 
        New-Item -Path $Item.Root -ItemType Directory -Verbose 
    }

    New-Website -Name $Item.Name -ApplicationPool $Item.AppPool -PhysicalPath $Item.Root | Start-Website
    
    Set-WebBinding -Name $Item.Name -HostHeader "" -PropertyName HostHeader -Value $Item.URL

    $Site = Get-WebBinding | ? BindingInformation -Match $Item.URL

    New-WebVirtualDirectory -Site $Item.Name -Name $Item.Host -PhysicalPath $Item.Root -Force
    Set-WebConfigurationProperty -PSPath Machine/Webroot/Apphost -Location $Item.Name -Name Enabled -Filter system.webServer/webdav/Authoring -Value $True

    @{  FilePath     = Get-ChildItem -Path "$($Item.System32)\inetsrv" *appcmd.exe | % FullName
        ArgumentList = "Set Config '{0}/{1}' /Section:system.webServer/webdav/authoringRules /+[Users='*',Path='*',Access='Read,Source'] /Commit:AppHost" -f $Item.Name, $Item.Host
        WindowStyle  = "Hidden" 
        
    }                | % { Start-Process @_ -PassThru } | Out-Null

    @{  PSPath       = $Item.Site
        Filter       = "system.webServer/staticContent"
        Name         = "." 
    
    } | % {
    
        If ( ".*" -notin ( Get-WebConfigurationProperty @_ | % Collection | % FileExtension ) )
        {
            Add-WebConfigurationProperty @_ -Value @{ fileExtention = ".*" ; mimeType = "Text/Plain" } -Verbose
        }
    }

    ForEach ( $I in 0..8 )
    {
        @{ PSPath    = "Machine/WebRoot/AppHost"
           Location  = @( $Item.Name ; "$($Item.Name)\$($Item.Host)" )[1,1,0,1,0,1,0,1,0][$I]
           Filter    = @("{0}/anonymous{1} {0}/windows{1} {2}Rules {2}/Properties {3}/FileExtensions {3}/Verbs" -f ("Security/aut" +
                        "hentication Authentication WebDAV/Authoring Security/requestFiltering" -Split " ") -Split " " | % { 
                        "system.webServer/$_" } )[0,1,2,3,3,4,4,5,5][$I]
           Name      = @("Enabled DefaultMimeType AllowInfinitePropfindDepth ApplyToWebDAV" -Split " ")[0,0,1,2,2,3,3,3,3][$I]
           Value     = @("False True Text/XML" -Split " ")[0,1,2,1,1,0,0,0,0][$I]
        
        }            | % { Set-WebConfigurationProperty @_ }
    }

    Get-IISConfigSection | ? SectionPath -match system.webServer/Security/RequestFiltering | % GetChildElement hiddenSegments | % Attributes | % { 
    
        $_.Value     = $False 
    }

    "IIS_IUSRS","IUSR","IIS AppPool\$($Item.AppPool)" | % { 
        
        @{  Sam       = $_
            Rights    = "ReadAndExecute"
            Access    = "Allow"
            Inherit   = "ContainerInherit","ObjectInherit"
            Propagate = "InheritOnly"
        }             | % { New-ACLObject @_ } | % { Add-ACL -Path $Item.Root -ACL $_ }
    }

    "IIS_IUSRS","IIS AppPool\$($Item.AppPool)" | % { 
        
        @{  Sam       = $_
            Rights    = "Modify"
            Access    = "Allow"
            Inherit   = "ContainerInherit","ObjectInherit"
            Propagate = "InheritOnly"
        }             | % { New-ACLObject @_ } | % { Add-ACL -Path $Item.AppData -ACL $_ }
    }

    $Path = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

    @( 2..3 | % { "SSL $_.0" } ; 0..2 | % { "TLS 1.$_" } ) | % { 

        If ( ! ( Test-Path $Path\$_ ) )
        {
            New-Item -Path $Path -Name $_
        }

        ForEach ( $I in "Client","Server" )
        {
            If ( ! ( Test-Path $Path\$_\$I ) )
            {
                New-Item -Path $Path\$_ -Name $I -Verbose
            }

            ForEach ( $X in "DisabledByDefault","Enabled" )
            {
                Set-ItemProperty -Path $Path\$_\$I -Name $X -Value 0 -Verbose
            }

            If ( $_ -eq "TLS 1.2" )
            {
                Set-ItemProperty -Path $Path\$_\$I -Name Enabled -Value 1 -Verbose
            }
        }
    }

    "","\WOW6432NODE" | % { "HKLM:\SOFTWARE$_\Microsoft\.NETFramework" } | % { 

        ForEach ( $I in "v2.0.50727","v4.0.30319" )
        {
            If ( ! ( Test-Path $_\$I ) )
            {
                New-Item -Path $_\$I -Verbose
            }

            Set-ItemProperty -Path $_\$I -Name SystemDefaultTLSVersions -Type DWORD -Value 1 -Verbose
        }
    }
}
