<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Show-ToastNotification.ps1
          Solution: FightingEntropy Module
          Purpose: Almost like Burnt Toast (which is probably cooler than this is)
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-07
          Modified: 2022-02-25
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO: Gotta figure out how to automatically toggle between the default stuff and other templates
                AKA, it's not broken, but needs some additional logical structuring and renaming: ($Message,$Header,$Footer, etc)
                I have some ideas but they're not developed enough quite yet.
.Example
Show-ToastNotification -Type Image -Mode 4 -Image "C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\OEMlogo.bmp" -Message "Kickass notification"
Show-ToastNotification -Type Text  -Mode 2 -Header "Wireless connection established" -Message "Network name"
#>

Function Show-ToastNotification
{
    [CmdLetBinding()]
    Param (
    [Parameter(ParameterSetName=0,Position=0,Mandatory)]
    [Parameter(ParameterSetName=1,Position=0,Mandatory)]
    [ValidateSet("Text","Image")]
    [String] $Type,

    [Parameter(ParameterSetName=0,Position=1,Mandatory)]
    [Parameter(ParameterSetName=1,Position=1,Mandatory)]
    [ValidateSet(1,2,3,4)]
    [UInt32] $Mode,

    [Parameter(ParameterSetName=1,Position=2,Mandatory)]
    [ValidateScript({$_ -match "((http[s]*://)|(\w+:\\\w+)|(ms-app)+([x|data])+(:///))"})]
    [String] $Image,

    [Parameter(ParameterSetName=0,Position=2)]
    [Parameter(ParameterSetName=1,Position=3)]
    [ValidateScript({$_ -match (@(8,4,4,4,12 | % { "[a-zA-Z0-9]{$_}"}) -join "-")})]
    [String] $Guid = (New-Guid),

    [Parameter(ParameterSetName=0,Position=3,Mandatory)]
    [Parameter(ParameterSetName=1,Position=4,Mandatory)]
    [String] $Message,

    [Parameter(ParameterSetName=0,Position=4)]
    [Parameter(ParameterSetName=1,Position=5)]
    [String] $Header,

    [Parameter(ParameterSetName=0,Position=5)]
    [Parameter(ParameterSetName=1,Position=6)]
    [String] $Body,

    [Parameter(ParameterSetName=0,Position=6)]
    [Parameter(ParameterSetName=1,Position=7)]
    [String] $Footer)

    Class Toast
    {
        [String]          $Module = "[FightingEntropy(π)]"
        [String]            $Type
        [Validateset(1,2,3,4)]
        [UInt32]            $Mode
        [Object]         $Message
        [String]            $Guid
        [String]            $Time = (Get-Date)
        [Object]            $File
        [String]          $Header
        [String]            $Body
        [String]          $Footer
        [String]        $Template
        [Object]             $XML
        [Object]           $Toast
        Toast([String]$Type,[UInt32]$Mode,[Object]$Message,[String]$GUID)
        {
            $This.Type       = $Type
            $This.Mode       = $Mode
            $This.Message    = $Message
            $This.GUID       = $Guid
            $This.File       = $Null
            $This.GetTemplate()
        }
        Toast([String]$Type,[UInt32]$Mode,[Object]$Message,[String]$GUID,[String]$File)
        {
            $This.Type       = $Type
            $This.Mode       = $Mode
            $This.Message    = $Message
            $This.GUID       = $Guid
            $This.GetFile($File)
            $This.GetTemplate()
        }
        GetFile([String]$Path)
        {
            $Temp            = $Null
            Switch -Regex ($Path)
            {
                "http[s]*://" 
                {
                    [Net.ServicePointManager]::SecurityProtocol = 3072
                    $Temp = "$Env:Temp\$(Split-Path -Leaf $Path)"
                    Start-BitsTransfer -Source $Path -Destination $Temp
                    If (Test-Path $Temp)
                    {   
                        $This.File = "file:///{0}" -f $Temp.Replace("\","/")
                    }
                    Else
                    {
                        Throw "File could not be loaded"
                    }
                }
                "(\w+:\\\w+)"
                {
                    If (Test-Path $Path)
                    {
                        $This.File = "file:///{0}" -f $Path.Replace("\","/")
                    }
                    Else
                    {
                        Throw "Invalid path to image"
                    }
                }
                "(ms-app)+([x|data])+(:///)"
                {
                    Throw "ms-app* Not yet implemented"
                }
            }
        }
        GetTemplate()
        {
            $Temp = @('<toast>',
            '    <visual>';
            If ($This.File -eq $Null)
            {
                "        <binding template='ToastText0$($This.Mode)'>"
            }
            If ($This.File -ne $Null)
            {
                "        <binding template='ToastImageAndText0$($This.Mode)'>",
                "            <image id='1' src='$($This.File)' alt='$($This.File)'/>"
            }

            ForEach ($X in @( Switch ($This.Mode) { 1 { 1 } 2 { 1,2 } 3 { 1,2,3 } 4 { 1,2,3 } }))
            {
                "            <text id='$X'>{$($X-1)}</text>";
            } 
            "        </binding>",
            "    </visual>",
            "</toast>")

            $This.Template = $Temp -join "`n"
        }
        Display()
        {
            [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType = WindowsRuntime] > $Null
            [Windows.UI.Notifications.ToastNotification,Windows.UI.Notifications,ContentType = WindowsRuntime] > $Null
            [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom.XmlDocument,ContentType = WindowsRuntime] > $Null

            $This.XML             = [Windows.Data.Xml.Dom.XmlDocument]::new()
            $This.XML.LoadXml($This.Template)
            $This.Toast           = [Windows.UI.Notifications.ToastNotification]::new($This.XML)
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($This.Module).Show($This.Toast)
        }
    }

    $Return    = Switch ($Image -eq $Null)
    {
        $True  { [Toast]::New($Type,$Mode,$Message,$GUID)        }
        $False { [Toast]::New($Type,$Mode,$Message,$GUID,$Image) }
    }

    $Return.Header                = @($Header,$Return.Module)[!$Header]
    $Return.Body                  = $Message
    $Return.Footer                = @($Footer,$Return.Time)[!$Footer]
    $Return.Template              = $Return.Template -f $Return.Header, $Return.Body, $Return.Footer
    $Return.Display()
}
