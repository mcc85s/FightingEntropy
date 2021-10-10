<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Install-IISServer.ps1
          Solution: FightingEntropy Module
          Purpose: To install, stage, and configure an IIS Server for the Microsoft Deployment Toolkit/PSD modification
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-08
          Modified: 2021-10-08

          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Install-IISServer
{
    [CmdLetBinding()]
    Param(
        [Parameter()][String]           $SiteName =       "MDTSite",
        [Parameter()][String]        $AppPoolName =    "MDTAppPool",
        [Parameter()][String]    $VirtualHostName =    "MDTService",
        [Parameter()][String]   $PSDeploymentRoot = "C:\FlightTest",
        [Parameter()][String] $PSVirtualDirectory =    "FlightTest")

    Add-Type -AssemblyName PresentationFramework

    Class SecurityChannel
    {
        [String]   $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        SecurityChannel()
        {
            ForEach ($Type in "SSL 2.0;SSL 3.0;TLS 1.0;TLS 1.1;TLS 1.2" -Split ";")
            {
                $Item = "{0}\{1}" -f $This.Path, $Type

                If (!(Test-Path $Item))
                { 
                    New-Item -Path $This.Path -Name $Type -Verbose
                }
                
                ForEach ($Tag in "Client","Server")
                {
                    $Slot = "$Item\$Tag"

                    If (!(Test-Path $Slot))
                    {
                        New-Item -Path $Item -Name $Tag -Verbose
                    }
                    
                    ForEach ($Opt in "DisabledByDefault","Enabled")
                    {
                        Set-ItemProperty -Path $Slot -Name $Opt -Value 0 -Verbose
                    }

                    If ($Type -eq "TLS 1.2")
                    {
                        Set-ItemProperty -Path $Slot -Name Enabled -Value 1 -Verbose
                    }
                }
            }
        }
    }

    Class TLS
    {
        [String[]] $Path = ("" ,"\WOW6432NODE" | % { "HKLM:\SOFTWARE$_\Microsoft\.NETFramework" })         
        TLS()
        {
            ForEach ($Item in $This.Path)
            {
                ForEach ($Version in "v2.0.50727","v4.0.30319")
                {
                    If (!(Test-Path "$Item\$Version"))
                    { 
                        New-Item -Path $Item -Name $Version -Verbose
                    }
                    
                    Set-ItemProperty -Path $Item\$Version -Name SystemDefaultTlsVersions -Value 1 -Verbose
                }
            }
        }
    }

    Class IISService
    {
        [String] $Name
        [String] $Status
        IISService([String]$Name)
        {
            $This.Name   = $Name
            $This.Get()
        }
        Get()
        {
            $This.Status = Get-Service -Name $This.Name | % Status
            If (!($This.Status))
            {
                $This.Status = "NotInstalled"
            }
        }
        Start()
        {
            Write-Theme "Starting [~] $($This.Name)"
            Start-Service -Name $This.Name -Verbose
            Start-Sleep 1
            $This.Get()
        }
        Stop()
        {
            Write-Theme "Stopping [~] $($This.Name)"
            Stop-Service -Name $This.Name -Force -Verbose
            Start-Sleep 1
            $This.Get()
        }
    }

    Class IISFeature
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [UInt32] $Installed
        IISFeature([UInt32]$Index,[Object]$Feature)
        {
            $This.Index       = $Index
            $This.Name        = $Feature.Name
            $This.Description = $Feature.Description 
            $This.Installed   = $Feature.Installed
        }
    }

    Class IISFeatures
    {
        Hidden [Object] $Query
        Hidden [String[]] $Features = ("BITS BITS-IIS-Ext DSC-Service FS-SMBBW ManagementOData Net-Framework-45-ASPN" +
                                "et Net-WCF-HTTP-Activation45 RSAT-BITS-Server WAS WAS-Config-APIs WAS-Proces" +
                                "s-Model WebDAV-Redirector {0}App-Dev {0}AppInit {0}Asp-Net45 {0}Basic-Auth {" + 
                                "0}Common-Http {0}Custom-Logging {0}DAV-Publishing {0}Default-Doc {0}Digest-A" + 
                                "uth {0}Dir-Browsing {0}Errors {0}Filtering {0}Health {0}Includes {0}Logging " +
                                "{0}Log-Libraries {0}Metabase {0}Mgmt-Console {0}Net-Ext45 {0}Performance {0}" +
                                "Redirect {0}Request-Monitor {0}Security {0}Stat-Compression {0}Static-Conten" + 
                                "t {0}Tracing {0}Url-Auth {0}WebServer {0}Windows-Auth Web-ISAPI-Ext Web-ISAP" +
                                "I-Filter Web-Server WindowsPowerShellWebAccess") -f "Web-HTTP-" -Split " "
        [Object]    $Output
        [Object]   $Install
        IISFeatures()
        {
            $This.Query      = Get-WindowsFeature | ? Name -in $This.Features
            $This.Install    = @( )
            $This.Output     = @( )
            ForEach ( $X in 0..($This.Query.Count - 1))
            { 
                $This.Output += [IISFeature]::New($This.Output.Count,$This.Query[$X])
            }
        }
        Installed([Object]$Feature)
        {
            $This.Install    += $Feature
        }
    }

    Class IISConfigItem
    {
        Hidden [Hashtable] $Splat
        [String]$PSPath
        [String]$Location
        [String]$Filter
        [String]$Name
        [Object]$Value
        IISConfigItem([String]$PSPath,[String]$Location,[String]$Filter,[String]$Name,[Object]$Value)
        {
            $This.PSPath   = $PSPath
            $This.Location = $Location
            $This.Filter   = $Filter
            $This.Name     = $Name
            $This.Value    = $Value
            $This.Splat    = @{

                PSPath     = $PSPath
                Location   = $Location
                Filter     = $Filter
                Name       = $Name
                Value      = $Value
            }
        }
        Set()
        {
            $Item          = $This.Splat
            Set-WebConfigurationProperty @Item -Verbose
        }
    }

    $Features = [IISFeatures]::New()

    If ($Features.Output | ? Installed -eq 0)
    {
        Write-Theme "Installing [~] IIS Features"

        ForEach ($Item in $Features.Output)
        {
            $Count = "$($Item.Index+1)/$($Features.Output.Count)"
            Switch ($Item.Installed)
            {
                0
                {
                    Write-Theme $Item -Title Installing -Prompt "Installing $($Item.Name) ($Count)"
                    $Item = Install-WindowsFeature -Name $Item.Name -IncludeAllSubFeature -IncludeManagementTools
                    $Features.Installed($Item)
                }
                1
                {
                    Write-Theme "Installed [+] $($Item.Name) ($Count)"
                }
            }
        }

        If (($Features.Install | ? RestartNeeded -eq Yes) -or !(Get-Service | ? Name -eq MRxDAV))
        {
            Switch([System.Windows.MessageBox]::Show("A system restart is needed to continue","Proceed?","YesNo"))
            {
                No  { Break            } 
                Yes { Restart-Computer } # Insert Scheduled task to run on restart and then remove the entry after it commences
            }
        }
    }

    Import-Module -Name WebAdministration -Verbose -Force

    Class IIS
    {
        [String]            $SiteName
        [String]         $AppPoolName
        [String]     $VirtualHostname
        [String]    $PSDeploymentRoot
        [String]  $PSVirtualDirectory
        [String]                 $URL
        [Object]                $Site
        [Object]            $Services
        [Object]              $Config
        [String]              $System = $Env:SystemDrive
        [String]            $System32 = "$Env:SystemRoot\System32"
        [String]            $Hostname = $Env:ComputerName
        [String]                $Date = (Get-Date -UFormat "%m-%d-%Y")
        [String]             $LogPath = "$Env:Temp\ACL"
        [String]             $IISRoot
        [String]         $AppDataRoot
        [String]             $IISPath
        [String]         $AppPoolPath
        [Object] $VirtualWebDirectory
        [String]             $AppHost = 'MACHINE/WEBROOT/APPHOST'
        [String]                $Base
        [String]                $Full
        IIS([String]$SiteName,[String]$AppPoolName,[String]$VirtualHostname,[String]$PSDeploymentRoot,[String]$PSVirtualDirectory)
        {
            $This.SiteName           = $SiteName
            $This.AppPoolName        = $AppPoolName
            $This.VirtualHostname    = $VirtualHostname
            $This.PSDeploymentRoot   = $PSDeploymentRoot
            $This.PSVirtualDirectory = $PSVirtualDirectory
            $This.Services           = "MRxDAV","WebClient","WAS","W3SVC" | % { [IISService]$_ }
            $This.Config             = @( )
            $This.IISRoot            = $This.System, "inetpub", $This.SiteName -join '\'
            $This.AppDataRoot        = $This.IISRoot, "AppData" -join '\'
            $This.IISPath            = "IIS:\Sites\$SiteName" 
            $This.AppPoolPath        = "IIS:\AppPools\$AppPoolName"
            If (Get-CimInstance Win32_ComputerSystem | % PartOfDomain)
            {
                $This.URL            = "{0}-$Env:ComputerName.{1}" -f $VirtualHostName,$Env:UserDNSDomain.toLower()
            }
            Else
            {
                $This.URL            = ""
            }
            $This.AppHost            = "MACHINE/WEBROOT/APPHOST"
            $This.Base               = "$($This.SiteName)/"
            $This.Full               = "$($This.SiteName)/$($This.PSVirtualDirectory)"
        }
        GetServices()
        {
            $This.Services | % { $_.Get() }
        }
        SetServices()
        {
            $This.Services | % { Set-Service $_.Name -StartupType Automatic -Verbose }
        }
        StartServices()
        {
            ForEach ($Item in $This.Services)
            {
                If ($Item.Status -ne "Running")
                {
                   $Item.Start()
                }
            }
            $This.GetServices()
        }
        StopServices()
        {
            ForEach ($Item in $This.Services)
            {
                If ($Item.Status -ne "Stopped")
                {
                   $Item.Stop()
                }
            }
            $This.GetServices()
        }
        Root()
        {
            ForEach ($Item in $This.IISRoot, $This.AppDataRoot)
            {
                If (!(Test-Path $Item))
                {
                    New-Item $Item -ItemType Directory -Verbose
                }
            }
        }
        AddConfig([String]$PSPath,[String]$Location,[String]$Filter,[String]$Name,[Object]$Value)
        {
            $This.Config += [IISConfigItem]::New($PSPath,$Location,$Filter,$Name,$Value)
        }
        SetACL([String]$Path,[Object]$ACL)
        {
            (Get-ACL -Path $Path).AddAccessRule($ACL) | % { Set-ACL -Path $Path -ACLObject $_ -Verbose }
        }
    }

    $Master = [IIS]::New($SiteName,$AppPoolName,$VirtualHostName,$PSDeploymentRoot,$PSVirtualDirectory)
    $Master.Root()

    $Site = Get-WebSite | ? Name -eq "Default Web Site"
    $Site | Stop-WebSite
    $Site.ServerAutoStart = $False

    # [Services]
    $Master.GetServices()
    $Master.StartServices()
    If (($Master.Services | ? Status -eq Running).Count -ne 4)
    {
        $Services = $Master.Services | ? Status -eq Running
        Write-Theme "Service(s) [$($Services.Name -join ', ')] not running"
        Break
    }
    $Master.SetServices()

    # [AppPool]
    If (Test-Path $Master.AppPoolPath)
    {
        Remove-Item $Master.AppPoolPath -Recurse -Verbose -Confirm:$False -Force
    }
    New-WebAppPool -Name $Master.AppPoolName -Force -Verbose

    ForEach ($I in 0..2)
    {
        $Name, $Value = ("Enable32BitAppOnWin64 True;ManagedRuntimeVersion v4.0;ManagedPipelineMode Integrated" -Split ";")[$I] -Split " "
        Set-ItemProperty -Path $Master.AppPoolPath -Name $Name -Value $Value -Verbose
    }

    Restart-WebAppPool -Name $Master.AppPoolName -Verbose

    # [Site]
    Get-Website | ? Name -eq $Master.SiteName | Remove-Website -Verbose
    New-Website -Name $Master.SiteName -ApplicationPool $Master.AppPoolName -PhysicalPath $Master.IISRoot -Verbose | Start-Website -Verbose
    
    Set-WebBinding -Name $Master.SiteName -HostHeader "" -PropertyName HostHeader -Value $Master.URL -Verbose

    $Master.Site = Get-WebBinding | ? BindingInformation -Match $Master.URL

    # [VirtualWebDirectory]
    Get-WebVirtualDirectory -Name $Master.PSVirtualDirectory | % {

        $ItemX       = $_.ItemXPath -Split "(\[|\])" -Replace "(\[|\])","" | ? Length -gt 0
        $Site        = $ItemX[1].Split("'")[1]
        $Application = $ItemX[3].Split("'")[1]
        Remove-Item "IIS:\Sites\$Site\$Application\$($Master.PSVirtualDirectory)" -Recurse -Confirm:$False -Force -Verbose
    }

    $Master.VirtualWebDirectory = New-WebVirtualDirectory -Site $Master.SiteName -Name $Master.PSVirtualDirectory -PhysicalPath $Master.PSDeploymentRoot -Force -Verbose

    # [WebConfiguration]
    $Authoring       = "system.webserver/webdav/authoring"
    $Master.AddConfig($Master.AppHost,$Master.Base,$Authoring,"Enabled",$True)
    $Master.Config[0].Set()

    $Splat           = @{
        
        FilePath     = "{0}\inetsrv\appcmd.exe" -f $Master.System32
        ArgumentList = "Set Config `"{0}/{1}`" /section:{2}Rules /+[users='*',path='*',access='Read,Source'] /commit:apphost" -f $Master.SiteName, $Master.PSVirtualDirectory, $Authoring
    }

    # [AppHost]
    "$env:Temp\SilentFile.txt" | % { Start-Process @Splat -NoNewWindow -RedirectStandardOutput $_ -Wait; Get-Content $_; Remove-Item $_ }

    # [MimeType]
    $Splat           = @{ PSPath = "IIS:\Sites\$($Master.SiteName)\$($Master.PSVirtualDirectory)"; Filter = "system.webServer/staticContent"; Name = "." } 
    If (".*" -notin (Get-WebConfigurationProperty @Splat | % Collection | % FileExtension) )
    {
        Add-WebConfigurationProperty @Splat -Value @{ fileExtension = '.*' ; mimeType = 'Text/Plain' } -Verbose
        Write-Theme "Applied [~] (Config) Mime Type (.*)" 10,2,15,0
    }

    # [Directory Browsing]
    Set-WebConfigurationProperty -PSPath "IIS:\Sites\$($Master.SiteName)\$($Master.PSVirtualDirectory)" -filter /system.webServer/directoryBrowse -name Enabled  -Value $True
	Write-Theme "Applied [+] (Config) Directory Browsing for $($Master.PSVirtualDirectory)" 10,2,15,0

    # [Authentication]
    $Authentication = "system.webServer/security/authentication"
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authentication/anonymousAuthentication","Enabled",$False)
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authentication/windowsAuthentication","Enabled",$True)
    $Master.Config[1].Set()
    $Master.Config[2].Set()
    Write-Theme "Applied [+] (Config) Anonymous/Windows Authentication" 10,2,15,0

	# [WebDAV Settings]
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Authoring`Rules","defaultMimeType","text/xml")
    $Master.Config[3].Set()
    Write-Theme "Applied [+] (Config) Default Mime Type" 10,2,15,0

    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authoring/properties","allowInfinitePropfindDepth",$True)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Authoring/properties","allowInfinitePropfindDepth",$True)
    $Master.Config[4].Set()
    $Master.Config[5].Set()
    Write-Theme "Applied [+] (Config) Infinite Property Search Depth" 10,2,15,0

    # [Security Request Filtering]
    $Security = "system.webServer/security/requestFiltering"
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Security/fileExtensions","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Security/fileExtensions","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Security/verbs","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Security/verbs","applytoWebDAV",$False)
    $Master.Config[6].Set()
    $Master.Config[7].Set()
    $Master.Config[8].Set()
    $Master.Config[9].Set()
    Write-Theme "Applied [+] (Config) Security Request Filtering" 10,2,15,0
	
    # [Hidden Segments] 
    Get-IISConfigSection -SectionPath $Security | Get-IISConfigElement -ChildElementName hiddenSegments | % {

        Set-IISConfigAttributeValue -ConfigElement $_ -AttributeName applyToWebDAV -AttributeValue $false
    }
	Write-Theme "Applied [+] (Config) Hidden Segments" 10,2,15,0

    ForEach ($Sam in "IIS_IUSRS","IUSR","IIS AppPool\$($Master.AppPoolName)")
    {     
        $Master.SetACL($Master.IISRoot,[System.Security.AccessControl.FileSystemAccessRule]::New($Sam,"ReadAndExecute","ContainerInherit,ObjectInherit","InheritOnly","Allow"))
    }

    ForEach ($Sam in "IIS_IUSRS","IIS AppPool\$($Master.AppPoolName)")
    {
        $Master.SetACL($Master.AppDataRoot,[System.Security.AccessControl.FileSystemAccessRule]::New($Sam,"Modify","ContainerInherit,ObjectInherit","InheritOnly","Allow"))
    }

    [SecurityChannel]::New() | Out-Null
    [TLS]::New() | Out-Null
}
