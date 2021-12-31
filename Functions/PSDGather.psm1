<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDGather.psm1
          Solution: PowerShell Deployment for MDT
          Purpose:  Module for Wmi queries & processing rules into [tsenv:\] variables.
          Author:   Original [PSD Development Team], 
                    Modified [mcc85s]
          Contact:  Original [@Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy]
                    Modified [@mcc85s]
          Primary:  Original [@Mikael_Nystrom]
                    Modofied [@mcc85s]
          Created: 
          Modified: 2021-12-31

          Version - 0.0.0 - () - Finalized functional version 1.
.Example
#>

# Check for debug in PowerShell and TSEnv
If ($TSEnv:PSDDebug -eq "YES")
{
    $Global:PSDDebug = $true
}

If ($PSDDebug -eq $True)
{
    $verbosePreference = "Continue"
}

Function Get-PSDLocalInfo
{
    Process
    {
        # Look up OS details
        $tsenv:IsServerCoreOS         = "False"
        $tsenv:IsServerOS             = "False"

        Get-WmiObject Win32_OperatingSystem | % { $tsenv:OSCurrentVersion = $_.Version; $tsenv:OSCurrentBuild = $_.BuildNumber }
        If (Test-Path HKLM:System\CurrentControlSet\Control\MiniNT) 
        {
            $tsenv:OSVersion          = "WinPE"
        }
        Else
        {
            $tsenv:OSVersion          = "Other"
            If (Test-Path "$env:WINDIR\Explorer.exe") 
            {
                $tsenv:IsServerCoreOS = "True"
            }
            
            If (Test-Path HKLM:\System\CurrentControlSet\Control\ProductOptions\ProductType)
            {
                $ProductType          = Get-Item HKLM:System\CurrentControlSet\Control\ProductOptions\ProductType
                If ($ProductType -match "(ServerNT|LanmanNT)")
                {
                    $tsenv:IsServerOS = "True"
                }
            }
        }

        # Look up network details
        $ipList                   = @()
        $macList                  = @()
        $gwList                   = @()

        $Config                   = Get-WmiObject Win32_NetworkAdapterConfiguration | ? IPEnabled
        $Config                     | % {
            $_.IPAddress            | % {  $ipList += $_ }
            $_.MacAddress           | % { $macList += $_ }
            If ($_.DefaultIPGateway) 
            {
                $_.DefaultIPGateway | % {  $gwList += $_ }
            }
        }

        $tsenvlist:IPAddress      = $ipList
        $tsenvlist:MacAddress     = $macList
        $tsenvlist:DefaultGateway = $gwList

        # Look up asset information
        $tsenv:IsDesktop          = "False"
        $tsenv:IsLaptop           = "False"
        $tsenv:IsServer           = "False"
        $tsenv:IsSFF              = "False"
        $tsenv:IsTablet           = "False"

        Get-WmiObject Win32_SystemEnclosure | % {
            $tsenv:AssetTag       = $_.SMBIOSAssetTag.Trim()
            Switch($_.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {$tsenv:IsLaptop  = "True"}
                {$_ -in 3..7+15,16}     {$tsenv:IsDesktop = "True"}
                {$_ -in 23}             {$tsenv:IsServer  = "True"}
                {$_ -in 34..36}         {$tsenv:IsSFF     = "True"}
                {$_ -in 30..32+13}      {$tsenv:IsTablet  = "True"}
            }
        }

        Get-WmiObject Win32_BIOS | % {
            $tsenv:SerialNumber  = $_.SerialNumber.Trim()
        }

        If ($env:PROCESSOR_ARCHITEW6432) 
        {
            If ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") 
            {
                $tsenv:Architecture = "x64"
            }
            Else 
            {
                $tsenv:Architecture = $env:PROCESSOR_ARCHITEW6432.ToUpper()
            }
        }
        Else 
        {
            If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") 
            {
                $tsenv:Architecture = "x64"
            }
            Else 
            {
                $tsenv:Architecture = $env:PROCESSOR_ARCHITECTURE.ToUpper()
            }
        }

        Get-WmiObject Win32_Processor | % {
            $tsenv:ProcessorSpeed     = $_.MaxClockSpeed
            $tsenv:SupportsSLAT       = $_.SecondLevelAddressTranslationExtensions
        }

        # TODO: Capable architecture
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Capable architecture" 

        Get-WmiObject Win32_ComputerSystem | % {
            $tsenv:Make               = $_.Manufacturer
            $tsenv:Model              = $_.Model
            $tsenv:Memory             = [UInt32]($_.TotalPhysicalMemory/1024/1024)
        }

        Get-WmiObject Win32_ComputerSystemProduct | % {
            $tsenv:UUID               = $_.UUID
        }
    
        Get-WmiObject Win32_BaseBoard | % {
            $tsenv:Product            = $_.Product
        }

        # UEFI
        Try
        {
            Get-SecureBootUEFI -Name SetupMode | Out-Null
            $tsenv:IsUEFI             = "True"
        }
        Catch
        {
            $tsenv:IsUEFI             = "False"
        }

        # TEST: Battery
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TEST: Battery" 

        $bFoundAC                     = $False
        $bOnBattery                   = $False
        $bFoundBattery                = $False
        ForEach ($Battery in (Get-WmiObject -Class Win32_Battery))
        {
            $bFoundBattery            = $True
            If ([UInt32]$Battery.BatteryStatus -eq 2)
            {
                $bFoundAC             = $True
            }
        }
        If ($bFoundBattery -and !$bFoundAC)
        {
            $tsenv.IsOnBattery        = $True
        }
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): bFoundAC: $bFoundAC" 
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): bOnBattery :$bOnBattery" 
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): bFoundBattery: $bFoundBattery"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv.IsOnBattery is now $($tsenv.IsOnBattery)"

        # TODO: GetDP
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: GetDP" 

        # TODO: GetWDS
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: GetWDS" 

        # TODO: GetHostName
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: GetHostName" 
        
        # TODO: GetOSSKU
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: GetOSSKU" 

        # TODO: GetCurrentOSInfo
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: GetCurrentOSInfo" 

        # TODO: Virtualization
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TEST: Virtualization" 
    
        $Win32_ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
        $tsenv:IsVm           = Switch ($Win32_ComputerSystem.model)
        {
            "Virtual Machine" {"True"} "VMware Virtual Platform" {"True"} "VMware7,1" {"True"} "Virtual Box" {"True"} Default {"False"}
        }

        
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Model is $($Win32_ComputerSystem.model)" 
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): tsenv:IsVM is now $tsenv:IsVM" 
        
        # TODO: BitLocker
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: BitLocker" 
    }
}

Function Invoke-PSDRules
{
    [CmdletBinding()] 
    Param( 
        [ValidateNotNullOrEmpty()][Parameter(ValueFromPipeline,Mandatory)] 
        [String]$FilePath,
        [ValidateNotNullOrEmpty()][Parameter(ValueFromPipeline,Mandatory)] 
        [String]$MappingFile)

    Begin
    {
        $Global:iniFile               = Get-IniContent $FilePath
        [Xml]$Global:variableFile     = Get-Content $MappingFile

        # Process custom properties
        If ($Global:iniFile["Settings"]["Properties"])
        {
            $Global:iniFile["Settings"]["Properties"].Split(",").Trim() | % {

                $newVar               = $Global:variableFile.properties.property[0].Clone()
                If ($_.EndsWith("(*)"))
                {
                  $newVar.id          = $_.Replace("(*)","")
                  $newVar.type        = "list"
                }
                Else
                {
                  $newVar.id          = "$_"
                  $newVar.type        = "string"
                }
                $newVar.overwrite     = "false"
                $newVar.description   = "Custom property"
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Adding custom property $($newVar.id)" 
                $null                 = $Global:variableFile.properties.appendChild($newVar)
            }
        }
        $Global:variables             = $Global:variableFile.properties.property
    }
    Process
    {
        $Global:iniFile["Settings"]["Priority"].Split(",").Trim() | Invoke-PSDRule
    }
}

Function Invoke-PSDRule
{
    [CmdletBinding()] 
    Param(
        [ValidateNotNullOrEmpty()][Parameter(ValueFromPipeline,Mandatory)] 
        [String]$RuleName)

    Begin
    {

    }
    Process
    {
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing rule $RuleName" 

        $v                     = $global:variables | ? id -ieq $RuleName
        If ($RuleName.ToUpper() -eq "DEFAULTGATEWAY") 
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Process default gateway" 
        }
        ElseIf ($v) 
        {
            If ($v.type -eq "list") 
            {
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing values of $RuleName" 
                (Get-Item tsenvlist:$($v.id)).Value | Invoke-PSDRule
            }
            Else
            {
                $s = (Get-Item tsenv:$($v.id)).Value
                If ($s -ne "")
                {
                  Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing value of $RuleName" 
                  Invoke-PSDRule $s
                }
                Else
                {
                  Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Skipping rule $RuleName, value is blank" 
                }
            }
        }
        Else
        {
            Get-PSDSettings $global:iniFile[$RuleName]
        }
    }
}

Function Get-PSDSettings
{
    [CmdletBinding()]Param($Section) 
    Begin
    {

    }
    Process
    {
        $skipProperties = $False

        # Exit if the section doesn't exist
        If (!$Section)
        {
            Return
        }

        # Process special sections and exits
        If ($Section.Contains("UserExit"))
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Process UserExit Before" 
        }

        If ($Section.Contains("SQLServer"))
        {
            $skipProperties = $True
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Database" 
        }

        If ($Section.Contains("WebService")) 
        {
            $skipProperties = $True
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: WebService" 
        }

        If ($Section.Contains("Subsection")) 
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing subsection" 
            Invoke-PSDRule $Section["Subsection"]
        }

        # Process properties
        If (!$skipProperties) 
        {	
            $Section.Keys          | % {
                $sectionVar        = $_
                $v                 = $Global:variables | ? id -ieq $sectionVar
                If ($v)
                {
                    If ((Get-Item tsenv:$v).Value -eq $Section[$sectionVar])
                    {
                      # Do nothing, value unchanged
                    }
                    If ((Get-Item tsenv:$v).Value -eq "" -or $v.overwrite -eq "true") 
                    {
                        $Value     = $((Get-Item tsenv:$($v.id)).Value)
                        If ($value -eq '')
                        {
                            $value = "EMPTY"
                        }
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Changing PROPERTY $($v.id) to $($section[$sectionVar]), was $Value" 
                        Set-Item tsenv:$($v.id) -Value $section[$sectionVar]
                    }
                    ElseIf ((Get-Item tsenv:$v).Value -ne "") 
                    {
                        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Ignoring new value for $($v.id)" 
                    }
                }
                Else
                {
                    $trimVar       = $sectionVar.TrimEnd("0","1","2","3","4","5","6","7","8","9")
                    $v             = $Global:variables | ? id -ieq $trimVar
                    If ($v)
                    {
                        If ($v.type -eq "list") 
                        {
                            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Adding $($section[$sectionVar]) to $($v.id)" 
                            $N     = @((Get-Item tsenvlist:$($v.id)).Value)
                            $N    += [String] $section[$sectionVar]
                            Set-Item tsenvlist:$($v.id) -Value $n
                        }
                    }
                }
            } 
        }

        If ($section.Contains("UserExit")) 
        {
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Process UserExit After" 
        }
    }
}

Function Get-IniContent
{ 
    <# 
    .Synopsis 
        Gets the content of an INI file 
         
    .Description 
        Gets the content of an INI file and returns it as a hashtable 
         
    .Notes 
        Author		: Oliver Lipkau <oliver@lipkau.net> 
        Blog		  : http://oliver.lipkau.net/blog/ 
      	Source		: https://github.com/lipkau/PsIni
			  http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
        Version		: 1.0 - 2010/03/12 - Initial release 
			  1.1 - 2014/12/11 - Typo (Thx SLDR); Typo (Thx Dave Stiff)
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Collections.Hashtable 
         
    .Parameter FilePath 
        Specifies the path to the input file. 
         
    .Example 
        $FileContent = Get-IniContent "C:\myinifile.ini" 
        ----------- 
        Description 
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent 
     
    .Example 
        $inifilepath | $FileContent = Get-IniContent 
        ----------- 
        Description 
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent 
     
    .Example 
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini" 
        C:\PS>$FileContent["Section"]["Key"] 
        ----------- 
        Description 
        Returns the key "Key" of the section "Section" from the C:\settings.ini file 
         
    .Link 
        Out-IniFile 
    #> 
     
    [CmdletBinding()]Param( 
        [ValidateNotNullOrEmpty()] 
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]
        [Parameter(ValueFromPipeline,Mandatory)] 
        [String]$FilePath)
     
    Begin 
    {
        # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Function started"
    } 
         
    Process 
    { 
        # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing file: $Filepath"
             
        $Ini                          = @{} 
        Switch -Regex -File $FilePath 
        { 
            "^\[(.+)\]$" # Section 
            { 
                $Section              = $Matches[1] 
                $Ini[$Section]        = @{} 
                $CommentCount         = 0 
            } 
            "^(;.*)$" # Comment 
            { 
                If (!$Section) 
                { 
                    $Section          = "No-Section" 
                    $ini[$Section]    = @{} 
                } 
                $Value                = $matches[1] 
                $CommentCount         = $CommentCount + 1 
                $Name                 = "Comment" + $CommentCount 
                $Ini[$Section][$Name] = $Value 
            }  
            "(.+?)\s*=\s*(.*)" # Key 
            { 
                If (!$Section)
                { 
                    $Section          = "No-Section" 
                    $Ini[$Section]    = @{} 
                } 
                $Name, $Value         = $Matches[1,2] 
                $Ini[$Section][$Name] = $Value 
            } 
        } 
        # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Finished Processing file: $FilePath" 
        # "^\[(.+)\]$" Section | "^(;.*)$" Comment | "(.+?)\s*=\s*(.*)" Key
        Return $Ini 
    } 
         
    End 
    {
        # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Function ended" 
    } 
}
