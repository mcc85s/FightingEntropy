<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEModule.ps1
          Solution: FightingEntropy Module
          Purpose: For various system management, networking, automation tasks, as well as console styling, and GUI design
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-09-30
          Modified: 2021-10-30

          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEModule
{
    [CmdLetBinding( DefaultParameterSetName = "Default",
                    HelpUri                 = "http://www.github.com/mcc85s/FightingEntropy" )]
    Param(                
        [Parameter(ParameterSetName =   "Default" )][Switch]       $All ,
        [Parameter(ParameterSetName =   "Classes" )][Switch]   $Classes , 
        [Parameter(ParameterSetName = "Functions" )][Switch] $Functions , 
        [Parameter(ParameterSetName =   "Control" )][Switch]   $Control , 
        [Parameter(ParameterSetName =  "Graphics" )][Switch]  $Graphics , 
        [Parameter(ParameterSetName =      "Role" )][Switch]      $Role )

    Class Root
    {
        Hidden [Object] $Order = @(("Base Name Description Author Company Copyright GUID Version Date OS Manifest RegPath Default Main " +
                                   "Trunk ModPath ManPath Tree Classes Control Functions Graphics Status") -Split " ")
        [String]        $Base
        [String]        $Name
        [String] $Description
        [String]      $Author
        [String]     $Company
        [String]   $Copyright
        [String]        $GUID
        [String]     $Version
        [String]        $Date
        [Object]          $OS
        [Object]    $Manifest
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
        [Object]        $Type
        [Object]        $Role
        Root([Object]$ID)
        {
            $This.Base        = $ID.Base
            $This.Name        = $ID.Name
            $This.Description = $ID.Description
            $This.Author      = $ID.Author
            $This.Company     = $ID.Company
            $This.Copyright   = $ID.Copyright
            $This.GUID        = $ID.GUID
            $This.Version     = $ID.Version
            $This.Date        = $ID.Date
            $This.OS          = Get-FEOS
            $This.Manifest    = Get-FEManifest
            $This.RegPath     = $ID.RegPath
            $This.Default     = $ID.Default
            $This.Main        = $ID.Main
            $This.Trunk       = $ID.Trunk
            $This.ModPath     = $ID.ModPath
            $This.ManPath     = $ID.ManPath
            $This.Path        = $ID.Path
            $This.Status      = $ID.Status
            $This.Tree        = Get-ChildItem $This.Path | ? Name -in $This.Manifest.Names
            $This.Classes     = $This.Tree | ? Name -eq Classes  | Get-ChildItem
            $This.Control     = $This.Tree | ? Name -eq Control  | Get-ChildItem
            $This.Functions   = $This.Tree | ? Name -eq Functions| Get-ChildItem
            $This.Graphics    = $This.Tree | ? Name -eq Graphics | Get-ChildItem
            $This.Type        = $This.OS.Type
            $This.Role        = Get-FERole
        }
        [String] ToString()
        {
            Return @( "[FightingEntropy($([char]960))][$($This.Version)]" )
        }
        [String] ModPrompt()
        {
            Return @( "[FightingEntropy($([char]960))][$($This.Version)]" )
        }
        ModuleInfo()
        {
            Write-Theme $This -Title Module -Prompt $This.ModPrompt()
        }
        HostInfo()
        {
            Write-Theme $This.Role -Title Host -Prompt $This.ModPrompt()
        } 
        ProcessInfo()
        {            
            Write-Theme (Get-FEProcess -Text) -Title Processes -Prompt $This.ModPrompt()
        }
        AdapterInfo()
        {
            Write-Theme (Get-FENetwork -Adapter -Text) -Title Adapters -Prompt $This.ModPrompt()
        }
        InterfaceInfo()
        {
            Write-Theme (Get-FENetwork -Interface -Text) -Title Interfaces -Prompt $This.ModPrompt()
        }
        ServiceInfo()
        {
            Write-Theme (Get-FEService -Text) -Title Services -Prompt $This.ModPrompt()
        }
    }

    Class Version
    {
        [UInt32] $Exists
        [UInt32] $Year
        [UInt32] $Month
        [UInt32] $Slot
        [String] $RegPath
        Version([Object]$Object)
        {
            $ID           = $Object.PSChildName.Split(".")
            $This.Year    = $ID[0]
            $This.Month   = $ID[1] 
            $This.Slot    = $ID[2]
            $This.RegPath = $Object.GetValue("RegPath")
            $This.Exists  = 0
            If ($This.Regpath)
            {
                $This.Exists = Test-Path $This.RegPath
            }
        }
    }
        
    $Name      = "FightingEntropy"
    $Company   = "Secure Digits Plus LLC"
    $Default   = "HKLM:\Software\Policies\$Company\$Name"
    If (!(Test-Path $Default))
    {
        Throw "Installation not found"
    }
    
    $Item      = Get-Item $Default
    If (-not $Item)
    {
        Throw "Registry not found"
    }
    
    $Child     = Get-ChildItem $Default | % { [Version]::New($_) } | ? Exists | Sort-Object Year | Select-Object -First 1
    $RegPath   = Get-ItemProperty $Child.RegPath
    
    Switch ($PSCmdLet.ParameterSetName)
    {
        Default   {[Root]::New($RegPath)}
        Classes   {[Root]::New($RegPath).Classes}
        Functions {[Root]::New($RegPath).Functions}
        Control   {[Root]::New($RegPath).Control}
        Graphics  {[Root]::New($RegPath).Graphics}
        Role      {[Root]::New($RegPath).Role}
    }
}
