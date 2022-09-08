Class BitBucketItem
{
    [UInt32] $Index
    [String] $Name
    [String] $ParentPath
    [String] $DeletionTimeText
    [String] $Size
    [String] $SizeText
    [String] $Type
    [String] $LastWriteTime
    [String] $LastWriteTimeText
    [String] $CreationTimeText
    [String] $LastAccessTimeText
    [String] $AttributesText
    [String] $IsFolder
    [String] $BitBucketPath
    BitBucketItem([UInt32]$Index,[Object]$BitBucket,[Object]$Item)
    {
        $This.Name               = $bitBucket.GetDetailsOf($Item,0)
        $This.ParentPath         = $bitBucket.GetDetailsOf($Item,1)
        $This.DeletionTimeText   = $bitBucket.GetDetailsOf($Item,2)
        $This.Size               = $Item.Size
        $This.SizeText           = $bitBucket.GetDetailsOf($Item,3)
        $This.Type               = $bitBucket.GetDetailsOf($Item,4)
        $This.LastWriteTime      = $Item.ModifyDate
        $This.LastWriteTimeText  = $bitBucket.GetDetailsOf($Item,5)
        $This.CreationTimeText   = $bitBucket.GetDetailsOf($Item,6)
        $This.LastAccessTimeText = $bitBucket.GetDetailsOf($Item,7)
        $This.AttributesText     = $bitBucket.GetDetailsOf($Item,8)
        $This.IsFolder           = $Item.IsFolder()
        $This.BitBucketPath      = $Item.Path
    }
}

Class BitBucketContainer
{
    [Object] $Application
    [Object] $BitBucket
    [Object] $Output
    BitBucketContainer()
    {
        $This.Application = New-Object -ComObject Shell.Application
        $This.BitBucket   = $This.Application.NameSpace(0x0A)
    }
    Reset()
    {
        $This.Output      = @( )
        Foreach ($Item in $This.BitBucket.Items())
        {
            $This.Output += [BitBucketItem]::New($This.BitBucket,$This.Output.Count,$Item)
        }
    }
}

$Obj = [BitBucketContainer]::New()
