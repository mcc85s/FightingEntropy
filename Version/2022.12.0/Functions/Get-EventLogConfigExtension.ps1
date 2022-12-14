<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2022-12-14 14:19:11                                                                  //
 \\==================================================================================================// 

    FileName   : Get-EventLogConfigExtension.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : This function extends the functionality of the default EventLogConfig class,
                 and (imports/exports) that information
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-12-14
    Modified   : 2022-12-14
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-EventLogConfigExtension
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][UInt32]$Rank,
        [Parameter(Mandatory,ParameterSetName=0)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Config)

    Class EventLogConfigExtension
    {
        [UInt32] $Rank
        [String] $LogName
        [Object] $LogType
        [Object] $LogIsolation
        [Boolean] $IsEnabled
        [Boolean] $IsClassicLog
        Hidden [String] $SecurityDescriptor
        [String] $LogFilePath
        Hidden [Int64] $MaximumSizeInBytes
        [Object] $Maximum
        [Object] $Current
        [Object] $LogMode
        Hidden [String] $OwningProviderName
        [Object] $ProviderNames
        Hidden [Object] $ProviderLevel
        Hidden [Object] $ProviderKeywords
        Hidden [Object] $ProviderBufferSize
        Hidden [Object] $ProviderMinimumNumberOfBuffers
        Hidden [Object] $ProviderMaximumNumberOfBuffers
        Hidden [Object] $ProviderLatency
        Hidden [Object] $ProviderControlGuid
        Hidden [Object[]] $EventLogRecord
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Name)
        {
            $This.Rank                           = $Rank
            $Event                               = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($Name)
            $This.LogName                        = $Event.LogName 
            $This.LogType                        = $Event.LogType 
            $This.LogIsolation                   = $Event.LogIsolation 
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = "{0:n2} MB" -f ($Event.MaximumSizeInBytes/1MB) 
            $This.Current                        = If (!(Test-Path $This.LogFilePath)) { "0.00 MB" } Else { "{0:n2} MB" -f (Get-Item $This.LogFilePath | % { $_.Length/1MB }) }
            $This.LogMode                        = $Event.LogMode
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        EventLogConfigExtension([Object]$Event)
        {
            $This.Rank                           = $Event.Rank
            $This.Logname                        = $Event.LogName
            $This.LogType                        = $This.GetLogType($Event.LogType)
            $This.LogIsolation                   = $This.GetLogIsolation($Event.LogIsolation)
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath 
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = $Event.Maximum
            $This.Current                        = $Event.Current
            $This.LogMode                        = $This.GetLogMode($Event.LogMode)
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        GetEventLogRecord()
        {
            $This.Output = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
            $This.Total  = $This.Output.Count
            $Depth       = ([String]$This.Total.Count).Length
            If ($This.Total -gt 0)
            {
                $C = 0
                ForEach ($Record in $This.Output)
                {
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    Index -Value $Null
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Rank -Value $C 
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    LogId -Value $This.Rank
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name DateTime -Value $Record.TimeCreated
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Date -Value $Record.TimeCreated.ToString("yyyy-MMdd-HHMMss")
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Name -Value ("$($Record.Date)-$($This.Rank)-{0:d$Depth}" -f $C)
                    $C ++
                }
            }
        }
        [Object] GetLogType([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogType]::Administrative }
                1 { [System.Diagnostics.Eventing.Reader.EventLogType]::Operational }
                2 { [System.Diagnostics.Eventing.Reader.EventLogType]::Analytical }
                3 { [System.Diagnostics.Eventing.Reader.EventLogType]::Debug }  
            }
            Return $Return
        }
        [Object] GetLogIsolation([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Application }
                1 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::System }
                2 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Custom }
            }
            Return $Return
        }
        [Object] GetLogMode([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular   }
                1 { [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup }
                2 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain     }
            }
            Return $Return
        }
        [Object] Config()
        {
            Return $This | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,MaximumSizeInBytes,Maximum,Current,LogMode,
            OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,
            ProviderControlGuid
        }
        [String] ToString()
        {
            Return "({0}/{1}/{2})" -f $This.Rank, $This.LogName, $This.Total
        }
    }
    
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogConfigExtension]::New($Rank,$Name) }
        1 { [EventLogConfigExtension]::New($Config)     }
    }
}
