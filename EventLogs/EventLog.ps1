# Collects every event log on a system using PowerShell... not done with it. 
Class EventLogList
{
    Hidden [Object] $Hash
    Hidden [String[]] $Names
    [Object[]] $Log
    EventLogList()
    {
        $This.Hash = @{ }
        $This.Log  = @( )
        Get-WinEvent -ListLog * | % { 
            
            Write-Host $_.LogName
            $This.Hash.Add($This.Hash.Count,$_.LogName) 
        }

        $This.Collect()
    }
    Collect()
    {
        ForEach ($X in 0..($This.Hash.Count-1))
        {
            $EventLog = $This.Hash[$X]
            Write-Host "Processing [~] $EventLog"
            Write-Progress -Activity "Collecting Event Log: [$EventLog]" -Status Starting -PercentComplete 0
            If ($EventLog -eq "Security")
            {
                Write-Host "Please wait, 'Security' log takes a moment to start loading."
            }
            $Swap     = Get-WinEvent -Logname $EventLog -EA 0

            If ($Swap)
            {
                ForEach ($I in 0..($Swap.Count-1))
                {
                    Write-Progress -Activity "Collecting Event Log: [$EventLog]" -Status "($I/$($Swap.Count))" -PercentComplete ($I * 100 / $Swap.Count)
                }

                Write-Progress -Activity "Collected Event Log: [$EventLog]" -Status Completed -Completed
            }
            Else
            {
                Write-Progress -Activity "Collected Event Log: [$EventLog], but it contained (0) entries." -Status Completed -Completed
            }

            $This.Log += $Swap | Sort-Object TimeCreated
        }
    }
}

$EventList = [EventLogList]::New()
