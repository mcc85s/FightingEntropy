<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Show-ToastNotification.ps1                                                               //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : Almost like Burnt Toast (which is probably cooler than this is).                         //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-12                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11-16-2022 16:53:17    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Show-ToastNotification
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=0,Position=0)]
        [Parameter(ParameterSetName=1,Position=0)][String]$Message,
        [Parameter(ParameterSetName=1,Position=1)][String]$Header,
        [Parameter(ParameterSetName=0,Position=2)]
        [Parameter(ParameterSetName=1,Position=2)][String]$Body,
        [Parameter(ParameterSetName=0,Position=3)]
        [Parameter(ParameterSetName=1,Position=3)][String]$Footer,
        [Parameter(ParameterSetName=0,Position=3)]
        [Parameter(ParameterSetName=1,Position=3)][String]$Guid=(New-Guid),
        [Parameter(ParameterSetName=1,Position=4)][String]$Image)

    [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType = WindowsRuntime] > $Null
    [Windows.UI.Notifications.ToastNotification,Windows.UI.Notifications,ContentType = WindowsRuntime] > $Null
    [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom.XmlDocument,ContentType = WindowsRuntime] > $Null

    Class Toast
    {
        [String]            $Type = "Text"
        [UInt32]            $Mode = 1
        [String[]]       $Message
        [String]           $Image = $Null
        [Object]            $GUID
        [String]            $Time = (Get-Date)
        [String]          $Header
        [String]            $Body
        [String]          $Footer
        [String]        $Template
        [Object]             $XML
        [Object]           $Toast
        Toast([String]$Message,[Object]$Guid)
        {
            $This.Message = $Message
            $This.Guid    = $Guid
        }
        SetImage([String]$Image)
        {
            Switch -Regex ($Image)
            {
                "http[s]*://" 
                {
                    [Net.ServicePointManager]::SecurityProtocol = 3072
                    $File       = "$Env:Temp\{0}" -f (Split-Path -Leaf $Image)
                    Invoke-WebRequest -URI $Image -OutFile $File
                    $This.Image = "file:///{0}" -f $This.File.Replace("\","/")
                }
                "(\w+:\\\w+)"
                {
                    If (!([System.IO.File]::Exists($Image)))
                    {
                        Throw "Invalid path to image" 
                    }

                    $This.Image  = "file:///{0}" -f $Image.Replace("\","/")
                }
                "(ms-app)+([x|data])+(:///)"
                {
                    Throw "ms-app* Not yet implemented"
                }
            }
        }
        [Object] GetTemplate()
        {
            $T            = @{ }
            $T.Add($T.Count,"<toast>")
            $T.Add($T.Count,"    <visual>")

            Switch ($This.Type)
            {  
                Text
                { 
                    $T.Add($T.Count,"        <binding template=`"ToastText0$($This.Mode)`">;")  
                }
                Image
                { 
                    $T.Add($T.Count,"        <binding template=`"ToastImageAndText0$($This.Mode)`">;")
                    $T.Add($T.Count,"            <image id=`"1`" src=`"$($This.Image)`" alt=`"$($This.Image)`"/>;") 
                }
            }

            $Slot = Switch ([Int32]($This.Mode))
            {
                1 { 1 } 2 { 1,2 } 3 { 1,2,3 } 4 { 1,2,3 } 
            } 
            
            $Slot | % { $T.Add($T.Count,"            <text id=`"$_`">{$($_-1)}</text>" ) } 

            $T.Add($T.Count,"        </binding>")
            $T.Add($T.Count,"    </visual>")
            $T.Add($T.Count,"</toast>")

            Return $T[0..($T.Count-1)] -join "`n"
        }
        Populate()
        {
            $This.Template = $This.GetTemplate() -f $This.Header, $This.Body, $This.Footer
        }
        GetXML()
        {
            $This.XML             = New-Object Windows.Data.Xml.Dom.XmlDocument
            $This.XML.LoadXml($This.Template)
            $This.Toast           = New-Object Windows.UI.Notifications.ToastNotification $This.XML
        }
        ShowMessage()
        {
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($This.Guid).Show($This.Toast)
        }
    }

    $Object = [Toast]::New($Message,$Guid)
    If ($Header)
    {
        $Object.Header = $Header
        $Object.Mode   ++
    }
    If ($Body)
    {
        $Object.Body   = $Body
        $Object.Mode   ++
    }
    If ($Footer)
    {
        $Object.Footer = $Footer
        $Object.Mode   ++
    }
    If ($Image)
    {
        $Object.SetImage($Image)
        $Object.Type   = "Image"
    }
    
    $Object.Populate()
    $Object.GetXML()
    $Object.ShowMessage()
}
