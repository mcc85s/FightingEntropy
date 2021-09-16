Class _LocaleList
{
    [String]$Path
    Hidden [Object]$Stack
    [Object]$Keyboard
    [Object]$Timezone

    LocaleList([String]$Path)
    {
        $This.Path     = $Path
        $This.Stack    = @( )

        $Content       = Get-Content $Path
        $X             = 0
        $Mode          = 0
        Do
        {
            $Line = $Content[$X]
            If ($Line -match "\<KeyboardLocale\>")
            { 
                $X ++
                Do
                {
                    $Line = $Content[$X]
                    If ($Line -match "\<option")
                    {
                        $This.Stack += [LocaleItem]::New(0,$Line)
                    }
                    $X ++
                }
                Until ($Line -match "\<\/KeyboardLocale\>")
            }
            If ($Line -match "\<TimeZone\>")
            {
                $X ++ 
                Do
                {
                    $Line = $Content[$X]
                    If ($Line -match "\<option")
                    {
                        $This.Stack += [LocaleItem]::New(1,$Line)
                    }
                    $X ++
                }
                Until ($Line -match "\<\/TimeZone\>")
            }
            $X ++
        }
        Until ($X -ge ($Content.Count- 1))

        $This.Keyboard = $This.Stack | ? Type -eq Keyboard
        $This.TimeZone = $This.Stack | ? Type -eq TimeZone
    }
}
