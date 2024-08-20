# // Uses DISM to export a defaultapps.xml file to parse through in order to search operating system for particular files much more quickly.
# // Very useful for drives that have a lot of data on them, or even combing through temporary files, or the appdata folder.

Class FileAssociationIdentifier
{
    [UInt32] $Index
    [String] $Extension
    [String] $ProgId
    [String] $Application
    FileAssociationIdentifier([UInt32]$Index,[String]$Line)
    {
        $This.Index       = $Index
        $xLine            = $Line.Substring(15).TrimEnd(" />") -Replace "`" ","`"`n" -Split "`n"
        $This.Extension   = $xLine[0].Split("=")[1].Trim('"')
        $This.ProgId      = $xLine[1].Split("=")[1].Trim('"')
        $This.Application = $xLine[2].Split("=")[1].Trim('"')
    }
    [String] ToString()
    {
        Return "<File.Association.Identifer>"
    }
}

Class FileAssociationApplication
{
    [UInt32]        $Index
    [String]         $Name
    [String[]] $Extensions
    FileAssociationApplication([UInt32]$Index,[String]$Name)
    {
        $This.Index      = $Index
        $This.Name       = $Name
        $This.Extensions = @( )
    }
    [String] Regex()
    {
        Return "({0})" -f ($This.Extensions -join "|").Replace(".","\.")
    }
    [String] ToString()
    {
        Return "<File.Association.Application>"
    }
}

Class FileAssociationMaster
{
    [String]         $Path
    [Object]  $Association
    [Object]       $Output
    FileAssociationMaster([String]$Path)
    {
        $This.Path    = $Path
    }
    DismExport()
    {
        Dism /Online /Export-DefaultAppAssociations:"$($This.Path)"
    }
    [Object] FileAssociationIdentifier([UInt32]$Index,[String]$Line)
    {
        Return [FileAssociationIdentifier]::New($Index,$Line)
    }
    [Object] FileAssociationApplication([UInt32]$Index,[String]$Name)
    {
        Return [FileAssociationApplication]::New($Index,$Name)
    }
    GetAssociations()
    {
        $This.Association = @( )

        ForEach ($Line in [System.IO.File]::ReadAllLines($This.Path))
        {
            Switch -Regex ($Line)
            {
                Default
                {

                }
                "^\s+\<Association"
                {
                    $This.Association += $This.FileAssociationIdentifier($This.Output.Count,$Line)
                }
            }
        }

        $This.Association = $This.Association | Sort-Object Application

        ForEach ($X in 0..($This.Association.Count-1))
        {
            $This.Association[$X].Index = $X
        }
    }
    GetApplications()
    {
        $List        = $This.Association.Application | Select-Object -Unique
        $This.Output = @( )
        
        For ($X = 0; $X -lt $List.Count; $X ++)
        {
            $Name             = $List[$X]
            $Item             = $This.FileAssociationApplication($X,$Name)
            $Item.Extensions  = $This.Association | ? Application -eq $Name | % Extension
            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<File.Association.Master>"
    }
}

$Target = "$Home\Desktop\DefaultApps.xml"
$App    = [FileAssociationMaster]::New($Target)

# $App.DismExport() # <- tells DISM to export the current 'defaultapps.xml' to that path

$App.GetAssociations() # <- parses through that file for all entries, ranks by name, reindexes

$App.GetApplications() # <- selects unique apps, extracts the file extensions for a particular app

# // Search a drive recursively for specific file types

$Drive  = "$Home\Downloads" # <- Replace with file system path to recursively search

$Filter = $App.Output[9].Regex() # <- Replace with any entry in the output array
$List   = Get-ChildItem $Drive -Recurse | ? Extension -match $Filter

$List | Format-Table # <- Shows all of the file system entries it found
