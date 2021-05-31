Function Remove-FEShare
{
    [CmdLetBinding()]Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(ParameterSetName=0,ValueFromPipeline=$True,Mandatory)][String]$ShareName,
    [Parameter(ParameterSetName=1,ValueFromPipeline=$True,Mandatory)][Object]$Share)
    
    If ( $ShareName )
    {
        $Share = Get-FEShare -Name $ShareName
    }

    If (!($Share))
    {
        Write-Theme "Share [!] Not found" 12,4,15,0
    }
    
    If ($Share)
    {
        Import-Module ("${env:ProgramFiles}\{0} {1} {2}\Bin\{0}{1}{2}.psd1" -f "Microsoft","Deployment","Toolkit")

        If ( Get-SMBShare -Name $Share.Name -EA 0 )
        {
            Remove-SMBShare -Name $Share.Name -Force -Verbose -EA 0
        }

        If ( Get-MDTPersistentDrive | ? Name -eq $Share.Label -EA 0)
        {
            Remove-MDTPersistentDrive -Name $Share.Label -Verbose
        }

        If ( Get-PSDrive -Name $Share.Label -EA 0 )
        {
            Remove-PSDrive -Name $Share.Label -Force -Verbose
        }
    
        If ( Get-Item -Path $Share.Path -EA 0 ) 
        {
            Remove-Item -Path $Share.Path -Force -Recurse -Verbose
        }
    }
}
