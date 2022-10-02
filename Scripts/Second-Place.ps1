Class Car
{
    [UInt32]         $Index
    [String]          $Name
    [DateTime]        $Date
    [String]   $Description
    [String]           $Url
    Car([UInt32]$Index,[String]$Path,[String]$Description,[String]$Url)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }

        $This.Index       = $Index
        $Item             = Get-Item $Path
        $This.Name        = $Item.Name
        $Str              = [Regex]::Matches($Item.Name,"\d{8}_\d{6}").Value
        $xDate            = "{0}/{1}/{2} {3}:{4}:{5}" -f $Str.Substring(0,4),
                                                         $Str.Substring(4,2),
                                                         $Str.Substring(6,2),
                                                         $Str.Substring(9,2),
                                                         $Str.Substring(11,2),
                                                         $Str.Substring(13,2)
        $This.Date        = [DateTime]$xDate
        $This.Description = $Description
        $This.Url         = $Url
    }
}

Class CarContainer
{
    [String] $Name
    [Object] $Output
    CarContainer([String]$Name)
    {
        $This.Name = $Name
        $This.Output = @( )
    }
    Add([String]$Path,[String]$Description,[String]$Url)
    {
        $This.Output += [Car]::New($This.Output.Count,$Path,$Description,$Url) 
    }
}

$Cars = [CarContainer]::New("Second-Place")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20220704_105100832.jpg","Lamborghini Huracan (1/1)","https://drive.google.com/file/d/1qhJuOttNCdS1Wesr3mqvcuS8VZipVNO4")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20220921_075117301.jpg","McLaren 570S (1/4)","https://drive.google.com/file/d/1oKbngyd2LDuXopfdmhw2N078Jmi32O2L")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20220921_075124287.jpg","McLaren 570S (2/4)","https://drive.google.com/file/d/11UvWd9Mvc8kqy9VWNlBJSim92DP1Kps1")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20220921_075220813.jpg","McLaren 570S (3/4)","https://drive.google.com/file/d/1BN7v6ZwaZ1y36lLhSru5zEuE9rGp9x-e")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20220921_075235395.jpg","McLaren 570S (4/4)","https://drive.google.com/file/d/1yYzAUEwwp3ysSaOp5SjQEptkkP_9cPdS")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20221002_145258218.jpg","Ferarri 488 Pista (1/3)","https://drive.google.com/file/d/1PhzvDlnS3smFHpaToZ7hstb2jY62memM")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20221002_145303969.jpg","Ferarri 488 Pista (2/3) + McClaren 720S (1/2)","https://drive.google.com/file/d/16SbVMWT8g86J8m4PRUokP8CyyEKETLYk")
$Cars.Add("C:\Users\mcadmin\Desktop\Second-Place Vehicles\IMG_20221002_145311651.jpg","Ferarri 488 Pista (3/3) + McClaren 720S (2/2)","https://drive.google.com/file/d/1YVbh8AHK8-6BeeVlyCXrpHX5GE0FiWI_")
