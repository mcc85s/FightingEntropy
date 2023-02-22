Function Get-FolderHash
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$Path)

    Class FileHash
    {
        [String] $Name
        [String] $Hash
        FileHash([Object]$File)
        {
            $This.Name = $File.Name
            $This.Hash = Get-FileHash $File.Fullname | % Hash
        }
    }

    ForEach ($File in Get-ChildItem $Path)
    {
        [FileHash]::New($File)
    }
}
