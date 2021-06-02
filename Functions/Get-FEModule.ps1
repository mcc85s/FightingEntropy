Function Get-FEModule
{
    [CmdLetBinding( DefaultParameterSetName = "Default",
                    HelpUri                 = "http://www.github.com/mcc85sx/FightingEntropy" )]
    Param(                
        [Parameter( ParameterSetName        = "Default"     )][Switch]          $All ,
        [Parameter( ParameterSetName        = "Classes"     )][Switch]      $Classes , 
        [Parameter( ParameterSetName        = "Functions"   )][Switch]    $Functions , 
        [Parameter( ParameterSetName        = "Control"     )][Switch]      $Control , 
        [Parameter( ParameterSetName        = "Graphics"    )][Switch]     $Graphics , 
        [Parameter( ParameterSetName        = "Role"        )][Switch]         $Role )
        
        Class _Module
        {
            [String]        $Base
            [String]        $Name
            [String] $Description
            [String]      $Author
            [String]     $Company
            [String]   $Copyright
            [String]        $GUID
            [String]     $Version
            [Object]          $OS
            [Object]    $Manifest
            [Object]    $Registry
            [Object]     $RegPath
            [String]     $Default
            [String]        $Main
            [String]       $Trunk
            [String]     $ModPath
            [String]     $ManPath
            [String]        $Path
            [Object]        $Tree
            [Object[]]   $Classes
            [Object[]]   $Control
            [Object[]] $Functions
            [Object[]]  $Graphics
            [Object]      $Status
            [Object]        $Role

            _Module([String]$Path)
            {
                $ID               = Get-ItemProperty $Path
                $This.Registry    = $ID
                $This.Base        = $ID.Base
                $This.Name        = $ID.Name
                $This.Description = $ID.Description
                $This.Author      = $ID.Author
                $This.Company     = $ID.Company
                $This.Copyright   = $ID.Copyright
                $This.GUID        = $ID.GUID
                $This.Version     = $ID.Version
                $This.Date        = $ID.Date
                $This.RegPath     = $ID.RegPath
                $This.Default     = $ID.Default
                $This.Main        = $ID.Main
                $This.Trunk       = $ID.Trunk
                $This.ModPath     = $ID.ModPath
                $This.ManPath     = $ID.ManPath
                $This.Path        = $ID.Path
                $This.Status      = $ID.Status
            }
        }
        
        $Name      = "FightingEntropy"
        $Company   = "Secure Digits Plus LLC"
        $Default   = "HKLM:\Software\Policies\$Company\$Name"
        If (!(Test-Path $Default))
        {
            Throw "Installation not found"
        }
        
        $Item = Get-Item $Default
        If (!$Item)
        {
            Throw "Registry not found"
        }
        
        $Child = Get-ChildItem $Default
        If (!$Child)
        {
            Throw "No version detected"
        }
        
        If ($Child.Count -gt 1)
        {
            $Child = $Child[-1]
        }
        
        $Mod       = [_Module]::New($Child)
        
        Switch ($PSCmdLet.ParameterSetName)
        {   
            Default   {$Mod}
            Classes   {$Mod.Classes}
            Functions {$Mod.Functions}
            Control   {$Mod.Control}
            Graphics  {$Mod.Graphics}
            Role      {$Mod.Role}
        }
}
