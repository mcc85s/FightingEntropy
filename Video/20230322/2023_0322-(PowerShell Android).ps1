Class ComObject
{
    Hidden [Object]      $Com
    Hidden [String]  $DevPath
    [String]            $Type
    [DateTime] $LastWriteTime
    [Int64]           $Length
    [String]          $Parent
    [String]            $Name
    [String]        $Fullname
    ComObject([Object]$Root,[String]$Parent,[Object]$Object)
    {
        $This.Com     = $Object
        $This.DevPath = $Object.Path
        $This.Parent  = $Parent
    }
    [Object] Detail([UInt32]$Var)
    {
        Return $This.Com.Parent.GetDetailsOf($This.Com,$Var)
    }
    [UInt64] GetSize()
    {
        Return @(Switch -Regex ($This.Size)
        {
            Default
            {
                $This.Size -Replace " ", ""
            }
            bytes
            {
                $This.Size -Replace " bytes", ""
            }

        }) | Invoke-Expression
    }
}

Class ComFile : ComObject
{
    [String]             $Size
    Hidden [String] $Extension
    [UInt32]            $Count
    ComFile([Object]$Root,[String]$Parent,[Object]$Object) : Base($Root,$Parent,$Object)
    {
        $This.Type          = "File"
        $This.LastWriteTime = [DateTime]$This.Detail(3)
        $This.Size          = $This.Detail(2)
        $This.GetSize()
        $This.Parent        = $Parent
        $This.Extension     = ($Object.Type -Split " ")[0].ToLower().TrimEnd(".")
        $This.Name          = $Object.Name
        $This.Fullname      = "{0}\{1}" -f $This.Parent, $This.Name
        Write-Host $This.Fullname
        $This.Count         = 0
        If (!$Root.Output[$This.Fullname])
        {
            $Root.Output.Add($This.Fullname,$This)
        }
    }
}

Class ComDirectory : ComObject
{
    [Object]            $Item
    [UInt32]           $Count
    ComDirectory([Object]$Root,[String]$Parent,[Object]$Object) : Base($Root,$Parent,$Object)
    {
        $This.Type          = "Directory"
        $This.LastWriteTime = [DateTime]$Object.ModifyDate
        $This.Length        = $Object.Size
        $This.Parent        = $Parent
        $This.Name          = $Object.Name
        $This.Fullname      = $This.Parent, $This.Name -join "\"
        Write-Host $This.Fullname
        $This.Item          = $This.GetChildItem($Root)
        $This.Count         = $This.Item.Count
        If (!$Root.Output[$This.Fullname])
        {
            $Root.Output.Add($This.Fullname,$This)
        }
    }
    [Object[]] GetChildItem($Root)
    {
        Return @(ForEach ($Item in $This.Com.GetFolder.Items())
        { 
            Switch ($Item.IsFolder)
            {
                $True  
                {
                    [ComDirectory]::New($Root,$This.Fullname,$Item)
                }
                $False 
                { 
                    [ComFile]::New($Root,$This.Fullname,$Item)
                }            
            }
        })
    }
}

Class DeviceConnection
{
    [String]  $Label
    [Object]   $Root
    [Object] $Output = @{ }
    DeviceConnection()
    {
        $This.Label   = $This.PnP()
        $This.Root    = $This.Shell().NameSpace(17).Self.GetFolder.Items() | ? Name -eq $This.Label | % { 

            $This.NewDirectory($This,"",$_)
        }
    }
    [Object[]] PnP()
    {
        $List = Get-PnpDevice -PresentOnly | ? Class -eq WPD | ? InstanceID -match ^USB
        $Item = Switch ([UInt32](!!$List))
        {
            0
            {
                $Null
            }
            1
            {
                $List | % FriendlyName
            }
        }

        Return $Item
    }
    [Object] Shell()
    {
        Return New-Object -ComObject Shell.Application
    }
    [Object] NewDirectory([Object]$Root,[String]$Parent,[Object]$Object)
    {
        Return [ComDirectory]::New($Root,$Parent,$Object)
    }
    [Object] NewFile([Object]$Root,[String]$Parent,[Object]$Object)
    {
        Return [ComFile]::New($Root,$Parent,$Object)
    }
    [Object[]] Enumerate()
    {
        $Swap = @($This.Output.GetEnumerator() | Sort-Object Name | % Value)
        Return @($Swap[0..($Swap.Count-1)])
    }
}

$Phone   = [DeviceConnection]::New()
$Output  = $Phone.Enumerate()
