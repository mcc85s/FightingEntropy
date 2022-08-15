# Required to access System.Device.Location namespace
Add-Type -AssemblyName System.Device

# Create the required object
$GeoWatcher = [System.Device.Location.GeoCoordinateWatcher]::New() 
$GeoWatcher.Start()

# Begin resolving current locaton
While ($GeoWatcher | ? Status -ne Ready | ? Permission -ne Denied)
{
    # Wait for discovery.
    Start-Sleep -Milliseconds 100
}  

If ($GeoWatcher.Permission -eq 'Denied')
{
    Write-Error 'Access Denied for Location Information'
}
Else
{
    # Select the relevant results.
    $GeoWatcher.Position.Location | Select-Object Latitude, Longitude
}
