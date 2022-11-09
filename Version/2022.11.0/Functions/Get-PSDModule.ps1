<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-PSDModule.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : Retrieves the PowerShell Deployment modification by FriendsOfMDT and                     //   
   \\                     inserts FightingEntropy customizations.                                                  \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-11-08                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11/08/2022 19:31:19    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-PSDModule
{
    Class PSDObject
    {
        [String] $Type
        [String] $Name
        [String] $Fullname
        [String] $Source
        PSDObject([String]$Type,[String]$Name,[String]$Target,[String]$Source)
        {
            $This.Type     = $Type
            $This.Name     = $Name
            $This.Fullname = $Target
            $This.Source   = "{0}/{1}?raw=true" -f $Source, $Name
        }
    }

    Class PSDManifest
    {
        [String] $FriendsOfMdt = "https://github.com/FriendsOfMDT/PSD"
        [String] $PSDSource    = "https://github.com/FriendsOfMDT/PSD/archive/refs/heads/master.zip"
        [String] $Mdt
        [String] $Psd
        [String] $Base
        [Object] $Output
        PSDManifest([String]$Base)
        {
            $This.MDT    = $Base
            $This.Main()
        }
        PSDManifest()
        {
            $This.MDT    = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \
            $This.Main()
        }
        Main()
        {
            # // ____________________
            # // | Assign variables |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            $This.PSD    = "{0}\PSD" -f $This.MDT
            $This.Base   = "https://gitub.com/mcc85s/FightingEntropy/blob/main/PSD"

            $This.Output = @( )
            ForEach ($Item in ("Base","Install-PSD.ps1", "Install-PSD.ps1"),
                              ("Script","PSDFinal.ps1", "Scripts\PSDFinal.ps1"),
                              ("Script","PSDStart.ps1", "Scripts\PSDStart.ps1"),
                              ("Script","PSDWizard.psm1", "Scripts\PSDWizard.psm1"),
                              ("Script","PSDDeploymentShare.psm1", "Scripts\PSDDeploymentShare.psm1"),
                              ("Script","PSDUtility.psm1", "Scripts\PSDUtility.psm1"),
                              ("Script","PSDGather.psm1", "Scripts\PSDGather.psm1"),
                              ("Branding","PSDBackground.bmp", "Branding\PSDBackground.bmp"),
                              ("Script","Set-ScreenResolution.ps1", "Scripts\Set-ScreenResolution.ps1"))
            { 
                $This.Add($Item[0],$Item[1],$Item[2])
            }
        }
        Download()
        {
            If ((Get-ChildItem $This.PSD -EA 0).Count -eq 0)
            {
                # // ________________________________________
                # // | Download/Extract/Delete the zip file |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $Outfile = "$($This.PSD).zip"
                Invoke-RestMethod "$($This.PSDSource)?raw=true" -OutFile $Outfile -Verbose
                Expand-Archive -Path $Outfile -DestinationPath $This.MDT -Force
                Remove-Item $Outfile -Confirm:$False -Force
                Rename-Item "$($This.PSD)-master" -Newname $This.PSD -Verbose

                # // ____________________
                # // | Obtain all files |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($Item in $This.Output)
                {
                    Invoke-RestMethod $Item.Source -Outfile $Item.Target -Verbose
                }
            }
        }
        Add([String]$Type,[String]$Name,[String]$Target)
        {
            $This.Output += [PSDObject]::New($Type,$Name,"$($This.PSD)\$Target",$This.Base)
        }
    }

    # // _________________________
    # // | Test MDT installation |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    If (!(Test-Path "HKLM:\Software\Microsoft\Deployment 4"))
    {
        Throw "MDT not installed"
    }

    $Item = [PSDManifest]::New()
    $Item.PSD
}
