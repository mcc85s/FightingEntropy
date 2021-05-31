Function New-ACLObject
{
    Param(
    [String]                                               $Sam ,
    [System.Security.AccessControl.FileSystemRights]    $Rights ,
    [System.Security.AccessControl.AccessControlType]   $Access ,
    [System.Security.AccessControl.InheritanceFlags]   $Inherit ,
    [System.Security.AccessControl.PropagationFlags] $Propagate )
    
    Return [System.Security.AccessControl.FileSystemAccessRule]::New($Sam,$Rights,$Inherit,$Propagate,$Access)
}
