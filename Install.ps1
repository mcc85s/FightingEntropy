$base = "github.com/mcc85s/FightingEntropy"

[Net.ServicePointManager]::SecurityProtocol = 3072

Class _File
{
    [String] $Type
    [String] $Name
    [String] $Path

    _File([String]$Name,[String]$Type,[String]$Root)
    {
        $This.Name    = $Name
        $This.Type    = $Type
        $This.Path    = "$Root\$Name"
    }

    Content([String]$Base)
    {
        Invoke-WebRequest -Uri "$Base\$($This.Type)\$($This.Name)?raw=true" -OutFile $This.Path -Verbose
    }
}

Class _Install
{
    [String]        $Root = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
    [String]        $Base = "github.com/mcc85s/FightingEntropy/blob/main"
    [String[]]     $Names = ("Classes Control Functions Graphics" -Split " ")
    [Object[]]   $Classes
    [Object[]]   $Control
    [Object[]] $Functions
    [Object[]]  $Graphics

    [String[]] List([String]$Type)
    {
        Return @( IRM "$($This.Base)/$Type/index.txt?raw=true" ) -Split "`n" | ? Length -gt 0
    }

    _Install()
    {
        $Path = $Null

        ForEach ( $X in $This.Root.Split("\"))
        {
            If ( $Path -eq $Null )
            {
                $Path = $X
            }

            Else
            {
                $Path = "$Path\$X"
            }

            If (!(Test-Path $Path))
            {
                New-Item $Path -ItemType Directory -Verbose
            }
        }

        ForEach ( $Name in $This.Names )
        {
            $Path = "$($This.Root)\$Name"

            If (!(Test-Path $Path))
            {
                New-Item $Path -ItemType Directory -Verbose
            }

            $This.$Name = $This.List($Name) | % { [_File]::New($_,$Name,$Path) }
        }

        ForEach ( $Object in $This.Classes, $This.Control, $This.Functions, $This.Graphics )
        {
            $Object.Content($This.Base)
        }
    }
}

$Install = [_Install]::New()
