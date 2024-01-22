<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 17:53:02                                                                  //
 \\==================================================================================================// 

    FileName   : Get-ThreadController.ps1 
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : This function manages runspace (individual threads/pool/throttling)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Incomplete

.Example
#>

Function Get-ThreadController
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(ParameterSetName=1)][UInt32]$Reserve)

    # // ====================================================
    # // | Individual thread index for processor throttling |
    # // ====================================================
    
    Class ThreadIndexObject
    {
        [UInt32]          $Index
        [UInt32]        $Enabled
        [UInt32]           $Core
        [Float]           $Value
        [String]          $Label
        ThreadIndexObject([UInt32]$Index,[UInt32]$Core,[Double]$Value)
        {
            $This.Index      = $Index
            $This.Core       = $Core
            $This.Value      = $Value
            $This.Label      = $This.ToString()
        }
        [String] ToString()
        {
            Return "({0}) {1:n2}%" -f $This.Core, ($This.Value*100)
        }
    }

    # // ======================================================
    # // | Entire collection of thread indexes for throttling |
    # // ======================================================

    Class ThreadIndex
    {
        [UInt32]     $Total
        [UInt32]  $Reserved
        [UInt32] $Available
        [Decimal]  $Segment
        [Object]   $Current
        [Object]   $Maximum
        [Object]   $Minimum
        [Object]    $Output = @( )
        Hidden [UInt32] $Debug
        ThreadIndex()
        {
            $This.Init(0,0)
        }
        ThreadIndex([Decimal]$Throttle)
        {
            $This.Init(0,$Throttle)
        }
        ThreadIndex([Switch]$Reserved,[UInt32]$Count)
        {
            $This.Init($Count,0)
        }
        ThreadIndex([Switch]$Reserved,[UInt32]$Count,[Decimal]$Throttle)
        {
            $This.Init($Count,$Throttle)
        }
        [UInt32] GetCount()
        {
            Return [Environment]::GetEnvironmentVariable("Number_Of_Processors")
        }
        [Double] GetLoad()
        {
            Return (Get-CimInstance Win32_Processor | % LoadPercentage)/100
        }
        Init([UInt32]$Reserved,[Decimal]$Throttle)
        {
            $This.Total       = $This.GetCount()
            $This.Reserved    = $Reserved
            $This.Available   = $This.Total - $This.Reserved
            $This.Stage()
            $This.Maximum     = $This.Output[0+$This.Reserved]
            $This.Minimum     = $This.Output[-1]

            ForEach ($Item in $This.Output | ? Value -le $This.Maximum.Value)
            {
                $Item.Enabled = 1 
            }

            Switch ($Throttle)
            {
                0       
                { 
                    $This.Current = $This.Maximum
                }
                Default 
                {
                    $This.AutoThrottle()
                }
            }
        }
        Stage()
        {
            $This.Output      = @( )
            $This.Segment     = (100/$This.Total)/100
            ForEach ($X in $This.Total..1)
            {
                $This.Add($X,$X*$This.Segment)
            }
        }
        Add([UInt32]$Cores,[Double]$Value)
        {
            $This.Output     += [ThreadIndexObject]::New($This.Output.Count,$Cores,$Value)
        }
        [UInt32] GetInt([UInt32]$Slot)
        {   
            $Y = 0
            Switch ($Slot)
            {
                0 { $Y = @(($This.Output | ? Enabled)[0];($This.Output)[0])[!$This.Reserved].Value } 1 { $Y = $This.GetLoad() } 2 { $Y = $This.Segment }
            }

            Return ($Y * 1000)
        }
        [UInt32] Factor([Double]$X)
        {
            Return [UInt32]($X * 1000)
        }
        AutoThrottle()
        {
            $Y  = @() 
            $Y += $This.GetInt(0) - $This.GetInt(1)
            $Y += $This.GetInt(2)
            $Y += $Y[0] % $Y[1]
            $Y += ($Y[0] - $Y[2])/$Y[1]
            $Y += ($Y[-1] + [UInt32](($Y[1] - $Y[2]) -lt ($Y[1] * 0.5)))

            If ($This.Debug -eq 1)
            {
                $L = "Target  : ;Segment : ;Remain  : ;Factor  : ;Final   : " -Split ";"
                $C = 0
                Do
                {
                    [Console]::WriteLine($L[$C]+$Y[$C])
                    $C ++
                }
                Until ($C -eq 5) 
            }

            $This.Current     = $This.Output | ? Core -eq $Y[-1]
        }
        [Object[]] GetOutput()
        {
            $Return  = @( ) 
            $Return += $This | Format-Table
            $Return += $This.Output | Format-Table
            
            Return $Return
        }
        [String] ToString()
        {
            Return "({0})" -f ("Total: "+$This.Total+" / Reserved: "+$This.Reserved+" / Available: "+$This.Available+" / Segment: "+$This.Segment)
        }
    }

    # // =======================================================
    # // | Used to track console logging, similar to Stopwatch |
    # // =======================================================

    Class ThreadTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        ThreadTime([String]$Name)
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

    # // ========================================
    # // | Single object that displays a status |
    # // ========================================

    Class ThreadStatus
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        ThreadStatus([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
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

    # // =========================================================================
    # // | A collection of status objects, uses itself to create/update messages |
    # // =========================================================================

    Class ThreadStatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        ThreadStatusBank()
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
            $This.Status = [ThreadStatus]::New($This.Output.Count,$This.Elapsed(),$This.Status.State,$This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [ThreadStatus]::New($This.Output.Count,$This.Elapsed(),$State,$Status)
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
            $This.Start  = [ThreadTime]::New("Start")
            $This.End    = [ThreadTime]::New("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([Int32]$State,[String]$Status)
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
    
    # // ==================================================
    # // | For each individual name/value thread property |
    # // ==================================================

    Class ThreadProperty
    {
        [String] $Name
        [Object] $Value
        ThreadProperty([String]$Name,[Object]$Value)
        {
            $This.Name = $Name
            $This.Value = $Value
        }
    }
    
    # // =================================================
    # // | To be phased out, tracks progress of a thread |
    # // =================================================

    Class ThreadProgression
    {
        [UInt32] $Index
        [Object] $Target
        Hidden [Object] $Load
        [Object] $File
        [UInt32] $Current
        [UInt32] $Total
        [Float] $Percent
        ThreadProgression([UInt32]$Index,[String]$Target,[Object]$Load,[Object]$File)
        {
            $This.Index   = $Index
            $This.Target  = $Target
            $This.Load    = $Load
            $This.File    = $File
            $This.Total   = $Load.Keys.Count
            $This.Percent = 0.00
        }
        Update()
        {
            $Bytes         = [System.IO.File]::ReadAllBytes($This.File)
            If (!$Bytes)
            {
                $This.Percent = 0.00
                $This.Current = 0
            }
            Else
            {
                $String       = ([Char[]]($Bytes) -join '') -Replace "\(|\)|\%","" -Split " "
                $This.Current = $String[1].Split("/")[0]
                $This.Percent = [Math]::Round($This.Current*100/$This.Total,2)
            }
        }
        [String] ToString()
        {
            Return "[{0}] : ({1}%) ({2}/{3})" -f $This.Index, $This.Percent, $This.Current, $This.Total
        }
    }

    # // ============================================================
    # // | To be phased out, tracks PERCENTAGE of THREAD completion |
    # // ============================================================

    Class ThreadProgressionList
    {
        Hidden [Object]  $Timer = [System.Diagnostics.Stopwatch]::New()
        [String]          $Time
        [String]        $Status
        [Float]        $Percent
        Hidden [Object] $Output = @( )
        ThreadProgressionList()
        {
            $This.Time   = $This.Timer.Elapsed.ToString()
            $This.Status = "Awaiting initialization"
        }
        Load([UInt32]$Index,[String]$Target,[Object[]]$Load,[Object]$File)
        {
            $This.Output += [ThreadProgression]::New($Index,$Target,$Load,$File)
        }
        Start()
        {
            $This.Timer.Start()
            $This.Status = "Processing"
            $This.Update()
        }
        Complete()
        {
            $This.Timer.Stop()
            $This.Update()
        }
        [Object] Update()
        {
            ForEach ($Item in $This.Output)
            {
                $Item.Update()
            }
            $TotalPercent = ( $This.Output.Percent -join "+" ) | Invoke-Expression
            $This.Percent = [Math]::Round($TotalPercent/$This.Output.Count,2)
            $This.Time    = $This.Timer.Elapsed.ToString()
            Return @( 
                $This;
                $This.Output | % ToString
            )
        }
    }
        
    # // ================================================================================
    # // | An individual thread, with its' various information for tracking and logging |
    # // ================================================================================

    Class ThreadObject
    {
        Hidden [UInt32] $Slot
        [UInt32] $Index
        Hidden [String] $Type
        Hidden [String] $InstanceId
        Hidden [Object] $PowerShell
        Hidden [Object] $Handle
        [Object] $Status
        Hidden [String] $Time
        [UInt32] $Complete
        Hidden [Object] $Output
        ThreadObject([UInt32]$Slot,[UInt32]$Index,[Object]$PowerShell)
        {
            $This.Slot           = $Slot
            $This.Index          = $Index
            $This.Type           = Switch ($Index) { 0 { "Main" } Default { "Sub" } }
            $This.InstanceId     = $PowerShell.InstanceId
            $This.PowerShell     = $PowerShell
            $This.Handle         = $Null
            $This.Status         = [ThreadStatusBank]::New()
            $This.Output         = $Null
        }
        BeginInvoke()
        {
            $This.Status.Initialize()
            $This.Time           = $This.Status.Elapsed()
            $This.Complete       = 0
            $This.Handle         = $This.PowerShell.BeginInvoke()
        }
        EndInvoke()
        {
            If ($This.Complete -ne 1)
            {
                $This.Status.Finalize()
                $This.Time       = $This.Status.Span
                $This.Complete   = 1
            }
            
            $This.Output         = $This.PowerShell.EndInvoke($This.Handle)
            $This.PowerShell.Dispose()
        }
        AddScript([String]$Script)
        {
            $This.PowerShell.AddScript($Script,$True)
            If ($? -eq $True)
            {
                $This.Status.Update(1,"PowerShell [+] Added: script for ($($This.InstanceID))")
            }
        }
        IsComplete()
        {
            If ($This.Complete -eq 0)
            {
                Switch ([UInt32]$This.Handle.IsCompleted)
                {
                    0 
                    { 
                        $This.Time         = $This.Status.Elapsed()
                        $This.Status.Current()
                    }
                    1
                    {
                        $This.Time         = $This.Status.Elapsed()
                        $This.Status.Finalize()
                        $This.Complete     = 1
                    }
                }
            }
        }
        [Object] Config()
        {
            Return @($This | Select-Object Slot, Index, Type, InstanceId, PowerShell, Handle, Status, Time, Complete)
        }
        [Object] Current()
        {
            Return @($This | Select-Object Index, Status, Complete)
        }
    }
        
    # // ==========================================================================================
    # // | Meant to comparmentalize individual thread objects, which MAY include multiple threads |
    # // ==========================================================================================

    Class ThreadSlot
    {
        [UInt32]           $Index
        [String]            $Name
        [UInt32]           $Count
        [Object]         $Factory
        [Object]          $Status
        [Object]            $Time
        [Object]          $Thread
        Hidden [UInt32] $Complete
        Hidden [UInt32] $Disposed
        ThreadSlot([UInt32]$Index,[String]$Name,[UInt32]$Count,[Object]$Factory)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Count    = $Count
            $This.Factory  = $Factory
            $This.Status   = [ThreadStatusBank]::New()
            $This.Status.Initialize()
            $This.Time     = [System.Diagnostics.Stopwatch]::New()
            $This.Thread   = @( )

            $This.AllocateThreads()
        }
        ThreadSlot([UInt32]$Index,[String]$Name,[Object]$Factory)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Count    = 0
            $This.Factory  = $Factory
            $This.Status   = [ThreadStatusBank]::New()
            $This.Status.Initialize()
            $This.Time     = [System.Diagnostics.Stopwatch]::New()
            $This.Thread   = @( )
        }
        SetCount([Object]$Control,[UInt32]$Target)
        {
            If ($This.Count -ne 0)
            {
                $This.Update(-1,"SetCount [!] Exception: Count has already been adjusted.")
            }
            If ($Control.GetType().Name -ne "ThreadControl")
            {
                $This.Update(-1,"SetCount [!] Exception: Invalid [ThreadControl] object.")
            }
            ElseIf ($Control.GetProjectedCount($Target) -gt $Control.Throttle.Core)
            {
                $This.Update(-1,"SetCount [!] Exception: Projected count higher than throttle.")
            }
            Else
            {
                $This.Count        = $Target
                $Control.Allocated = $Control.GetProjectedCount($Target)
                $This.Update(1,"SetCount [+] Success: ThreadSlot count adjusted to ($Target) threads.")
            }
        }
        AllocateThreads()
        {
            If ($This.Count -eq 0)
            {
                $This.Update(-1,"Exception [!] No threads to allocate")
            }
            If ($This.Count -eq 1)
            {
                $This.AddThread($This.Index,0,$This.Factory)
            }
            If ($This.Count -gt 1)
            {
                ForEach ($X in 0..($This.Count-1))
                {
                    $This.AddThread($This.Index,$X,$This.Factory)
                }
            }
        }
        [Object] Current()
        {
            $This.Status.Current()
            Return $This.Status.Last()
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.Status.Update($State,$Status)
            Return $This.Status.Last()
        }
        AddThread([UInt32]$Slot,[UInt32]$Index,[Object]$Factory)
        {
            $Type              = $Factory.GetType().Name
            $PowerShell        = [PowerShell]::Create($Factory.InitialSessionState)
            $PowerShell.$Type  = $Factory
            $This.Thread      += [ThreadObject]::New($Slot,$Index,$PowerShell)
            $This.Update(1,"ThreadSlot [+] Added thread [$Index]")
        }
        [UInt32] Query([UInt32]$Mode)
        {
            Return ($This.Thread.Handle | ? IsCompleted -eq $Mode).Count
        }
        BeginInvoke()
        {
            $This.Update(0,"ThreadSlot [~] Initializing Invocation: BeginInvoke()")
            $This.Time.Start()
            ForEach ($Item in $This.Thread)
            {
                $Item.BeginInvoke()
                $This.Update(1,"Opening [~] [Thread]://(Rank: $($Item.Rank), InstanceId: $($Item.PowerShell.InstanceId))")
            }
            $This.Update(1,"ThreadSlot [+] Initialized Invocation: BeginInvoke()")
        }
        CheckInvoke()
        {
            If ($This.Complete -ne 1)
            {
                ForEach ($Thread in $This.Thread)
                {
                    If ($Thread.Handle.IsCompleted -and $Thread.Complete -eq 0)
                    {
                        $Thread.IsComplete()
                        $This.Update(1,"Complete [+] Thread[$($Thread.Index)]")
                    }
                }

                If ($This.Query(0) -eq 0)
                {
                    $This.Complete = 1
                }
            }
        }
        EndInvoke()
        {
            If ($This.Complete -ne 1)
            {
                $Ct = $This.Query(0)
                Throw "Exception [!] ($Ct) threads still running."
            }

            $This.Update(0,"ThreadSlot [~] Initializing Invocation: EndInvoke()")
            $This.Thread | % { 
                
                $_.EndInvoke()
                $This.Update(1,"Closing [~] [Thread]://(Rank: $($_.Rank), InstanceId: ($($_.PowerShell.InstanceId))")    
            }

            $This.Update(1,"ThreadSlot [+] Initialized Invocation: EndInvoke()")
            $This.Status.Finalize()
        }
        [Void] Dispose()
        {
            $Runspaces = Get-Runspace | ? InstanceId -in $This.Thread.PowerShell.InstanceId
            $This.Update(0,"Disposing [~] ($($Runspaces.Count)) runspaces.")
            ForEach ($Runspace in $Runspaces)
            {
                $Runspace.Dispose()
                $This.Update(1,"Disposed [+] [Thread]://(InstanceId: $($Runspace.InstanceId))")
            }
            $This.Update(1,"Disposed [+] ($($Runspaces.Count)) runspaces.")
            $This.Disposed = 1
        }
        [Object] Output()
        {
            Return @(
            $This | Select-Object Rank, Name, Count, Status, Time, Thread | Format-Table
            $This.Threads | Select-Object Id, Time, Complete | Format-Table
            )
        }
        [Object] FullOutput()
        {
            Return @(
            $This | Select-Object Rank, Name, Count, Status, Time, Thread | Format-Table
            $This.Threads | Select-Object  Id, PowerShell, Handle, Status, Time, Complete | Format-Table
            )
        }
        [String] Progress()
        {
            Return ( "Elapsed: [{0}], Completed ({1}/{2})" -f $This.Status.Elapsed(), $This.Complete, $This.Count )
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    
    # // ================================================================================
    # // | To be phased out, meant to filtrate various properties of the thread objects |
    # // ================================================================================

    Class ThreadSubcontrol
    {
        [Object]  $Status
        [Object]    $Last
        [Object]    $Slot
        [Object]  $Object
        ThreadSubcontrol()
        {
            $This.Slot   = @( )
            $This.Object = @( )
            $This.Initialize()
        }
        [Object] Current()
        {
            $This.Last = $This.Status.Current()
            Return $This.Last
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.Last = $This.Status.Update($State,$Status)
            Return $This.Last
        }
        Initialize()
        {
            $This.Status = [ThreadStatusBank]::New()
            $This.Status.Initialize()
            $This.Update(1,"Subcontrol [+] Status: Initialized")
        }
        Add([Object]$Object)
        {
            Switch ($Object.GetType().Name)
            {
                ThreadSlot
                { 
                    $This.Slot   += $Object
                    $This.Update(1,  "ThreadSlot [+] Success: ($($Object.Name)) added.")
                }
                ThreadObject 
                { 
                    $This.Object += $Object
                    $This.Update(1,"ThreadObject [+] Success: ($($Object.Name)) added.") 
                }
            }
        }
        [Object] Get([UInt32]$Type,[String]$Prop,[Object]$Value)
        {
            $Return = @($This.Slot,$This.Object)[$Type] | ? $Prop -match $Value 
            If (!$Return)
            {
                $Return = $Null
            }

            Return $Return
        }
    }
    
    # // =================================================================================
    # // | Master thread controller object, allows multiple SLOTS with multiple THREADS, |
    # // | as well as to dynamically adjust the THROTTLE, or shift used threads around   |
    # // | Still rather experimental                                                     |
    # // =================================================================================
    
    Class ThreadControl
    {
        [Object]            $Index
        [Object]         $Throttle
        [Object]          $Maximum
        [Object]          $Minimum
        [String]             $Type
        [Object]          $Factory
        [Object]             $Slot = @( )
        [UInt32]        $Allocated
        [UInt32]        $Projected
        [UInt32]         $Disposed
        [Object]          $Session
        [Object]         $Assembly = @( )
        [Object]         $Function = @( )
        [Object]         $Variable = @( )
        [Object]         $Argument = @( )
        [Object]          $Command = @( )
        [Object]           $Status
        [Object]             $Last
        ThreadControl([UInt32]$Reserve)
        {
            $This.Initialize()
            $This.Index = [ThreadIndex]::New($True,$Reserve)
            $This.Update(1,"Throttle [+] Index: $($This.Index)")
            $This.Init()
        }
        ThreadControl()
        {
            $This.Initialize()
            $This.Index = [ThreadIndex]::New()
            $This.Update(1,"Throttle [+] Index: $($This.Index)")
            $This.Init()
        }
        [Object] Current()
        {
            $This.Last = $This.Status.Current()
            Return $This.Last
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.Last = $This.Status.Update($State,$Status)
            Return $This.Last
        }
        Initialize()
        {
            $This.Status = [ThreadStatusBank]::New()
            $This.Status.Initialize()
            $This.Update(1,"Control [+] Status: Initialized")
        }
        Init()
        {
            $This.Throttle               = $This.Index.Current
            $This.Update(1,"Throttle [+] Current: $($This.Throttle)")

            $This.Maximum                = $This.Index.Maximum
            $This.Update(1,"Throttle [+] Maximum: $($This.Maximum)")

            $This.Minimum                = $This.Index.Minimum
            $This.Update(1,"Throttle [+] Minimum: $($This.Minimum)")

            $This.Session                = $This.NewSessionState()
        }
        AutoThrottle()
        {
            $This.Index.AutoThrottle()
            If ($This.Index.Current -ne $This.Throttle)
            {
                $This.Throttle = $This.Index.Current
                $This.Update(1,"Throttle [+] AutoThrottle: $($This.Throttle)")
            }
        }
        [Object] NewSessionState()
        {
            $Item = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
            If ($Item)
            {
                $This.Update(1,"Session [+] Created: [Initial Session State]")
                $Item.ThreadOptions  = "ReuseThread"
                $Item.ApartmentState = [Threading.ApartmentState]::STA
                Return $Item
            }
            Else
            {
                $This.Update(-1,"Session [!] Failed: [Initial Session State] NOT created...")
                Return $Null
            }
        }
        AddAssembly([String]$Name)
        {
            If (!$This.Session)
            {
                $This.NewSessionState()
            }

            Switch ($Name -in (Get-AssemblyList).Name)
            {
                $True
                {
                    $Object          = [System.Management.Automation.Runspaces.SessionStateAssemblyEntry]::New($Name)
                    $This.Session.Assemblies.Add($Object)
                    $AssemblyNames   = $This.Session.Assemblies | % { [Regex]::Matches($_.Name,"(^\S+)").Value.TrimEnd(",") }
                    If ($Name -in $AssemblyNames)
                    {
                        $This.Update( 1,"Session [+] Success, [Assembly: ($Name)] added.")
                        $This.Assembly += $Object
                    }
                    Else
                    {
                        $This.Update(-1,"Session [!] Failed, unable to add [Assembly: ($Name)].")
                    }
                }
                $False
                {
                    $This.Update(-1,"Session [!] Failed, unable to add [Assembly: ($Name)], because it isn't loaded.")
                }
            }
        }
        AddFunction([String]$Name)
        {
            If (!$This.Session)
            {
                $This.NewSessionState()
            }

            Switch ($Name -in (Get-ChildItem Function:).Name)
            {
                $True
                {
                    $Content         = Get-Content Function:\$Name
                    $Object          = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Name,$Content)
                    $This.Session.Commands.Add($Object)
                    If ($Content -in $This.Session.Commands.Definition)
                    {
                        $This.Update( 1,"Session [+] Success, [Function: ($Name)] added.")
                        $This.Function  += $Object
                    }
                    Else
                    {
                        $This.Update(-1,"Session [!] Failed, unable to add [Function: ($Name)].")
                    }
                }
                $False
                {
                    $This.Update(-1,"Session [!] Failed, unable to add [Function: ($Name)], because it isn't loaded.")
                }
            }
        }
        AddVariable([String]$Name,[Object]$Value,[String]$Description)
        {
            If (!$This.Session)
            {
                $This.NewSessionState()
            }

            Switch ($Name -in (Get-ChildItem Variable:).Name)
            {
                $True
                {
                    $Object          = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::New($Name,$Value,$Description)
                    $This.Session.Variables.Add($Object)
                    If ($Name -in $This.Session.Variables.Name)
                    {
                        $This.Update( 1,"Session [+] Success, [Variable: ($Name)] added.")
                        $This.Variable += $Object
                    }
                    Else
                    {
                        $This.Update(-1,"Session [!] Failed, unable to add [Variable: ($Name)].")
                    }
                }
                $False
                {
                    $This.Update(-1,"Session [!] Failed, unable to add [Variable: ($Name)], because it isn't loaded.")
                }
            }
        }
        SetFactoryType([String]$Type)
        {
            Switch ($Type)
            {
                RunspacePool
                {
                    $This.Type       = "RunspacePool"
                    $This.Factory    = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool($This.Session)
                    If ($This.Factory)
                    {
                        $This.Factory.SetMinRunspaces(1)                   | Out-Null
                        $This.Factory.SetMaxRunspaces($This.Throttle.Core) | Out-Null
                        $This.Disposed   = 0
                        $This.Update(1,"RunspaceFactory [+] Created: $($This.Type)")
                    }
                    Else
                    {
                        $This.Update(-1,"RunspaceFactory [!] Exception: $PSItem")
                    }
                }
                Runspace
                {
                    $This.Type       = "Runspace"
                    $This.Factory    = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($This.Session)
                    If ($This.Factory)
                    {
                        $This.Disposed = 0
                        $This.Update(1,"RunspaceFactory [+] Created: $($This.Type)")
                    }
                    Else
                    { 
                        $This.Update(-1,"RunspaceFactory [!] Exception: $PSItem")
                    }
                }
                Default
                {
                    $This.Update(-1,"RunspaceFactory [!] Exception: Must select (Runspace/RunspacePool)")
                }
            }
        }
        [Object[]] Config([String]$Name)
        {
            If (!$This.Factory)
            {
                $This.Update(-1,"RunspaceFactory [!] Exception: (RunspaceFactory) not yet created, or has been disposed")
                Return $Null
            }
            Else
            {
                Return @( $This.Factory.PSObject.Properties | % { [ThreadProperty]::New($_.Name,$_.Value) })
            }
        }
        [UInt32] GetProjectedCount([UInt32]$Count)
        {
            Return ($This.Allocated + $Count)
        }
        [Void] ThreadFactory()
        {
            If (!$This.Factory -or $This.Disposed)
            {
                $This.Update(-1,"ThreadFactory [!] Failed: (RunspaceFactory) either null, or disposed")
            }
            Else
            {
                $This.Update(1,"ThreadFactory [+] Passed: ($($This.Type))")
            }
        }
        [Void] ThreadSlotName([String]$Name)
        {
            If ($This.GetThreadSlot($Name))
            {
                $This.Update(-1,"ThreadSlotName [!] Failed: ($Name) already exists.")
            }
            Else
            {
                $This.Update(1,"ThreadSlotName [+] Passed: ($Name) available.")
            }
        }
        [Void] ThreadSlotCount([UInt32]$Count)
        {
            If ($This.GetProjectedCount($Count) -gt $This.Throttle.Core)
            {
                $This.Update(-1,"ThreadSlotCount [!] Failed: ($($This.GetProjectedCount($Count))) exceeds the current throttle setting: ($($This.Throttle.Core)).")
            }
            Else
            {
                $This.Update(1,"ThreadSlotCount [+] Passed: ($($This.GetProjectedCount($Count))) thread(s) available.")
            }
        }
        [Void] NewThreadSlot([String]$Name)
        {
            ForEach ($Item in $This.ThreadFactory(), $This.ThreadSlotName($Name))
            {
                If ($This.Last.State -ne 1)
                {
                    Throw $This.Last.Status
                }
            }

            $This.Slot      += [ThreadSlot]::New($This.Slot.Count,$Name,$This.Factory)
            $This.Update(1,"ThreadSlot [+] ($Name) added.")
        }
        [Void] NewThreadSlot([UInt32]$Count,[String]$Name)
        {
            ForEach ($Item in $This.ThreadFactory(), $This.ThreadSlotName($Name), $This.ThreadSlotCount($Count))
            {
                If ($This.Last.State -ne 1)
                {
                    Throw $This.Last.Status
                }
            }

            $This.Slot      += [ThreadSlot]::New($This.Slot.Count,$Name,$Count,$This.Factory)
            $This.Allocated += $Count
            $This.Update(1,"ThreadSlot [+] ($Name) added.")
        }
        RemoveThreadSlot([String]$Name)
        {
            $xThreadSlot = $This.GetThreadSlot($Name)
            If ($xThreadSlot)
            {
                $This.Update(0,"ThreadSlot [~] ($Name) removing...")
                $xThreadSlot.Dispose()
                $This.Update(1,"ThreadSlot [+] ($Name) removed.")
            }
            $This.Slot       = $This.Slot | ? Name -ne $Name
            $This.Allocated  = $This.Slot.Thread.Count
            $This.Update(1,"ThreadSlot [+] Set: Allocated ($($This.Allocated)) thread count.") 
        }
        [ThreadSlot] GetThreadSlot([String]$String)
        {
            If ($String -match "(^\d+$)" -and [UInt32]$String -in $This.Slot.Index)
            {
                Return $This.Slot[[UInt32]$String]
            }
            ElseIf ($String -in $This.Slot.Name)
            {
                Return $This.Slot | ? Name -eq $String
            }
            Else
            {
                Return $Null
            }
        }
        [Void] SetThreadSlotCount([Object]$Object,[UInt32]$Count)
        {
            If ($Object.GetType().Name -ne "ThreadSlot")
            {
                $Object = $This.GetThreadSlot($Object)
                Switch ([UInt32](!!$Object))
                {
                    0 { $This.Update(-1,"ThreadSlot [!] Not found by that Name")  }
                    1 { $This.Update(1,"ThreadSlot [+] Found by that name/index") }
                }
            }

            $This.ThreadSlotCount($Count)
            Switch ($This.Last.State)
            {
                0 { Throw $This.Last.Status } 1 { $Object.SetCount($This,$Count); $Object.AllocateThreads() } 
            }
        }
        [Object] NewThreadSubcontrol()
        {
            Return [ThreadSubcontrol]::New()
        }
        DisposeThreadSlot([String]$Name)
        {
            If ($Name -notin $This.Slot.Name)
            {
                Throw "Invalid Name"
            }

            $Item           = $This.Slot | ? Name -eq $Name
            If ($Item.Disposed -eq 1)
            {
                Throw "ThreadSlot [!] [$Name] has already been disposed."
            }

            If ($Item.Disposed -eq 0)
            {
                $Item.Dispose()
                $This.Allocated = $This.Allocated - $Item.Count
                Write-Host "ThreadSlot [+] [$Name] has been disposed, and the threads have been returned"
            }
        }
        DisposeThreadSlot([UInt32]$Index)
        {
            If ($Index -notin $This.Slot.Index)
            {
                Throw "Invalid Index"
            }

            $Item        = $This.Slot | ? Index -eq $Index
            If ($Item.Disposed -eq 1)
            {
                Throw "ThreadSlot [!] [$($Item.Name)] has already been disposed."
            }

            If ($Item.Disposed -eq 0)
            {
                $Item.Dispose()
                $This.Allocated = $This.Allocated - $Item.Count
                Write-Host "ThreadSlot [+] [$($Item.Name)] has been disposed, and the threads have been returned"
            }
        }
        [String[]] ToString()
        {
            Return @(
            " ","Indexing",("-" * 120 -join ''),
            "Index     : $($This.Index.ToString())",
            "Throttle  : $($This.Throttle.ToString())",
            "Maximum   : $($This.Maximum.ToString())",
            "Minimum   : $($This.Minimum.ToString())",
            " ","Controls",("-" * 120 -join ''),
            "Type      : $($This.Type.ToString())",
            "Factory   : $($This.Factory.ToString()) ->",
            "Slot      : {$($This.Slot -join ", ")}",
            "Allocated : $($This.Allocated.ToString())",
            "Disposed  : $($This.Disposed.ToString())",
            " ","Session",("-" * 120 -join ''),
            "Session   : $($This.Session.ToString()) ->",
            "Assembly  : {$($This.Assembly.Name -join ", ")}",
            "Function  : {$($This.Function.Name -join ", ")}",
            "Variable  : {$($This.Variable.Name -join ", ")}",
            "Argument  : {$($This.Argument.Name -join ", ")}",
            "Command   : {$($This.Command.Name  -join ", ")}",
            " ")
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [ThreadControl]::New() } 1 { [ThreadControl]::New($Reserve) }
    }
}
