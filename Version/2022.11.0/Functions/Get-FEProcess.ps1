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
   //        FileName   : Get-FEProcess.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Retrieves the currently running processes.                                               //   
   \\        Author     : Michael C. Cook Sr.                                                                      \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-08                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11/08/2022 19:09:14    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-FEProcess
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1,Mandatory)][Switch]$Text)

    # // ______________________________________________________
    # // | Meant to adjust the (width/display) of output data |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatValue
    {
        Hidden [UInt32] $Width
        [Object]        $Value
        FormatValue([String]$String)
        {
            $This.Value = $String
            $This.Width = $This.Value.Length
        }
        SetBuffer([UInt32]$Width)
        {
            $This.Width = $Width
        }
        [String] ToString()
        {
            If ($This.Value.Length -lt $This.Width)
            {
                Return "{0}{1}" -f $This.Value, (@(" ") * ($This.Width-$This.Value.Length) -join "")
            }
            Else
            {
                Return $This.Value
            }
        }
    }

    # // _________________________________________________________________
    # // | Meant to contain and adjust the (width/display) of properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatColumn
    {
        [UInt32]  $Index
        [String]   $Name
        [UInt32]    $Max
        [Object] $Output
        FormatColumn([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Output = @( )

            $This.AddHeader($Name)
        }
        AddHeader([String]$Name)
        {
            ForEach ($Item in @($Name;@("-") * $Name.Length -join ''))
            {
                $This.AddItem($Item)
            }
        }
        AddItem([String]$Item)
        {
            $Prop = [FormatValue]::New($Item)
            If ($Prop.Width -gt $This.Max)
            {
                $This.Max = $Prop.Width
            }

            $This.Output += $Prop
        }
        SetBuffer([UInt32]$Width)
        {   
            $This.Output | % SetBuffer $Width
        }
    }

    # // ____________________________________________________________________
    # // | Provides a scalable structure for multiple columns of properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatTable
    {
        [UInt32]  $Count
        [Object] $Output
        FormatTable([Object]$Object,[String[]]$Header)
        {
            $This.Count  = $Object.Count + 2
            $This.Output = @( )

            ForEach ($Name in $Header)
            {
                $Container = [FormatColumn]::New($This.Output.Count,$Name)
                ForEach ($Item in $Object.$Name)
                {
                    $Container.AddItem($Item)
                }

                $Container.SetBuffer($Container.Max)

                $This.Output += $Container
            }
        }
        [Object[]] Draw()
        {
            $Swap   = @{ }
            $Select = 0..($This.Output.Count-1)
            ForEach ($X in 0..($This.Count-1))
            {
                $Swap.Add($Swap.Count,($Select | % { $This.Output[$_].Output[$X] }) -join " | ")
            }
        
            $Out    = @{ }
            $Out.Add($Out.Count,(@([char]95)*($Swap[0].Length+4) -join ""))
            $Swap[0..($Swap.Count-1)] | % { $Out.Add($Out.Count,"| $_ |") }
            $Out.Add($Out.Count,(@([char]175)*($Swap[0].Length+4) -join ""))
        
            Return @($Out[0..($Out.Count-1)])
        }
    }

    # // ______________________________________________________
    # // | Single process from the default Get-Process cmdlet |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FEProcess
    {
        [String]      $NPM
        [String]       $PM
        [String]       $WS
        [String]      $CPU
        [String]       $ID
        [String]       $SI
        [String]     $Name
        FEProcess([Object]$Process)
        {
            $This.NPM  = "{0:n2}" -f ($Process.NonpagedSystemMemorySize/1KB)
            $This.PM   = "{0:n2}" -f ($Process.PagedMemorySize/1MB)
            $This.WS   = "{0:n2}" -f ($Process.WorkingSet/1MB)
            $This.CPU  = "{0:n2}" -f $Process.TotalProcessorTime.TotalSeconds
            $This.ID   = $Process.Id
            $This.SI   = $Process.SessionID
            $This.Name = $Process.ProcessName
        }
    }

    # // __________________________________________________________
    # // | Multiple processes from the default Get-Process cmdlet |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FEProcesses
    {
        [Object]$Output
        FEProcesses()
        {
            $This.Output = @( Get-Process | % { [FeProcess]$_ })
        }
        [Object[]] List()
        {
            Return [FormatTable]::New($This.Output,@("NPM","PM","WS","CPU","ID","SI","Name")).Draw()
        }
    }

    $Object = [FeProcesses]::New()
    Switch($PSCmdLet.ParameterSetName)
    {
        0 { $Object.Output }
        1 { $Object.List() }
    }
}
