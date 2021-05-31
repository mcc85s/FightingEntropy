Function Export-Ini # Originally based on Oliver Lipkau's Outfile-Ini script
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][String]$Path,
    [Parameter(Mandatory)][Hashtable]$Value)

    Class _Conversion
    {
        [String]       $Path
        [Hashtable]   $Value
        [Object]   $Encoding = (New-Object System.Text.UTF8Encoding $False)
        [Object]     $Output

        _Conversion([String]$Path,[Hashtable]$Value)
        {
            If (!(Test-Path ($Path | Split-Path -Parent)))
            {
                Throw "Invalid path"
            }

            If (Test-Path $Path)
            {
                Write-Host "Overwriting... $Path"
            }

            $This.Path   = $Path
            $This.Value  = $Value
            $This.Output = @( )

            ForEach ( $Item in $Value.GetEnumerator() )
            {     
                If ( $Item.Value.GetType().Name -eq "Hashtable" )
                {
                    $This.Output += "[$($Item.Name)]"
                    $Value.$($Item.Name).GetEnumerator() | % { $This.Output += "$($_.Name)=$($_.Value)" }
                    $This.Output += ""
                }
            
                Else
                {
                    $This.Output += "$($Item.Name)=$($Item.Value)"
                    $This.Output += ""
                }
            }

            [System.IO.File]::WriteAllLines($This.Path,$This.Output,$This.Encoding)
        }
    }

    [_Conversion]::new($Path,$Value)
}
