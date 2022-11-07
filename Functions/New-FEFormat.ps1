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
   //        FileName   : New-FEFormat.ps1                                                                         //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : For structuring and formatting categorized output.                                       //   
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
    ¯¯¯\\__[ 2022-10-10 16:25:43    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function New-FEFormat
{
    [CmdLetBinding()]Param(
    [Parameter(ParameterSetName=0,Position=0)][Object]$Table,
    [Parameter(ParameterSetName=1,Position=0)][Object]$Section,
    [Parameter(ParameterSetName=0,Position=1)]
    [Parameter(ParameterSetName=1,Position=1)][String[]]$Property)

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

    # // ____________________________________________________________
    # // | Converts an existing PSObject into an individual section |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatMaster
    {
        [UInt32]  $Index
        [String]   $Name
        [UInt32]    $Max
        [Object] $Output
        FormatMaster([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Output = @( )

            ForEach ($Item in $Object)
            {
                $Prop = [FormatValue]::New($Item)
                If ($Prop.Width -gt $This.Max)
                {
                    $This.Max = $Prop.Width
                }

                $This.Output += $Prop
            }

            $This.SetBuffer($This.Max)
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

    # // __________________________________________________________
    # // | Provides a scalable structure for a particular section |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatSection
    {
        [UInt32]  $Count
        [Object] $Output
        FormatSection([Object]$Object,[String[]]$Header)
        {
            $This.Count  = $Object.Count
            $This.Output = @( )

            ForEach ($Name in $Header)
            {
                $Container = [FormatMaster]::New($This.Output.Count,$Name,$Object.$Name)

                $This.Output += $Container
            }
        }
        [Object[]] Draw([UInt32]$Rank)
        {
            $Out   = @{ }
            $Array = $This.Output.Index | % {
            
                "{0}: {1}" -f $This.Output[$_].Name, $This.Output[$_].Output[$Rank]
            }
            $Line  = $Array -join " | "
    
            $Out.Add($Out.Count,(@([Char]95) * ($Line.Length + 4) -join ''))
            $Out.Add($Out.Count,"| $Line |")
            $Out.Add($Out.Count,(@([Char]175) * ($Line.Length + 4) -join ''))

            Return $Out[0..($Out.Count-1)]
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 
        { 
            [FormatTable]::New($Object,$Property)
        }
        1
        {
            [FormatSection]::New($Section,$Property)
        }
    }
}
