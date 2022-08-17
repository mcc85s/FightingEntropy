$Output = @( )
$Lines  = $Content -Split "`n"
ForEach ($X in 0..($Lines.Count-1))
{
    If ($Lines[$X].Length -gt 104)
    {
        $Array           = [Char[]]$Lines[$X]
        $Tray            = ""
        ForEach ($I in 0..($Array.Count-1))
        {
            If ($Tray.Length -eq 104)
            {
                $Output += $Tray
                $Tray    = ""
            }
            $Tray       += $Array[$I]
        }
        $Output         += $Tray
    }
    ElseIf ($Lines[$X].Length -le 104 -and $Lines[$X].Length -gt 0)
    {
        $Output         += $Lines[$X]
    }
    ElseIf ($Lines[$X].Length -eq 0)
    {
        $Output         += " " * 104 -join ''
    } 
}
