<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 10:05:38                                                                  //
 \\==================================================================================================// 

    FileName   : Install-IISServer.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : To (install/stage/configure) an IIS Server for:
                 [-] Microsoft Deployment Toolkit
                 [-] PowerShell Deployment modification
                 [-] FightingEntropy
                 [-] In general
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Edited 12/14/22

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

    # // ===========
    # // | IsAdmin |
    # // ===========

    $OS = Get-CimInstance Win32_OperatingSystem
    $ID = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    If (!($ID.IsInRole("Administrator") -or $ID.IsInRole("Administrators")))
    {
        If ([UInt32]$OS.BuildNumber -ge 6000)
        {
            Write-Host "Not running as admin, attempting elevation..."
            $Command = $MyInvocation | % { "-File `"{0} {1}`"; Exit" -f $_.MyCommand.Path, $_.UnboundArguments }
            Start-Process PowerShell -Verb Runas -Args $Command
        }
        Else
        {
            Throw "Must run as an administrator."
        }
    }

    # // ============
    # // | IsServer |
    # // ============

    If ($OS.Caption -notmatch "Windows Server")
    {
        Throw "Not a valid Windows Server operating system"
    }

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
            Write-Host "Starting [~] Service: [$($This.Name)]"
            Start-Service -Name $This.Name -Verbose
            Start-Sleep 1
            $This.Get()
        }
        Stop()
        {
            Write-Host "Stopping [~] Service: [$($This.Name)]"
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
        [Object]    $Output
        [Object]   $Install
        IISFeatures()
        {
            $This.Install    = @( )
            $This.Output     = @( )

            ForEach ($Item in Get-WindowsFeature | ? Name -in $This.Features())
            { 
                $This.Output += [IISFeature]::New($This.Output.Count,$Item)
            }
        }
        [String[]] Features()
        {
            $Out = ("BITS BITS-IIS-Ext DSC-Service FS-SMBBW ManagementOData Net-Framewor"+
            "k-45-ASPNet Net-WCF-HTTP-Activation45 RSAT-BITS-Server WAS WAS-Config-APIs "+
            "WAS-Process-Model WebDAV-Redirector {0}App-Dev {0}AppInit {0}Asp-Net45 {0}B"+
            "asic-Auth {0}Common-Http {0}Custom-Logging {0}DAV-Publishing {0}Default-Doc"+
            " {0}Digest-Auth {0}Dir-Browsing {0}Errors {0}Filtering {0}Health {0}Include"+
            "s {0}Logging {0}Log-Libraries {0}Metabase {0}Mgmt-Console {0}Net-Ext45 {0}P"+
            "erformance {0}Redirect {0}Request-Monitor {0}Security {0}Stat-Compression {"+
            "0}Static-Content {0}Tracing {0}Url-Auth {0}WebServer {0}Windows-Auth Web-IS"+
            "API-Ext Web-ISAPI-Filter Web-Server WindowsPowerShellWebAccess") 
            
            Return $Out -f "Web-HTTP-" -Split " "
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
        Write-Host "Installing [~] IIS Features"

        ForEach ($Item in $Features.Output)
        {
            $Count = "$($Item.Index+1)/$($Features.Output.Count)"
            Switch ($Item.Installed)
            {
                0
                {
                    Write-Host "Installing [~] ($Count) Feature: [$($Item.Name)]"
                    $Item = Install-WindowsFeature -Name $Item.Name -IncludeAllSubFeature -IncludeManagementTools
                    $Features.Installed($Item)
                }
                1
                {
                    Write-Host "Installed [+] ($Count) Feature: [$($Item.Name)]"
                }
            }
        }

        If (($Features.Install | ? RestartNeeded -eq Yes) -or !(Get-Service | ? Name -eq MRxDAV))
        {
            Switch([System.Windows.MessageBox]::Show("A system restart is needed to continue","Proceed?","YesNo"))
            {
                No  { Break            } 
                Yes 
                {
                    # Insert Scheduled task to run on restart and then remove the entry after it commences,
                    # not unlike how the Vault 7 C.I.A. tool (Assassin/After Midnight) works

                    Restart-Computer 
                }
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
        [String]                $Date = [DateTime]::Now.ToString("mm-dd-yyyy")
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
            $This.IISRoot            = "{0}\inetpub\{1}" -f $This.System, $This.SiteName
            $This.AppDataRoot        = "{0}\AppData" -f $This.IISRoot
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
        [Object] NewAcl([String]$ID,[String]$Mod,[String]$Inherit,[String]$Prop,[String]$Type)
        {
            Return [System.Security.AccessControl.FileSystemAccessRule]::New($ID,$Mod,$Inherit,$Prop,$Type)
        }
        [String] ApphostConfig([String]$Sitename,[String]$VirtualDirectory)
        {
            $Str = "Set Config `"{0}/{1}`" /section:{2}Rules /+[users='*',path='*',access='Read,Source'] /commit:apphost"
            Return $Str -f $SiteName, $VirtualDirectory, "system.webserver/webdav/authoring"
        }
    }

    $Master = [IIS]::New($SiteName,$AppPoolName,$VirtualHostName,$PSDeploymentRoot,$PSVirtualDirectory)
    $Master.Root()

    $Site = Get-WebSite | ? Name -eq "Default Web Site"
    $Site | Stop-WebSite
    $Site.ServerAutoStart = $False

    # // ============
    # // | Services |
    # // ============

    $Master.GetServices()
    $Master.StartServices()
    If (($Master.Services | ? Status -eq Running).Count -ne 4)
    {
        $Services = $Master.Services | ? Status -eq Running
        Write-Host "Service(s) [!] [$($Services.Name -join ', ')] not running"
        Break
    }

    $Master.SetServices()

    # // ===========
    # // | AppPool |
    # // ===========

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

    # // ========
    # // | Site |
    # // ========

    Get-Website | ? Name -eq $Master.SiteName | Remove-Website -Verbose
    New-Website -Name $Master.SiteName -ApplicationPool $Master.AppPoolName -PhysicalPath $Master.IISRoot -Verbose | Start-Website -Verbose
    
    Set-WebBinding -Name $Master.SiteName -HostHeader "" -PropertyName HostHeader -Value $Master.URL -Verbose

    $Master.Site = Get-WebBinding | ? BindingInformation -Match $Master.URL

    # // =======================
    # // | VirtualWebDirectory |
    # // =======================

    Get-WebVirtualDirectory -Name $Master.PSVirtualDirectory | % {

        $ItemX       = $_.ItemXPath -Split "(\[|\])" -Replace "(\[|\])","" | ? Length -gt 0
        $Site        = $ItemX[1].Split("'")[1]
        $Application = $ItemX[3].Split("'")[1]
        Remove-Item "IIS:\Sites\$Site\$Application\$($Master.PSVirtualDirectory)" -Recurse -Confirm:$False -Force -Verbose
    }

    $Splat           = @{ 

        Site         = $Master.SiteName
        Name         = $Master.PSVirtualDirectory
        PhysicalPath = $Master.PSDeploymentRoot
    }

    $Master.VirtualWebDirectory = New-WebVirtualDirectory @Splat -Force -Verbose

    # // ====================
    # // | WebConfiguration |
    # // ====================

    $Authoring       = "system.webserver/webdav/authoring"
    $Master.AddConfig($Master.AppHost,$Master.Base,$Authoring,"Enabled",$True)
    $Master.Config[0].Set()

    $Splat           = @{
        
        FilePath     = "{0}\inetsrv\appcmd.exe" -f $Master.System32
        ArgumentList = $Master.ApphostConfig($Master.SiteName,$Master.PSVirtualDirectory)
    }

    # // ===========
    # // | AppHost |
    # // ===========

    ForEach ($Item in "$env:Temp\SilentFile.txt")
    {
        Start-Process @Splat -NoNewWindow -RedirectStandardOutput $Item -Wait
        [System.IO.File]::ReadAllLines($Item)
        [System.IO.File]::Delete($Item)
        $Item = $Null
    }

    # // ============
    # // | MimeType |
    # // ============

    $Splat           = @{ 
        
        PSPath       = "IIS:\Sites\$($Master.SiteName)\$($Master.PSVirtualDirectory)"
        Filter       = "system.webServer/staticContent"
        Name         = "." 
    }

    If (".*" -notin (Get-WebConfigurationProperty @Splat | % Collection | % FileExtension) )
    {
        Add-WebConfigurationProperty @Splat -Value @{ fileExtension = '.*' ; mimeType = 'Text/Plain' } -Verbose
        Write-Host "Applied [~] (Config) Mime Type (.*)"
    }

    # // ======================
    # // | Directory Browsing |
    # // ======================

    Set-WebConfigurationProperty -PSPath "IIS:\Sites\$($Master.SiteName)\$($Master.PSVirtualDirectory)" -filter /system.webServer/directoryBrowse -name Enabled  -Value $True
	Write-Host "Applied [+] (Config) Directory Browsing for $($Master.PSVirtualDirectory)"

    # // ==================
    # // | Authentication |
    # // ==================

    $Authentication = "system.webServer/security/authentication"
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authentication/anonymousAuthentication","Enabled",$False)
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authentication/windowsAuthentication","Enabled",$True)
    $Master.Config[1].Set()
    $Master.Config[2].Set()
    Write-Host "Applied [+] (Config) Anonymous/Windows Authentication"

    # // ===================
    # // | WebDAV Settings |
    # // ===================

    $Master.AddConfig($Master.AppHost,$Master.Base,"$Authoring`Rules","defaultMimeType","text/xml")
    $Master.Config[3].Set()
    Write-Host "Applied [+] (Config) Default Mime Type"

    $Master.AddConfig($Master.AppHost,$Master.Full,"$Authoring/properties","allowInfinitePropfindDepth",$True)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Authoring/properties","allowInfinitePropfindDepth",$True)
    $Master.Config[4].Set()
    $Master.Config[5].Set()
    Write-Host "Applied [+] (Config) Infinite Property Search Depth"

    # // ==============================
    # // | Security Request Filtering |
    # // ==============================

    $Security = "system.webServer/security/requestFiltering"
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Security/fileExtensions","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Security/fileExtensions","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Full,"$Security/verbs","applytoWebDAV",$False)
    $Master.AddConfig($Master.AppHost,$Master.Base,"$Security/verbs","applytoWebDAV",$False)
    $Master.Config[6].Set()
    $Master.Config[7].Set()
    $Master.Config[8].Set()
    $Master.Config[9].Set()
    Write-Host "Applied [+] (Config) Security Request Filtering"
	
    # // ===================
    # // | Hidden Segments |
    # // ===================

    Get-IISConfigSection -SectionPath $Security | Get-IISConfigElement -ChildElementName hiddenSegments | % {

        Set-IISConfigAttributeValue -ConfigElement $_ -AttributeName applyToWebDAV -AttributeValue $false
    }
	Write-Host "Applied [+] (Config) Hidden Segments"

    ForEach ($Sam in "IIS_IUSRS","IUSR","IIS AppPool\$($Master.AppPoolName)")
    {     
        $Master.SetACL($Master.IISRoot,$This.NewAcl($Sam,"ReadAndExecute","ContainerInherit,ObjectInherit","InheritOnly","Allow"))
    }

    ForEach ($Sam in "IIS_IUSRS","IIS AppPool\$($Master.AppPoolName)")
    {
        $Master.SetACL($Master.AppDataRoot,$This.NewAcl($Sam,"Modify","ContainerInherit,ObjectInherit","InheritOnly","Allow"))
    }

    [Void][SecurityChannel]::New()
    [Void][TLS]::New()
}
