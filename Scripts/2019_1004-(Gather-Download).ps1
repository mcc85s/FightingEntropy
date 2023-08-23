# Script originally written (10/04/2019)

Function Gather-Download
{
    [CmdLetBinding()]Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Position=0,Mandatory,ValueFromPipeline=$True,HelpMessage="Source")][Alias("U")][String]$URL,
        [Parameter(Position=1,ValueFromPipeline=$True,HelpMessage="Destination")][Alias("D")][String]$Path="$Home\Downloads",
        [Parameter(Position=2,ValueFromPipeline=$True,HelpMessage="Action")][Alias("N")][String]$Info="$URL",
        [Parameter(Position=3,ValueFromPipeline=$True,HelpMessage="SHA256")][Alias("H")][Switch]$Hash
    )
    
    # Import the Bits Transfer module ("IPMO" is an alias for "Import-Module")
    Import-Module BitsTransfer

    # Set service point manager to "TLS 1.2"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Sets default target path, not necessary since $Path parameter has a default value of "$Home\Downloads"
    If (!$Path) 
    {
        $Path = "$Home\Downloads"
    }

    # Sets information, not necessary since $Info parameter has a default value of "$URL"
    If (!$Info)
    {
        $Info = $URL
    }

    # Creates an ordered hashtable which could be a (class object/PSObject) instead
    $File = [Ordered]@{

        Source      = "$URL"
        Destination = "$Path\$($URL.Split('/')[-1])"
        Description = "$Info"
    }

    # Starts the transfer and if it catches an exception, fallback to Invoke-WebRequest instead
    Start-BitsTranfer @File | ? { $_.Exception.Message } | % { IWR -Uri $URL -OutFile $File.Destination }

    # Sleep until the download is complete
    $File | ? { $_.JobState -eq "Transferring" -or $_.JobState -eq "Connecting" } | % { Start-Sleep -Milliseconds 150 }

    # Switch for the job state
    Switch ($File.JobState)
    {
        Transferred
        {
            Complete-BitsTransfer -BitsJob $File
        }
        Error
        {
            $File | Format-List
        }
    }

    # Capture the output to a(n) (object/variable)
    $Echo = $File | % { 
        
        [Ordered]@{ 
            
            Item = $_.Description; 
            URL  = $_.Source; 
            Save = $_.Destination 
        }
    }

    # If -Hash parameter is used, add that to the (object/variable)
    If ($Hash)
    {
        $Echo.Add("Hash",(Get-FileHash $Echo.Save -Algorithm SHA256).Hash)
    }

    # Returns the (variable/object) $Echo
    Return $Echo
}

$Drivers = @{ URL = "https://downloadmirror.intel.com/29074/igfx_win10_100.7212.exe" }

Gather-Download @Drivers -Hash

$Downloads = Get-ChildItem "$Home\downloads" -Filter "igfx_win10_100.7212"
$Downloads | % { Get-FileHash -Path $_.Fullname -Algorithm SHA256 | % { 

    Echo "File:$($_.Fullname)",
    "SHA256: $($_.Hash)"
}}

$Downloads | % { Get-FileHash -Path $_.Fullname -Algorithm MD5 | % {

    Echo "File:$($_.Fullname)",
    "MD5: $($_.Hash)"
}}
