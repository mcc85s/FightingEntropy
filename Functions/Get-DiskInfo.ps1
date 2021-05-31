Function Get-DiskInfo
{
    Class _DiskDrive
    {
        [String]       $Drive
        [String]       $Label
        [String]       $Total
        [String]        $Free
        [String]        $Used

        _DiskDrive([Object]$Disk)
        {
            @{  Size    = $Disk.Size / 1GB
                Free    = $Disk.FreeSpace / 1GB
                Used    = ( $Disk.Size - $Disk.FreeSpace ) / 1GB } | % {

                $This.Drive = $Disk.DeviceID
                $This.Label = $Disk.VolumeName
                $This.Total = "{0:n2} GB" -f $_.Size
                $This.Free  = "{0:n2} GB [{1:n2}%]" -f $_.Free, (($_.Free * 100) / $_.Size)
                $This.Used  = "{0:n2} GB [{1:n2}%]" -f $_.Used, (($_.Used * 100) / $_.Size)
            }
        }
    }

    ForEach ( $Disk in [wmiclass]"Win32_LogicalDisk" | % GetInstances | ? DriveType -eq 3 )
    {
        [_DiskDrive]::New($Disk)
    }
}
