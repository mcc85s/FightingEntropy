<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDDeploymentShare.psd1
          Solution: PowerShell Deployment for MDT
          Purpose:  Deployment share commands (Troubleshooting/Connection)
          Author:   Original [PSD Development Team], 
                    Modified [mcc85s]
          Contact:  Original [@Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy]
                    Modified [@mcc85s]
          Primary:  Original [@Mikael_Nystrom]
                    Modified [@mcc85s]
          Created: 
          Modified: 2022-01-05

          Version - 0.0.0 - () - Finalized functional version 1.
.Example
#>

# Check for debug in PowerShell and TSEnv
If ($TSEnv:PSDDebug -eq "YES")
{
    $Global:PSDDebug = $true
}

If ($PSDDebug -eq $true)
{
    $verbosePreference = "Continue"
}

Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Importing module Bitstransfer"

Import-Module BitsTransfer -Scope Global -Force -Verbose:$False

# Local variables
$global:psddsDeployRoot     = ""
$global:psddsDeployUser     = ""
$global:psddsDeployPassword = ""
$global:psddsCredential     = ""

# Main function for establishing a connection 
Function Get-PSDConnection
{
    Param([String]$DeployRoot,[String]$Username,[String]$Password)

    # If these fields are mandatory, no need for these settings
    If (($Username -eq "\") -or ($Username -eq "")) 
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No UserID specified"
        $Username               = Get-PSDInputFromScreen -Header UserID -Message "Enter User ID [DOMAIN\Username] or [COMPUTER\Username]" -ButtonText Ok
        $tsenv:UserDomain       = $Username | Split-Path
        $tsenv:UserID           = $Username | Split-Path -Leaf
    }
    If ($Password -eq "")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No UserPassword specified"
        $Password               = Get-PSDInputFromScreen -Header UserPassword -Message "Enter Password"  -ButtonText Ok -PasswordText
        $tsenv:UserPassword     = $Password
    }
    Save-PSDVariables | Out-Null
    # Save values in local variables
    $Global:psddsDeployRoot     = $DeployRoot
    $Global:psddsDeployUser     = $Username
    $Global:psddsDeployPassword = $Password

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psddsDeployRoot is now $Global:psddsDeployRoot"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psddsDeployUser is now $Global:psddsDeployUser"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psddsDeployPassword is now $Global:psddsDeployPassword"

    # Get credentials
    If (!$Global:psddsDeployUser -or !$Global:psddsDeployPassword)
    {
        $Global:psddsCredential = Get-Credential -Message "Specify credentials needed to connect to $uncPath"
    }
    Else
    {
        $Secure                 = ConvertTo-SecureString $Global:psddsDeployPassword -AsPlainText -Force
        $Global:psddsCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:psddsDeployUser, $Secure
    }

    # Make sure we can connect to the specified location
    Switch -Regex ($Global:psddsDeployRoot)
    {
        "(http[s]*)"
        {
            # Get a copy of the Control folder
            $Cache                  = Get-PSDContent -Content Control
            $Root                   = Split-Path -Path $Cache -Parent

            # Get a copy of the Templates folder
            $null                   = Get-PSDContent -Content Templates

            # Connect to the cache
            Get-PSDProvider -DeployRoot $root
        }
        "(\\\\.+)"
        {
            # Connect to a UNC path
            Try
            {
                New-PSDrive -Name (Get-PSDAvailableDriveLetter) -PSProvider FileSystem -Root $global:psddsDeployRoot -Credential $global:psddsCredential -Scope Global
            }
            Catch
            {

            }
            Get-PSDProvider -DeployRoot $global:psddsDeployRoot
        }
        Default
        {
            # Connect to a local path (no credential needed)
            Get-PSDProvider -DeployRoot $global:psddsDeployRoot
        }
    }
}

# Internal function for initializing the MDT PowerShell provider, to be used to get 
# objects from the MDT deployment share.
Function Get-PSDProvider
{
    Param ([String]$DeployRoot)

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): deployRoot is now $deployRoot"

    # Set an install directory if necessary (needed so the provider can find templates)
    If (!(Test-Path "HKLM:\Software\Microsoft\Deployment 4"))
    {
        $null = New-Item "HKLM:\Software\Microsoft\Deployment 4" -Force
        Set-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" -Name "Install_Dir" -Value "$deployRoot\" -Force
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Set MDT Install_Dir to $deployRoot\ for MDT Provider."
    }

    # Set an install directory if necessary (needed so the provider can find templates)
    If (!(Test-Path "HKLM:\Software\Microsoft\Deployment 4\Install_Dir"))
    {
        Set-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" -Name "Install_Dir" -Value "$deployRoot\" -Force
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Set MDT Install_Dir to $deployRoot\ for MDT Provider."
    }

    # Load the PSSnapIn PowerShell provider module
    $modules = Get-PSDContent -Content "Tools\Modules"
    Import-Module "$modules\Microsoft.BDD.PSSnapIn" -Verbose:$False

    # Create the PSDrive
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating MDT provider drive DeploymentShare: at $deployRoot"
    $Result = New-PSDrive -Name DeploymentShare -PSProvider MDTProvider -Root $deployRoot -Scope Global
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating MDT provider drive $($Result.name): at $($result.Root)"
}

# Internal function for getting the next available drive letter.
Function Get-PSDAvailableDriveLetter
{
    $Drives  = (Get-PSDrive -PSProvider FileSystem).Name
    $Letters = [Char[]]@(90..65)
    ForEach ($Letter in $Letters)
    {
        If ($Drives -notcontains $Letter) 
        {
            Return $Letter
            Break
        }
    }
}

# Function for finding and retrieving the specified content.  The source location specifies
# a relative path within the deployment share.  The destination specifies the local path where
# the content should be placed.  If no destination is specified, it will be placed in a
# cache folder.
Function Get-PSDContent
{
    Param ([String]$Content, [String]$Destination = "")

    $Dest = ""

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Content:[$content], destination:[$destination]"

    # Track the time
    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Track the time"
    $Start = Get-Date

    # If the destination is blank, use a default value
    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): If the destination is blank, use a default value"
    If ($Destination -eq "")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Destination is blank, running $PSDLocalDataPath = Get-PSDLocalDataPath"
        $PSDLocalDataPath = Get-PSDLocalDataPath
        # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): PSDLocalDataPath is $PSDLocalDataPath"
        $Dest = "$PSDLocalDataPath\Cache\$Content"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Dest is $dest"
    }
    Else
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Destination is NOT blank"
        $Dest = $Destination
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Dest is $dest"
    }

    # If the destination already exists, assume the content was already downloaded.
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): If the destination already exists, assume the content was already downloaded."
    # Otherwise, download it, copy it, .
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Otherwise, download it, copy it."

    If (Test-Path $dest)
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Access to $dest is OK"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Already copied $content, not copying again."
    }
    ElseIf ($global:psddsDeployRoot -ilike "http*")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psddsDeployRoot is now $global:psddsDeployRoot"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Running Get-PSDContentWeb -content $content -destination $dest"
        Get-PSDContentWeb -content $content -destination $dest
    }
    ElseIf ($global:psddsDeployRoot -like "\\*")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): global:psddsDeployRoot is now $global:psddsDeployRoot"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Running Get-PSDContentUNC -content $content -destination $dest"
        Get-PSDContentUNC -content $content -destination $dest
    }
    Else
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Path for $content is already local, not copying again"
    }

    # Report the time
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Report the time"
    $Elapsed = (Get-Date) - $start
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Elapsed time to transfer $content : $elapsed"
    # Return the destination
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Return the destination $dest"
    Return $Dest
}

# Internal function for retrieving content from a UNC path (file share)
Function Get-PSDContentUNC
{
    Param ([String]$Content, [String]$Destination)

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Copying from $($global:psddsDeployRoot)\$content to $destination"
    Copy-PSDFolder "$($global:psddsDeployRoot)\$content" $destination
}

# Internal function for retrieving content from URL (web server/HTTP)
Function Get-PSDContentWeb
{
    Param([String]$Content,[String]$Destination)

    $maxAttempts    = 3
    $attempts       = 0
    $RetryInterval  = 5
    $Retry          = $True

    If ($tsenv:BranchCacheEnabled -eq "YES")
    {
        If ($tsenv:SMSTSDownloadProgram -ne "" -or $tsenv:SMSTSDownloadProgram -ne $null)
        {
            If ((Get-Process | ? Name -eq tsmanager).Count -ge 1)
            {    
                # Create the destination folder
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating $destination"
                Try
                {
                    New-Item -Path $destination -ItemType Directory -Force | Out-Null
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating $destination was a success"
                }
                Catch
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Creating $destination was a failure"
                    Return
                }

                # Make some calc...
                $FullSource = "$($global:psddsDeployRoot)/$content"
                $FullSource = $fullSource.Replace("\", "/")
                #$Request  = [System.Net.WebRequest]::Create($fullSource)
                $TopUri    = New-Object system.uri $fullSource
                #$PrefixLen = $TopUri.LocalPath.Length

                # We are using an ACP/ assume it works in WinPE as well. We use ACP as BITS does not function as regular BITS in WinPE, so cannot use PS cmdlet.
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Downloading files using ACP."

                # Begin create regular ACP style .ini file
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Create regular ACP style .ini file"

                #Needed, do not remove.
                $PSDPkgId = "PSD12345" 

                # Create regular ACP style .ini file
                $IniPath = "$env:tmp\$PSDPkgId"+"_Download.ini"
                Set-Content -Value '[Download]' -Path $IniPath -Force -Encoding Ascii
                Add-Content -Value "Source=$TopUri" -Path $IniPath
                Add-Content -Value "Destination=$Destination" -Path $IniPath
                Add-Content -Value "MDT=true" -Path $IniPath

                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Destination=$Destination"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Source=$TopUri"

                If ((Get-Process | ? Name -eq TSManager).Count -ne 0)
                {
                    Add-Content -Value "Username=$($tsenv:UserDomain)\$($tsenv:UserID)" -Path $IniPath
                    Add-Content -Value "Password=$($tsenv:UserPassword)" -Path $IniPath
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Username=$($tsenv:UserDomain)\$($tsenv:UserID)"
                }

                # ToDo, check that the ini file exists before we try...
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Downloading information saved to $IniPath so starting $tsenv:SMSTSDownloadProgram"

                If (Test-Path -Path $IniPath)
                {
                    #Start-Process -Wait -FilePath "$tsenv:SMSTSDownloadProgram" -ArgumentList "$iniPath $PSDPkgId `"$($destination)`""
                    $Return = Start-Process -Wait -WindowStyle Hidden -FilePath "$tsenv:SMSTSDownloadProgram" -ArgumentList "$IniPath $PSDPkgId `"$($Destination)`"" -PassThru
                    If ($Return.ExitCode -eq 0)
                    {
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $tsenv:SMSTSDownloadProgram Success"
                        $Retry = $False
                        Return
                    }
                    Else
                    {
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $tsenv:SMSTSDownloadProgram Fail with exitcode $($Return.ExitCode)" -Loglevel 2
                    }
                    # ToDo hash verification?
                }
                Else
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to access $IniPath, aborting..." -Loglevel 2
                    # Show-PSDInfo -Message "Unable to access $iniPath, aborting..." -Severity Information
                    # Start-Process PowerShell -Wait
                    # Exit 1
                }
            }
            Else
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to use ACP since TSManager is not running, using fallback"
            }
        }
    }

    While ($Retry)
    {
        $Attempts ++
        Try
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Retrieving directory listing of $FullSource via WebDAV."
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Attempt $Attempts of $maxAttempts"

            $FullSource             = "$($global:psddsDeployRoot)/$Content"
            $FullSource             = $FullSource.Replace("\", "/")
            $Request                = [System.Net.WebRequest]::Create($FullSource)
            $TopUri                 = New-Object System.Uri $FullSource
            $PrefixLen              = $TopUri.LocalPath.Length

            $Request.UserAgent      = "PSD"
            $Request.Method         = "PROPFIND"
            $Request.ContentType    = "text/xml"
            $Request.Headers.Set("Depth", "infinity")
            $Request.Credentials    = $global:psddsCredential

            $Response               = $Request.GetResponse()
            $Retry                  = $False
        }
        Catch
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to retrieve directory listing!"
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $($_.Exception.InnerException)"
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $Response"

            #$Message = "Unable to Retrieve directory listing of $($fullSource) via WebDAV. Error message: $($_.Exception.Message)"
            #Show-PSDInfo -Message "$($Message)" -Severity Error
            #Start-Process PowerShell -Wait
            #Break 

            If ($Attempts -ge $MaxAttempts)
            {
                Throw
            }
            Else
            {
                Start-Sleep -Seconds $RetryInterval
            }
        }
    }

	If ($Response -ne $null)
    {
        $Sr                  = New-Object System.IO.StreamReader -ArgumentList $Response.GetResponseStream(),[System.Encoding]::Default
        [Xml]$Xml            = $Sr.ReadToEnd()		

        # Get the list of files and folders, to make this easier to work with
    	$Results             = @()
        $Xml.Multistatus.Response | ? Href -ine $Url | % {
            $Uri             = New-Object System.Uri $_.Href
            $Dest            = $Uri.LocalPath.Replace("/","\").Substring($PrefixLen).Trim("\")
            $Obj             = [PSCustomObject]@{
                Href         = $_.Href
                Name         = $_.Propstat.Prop.Displayname
                IsCollection = $_.Propstat.Prop.IsCollection
                Destination  = $Dest
            }
            $Results        += $Obj
        }
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Directory listing retrieved with $($Results.Count) items."

        # Create the folder structure
        $Results             | ? IsCollection -eq 1 | Sort-Object Destination | % {
            $Folder          = "$Destination\$($_.Destination)"
            If (Test-Path $Folder)
            {
                # Already exists
            }
            Else
            {
                $null = MkDir $Folder
            }
        }

        # If possible, do the transfer using BITS.  Otherwise, download the files one at a time
        If ($env:SYSTEMDRIVE -eq "X:")
        {
            # In Windows PE, download the files one at a time using WebClient
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Downloading files using WebClient."
            $Wc                  = New-Object System.Net.WebClient
            $Wc.Credentials      = $global:psddsCredential
            $Results             | ? IsCollection -eq 0 | Sort-Object Destination | % {
                $Href            = $_.Href
                $FullFile        = "$Destination\$($_.Destination)"
                Try
                {
                    $Wc.DownloadFile($Href, $FullFile)
                }
                Catch
                {
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to download file $href."
                    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $($_.Exception.InnerException)"
                }
            }            
        }
        Else
        {
            # Create the list of files to download
            $SourceUrl             = @()
            $DestFile              = @()
            $Results               | ? IsCollection -eq 0 | Sort-Object Destination | % {
                $SourceUrl        += [String]$_.Href
                $FullFile          = "$Destination\$($_.Destination)"
                $DestFile         += [String]$FullFile
            }
            # Do the download using BITS
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Downloading files using BITS."
            $BitsJob = Start-BitsTransfer -Authentication Ntlm -Credential $global:psddsCredential -Source $SourceUrl -Destination $DestFile -TransferType Download -DisplayName "PSD Transfer" -Priority High
        }
    }
}

# Reconnection logic
If (Test-Path "tsenv:")
{
    If ($tsenv:DeployRoot -ne "")
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reconnecting to the deployment share at $($tsenv:DeployRoot)."
        If ($tsenv:UserDomain -ne "")
        {
            Get-PSDConnection -deployRoot $tsenv:DeployRoot -username "$($tsenv:UserDomain)\$($tsenv:UserID)" -password $tsenv:UserPassword
        }
        Else
        {
            Get-PSDConnection -deployRoot $tsenv:DeployRoot -username $tsenv:UserID -password $tsenv:UserPassword
        }
    }
}

Function Test-PSDContent
{
    Param ([string]$Content)

    If ($global:psddsDeployRoot -ilike "http*")
    {
        Return Test-PSDContentWeb -content $Content
    }
    If ($global:psddsDeployRoot -like "\\*")
    {
        Return Test-PSDContentUNC -content $Content
    }
}

Function Test-PSDContentWeb
{
    Param ([String]$Content)

    $maxAttempts     = 3
    $attempts        = 0
    $RetryInterval   = 5
    $Retry           = $True

    While($Retry)
    {
        $Attempts++
        Try
        {
            #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Retrieving directory listing of $fullSource via WebDAV."
            #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Attempt $attempts of $maxAttempts"

            $FullSource          = "$($global:psddsDeployRoot)/$content"
            $FullSource          = $FullSource.Replace("\", "/")
            $Request             = [System.Net.WebRequest]::Create($FullSource)
            $TopUri              = New-Object System.Uri $FullSource
            $PrefixLen           = $TopUri.LocalPath.Length

            $Request.UserAgent   = "PSD"
            $Request.Method      = "PROPFIND"
            $Request.ContentType = "text/xml"
            $Request.Headers.Set("Depth", "infinity")
            $Request.Credentials = $global:psddsCredential

            $Response            = $Request.GetResponse()
            $Retry               = $False
        }
        Catch
        {
            #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Unable to retrieve directory listing!"
            #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $($_.Exception.InnerException)"
            #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): $response"

            #$Message = "Unable to Retrieve directory listing of $($fullSource) via WebDAV. Error message: $($_.Exception.Message)"
            #Show-PSDInfo -Message "$($Message)" -Severity Error
            #Start-Process PowerShell -Wait
            #Break 

            If($Attempts -ge $MaxAttempts)
            {
                Throw
            }
            Else
            {
                Start-Sleep -Seconds $RetryInterval
            }
        }
    }

	If ($Response -ne $null)
    {
        $Sr                       = New-Object System.IO.StreamReader -ArgumentList $Response.GetResponseStream(),[System.Encoding]::Default
        [Xml]$Xml                 = $sr.ReadToEnd()		

        # Get the list of files and folders, to make this easier to work with
    	$Results                  = @()
        $Xml.Multistatus.Response | ? Href -ine $Url | % {
            $Uri                  = New-Object System.Uri $_.Href
            $Dest                 = $Uri.LocalPath.Replace("/","\").Substring($PrefixLen).Trim("\")
            $Obj                  = [PSCustomObject]@{
                Href              = $_.Href
                Name              = $_.Propstat.Prop.Displayname
                IsCollection      = $_.Propstat.Prop.IsCollection
                Destination       = $Dest
            }
            $Results             += $Obj
        }
    }
    Return $Results
}

Function Test-PSDContentUNC
{
    Param ([String]$Content)

    Get-ChildItem "$($global:psddsDeployRoot)\$Content"
}

Export-ModuleMember -Function Get-PSDConnection
Export-ModuleMember -Function Get-PSDContent
Export-ModuleMember -Function Test-PSDContent
