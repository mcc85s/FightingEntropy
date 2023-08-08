<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-07 20:41:21                                                                  //
 \\==================================================================================================// 

   FileName   : Get-FEProcess.ps1
   Solution   : [FightingEntropy()][2023.8.0]
   Purpose    : Loads the FightingEntropy module
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2023-08-07
   Modified   : 2023-08-07
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : Loads the running processes on a system

.Example
#>

Function Get-FEProcess
{
    Class ByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        ByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Enum ProcessSortType
    {
        Name
        Id
        SessionId
        VirtualMemory
        WorkingSet
        PagedMemory
        NonpagedMemory
        ProcessorTime
        Path
        Active
    }

    Class ProcessSortItem
    {
        [UInt32] $Index
        [String] $Name
        [String] $Fullname
        ProcessSortItem([String]$Name)
        {
            $This.Index = [UInt32][ProcessSortType]::$Name
            $This.Name  = [ProcessSortType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ProcessSortList
    {
        [Object] $Output
        ProcessSortList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] ProcessSortItem([String]$Name)
        {
            Return [ProcessSortItem]::New($Name)
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([ProcessSortType]))
            {
                $Item          = $This.ProcessSortItem($Name)
                $Item.Fullname = Switch ($Item.Name)
                {
                    Name           { "Name"                       }
                    Id             { "Id"                         }
                    Active         { "HasExited"                  }
                    SessionId      { "SessionId"                  }
                    VirtualMemory  { "VirtualMemorySize64"        }
                    WorkingSet     { "WorkingSet"                 }
                    PagedMemory    { "PagedMemorySize64"          }
                    NonpagedMemory { "NonpagedSystemMemorySize64" }
                    ProcessorTime  { "TotalProcessorTime"         }
                    Path           { "Path"                       }
                }

                $This.Output   += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Process.Sort[List]>"
        }
    }

    Class ProcessItem
    {
        [UInt32]          $Index
        Hidden [Object] $Process
        [String]           $Name
        [UInt32]             $Id
        [UInt32]         $Active
        [UInt32]      $SessionId
        [Object]  $VirtualMemory
        [UInt64]     $WorkingSet
        [Object]    $PagedMemory
        [Object] $NonpagedMemory
        [Object]  $ProcessorTime
        [String]           $Path
        ProcessItem([UInt32]$Index,[Object]$Process)
        {
            $This.Index          = $Index
            $This.Process        = $Process
            $This.Name           = $Process.Name
            $This.Id             = $Process.Id
            $This.Active         = $Process.HasExited
            $This.SessionId      = $Process.SessionId
            $This.VirtualMemory  = $This.ByteSize("VirtualMemory",$Process.VirtualMemorySize64)
            $This.WorkingSet     = $Process.WorkingSet64
            $This.PagedMemory    = $This.ByteSize("PagedMemory",$Process.PagedMemorySize64)
            $This.NonpagedMemory = $This.ByteSize("NonpagedMemory",$Process.NonpagedSystemMemorySize64)
            $This.ProcessorTime  = $Process.TotalProcessorTime
            $This.Path           = $Process.Path
        }
        [Object] ByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [ByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class ProcessController
    {
        [Object] $Property
        [Object]   $SortBy
        [UInt32]     $Mode
        [Object]   $Output
        ProcessController()
        {
            $This.Property = $This.ProcessSortList()
            $This.SetSortBy(0,"Name")
        }
        [Object] ProcessItem([UInt32]$Index,[Object]$Process)
        {
            Return [ProcessItem]::New($Index,$Process)
        }
        [Object] ProcessSortList()
        {
            Return [ProcessSortList]::New()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object[]] GetObject()
        {
            $Process = Get-Process | Sort-Object $This.SortBy.Fullname
            $Item    = Switch ($This.Mode)
            {
                0 { $Process[0..($Process.Count-1)] }
                1 { $Process[($Process.Count-1)..0] }
            }

            Return $Item
        }
        [Object] GetSortBy([String]$Name)
        {
            Return $This.Property.Output | ? Name -eq $Name
        }
        SetSortBy([UInt32]$Mode,[String]$Name)
        {
            If ($Mode -in 0,1 -and $Name -in $This.Property.Output.Name)
            {
                $This.Mode   = $Mode
                $This.SortBy = $This.GetSortBy($Name)
                $This.Refresh()
            }
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Process in $This.GetObject())
            {
                $This.Output += $This.ProcessItem($This.Output.Count,$Process)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.Process[Controller]>"
        }
    }

    [ProcessController]::New()
}
