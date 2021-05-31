Class _Image
{
    [String]          $SourceIndex
    [String]      $SourceImagePath
    [String] $DestinationImagePath
    [String]      $DestinationName

    _Image(
    [String]          $SourceIndex ,
    [String]      $SourceImagePath ,
    [String] $DestinationImagePath ,
    [String]      $DestinationName )
    {
        $This.SourceIndex          = $SourceIndex
        $This.SourceImagePath      = $SourceImagePath
        $This.DestinationImagePath = $DestinationImagePath
        $This.DestinationName      = $DestinationName
    }
}
