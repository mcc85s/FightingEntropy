Function Get-EnvironmentKey
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Path,
        [Parameter()][Switch]$Convert
    )

    If (!(Test-Path $Path))
    {
        Throw "Invalid path"
    }

    If (Get-Item $Path | ? Extension -ne ".csv")
    {
        Throw "Invalid environment key"
    }

    $Key = Import-CSV $Path
    If ($Convert)
    {
        $Key = $Key | ConvertTo-Json
    }

    $Key
}
