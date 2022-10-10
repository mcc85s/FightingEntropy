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
   //        FileName   : Get-EventLogController.ps1                                                               //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Controller for the EventLog Utility (Xaml/Threading/GUI/Logging).                        //   
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
    ¯¯¯\\__[ 2022-10-10 16:25:42    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Get-EventLogController
{
    [CmdLetBinding()]Param()

    Class ProjectTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        ProjectTime([String]$Name)
        {
            $This.Name = $Name
            $This.Time = [DateTime]::MinValue
            $This.Set  = 0
        }
        Toggle()
        {
            $This.Time = [DateTime]::Now
            $This.Set  = 1
        }
        [String] ToString()
        {
            Return $This.Time.ToString()
        }
    }

    Class ProjectStatus
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        ProjectStatus([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
        {
            $This.Index   = $Index
            $This.Elapsed = $Time
            $This.State   = $State
            $This.Status  = $Status
        }
        [String] ToString()
        {
            Return "[{0}] (State: {1}/Status: {2})" -f $This.Elapsed, $This.State, $This.Status
        }
    }

    Class ProjectStatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        ProjectStatusBank()
        {
            $This.Reset()
        }
        [String] Elapsed()
        {
            Return @(Switch ($This.End.Set)
            {
                0 { [Timespan]([DateTime]::Now-$This.Start.Time) }
                1 { [Timespan]($This.End.Time-$This.Start.Time) }
            })         
        }
        [Void] SetStatus()
        {
            $This.Status = [ProjectStatus]::New($This.Output.Count,$This.Elapsed(),$This.Status.State,$This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [ProjectStatus]::New($This.Output.Count,$This.Elapsed(),$State,$Status)
        }
        Initialize()
        {
            If ($This.Start.Set -eq 1)
            {
                $This.Update(-1,"Start [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.Start.Toggle()
            $This.Update(0,"Running [~] ($($This.Start))")
        }
        Finalize()
        {
            If ($This.End.Set -eq 1)
            {
                $This.Update(-1,"End [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.End.Toggle()
            $This.Span = $This.Elapsed()
            $This.Update(100,"Complete [+] ($($This.End)), Total: ($($This.Span))")
        }
        Reset()
        {
            $This.Start  = [ProjectTime]::New("Start")
            $This.End    = [ProjectTime]::New("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([UInt32]$State,[String]$Status)
        {
            $This.SetStatus($State,$Status)
            $This.Write()
            Return $This.Last()
        }
        [Object] Current()
        {
            $This.Update($This.Status.State,$This.Status.Status)
            Return $This.Last()
        }
        [Object] Last()
        {
            Return $This.Output[$This.Output.Count-1]
        }
        [String] ToString()
        {
            If (!$This.Span)
            {
                Return $This.Elapsed()
            }
            Else
            {
                Return $This.Span
            }
        }
    }

    Class ProjectEventSlot
    {
        [String] $Type
        [Int32]  $Index    = -1
        [Object] $Property
        [Object] $Filter
        [Object] $Result
        [Object] $Hash     = @{ }
        ProjectEventSlot([Object]$Types,[String]$Type)
        {
            $This.Type     = $Type
            $List          = $Types | ? Name -match $Type
            $This.Property = $List  | ? Name -match Property | % Control
            $This.Filter   = $List  | ? Name -match Filter   | % Control
            $This.Result   = $List  | ? Name -match Result   | % Control
        }
        SetIndex([UInt32]$Index)
        {
            $This.Index    = $Index
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class ProjectEventTree
    {
        [Object] $LogMain
        [Object] $LogOutput
        [Object] $Output
        ProjectEventTree([Object]$Types)
        {
            $This.LogMain   = [ProjectEventSlot]::New($Types,"LogMain")
            $This.LogOutput = [ProjectEventSlot]::New($Types,"LogOutput")
            $This.Output    = [ProjectEventSlot]::New($Types,"Output")
        }
    }

    Class ProjectController
    {
        [String] $Begin
        [Bool]   $Started
        [Object] $Event
        [Object] $Types
        Hidden [Hashtable] $Hash
        [Object] $Window
        [Object] $MainTab
        [Object] $LogTab
        [Object] $OutputTab
        [Object] $ViewTab
        [Object] $MainPanel
        [Object] $Time
        [Object] $Start
        [Object] $Section
        [Object] $Slot
        [Object] $Throttle
        [Object] $AutoThrottle
        [Object] $Threads
        [Object] $DisplayName
        [Object] $Guid
        [Object] $Archive
        [Object] $Base
        [Object] $Browse
        [Object] $Export
        [Object] $System
        [Object] $ConsoleSlot
        [Object] $Console
        [Object] $TableSlot
        [Object] $Table
        [Object] $Mode
        [Object] $Continue
        [Object] $Progress
        [Object] $ConsoleSet
        [Object] $TableSet
        [Object] $LogPanel
        [Object] $LogMainProperty
        [Object] $LogMainFilter
        [Object] $LogMainRefresh
        [Object] $LogMainResult
        [Object] $LogSelected
        [Object] $LogTotal
        [Object] $LogClear
        [Object] $LogOutputProperty
        [Object] $LogOutputFilter
        [Object] $LogOutputRefresh
        [Object] $LogOutputResult
        [Object] $OutputPanel
        [Object] $OutputProperty
        [Object] $OutputFilter
        [Object] $OutputRefresh
        [Object] $OutputResult
        [Object] $ViewPanel
        [Object] $ViewResult
        [Object] $ViewCopy
        [Object] $ViewClear
        [Object] $Status
        [Object] $Last
        ProjectController()
        {
            $This.Begin                  = $Null
            $This.Started                = 0
            $This.Event                  = @( )
            $This.Types                  = @( )
            $This.Hash                   = @{ }
            $This.Window                 = $Null
            $This.Status                 = [ProjectStatusBank]::New()
            $This.Status.Initialize()
            $This.Update(1,"UserInterface [+] Initialized")
        }
        [Object] Current()
        {
            $This.Last = $This.Status.Current()
            Return $This.Last
        }
        [Object] Update([UInt32]$State,[String]$Status)
        {
            $This.Last = $This.Status.Update($State,$Status)
            Return $This.Last
        }
        [Void] SetWindow([Object]$Window)
        {
            $This.Window                 = $Window
        }
        [Void] Load([Object]$Type)
        {
            $This.Hash.Add($Type.Name,$This.Types.Count)
            $This.Types                 += $Type
            $This.$($Type.Name)          = $Type.Control
            $This.Update(1,"UserInterface [+] Added: [$($Type.Name)]")
        }
        [Object] Pull([String]$Name)
        {
            If ($Name -in $This.Types.Name)
            {
                Return $This.Types[$This.Hash[$Name]]
            }
            Else
            {
                Return $Null
            }
        }
        [Void] Menu([UInt32]$Slot)
        {
            $Names                       = "Main","Log","Output","View"
            ForEach ($X in 0..($Names.Count-1))
            {
                $Item                    = $This."$($Names[$X])Tab"
                $Item.Dispatcher.Invoke(
                [Action]{

                    $Item.Background     = @("#DFFFBA","#4444FF")[$X -eq $Slot]
                    $Item.Foreground     = @("#000000","#FFFFFF")[$X -eq $Slot]
                    $Item.BorderBrush    = @("#000000","#111111")[$X -eq $Slot]

                },"Normal")
                   
                $Item                    = $This."$($Names[$X])Panel"
                $Item.Dispatcher.Invoke(
                [Action]{

                    $Item.Visibility     = @("Collapsed","Visible")[$X -eq $Slot]

                },"Normal")
            }
        }
        [Void] Submain([UInt32]$Slot)
        {
            $Names                       = "Console","Table"
            ForEach ($X in 0..($Names.Count-1))
            {
                $Item                    = $This."$($Names[$X])Set"
                $Item                    = $This."$($Names[$X])Tab"
                $Item.Dispatcher.Invoke([Action]{

                    $Item.Background     = @("#DFFFBA","#4444FF")[$X -eq $Slot]
                    $Item.Foreground     = @("#000000","#FFFFFF")[$X -eq $Slot]
                    $Item.BorderBrush    = @("#000000","#111111")[$X -eq $Slot]

                },"Normal")
                   
                $Item                    = $This."$($Names[$X])Panel"
                $Item.Dispatcher.Invoke([Action]{

                    $Item.Visibility     = @("Collapsed","Visible")[$X -eq $Slot]

                },"Normal")
            }   
        }
        [Void] Initialize([Object]$Project)
        {
            $This.Project                         = $Project
            $This.Main(0) 
 
            $This.LogTab.IsEnabled                = 1
            $This.OutputTab.IsEnabled             = 1
            $This.ViewTab.IsEnabled               = 1
        
            $This.Time.Text                       = $This.Project.Time.Elapsed
            $This.Start.Text                      = $This.Project.Start.ToString()
        
            $This.Project.System.GetOutput()      | Out-Null
            $This.System                          = $This.Project.System.Output.Content | Get-PropertyObject
        
            $This.DisplayName.Text                = $This.Project.DisplayName
            $This.Guid.Text                       = $This.Project.Guid
            $This.Base.Text                       = $This.Project.Base.ToString() | Split-Path -Leaf
    
            $This.Reset($This.Archive.Items       , $This.Archive.PSObject.Properties)
            $This.Reset($This.LogMainResult.Items , $This.Project.Logs)
            $This.Reset($This.OutputResult.Items  , $This.Project.Output)
    
            $This.SetRank(0)
        }
        SetRank([UInt32]$Rank)
        {
            $This.Rank                            = $Rank
            $This.Section                         = $This.System[$This.Rank]
            $This.Slot.Items.Clear()    
            $X                                    = 0
            Do
            {
                If ($This.Section.Slot[$X])
                {
                    $This.Slot.Items.Add($X)
                }
                $X ++
            }
            Until (!$This.Section.Slot[$X])
    
            $This.Slot.SelectedIndex              = 0
            $This.SetSlot()
        }
        SetSlot()
        {
            $This.Reset($This.System.Items,$This.Section.Slot[$This.Slot.SelectedIndex])
        }
        [Void] Reset([Object]$Sender,[Object[]]$Content)
        {
            $Sender.Clear()
            ForEach ($Item in $Content)
            {
                $Sender.Add($Item)
            }
        }
        [Void] SetBegin()
        {
            If ($This.Begin)
            {
                Throw "Begin already set"
            }
    
            $This.Begin = "{0}-{1}" -f [DateTime]::Now.ToString("yyyy-MMdd-HHmmss"), [Environment]::MachineName
        }
        [Void] SetEvent()
        {
            $This.Event = [ProjectEventTree]::New($This.Types)
        }
        [Object] PropertyItem([String]$Name,[Object]$Value)
        {
            Return Get-PropertyItem -Name $Name -Value $Value
        }
        [Object[]] PropertyObject([Object]$Object)
        {
            Return @( ForEach ($Item in $Object.PSObject.Properties)
            {
                Get-PropertyItem -Name $Item.Name -Value $Item.Value
            })
        }
        [Object[]] ViewProperties([Object]$Object)
        {
            Return $Object.PSObject.Properties | Get-PropertyItem
        }
        [String] CleanString([String]$String)
        {
            Return "({0})" -f [Regex]::Escape($String) 
        }
        [String] LogProperty([String]$Slot)
        {
            Return @( Switch ($Slot)
            {
                Rank { "Rank" } Name { "LogName" } Type { "LogType" } Path { "LogFilePath" }
            })
        }
        [Object] ViewCopy()
        {
            $Return                             = @( )
            $Buffer                             = ($This.ViewResult.Items | % Name | Sort-Object Length)[-1].Length
            ForEach ($Item in $This.ViewResult.Items)
            {
                $Split                          = $Item.Value -Split "`n"
                If ($Split.Count -eq 1)
                {
                    $Return                    += "{0}{1} : {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''), $Item.Value
                }
                If ($Split.Count -gt 1)
                {
                    ForEach ($X in 0..($Split.Count-1))
                    {
                        If ($X -eq 0)
                        {
                            $Return            += "{0}{1} : {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''),$Split[$X]
                        }
                        Else
                        {
                            $Return            += "{0}   {1}" -f ( " " * $Buffer -join ""), $Split[$X]
                        }
                    }
                }
            }
            Return $Return
        }
        [Void] ViewClear()
        {
            $This.ViewResult.Items.Clear()
        }
        ClearArchive()
        {
            $Item                               = Get-EventLogArchive -New
            $Type                               = $This.Types | ? Name -eq Archive
            $Type.Data                          = $Null
            $This.Reset($This.Archive.Items     , $Item.PSObject.Properties)
        }
        SetArchive([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid path specified"
            }
            
            $Item                               = Get-EventLogArchive -Path $Path
            $Type                               = $This.Types | ? Name -eq Archive
            $Type.Data                          = $Item
            $This.Reset($This.Archive.Items     , $Item.PSObject.Properties)
        }
        GetLogOutput()
        {
            $Flag                               = @(0,1)[$This.LogTotal.Text -ne 0]
            $This.Event.LogMain.Result          = $This.Project.Logs[$This.Event.LogMain.Index].Output
            If ($This.Event.LogMain.Result)
            {
                $This.Reset($This.LogOutputResult.Items,$This.Event.LogMain.Result)
            }
            $This.LogOutputProperty.IsEnabled   = $Flag
            $This.LogOutputFilter.Text          = ""
            $This.LogOutputFilter.IsEnabled     = $Flag
            $This.LogOutputRefresh.IsEnabled    = $Flag
            $This.LogOutputResult.IsEnabled     = $Flag
        }
    }

    [ProjectController]::New()
}