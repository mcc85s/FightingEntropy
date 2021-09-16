Class _LocaleItem
{
    Hidden [String]$Type
    Hidden[String]$Line
    [String]$Name
    [String]$Value
    LocaleItem([UInt32]$Mode,[String]$Line)
    {
        $This.Type  = @("Keyboard","TimeZone")[$Mode]
        $This.Line  = $Line -Replace "\s+", " "
        $This.Name  = [Regex]::Matches($Line,"\`".+\`"").Value.Replace('"',"")
        $This.Value = [Regex]::Matches($Line,"\>.+\<").Value.TrimStart(">").TrimEnd("<")
    }
}
