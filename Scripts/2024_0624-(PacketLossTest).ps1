<# 
  The purpose of this is to process a (*.json) file from [https://packetlosstest.com/] after running a packet loss test.
  
  The website listed above does an AMAZING job of running various tests to determine bandwidth issues.
  
  It also has a really useful display for the output in the browser, but- I decided to write these classes to turn the
  output (*.json) object into a command line object so that I can easily filter out what percentage of packets are
  returning either LATE, or not at all.

  Run test at [https://packetlosstest.com/] for preset [Counterstrike 2]
    - change duration to (180s)
    - export to (*.json) file
    - import (*.json) file after overloading the classes below
#>

Class PacketLossDetail
{
    [UInt32]     $Index
    [String]    $Status
    [UInt32]      $Ping
    [String] $Deviation
    PacketLossDetail([Object]$Detail,[Float]$Average)
    {
        $This.Index  = $Detail.Id
        $This.Status = $Detail.Status

        Switch -Regex ($Detail.Status)
        {
            ^Success$
            {
                $This.Ping      = $Detail.Ping
            }
            Default
            {
                $This.Ping      = 999
            }
        }

        $This.Deviation         = "{0:n2}" -f ($This.Ping - $Average)
    }
    [String] ToString()
    {
        Return "<Packet.Loss.Detail>"
    }
}

Class PacketLossObject
{
    [String]      $Total
    [String]     $Upload
    [String]   $Download
    [String]       $Late
    [Float]  $AvgLatency
    [Float]   $AvgJitter
    [UInt32]   $Duration
    [UInt32]  $Frequency
    [UInt32]       $Size
    [UInt32]   $MaxDelay
    [Object]     $Output
    PacketLossObject([String]$Path)
    {
        If (![System.IO.File]::Exists($Path))
        {
            Throw "Invalid path"
        }

        $File = [System.IO.File]::ReadAllLines($Path)

        If (!$File)
        {
            Throw "Invalid file"
        }

        $Object = $File | ConvertFrom-Json

        $This.Total      = "{0:p}" -f $Object.TotalPacketLoss
        $This.Upload     = "{0:p}" -f $Object.UploadPacketLoss
        $This.Download   = "{0:p}" -f $Object.DownloadPacketLoss
        $This.Late       = "{0:p}" -f $Object.LatePacketRate
        $This.AvgLatency = $Object.AverageLatency
        $This.AvgJitter  = $Object.AverageJitter
        $This.Duration   = $Object.Settings.Duration
        $This.Frequency  = $Object.Settings.Frequency
        $This.Size       = $Object.Settings.Size
        $This.MaxDelay   = $Object.Settings.AcceptableDelay

        $This.Output     = @( )
        $Hash            = @{ }

        ForEach ($Detail in $Object.Details)
        {
            $Hash.Add($Hash.Count,$This.PacketLossDetail($Detail))
        }

        $This.Output     = $Hash[0..($Hash.Count-1)]
    }
    [Void] GetReport()
    {
        [Console]::WriteLine("Total packets: ({0})" -f $This.Output.Count)
        [Console]::WriteLine("Total < 100ms ({0})" -f ($This.Output | ? Ping -lt 100).Count)
        [Console]::WriteLine("Total >= 100ms ({0})" -f ($This.Output | ? Ping -ge 100).Count)
        [Console]::WriteLine("Total >= 200ms ({0})" -f ($This.Output | ? Ping -ge 200).Count)
        [Console]::WriteLine("Total >= 300ms ({0})" -f ($This.Output | ? Ping -ge 300).Count)
        [Console]::WriteLine("Total >= 400ms ({0})" -f ($This.Output | ? Ping -ge 400).Count)
        [Console]::WriteLine("Total >= 500ms ({0})" -f ($This.Output | ? Ping -ge 500).Count)
        [Console]::WriteLine("Total >= 600ms ({0})" -f ($This.Output | ? Ping -ge 600).Count)
        [Console]::WriteLine("Total >= 700ms ({0})" -f ($This.Output | ? Ping -ge 700).Count)
        [Console]::WriteLine("Total >= 800ms ({0})" -f ($This.Output | ? Ping -ge 800).Count)
        [Console]::WriteLine("Total >= 900ms ({0})" -f ($This.Output | ? Ping -ge 900).Count)
        [Console]::WriteLine("Total >= 1s ({0})" -f ($This.Output | ? Ping -ge 1000).Count)
    }
    [Object] PacketLossDetail([Object]$Detail)
    {
        Return [PacketLossDetail]::New($Detail,$This.AvgLatency)
    }
    [String] ToString()
    {
        Return "<Packet.Loss.Object>"
    }
}

<#
  Now, I haven't added the portion of code that objectifies the (*.json) code by entering a path
  to the file. What I want to do, is have a way of downloading a sample (*.json) file that I was able
  to export from the utility at [packetlosstest.com], so that I can save it to a local file path,
  and THEN run the utility.
#>

$FileName     = "packet-loss-test-results-2024-06-24T21_20_35.216Z.json"
$Target       = "$Env:UserProfile\networktest"
If (![System.IO.Directory]::Exists($Target))
{
    [System.IO.Directory]::CreateDirectory($Target) > $Null
}

Start-BitsTransfer -Source "https://github.com/mcc85s/FightingEntropy/blob/main/Scripts/$FileName`?raw=true" -Destination "$Target\$Filename"

$Ctrl         = [PacketLossObject]::New("$Target\$Filename")
<#
  Total      : 4.80%
  Upload     : 4.70%
  Download   : 0.00%
  Late       : 21.40%
  AvgLatency : 81.52
  AvgJitter  : 91.76
  Duration   : 180
  Frequency  : 128
  Size       : 346
  MaxDelay   : 60
  Output     : {<Packet.Loss.Detail>, <Packet.Loss.Detail>, <Packet.Loss.Detail>, <Packet.Loss.Detail>...}
#>

$Ctrl.GetReport()
<#
  Total packets: (23039)
  Total < 100ms (18125)
  Total >= 100ms (4914)
  Total >= 200ms (3621)
  Total >= 300ms (2487)
  Total >= 400ms (1999)
  Total >= 500ms (1716)
  Total >= 600ms (1611)
  Total >= 700ms (1511)
  Total >= 800ms (1454)
  Total >= 900ms (1389)
  Total >= 1s (227)

  -
  
  So, the above information just turns various properties of the (*.json) file, into a PowerShell object, so that I can
  analyze the file a little bit faster than just looking at the graph on the website, or reviewing the entirety of the
  936kb file.

  I was able to determine that (18125/23039) of the packets are less than 100ms.
  100ms isn't all that great, but it's definitely better than anything higher than that.

  I could've added more information into the method GetReport(), but I'm just going to put the code that I just wrote,
  to show what percentage of packets are showing up within those categories, using the information in each of those lines.
#>

# Total >= 100ms
"{0:p} >= 100ms ({1}/{2})" -f (4914/23039),4914,23039
# Total >= 200ms
"{0:p} >= 200ms ({1}/{2})" -f (3621/23039),3621,23039
# Total >= 300ms
"{0:p} >= 300ms ({1}/{2})" -f (2487/23039),2487,23039
# Total >= 400ms
"{0:p} >= 400ms ({1}/{2})" -f (1999/23039),1999,23039
# Total >= 500ms
"{0:p} >= 500ms ({1}/{2})" -f (1716/23039),1716,23039
# Total >= 600ms
"{0:p} >= 600ms ({1}/{2})" -f (1611/23039),1611,23039
# Total >= 700ms
"{0:p} >= 700ms ({1}/{2})" -f (1511/23039),1511,23039
# Total >= 800ms
"{0:p} >= 800ms ({1}/{2})" -f (1454/23039),1454,23039
# Total >= 900ms
"{0:p} >= 900ms ({1}/{2})" -f (1389/23039),1389,23039
# Total >= 1s
"{0:p} >= 1s ({1}/{2})" -f (227/23039),227,23039

<#
  21.33% >= 100ms (4914/23039)
  15.72% >= 200ms (3621/23039)
  10.79% >= 300ms (2487/23039)
   8.68% >= 400ms (1999/23039)
   7.45% >= 500ms (1716/23039)
   6.99% >= 600ms (1611/23039)
   6.56% >= 700ms (1511/23039)
   6.31% >= 800ms (1454/23039)
   6.03% >= 900ms (1389/23039)
   0.99% >=    1s  (227/23039)

   -

   So, that right there, gives you a fully-qualified percentage notation on how many packets are actually
   arriving more than 100ms, 200ms, 300ms, 400ms, and so on until 1s.

   Anyway, I know how frustrating it can be to manage network equipment, but the fact of the matter is,
   these results are pretty bad. The packet loss is not consistently THIS bad on a day to day basis, but I've
   been collecting some of these files so that I can reproduce just how bad a particular day was, when I run
   a single test, and then notice that 5% of the packets were totally lost, and that 20% of the packets were
   late.
#>
  
