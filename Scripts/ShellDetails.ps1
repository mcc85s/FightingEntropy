Function Get-ShellMetadata
{
    [CmdLetBinding()]
    Param(
    [ValidateScript({Test-Path $_})]
    [Parameter(Mandatory,Position=0)][String]$Path)

    # // _________________________________________________________________________________________
    # // | Individual percentage object for conversion to STATUS, RANKING, and PERCENTAGE string |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ShellPercent
    {
        [Uint32] $Index
        [Uint32] $Step
        [Uint32] $Total
        [UInt32] $Percent
        [String] $String
        ShellPercent([UInt32]$Index,[UInt32]$Step,[Uint32]$Total)
        {
            $This.Index   = $Index
            $This.Step    = $Step
            $This.Total   = $Total
            $This.Calc()
        }
        Calc()
        {
            $Depth        = ([String]$This.Total).Length
            $This.Percent = ($This.Step/$This.Total)*100
            $This.String  = "({0:d$Depth}/{1}) {2:n2}%" -f $This.Step, $This.Total, $This.Percent
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    # // ___________________________________________________________________________________________________
    # // | This is a progress container, meant for dividing the work evenly, though < 100 doesn't work yet |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ShellProgress
    {
        [String] $Activity
        [String] $Status
        [UInt32] $Percent
        [Uint32] $Total
        [Uint32] $Depth
        [Uint32] $Step
        [Object[]] $Slot
        [Uint32[]] $Range
        ShellProgress([String]$Activity,[UInt32]$Total)
        {
            $This.Activity      = $Activity
            $This.Total         = $Total
            $This.Step          = [Math]::Round($Total/100)
            $This.Slot          = @( )
            ForEach ($X in 0..100)
            {
                $Count          = @($This.Step * $X;$Total)[$X -eq 100]

                $This.AddSlot($X,$Count,$Total) 
            }
            $This.Range         = $This.Slot.Step
            $This.Current()
        }
        AddSlot([UInt32]$Index,[UInt32]$Multiple,[UInt32]$Total)
        {
            $this.Slot         += [ShellPercent]::New($Index,$Multiple,$Total)
        }
        Increment()
        {
            $This.Percent ++
            $This.Current()
        }
        Current()
        {
            $This.Status = $This.Slot[$This.Percent]
        }
    }

    # // ____________________________________________________________________________________________
    # // | This is a file property container, meant for individual file property index, name, value |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ShellProperty
    {
        [Uint32] $Index
        [String] $Name
        [Object] $Value
        ShellProperty([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index 
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    # // ____________________________________________________________________________________________________
    # // | This is an interaction with the SHELL File System object, and all of its main properties/details |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ShellFile
    {
        [String]            $Mode
        [DateTime] $LastWriteTime
        [UInt64]          $Length
        [String]            $Name
        Hidden [String] $Fullname
        [Object]        $Property
        ShellFile([Object]$Folder,[Object]$File)
        {
            $Item               = Get-Item $File.Path
            $This.Mode          = $Item.Mode
            $This.LastWriteTime = $Item.LastWriteTime
            $This.Length        = $Item.Length
            $This.Name          = $Item.Name
            $This.Fullname      = $File.Path
            $Hash               = @{ } 
            0..255              | % { $Hash.Add($_,[ShellProperty]::New($_, $Folder.GetDetailsOf($folder,$_), $Folder.GetDetailsOf($File,$_))) }
            $This.Property      = @($Hash[0..255])
        } 
    }

    # // ________________________________________________________________________
    # // | This is the base shell object and all of it's child items/properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ShellBase
    {
        [String] $Path
        [Object] $Com
        [Object] $Root
        [Object] $Folder
        [Object] $File
        ShellBase([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid Path"
            }

            $This.Path   = $Path
            $This.Com    = New-Object -ComObject Shell.Application
            $This.Root   = $This.Com.Namespace($This.Path)
            $This.Folder = $This.Root.Self.GetFolder
            $This.File   = @()
            $Files       = @($This.Folder.Items())
            $P           = [ShellProgress]::New("Getting [~]",$Files.Count)

            Write-Progress -Activity $P.Activity -Status $P.Status -PercentComplete $P.Percent
            Switch ($Files.Count)
            {
                {$_ -eq 1}
                {
                    Write-Progress -Activity $P.Activity -Status $P.Status -PercentComplete $P.Percent
                    $This.File += [ShellFile]::New($This.Folder,$Files)
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($Files.Count-1))
                    {
                        If ($X -ne 0 -and $X -in $P.Range)
                        {
                            $P.Increment()
                            Write-Progress -Activity $P.Activity -Status $P.Status -PercentComplete $P.Percent
                        }
        
                        $This.File += [ShellFile]::New($This.Folder,$Files[$X])
                    }
                }
            }
            Write-Progress -Activity $P.Activity -Status $P.Status -Complete
        }
    }

    [ShellBase]::New($Path)
}
