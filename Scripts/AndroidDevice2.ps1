# Fully recursive, just working out the COPY portion

Class ComFile
{
    Hidden [Object]       $Com
    Hidden [String]   $DevPath
    [String]             $Type
    [DateTime]  $LastWriteTime
    Hidden [Int64]     $Length
    [String]             $Size
    Hidden [String]    $Parent
    Hidden [String] $Extension
    [String]             $Name
    [String]         $Fullname
    [UInt32]            $Count
    ComFile([Object]$Root,[String]$Parent,[Object]$Com)
    {
        $This.Com           = $Com
        $This.DevPath       = $Com.Path
        $This.Type          = "File"
        $This.LastWriteTime = [DateTime]$This.Detail(3)
        $This.Size          = $This.Detail(2)
        $This.GetSize()
        $This.Parent        = $Parent
        $This.Extension     = ($Com.Type -Split " ")[0].ToLower()
        $This.Name          = "{0}.{1}" -f $Com.Name, $This.Extension
        $This.Fullname      = "{0}\{1}" -f $This.Parent, $This.Name
        Write-Host $This.Fullname
        $This.Count         = 0
        If (!$Root.Output[$This.Fullname])
        {
            $Root.Output.Add($This.Fullname,$This)
        }
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

Class ComDirectory
{
    Hidden [Object]      $Com
    Hidden [String]  $DevPath
    [String]            $Type
    [DateTime] $LastWriteTime
    [Int64]           $Length
    Hidden [String]   $Parent
    [String]            $Name
    [String]        $Fullname
    [Object]            $Item
    [UInt32]           $Count
    ComDirectory([Object]$Root,[String]$Parent,[Object]$Com)
    {
        $This.Com           = $Com
        $This.DevPath       = $Com.Path
        $This.Type          = "Directory"
        $This.LastWriteTime = [DateTime]$Com.ModifyDate
        $This.Length        = $Com.Size
        $This.Parent        = $Parent
        $This.Name          = $Com.Name
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

Class Shell
{
    Hidden [Object]      $App
    Hidden [Object]     $Root
    Hidden [Object]      $Com
    Hidden [String]  $DevPath
    [String]            $Type
    [DateTime] $LastWriteTime
    [Int64]           $Length
    Hidden [String]   $Parent
    [String]            $Name
    [String]        $Fullname
    [Object]            $Item
    [UInt32]           $Count
    Shell([String]$Parent,[String]$Path)
    {
        $This.App           = New-Object -ComObject Shell.Application
        $This.Root          = $This.App.Namespace((@($Path,[UInt32]$Path)[[UInt32]($Path -match "^\d{2}$")]))
        $This.Com           = $This.Root.Self
        $This.DevPath       = $This.Com.Path
        $This.Type          = @("File","Folder")[[Uint32]$This.Com.IsFolder]
        $This.LastWriteTime = $This.Com.ModifyDate
        $This.Length        = $This.Com.Size
        $This.Parent        = $Parent
        $This.Name          = $This.Com.Name
        $This.Fullname      = @($This.Name;$This.Parent, $This.Name -join "\")[$This.Name -ne "This PC"]
    }
}

Class DeviceConnection
{
    Hidden [Object] $Device
    [String] $Name
    [Object] $Shell
    [Object] $Root
    [Object] $Output = @{ }
    DeviceConnection()
    {
        $This.Device       = Get-PnpDevice -PresentOnly | ? Class -eq WPD | ? InstanceID -match ^USB
        $This.Name         = $This.Device.FriendlyName
        $This.Shell        = $This.NewShell("",17)
        $This.Root         = $This.Shell.Root.Self.GetFolder.Items() | ? Name -eq $This.Name | % { $This.NewDirectory($This,"",$_) }
    }
    [Object] NewShell([String]$Parent,[String]$Namespace)
    {
        Return [Shell]::New($Parent,$Namespace)
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

$Dev = [DeviceConnection]::New()
