<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Show-ToastNotification.ps1                                                               //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Almost like Burnt Toast (which is probably cooler than this is).                         //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-10-10                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:45    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Show-ToastNotification
{
    [CmdLetBinding(DefaultParameterSetName="Text")]Param(
        [ValidateSet(1,2,3,4)]
        [Parameter(ParameterSetName= "Text",Position=0)]
        [Parameter(ParameterSetName="Image",Position=0)]                                 [Int32]    $Type ,
        [Parameter(ParameterSetName="Image",Position=1,HelpMessage=     "Web/File Path")][String]  $Image ,
        [Parameter(ParameterSetName= "Text",Position=1,HelpMessage= "New/Existing GUID")]
        [Parameter(ParameterSetName="Image",Position=2,HelpMessage= "New/Existing GUID")][String]   $GUID = (New-GUID),
        [Parameter(ParameterSetName= "Text",Position=2,HelpMessage=            "Header")]
        [Parameter(ParameterSetName="Image",Position=3,HelpMessage=            "Header")][String] $Header ,
        [Parameter(ParameterSetName= "Text",Position=3,HelpMessage=              "Body")]
        [Parameter(ParameterSetName="Image",Position=4,HelpMessage=              "Body")][String]   $Body ,
        [Parameter(ParameterSetName= "Text",Position=4,HelpMessage=              "Foot")]
        [Parameter(ParameterSetName="Image",Position=5,HelpMessage=              "Foot")][String] $Footer )

    Invoke-Expression ("using namespace System.{0}
    [{0}.ToastNotificationManager,{0},{1}]
    [{0}.ToastNotification,{0},{1}]
    [{2},{2},{1}]" -f "Windows.UI.Notifications","ContentType = WindowsRuntime","Windows.Data.Xml.Dom.XmlDocument")

    Class Cache
    {
        [String] $Path
        [Object] $File
        Cache([Object]$Image)
        {
            Switch -Regex ($Image)
            {
                "http[s]*://" 
                {
                    [Net.ServicePointManager]::SecurityProtocol = 3072
                    $This.Path            = $Image
                    $This.File            = "$Env:Temp{0}" -f (Split-Path -Leaf $Image)
                    Invoke-WebRequest -URI $This.Path -OutFile $This.File #| ? StatusDescription -ne OK | % { Throw "Exception" }
                    $This.Path            = "file:///{0}" -f $This.File.Replace("\","/")
                }

                "(\w+:\\\w+)"
                {
                    If ( ! ( Test-Path $Image ) )
                    {
                        Throw "Invalid path to image" 
                    }

                    $This.Path            = "file:///{0}" -f $Image.Replace("\","/")
                }

                "(ms-app)+([x|data])+(:///)"
                {
                    Throw "ms-app* Not yet implemented"
                }
            }
        }
    }

    Class Toast
    {
        [Validateset(1,2,3,4)]
        [Int32]             $Type
        [Object]         $Message
        [String]            $GUID
        [String]            $Time = (Get-Date)
        [Object]            $File
        [String]          $Header
        [String]            $Body
        [String]          $Footer
        Hidden [Hashtable]  $Temp
        Hidden [Int32] $TempCount
        [String]        $Template
        [Object]             $XML
        [Object]           $Toast
        Toast([Int32]$Type,[Object]$Message,[String]$GUID)
        {
            $This.Type       = $Type
            $This.Message    = $Message
            $This.GUID       = $GUID
            $This.File       = $Null
            $This.Load()
        }
        Toast([Int32]$Type,[Object]$Message,[String]$GUID,[String]$File)
        {
            $This.Type       = $Type
            $This.Message    = $Message
            $This.GUID       = $GUID
            $This.File       = [Cache]::New($File)
            $This.Load()
        }
        Load()
        {
            $This.Temp            = @{ }
            $This.TempCount       = 0

            $This.Temp.Add($This.TempCount++,"<toast>")
            $This.Temp.Add($This.TempCount++,"_<visual>")

            @( Switch ([Int32]($This.File -ne $Null))
            {  
                0 { $This.Temp.Add($This.TempCount++,"__<binding template=`"ToastText0$($This.Type)`">;")  }
                1 { $This.Temp.Add($This.TempCount++,"__<binding template=`"ToastImageAndText0$($This.Type)`">;")
                        $This.Temp.Add($This.TempCount++,"___<image id=`"1`" src=`"$($This.File.Path)`" alt=`"$($This.File.Path)`"/>;") }
            })

            @( Switch ([Int32]($This.Type))
            {
                1 { 1 } 
                2 { 1,2 } 
                3 { 1,2,3 } 
                4 { 1,2,3 } 

            }) | % { $This.Temp.Add($This.TempCount++,"___<text id=`"$_`">{$($_-1)}</text>" ) } 

            $This.Temp.Add($This.TempCount++,"__</binding>")
            $This.Temp.Add($This.TempCount++,"_</visual>")
            $This.Temp.Add($This.TempCount++,"</toast>")

            $This.Template        = ( $This.Temp.GetEnumerator() | Sort Name | % Value ).Replace("_","    ") -join "`n"
        }
        GetXML()
        {
            $This.XML             = Invoke-Expression "[Windows.Data.Xml.Dom.XmlDocument]::new()"
            $This.XML.LoadXml($This.Template)
            $This.Toast           = Invoke-Expression ( "[Windows.UI.Notifications.ToastNotification]::new({0})" -f $This.XML )
        }
        ShowMessage()
        {
            Invoke-Expression ( "[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier({0}).Show({1})" -f $This.GUID,$This.Toast )
        }
    }

    $Return                       = Switch([Int32]($Image -eq $Null)) 
    { 
        0 { [Toast]::New($Type,$Message,$GUID,$Image) } 
        1 { [Toast]::New($Type,$Message,$GUID) }
    }
    
    $Return.Header                = If ( $Header -eq $Null ) {    "Message" } Else { $Header }
    $Return.Body                  = If ( $Body   -eq $Null ) {        $GUID } Else { $Body   }
    $Return.Footer                = If ( $Footer -eq $Null ) { $Return.Time } Else { $Footer }

    $Return.Template              = $Return.Template -f $Return.Header, $Return.Body, $Return.Footer
    $Return.GetXML()
    $Return.ShowMessage()
}

