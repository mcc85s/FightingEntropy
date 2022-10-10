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
   //        FileName   : Get-PropertyObject.ps1                                                                   //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : This is specifically for a portion of the EventLogUtility GUI.                           //   
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
    ¯¯¯\\__[ 2022-10-10 16:25:44    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Get-PropertyObject
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory,ValueFromPipeline)][Object[]]$InputObject)

    Begin 
    {
        Class PropertyObject
        {
            [UInt32] $Rank
            [String] $Title
            [String] $Mode
            [UInt32] $Count
            [Object] $Slot
            PropertyObject([Object]$Section)
            {
                $This.Rank  = $Section.Rank
                $This.Title = $Section.Title
                $This.Mode  = $Section.Mode
                $This.Count = $Section.Quantity + 1
                $This.Slot  = @{ }
                $X = 0
                Do
                {
                    If ($Section.Slot[$X])
                    {
                        $Item = $Section.Slot[$X].Content
                        $This.Slot.Add($This.Slot.Count,$This.GetObject($Item,1))
                    }
                    $X ++
                }
                Until (!$Section.Slot[$X])
            }
            [Object] GetObject([Object]$Object,[UInt32]$Flag)
            {
                If ($Flag -eq 0)
                {
                    Return @( ForEach ($Item in $Object.PSObject.Properties)
                    {
                        $This.GetProperty($Item.Name,$Item.Value)  
                    })
                }
                Else
                {
                    Return @( ForEach ($X in 0..($Object.Count-1))
                    {
                        $Object[$X]
                    })
                }
            }
            [Object] GetProperty([String]$Name,[Object]$Value)
            {
                Return Get-PropertyItem -Name $Name -Value $Value
            }
            [String] ToString()
            {
                Return "{0}[{1}]" -f $This.Title, $This.Rank
            }
        }
        $Output = @( )
    }
    Process
    {
        $Output += [PropertyObject]::New($InputObject) 
    }
    End
    {
        $Output
    }
}