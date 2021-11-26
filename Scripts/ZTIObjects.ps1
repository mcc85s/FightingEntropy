
Class ZTIObject
{
    [String] $ID
    [String] $Type
    [Bool]   $Overwrite
    [String] $Description
    ZTIObject([String]$Line)
    {
        $Split            = $Line.Split('"')
        $This.ID          = $Split[1]
        $This.Type        = $Split[3]
        $This.Overwrite   = $Split[5]
        $This.Description = $Split[7]
    }
}

Class ZTISection
{
    [Object] $Content
    [Object] $Output
    ZTISection([Object]$Section)
    {
        $This.Content = $Section
        $This.Output  = $Section | % { $This.ZTIObject($_) }
    }
    [Object] ZTIObject([String]$Line)
    {
        Return [ZTIObject]::New($Line)
    }
}

Class ZTIFile
{
    [String] $Path
    [Object] $Content
    [Object] $Section
    ZTIFile([String]$Path)
    {
        $This.Path    = $Path
        $This.Content = Get-Content $Path
        $This.Section = @( )

        $X            = 0
        $Collect      = @()
        Do
        {
            Switch -Regex ($This.Content[$X])
            {
                Default 
                {
                
                }
                "\<property" 
                {
                    $Collect = @( )
                    Do
                    {
                        $Collect += $This.Content[$X]
                        $X ++
                    }
                    Until ($This.Content[$X] -notmatch "\<property")
                    $This.Section += [ZTISection]::New($Collect)
                }
            }
            $X ++
        }
        Until ($X -eq $This.Content.Count-1)
    }
}

# Get-Content $ZTI
# $ZTI = Get-ChildItem "C:\Program Files\Microsoft Deployment Toolkit" -Recurse | ? Name -eq ZTIGather.xml | % FullName
# $ZTIxml = [ZTIFile]::New($ZTI)
# $ZTIxml.Section.Output 

# Dumps all of the (Get-ChildItem tsenv:) variables for MDT/PXE environment
