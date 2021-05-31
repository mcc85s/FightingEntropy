Function Import-FEImage
{
    [CmdLetBinding()]
    Param(
    [Parameter(ParameterSetName=0,Mandatory)][Object]$ImageObject,
    [Parameter(ParameterSetName=1,Mandatory)][String]$Source,
    [Parameter(Mandatory)][String]$ShareName,
    [Parameter()][String]$Admin    = "Administrator",
    [Parameter()][String]$Password = "password", 
    [Parameter(Mandatory)][Object] $Key)

    Switch($PSCmdlet.ParameterSetName)
    {
        0
        {
            $Images = @( ) 

            ForEach ($Image in $ImageObject )
            {
                $Images += $Image
            }
        }

        1 
        { 
            If ( ! ( Test-Path $Source ) )
            {
                Throw "Invalid path"
            }

            $Images = Get-FEImage -Source $Source
        }
    }
    
    If (!$Images)
    {
        Throw "No images detected"
    }

    Import-Module (Get-MDTModule) -Verbose

    $Share       = Get-FEShare -Name $ShareName

    If (!($Share))
    {
        Throw "Share not detected"
    }
    
    New-PSDrive -Name $Share.Label -PSProvider MDTProvider -Root $Share.Path -Verbose -EA 0 

    $OS          = "$($Share.Label):\Operating Systems"
    $TS          = "$($Share.Label):\Task Sequences"
    $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]"
    $Control     = Get-FEModule -Control

    ForEach ( $Type in "Client","Server" )
    {
        $Version = $Images | ? InstallationType -eq $Type | % Version | Select-Object -Unique

        $OS,$TS | % { 
        
            If (!(Test-Path "$_\$Type"))
            {
                New-Item -Path $_ -Enable True -Name $Type -Comments $Comment -ItemType Folder -Verbose
            }

            If (!(Test-Path "$_\$Type\$Version"))
            {
                New-Item -Path "$_\$Type" -Enable True -Name $Version -Comments $Comment -ItemType Folder -Verbose
            }
        }
    }

    ForEach ( $Image in $Images )
    {
        $Type                   = $Image.InstallationType
        $Path                   = "$OS\$Type\$($Image.Version)"

        $OperatingSystem        = @{

            Path                = $Path
            SourceFile          = $Image.SourceImagePath
            DestinationFolder   = $Image.Label
        }
        
        Import-MDTOperatingSystem @OperatingSystem -Move -Verbose

        $TaskSequence           = @{ 
            
            Path                = "$TS\$Type\$($Image.Version)"
            Name                = $Image.ImageName
            Template            = "FE{0}Mod.xml" -f $Type
            Comments            = $Comment
            ID                  = $Image.Label
            Version             = "1.0"
            OperatingSystemPath = Get-ChildItem -Path $Path | ? Name -match $Image.Label | % { "{0}\{1}" -f $Path, $_.Name }
            FullName            = $Admin
            OrgName             = $Company
            HomePage            = $WebSite
            AdminPassword       = $Password
        }

        Import-MDTTaskSequence @TaskSequence -Verbose
    }
}
