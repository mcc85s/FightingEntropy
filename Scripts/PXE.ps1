$ScriptRoot="X:\Deploy\Scripts"
$DeployRoot=$ScriptRoot | Split-Path
$env:PSModulePath="$env:PSModulePath;$DeployRoot\Tools\Modules"
Import-Module Storage
Import-Module Microsoft.BDD.TaskSequenceModule
Import-Module PSDDeploymentShare
Import-Module PSDGather
Import-Module PSDUtility
Add-Type -AssemblyName PresentationFramework

Get-PSDLocalInfo
$MappingFile       = "X:\Deploy\Tools\Modules\PSDGather\ZTIGather.xml"
Invoke-PSDRules -FilePath "X:\Deploy\Scripts\Bootstrap.ini" -MappingFile $MappingFile

$tsenv:deployroot  = $tsenv:psddeployroots.Split(",")[0]
$DeployRoot        = $tsenv:deployroot

$Connect           = @{
 
	DeployRoot = $tsenv:deployroot
	Username   = "$tsenv:userdomain\$tsenv:userid"
	Password   = $tsenv:UserPassword
}

Get-PSDConnection @Connect
$Control           = Get-PSDContent -Content Control
Invoke-PSDRules -FilePath "$Control\CustomSettings.ini" -mappingfile $MappingFile

$Scripts           = Get-PSDContent -Content Scripts
$env:ScriptRoot    = $Scripts

$Modules           = Get-PSDContent -Content Tools\Modules
$env:PSModulePath  = "$env:PSModulePath;$Modules"

$Drive              = Get-PSDrive | ? Provider -match FileSystem | ? Root -eq $DeployRoot.ToString()
        $TSEnv              = @{ }
        ForEach ( $Item in Get-ChildItem TSEnv: )
        {
            $TSEnv.Add($Item.Name,$Item.Value)
        }
        $Root               = @{
                    
            DS              = Get-ChildItem DeploymentShare: -Recurse
            TSEnv           = $TSEnv
            Control         = "$($Drive.Name):\Control"
            Scripts         = "$($Drive.Name):\Scripts"
        }

(Get-Content "$($Root.Scripts)\Invoke-FEWizard.ps1") -join "`n" | IEX 
$Result = Invoke-FEWizard $Root
