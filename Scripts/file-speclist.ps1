
Class FileType
{
    Hidden [Object]$File
    [UInt32] $Index 
    [String] $Name
    [String] $Date
    [String] $Extension
    FileType([UInt32]$Index,[Object]$Object)
    {
        $This.Index     = $Index
        $This.Extension = "." + $Object.Name.Split(".")[-1] 
        $This.Name      = $Object.Name -Replace $This.Extension, ""
        $This.Date      = $Object.Date.ToString("MM/dd/yy HHmm")
    }
}

Class FileDate
{
    [String] $Type
    [String] $Date
    FileDate([String]$Type,[String]$Date)
    {
        $This.Type  = $Type
        $This.Date  = ([DateTime]($Date)).ToString("MM/dd/yy HHmm")
    }
    [String] ToString()
    {
        Return $This.Date
    }
}

Class FileBase
{
    [UInt32] $Index
    [String] $Name
    [String] $Type
    [String] $Extension
    [String] $Size
    [Object] $Original
    [Object] $Modified
    [Object] $Created
    [Object] $Accessed
    FileBase([UInt32]$Index,[Object]$Folder,[Object]$File)
    {
        $This.Index     = $Index
        $This.Extension = "." + $File.Name.Split(".")[-1] 
        $This.Name      = $File.Name -Replace $This.Extension, ""
        $This.Size      = $Folder.GetDetailsOf($File, 1)
        $This.Type      = $Folder.GetDetailsOf($File, 2)
        $This.Original  = Switch -Regex ($This.Type)
        {
            HEIC 
            {
                [FileDate]::New("Modified",($Folder.GetDetailsOf($File,12) -Replace [Char]8206,"" -Replace [Char]8207,""))
            }
            Default
            {
                $Null
            }
            
        }
        $This.Modified = [FileDate]::New("Modified", $Folder.GetDetailsOf($File, 3))
        $This.Created  = [FileDate]::New( "Created", $Folder.GetDetailsOf($File, 4))
        $This.Accessed = [FileDate]::New("Accessed", $Folder.GetDetailsOf($File, 5))
    }
}

Class FolderType
{
    [String] $Path
    Hidden [Object] $Folder
    Hidden [String[]] $Filter
    [Object[]] $Files
    FolderType([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }

        $This.Path   = $Path
        $This.Folder = (New-Object -ComObject Shell.Application).Namespace($Path)
    }
    SetFilter([String[]]$Filter)
    {
        $This.Filter = $Filter
    }
    Clear()
    {
        $This.Filter = @( )
        $This.Files  = @( )
    }
    [Object[]] GetItems()
    {
        Return @( Switch ([UInt32]($This.Filter.Count -gt 0))
        {
            0 { $This.Folder.Items() }
            1 { $This.Folder.Items() | ? Name -in $This.Filter } 
        })
    }
    Collect()
    {
        $This.Files  = @( )
        $Items       = $This.GetItems()
        $Segment     = [Math]::Round($Items.Count/100)
        $Slot        = 0..($Items.Count-1) | ? { $_ % $Segment -eq 0 }
        ForEach ($X in 0..($Items.Count-1))
        { 
            $Item    = $Items[$X]
            If ($X -in $Slot)
            {
                    $Percent = ($X*100/$Items.Count)
                    $String  = "({0:n2}%) ({1}/{2})" -f $Percent, $X, $Items.Count
                    [Console]::WriteLine("Processing [~] $String")
            }
            $This.Files += [FileBase]::New($This.Files.Count,$This.Folder,$Item) 
        }
    }
    [String[]] Output()
    {
        $Return = @( )
        $Depth  = ([String]$This.Files.Count).Length
        $Max    = ($This.Files.Name | Sort-Object Length)[-1].Length
        ForEach ($File in $This.Files)
        {
            $Item = $File.Name | % { 

                If ($_.Length -lt $Max)
                {
                   "{0}{1}" -f $_, (" " * ($Max - $_.Length) -join '')
                }
                Else
                {
                    $_
                }
            }
            $Date   = If (!!$File.Original) { $File.Original } Else { $File.Modified }

            $Return += "| {0:d$Depth} | {1} | {2} | _ |" -f $File.Index, $Item, $Date
        }
        Return $Return
    }
}

$Path   = "C:\Pictures"
$Folder = [FolderType]::New($Path)
$Folder.SetFilter(($Folder.Folder.Items() | ? Name -match "(IMG_\d{4}.HEIC)" | % Name))
$Folder.Collect()
$Folder.Output()

# $Folder.Collect()
# $Folder.Output()
