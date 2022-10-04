Class Entry
{
    [UInt32] $Index
    [String] $Name
    Hidden [String] $Fullname
    [String] $Url
    Entry([UInt32]$Index,[Object]$File)
    {
        $This.Index    = $index
        $This.Name     = $File.Name
        $This.Fullname = $File.Fullname
        $This.Url      = "<Insert Hyperlink>"
    }
    SetUrl([String]$Url)
    {
        $This.Url      = $Url
    }
}

Class EntryList
{
    [String] $Name
    [String] $Path
    [Object] $Output
    EntryList([String]$Name,[String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }

        $This.Name   = $Name
        $This.Path   = $Path
        Write-Host "Found [+] [$Path]"
        $This.Output = @( )

        Get-ChildItem $Path | % { $This.Add($_) }
    }
    Add([Object]$File)
    {
        $This.Output += [Entry]::New($This.Output.Count,$File)
        Write-Host "Added [+] [$($File.Fullname)]"
    }
    Set([String]$Name,[String]$Url)
    {
        If ($Name -notin $This.Output.Name)
        {
            Throw "Invalid name"
        }

        $Item = $This.Output | ? Name -eq $Name
        $Item.Url = $Url 
    }
}

$List = [EntryList]::New("Not News Pictures","D:\Users\mcadmin\Pictures\2022\10032022")

$List.Set("2004 Pontiac Grand Prix (1).jpg",    "https://drive.google.com/file/d/1y_i8R6l7EOkvxFzgf_W3jP3cg1u4F9xo")
$List.Set("capdigsvcarea.jpg",                  "https://drive.google.com/file/d/1Q2LKG5QWDHWDghuWFVUYKkXdje2ldU4q")
$List.Set("Catricala (1).jpg",                  "https://drive.google.com/file/d/1GEm-mKSjgV72818UB7MguM8f-Zum4Mqw")
$List.Set("Catricala (2).jpg",                  "https://drive.google.com/file/d/1yW83zEWYc8n0y_UXAztIx2GQF2EAI8Z4")
$List.Set("Catricala (3).jpg",                  "https://drive.google.com/file/d/1aT35fdotBVr382x6xXLZWgIEnrqcKBXL")
$List.Set("IMG_0403 (1).jpg",                   "https://drive.google.com/file/d/1AJVPkRIwup6yC-ZddMprzORAGnhnkqJt")
$List.Set("IMG_0432 (1).jpg",                   "https://drive.google.com/file/d/1Jlia9OkIvO36-xAPFNJLD9AFJFweLn-C")
$List.Set("IMG_0652 (1).PNG",                   "https://drive.google.com/file/d/1EDUbELE98fVqcgVr9WoKLDN1FWQyl1Jh")
$List.Set("iPhone 8 Plus (1).jpg",              "https://drive.google.com/file/d/173o4Bfd3WDRhow9MLsR51qsh25kU3TIe")
$List.Set("New Salem (1).jpg",                  "https://drive.google.com/file/d/12mWS0e8n2beMA843wT0IBzpxyUJdWDsV")
$List.Set("New Salem (2).jpg",                  "https://drive.google.com/file/d/1aQ_CmZ2oF6euDKWLoxTuBq3jkX5mFKm_")
$List.Set("New Salem (3).jpg",                  "https://drive.google.com/file/d/1eocObao3jJV_EHrNgdBCTrb0gxiiPEyl")
$List.Set("NYSDOCS (1).jpg",                    "https://drive.google.com/file/d/1bdwna7HG8Y7GEk3BqRF6poxS8RaLzPbi")
$List.Set("NYSDOCS (2).jpg",                    "https://drive.google.com/file/d/1wbjBoS-5zLUKbWCU0oiRR0z4B4xOr9wC")
$List.Set("SCSO-2020-002998 (1).JPG",           "https://drive.google.com/file/d/1ykNZKM_VS0NWdckqVToSmL-ujjTBl4zz")
$List.Set("SCSO-2020-002998 (2).JPG",           "https://drive.google.com/file/d/1i4s7_tiT5bdNWsydqIMDMFFRRrOx1-zZ")
$List.Set("SCSO-2020-002998 (3).JPG",           "https://drive.google.com/file/d/17K2GMKn6hx3CF_HrSuB8Z_HfPlUKmNkQ")
$List.Set("SCSO-2020-003173 (1).JPG",           "https://drive.google.com/file/d/14Ajb2y93NEJ6YC255-lHe361KoCF7OxP")
$List.Set("SCSO-2020-003173 (2).JPG",           "https://drive.google.com/file/d/1KsriWjDat6F2mz9Vy8FJMUWLRF6ViYO4")
$List.Set("SCSO-2020-003173 (3).JPG",           "https://drive.google.com/file/d/1l_fs1BP1FmQiuoQ7rJZQAh3dvpw5o-bQ")
$List.Set("SCSO-2020-003173 (4).JPG",           "https://drive.google.com/file/d/1cDq5H8QpzvowOJ1C3rLbraiNCJaoscTW")
$List.Set("SCSO-2020-003173 (5).JPG",           "https://drive.google.com/file/d/13zr1gip9mkaJSsXRnxU8lhZiR5cNYTKj")
$List.Set("SCSO-2020-003173 (6).JPG",           "https://drive.google.com/file/d/17ZvRkZWwxDTHCnrhbHOL7hh_L2MCnF7t")
$List.Set("SCSO-2020-003177 (1).JPG",           "https://drive.google.com/file/d/1xritPqOI-ng04v_yp203zM_3sG2-_Jb2")
$List.Set("SCSO-2020-003177 (2).JPG",           "https://drive.google.com/file/d/119rBz3sGpt6lPF4qQ90nWwALZ2W1iWJ3")
$List.Set("SCSO-2020-003177 (3).JPG",           "https://drive.google.com/file/d/1FfcBWZZlkmf88XOtq0xBIvgK6m_3qwkP")
$List.Set("SCSO-2020-003177 (4).JPG",           "https://drive.google.com/file/d/1WkNbhqgvDIWZJYbCObEI-j12Mz_g2CDJ")
$List.Set("SCSO-2020-003177 (5).JPG",           "https://drive.google.com/file/d/1rjCU9yHzIo6gFw41aPAtAMmr42-iAG1I")
$List.Set("SCSO-2020-003564 (1).JPG",           "https://drive.google.com/file/d/1wYsaD825xVjkJ7eCbve6DwflW5v1KYCx")
$List.Set("SCSO-2020-003564 (2).JPG",           "https://drive.google.com/file/d/1uwgrUG3MCA9AU6jue_7GtDZyoz5YDKxz")
$List.Set("SCSO-2020-003564 (3).JPG",           "https://drive.google.com/file/d/1AUscW2inUcTlCgps-qX0QrBmUKdLOE4h")
$List.Set("SCSO-2020-003564 (4).JPG",           "https://drive.google.com/file/d/1DwVB9wRN-mHBLKciGRinwMrdCZZgwIeI")
$List.Set("SCSO-2020-003564 (5).JPG",           "https://drive.google.com/file/d/1CTmhJEd-6vzlMZHv6iCeEcCjpc80Tjbs")
$List.Set("SCSO-2020-003688 (1).JPG",           "https://drive.google.com/file/d/1R0EUH3z8JRhliQuvpMogZK8l5Nzi80mw")
$List.Set("SCSO-2020-003688 (2).JPG",           "https://drive.google.com/file/d/1H62ZDnQT3s-k-aUXMJAFzWseMk79e_a7")
$List.Set("SCSO-2020-003688 (3).JPG",           "https://drive.google.com/file/d/1g00XTcJk5_tzb4Utdn_i2on_TYuwaXTV")
$List.Set("SCSO-2020-003688 (4).JPG",           "https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV")
$List.Set("SCSO-2020-003688 (5).JPG",           "https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV")
$List.Set("SCSO-2020-027797 (1).jpg",           "https://drive.google.com/file/d/19Vkh-Uc_7yR9HJcmQnsttIo6H5tmUYzK")
$List.Set("SCSO-2020-027797 (2).jpg",           "https://drive.google.com/file/d/1CjjAS46TX-RfeSYkhKmXVKsD94pwBX7b")
$List.Set("SCSO-2020-027797 (3).jpg",           "https://drive.google.com/file/d/1CQjwnrFkAxL9meg63z1ttdyz5Hczs5RM")
$List.Set("SCSO-2020-027797 (4).jpg",           "https://drive.google.com/file/d/1dfL4ca_lwe_CBDO1ttfYcL5d4_koopWC")
$List.Set("SCSO-2020-027797 (5).jpg",           "https://drive.google.com/file/d/1yGBIQbo20b6sPovrJkOOM9EXIUdPF2zQ")
$List.Set("SCSO-2020-027797 (6).JPG",           "https://drive.google.com/file/d/1pfbyK6dlsFKC1JTDaKxdvdCJQl1HX_3W")
$List.Set("SCSO-2020-028501-CORRECTED (1).jpg", "https://drive.google.com/file/d/1a4K323ZRoz6SkKUPCjR2ycM-AY5YpIAV")
$List.Set("SCSO-2020-040452 (1).JPG",           "https://drive.google.com/file/d/1xfJ2mYvxptHLldugAXjhEdASRJpWIzIK")
$List.Set("SCSO-2020-040452 (10).JPG",          "https://drive.google.com/file/d/1_VkPwS0UaoxPymS5rTYN3pKBSGtksw2E")
$List.Set("SCSO-2020-040452 (2).JPG",           "https://drive.google.com/file/d/1Tg6cFXH5dKEL8XaYYOG_YlvaOsDQcTWW")
$List.Set("SCSO-2020-040452 (3).JPG",           "https://drive.google.com/file/d/1U6CAQBk3f__piiQSSjPeInnKr8ao4wkj")
$List.Set("SCSO-2020-040452 (4).JPG",           "https://drive.google.com/file/d/1sbOUEgjK9AqrRrDRYa1EkU-ErkTXqURa")
$List.Set("SCSO-2020-040452 (5).JPG",           "https://drive.google.com/file/d/1gy68TFdZtye5l6beMmZBiUTYVXlJKe-i")
$List.Set("SCSO-2020-040452 (6).JPG",           "https://drive.google.com/file/d/1w9bTxJKvT5MUWmmqgIYY0DfayD5LOlSI")
$List.Set("SCSO-2020-040452 (7).JPG",           "https://drive.google.com/file/d/1CzN8beW0ZZdX090YOw2mEJIdCZC04PGW")
$List.Set("SCSO-2020-040452 (8).JPG",           "https://drive.google.com/file/d/1HvTGMksppPjm2DbP15TznxUefIsOMSXl")
$List.Set("SCSO-2020-040452 (9).JPG",           "https://drive.google.com/file/d/18lqeF2KZGTcP_y8stv8I7Vgj1eO3p9-N")
$List.Set("SCSO-2020-040845 (1).JPG",           "https://drive.google.com/file/d/16LJXiWdXHTHdjdu8RZljsP4QtcaLpb9o")
$List.Set("SCSO-2020-040845 (2).JPG",           "https://drive.google.com/file/d/1d66nKgEBDPUm_ZRRHGjtV21i5WlCQX11")
$List.Set("SCSO-2020-040845 (3).JPG",           "https://drive.google.com/file/d/1n9FR3MNUuqQTlOkdYa9D8ZePoGF8krpF")
$List.Set("SCSO-2020-040845 (4).JPG",           "https://drive.google.com/file/d/1M5z-B_Unn8kW3WXBFSBGL8wQXL5TU56v")
$List.Set("SCSO-2020-040845 (5).JPG",           "https://drive.google.com/file/d/1p2Jeu80lNBIuADhsbeDFPDhcP4qpwWhK")
$List.Set("SCSO-2020-040845 (6).JPG",           "https://drive.google.com/file/d/1vR6pvH9X3cVivusOdw1CO0AcOQZk-ItV")
$List.Set("SCSO-2020-040845 (7).JPG",           "https://drive.google.com/file/d/1PYhrVopmnkIXisUKQ-CeCzAKPQnMh2g3")
$List.Set("SCSO-2020-049517 (1).JPG",           "https://drive.google.com/file/d/1WhcxCTZt26-gh9t0ZQKk6wSUaYfKk2Cr")
$List.Set("SCSO-2020-049517 (2).JPG",           "https://drive.google.com/file/d/1toDPjjf-M__-QHDVXIDsII_J2RjBxckO")
$List.Set("SCSO-2020-049517 (3).JPG",           "https://drive.google.com/file/d/1qxFw216D3Wm4RU2qUI53A27LpvNtA6_a")
$List.Set("SCSO-2020-049517 (4).JPG",           "https://drive.google.com/file/d/1-jBAexBvmsXzXLw6v_QEHCu3OEqyng9i")
$List.Set("SCSO-2020-049517 (5).JPG",           "https://drive.google.com/file/d/17XwO7_Yb3AbU-IW0wKwl6fZiLciPdDs_")
$List.Set("SCSO-2020-049517 (6).JPG",           "https://drive.google.com/file/d/1iUkG4Wv02XKXMYZTuStZ5U6K1ZcdJ43r")
$List.Set("SCSO-2020-053053 (1).JPG",           "https://drive.google.com/file/d/1XNtAwHgD0SJwDHNqx9FKByY3U-TRuq3a")
$List.Set("SCSO-2020-053053 (2).JPG",           "https://drive.google.com/file/d/1cKcu6EM7KMztdSFgPNGysp6arvkQSYGM")
$List.Set("SCSO-2020-053053 (3).JPG",           "https://drive.google.com/file/d/1OVlZClO_mdtKK9A0rqBBf7zhsRz4mFqb")
$List.Set("SCSO-2020-053053 (4).JPG",           "https://drive.google.com/file/d/1M1xyGwyA-_1Dc0EEN-O-XX0iuq74GxTn")
$List.Set("SCSO-2020-053053 (5).JPG",           "https://drive.google.com/file/d/1V8rhIh-T6HXT5HBgrAynIEJ7FoDMTi4N")
$List.Set("SCSO-2020-028501 (1).JPG",           "https://drive.google.com/file/d/1adfRlVCkUn5H-eauU8pNtPogGlnsVwbP")
$List.Set("SCSO-2020-028501 (2).JPG",           "https://drive.google.com/file/d/1fxb8zTS2v19W5_iIjA3jaGxEaYpFROdO")
$List.Set("SCSO-2020-028501 (3).JPG",           "https://drive.google.com/file/d/1R14NXV0ziULhhv3tCfzxBuH-TDYv0iWy")
$List.Set("SCSO-2020-028501 (4).JPG",           "https://drive.google.com/file/d/1XvlYs2OHS0j6jbV5kYqhyYPb5JomMGH-")

<#
Index Name                               Url
----- ----                               ---
    0 2004 Pontiac Grand Prix (1).jpg    https://drive.google.com/file/d/1y_i8R6l7EOkvxFzgf_W3jP3cg1u4F9xo
    1 capdigsvcarea.jpg                  https://drive.google.com/file/d/1Q2LKG5QWDHWDghuWFVUYKkXdje2ldU4q
    2 Catricala (1).jpg                  https://drive.google.com/file/d/1GEm-mKSjgV72818UB7MguM8f-Zum4Mqw
    3 Catricala (2).jpg                  https://drive.google.com/file/d/1yW83zEWYc8n0y_UXAztIx2GQF2EAI8Z4
    4 Catricala (3).jpg                  https://drive.google.com/file/d/1aT35fdotBVr382x6xXLZWgIEnrqcKBXL
    5 EntryList.ps1                      <Insert Hyperlink>
    6 IMG_0403 (1).jpg                   https://drive.google.com/file/d/1AJVPkRIwup6yC-ZddMprzORAGnhnkqJt
    7 IMG_0432 (1).jpg                   https://drive.google.com/file/d/1Jlia9OkIvO36-xAPFNJLD9AFJFweLn-C
    8 IMG_0652 (1).PNG                   https://drive.google.com/file/d/1EDUbELE98fVqcgVr9WoKLDN1FWQyl1Jh
    9 iPhone 8 Plus (1).jpg              https://drive.google.com/file/d/173o4Bfd3WDRhow9MLsR51qsh25kU3TIe
   10 New Salem (1).jpg                  https://drive.google.com/file/d/12mWS0e8n2beMA843wT0IBzpxyUJdWDsV
   11 New Salem (2).jpg                  https://drive.google.com/file/d/1aQ_CmZ2oF6euDKWLoxTuBq3jkX5mFKm_
   12 New Salem (3).jpg                  https://drive.google.com/file/d/1eocObao3jJV_EHrNgdBCTrb0gxiiPEyl
   13 NYSDOCS (1).jpg                    https://drive.google.com/file/d/1bdwna7HG8Y7GEk3BqRF6poxS8RaLzPbi
   14 NYSDOCS (2).jpg                    https://drive.google.com/file/d/1wbjBoS-5zLUKbWCU0oiRR0z4B4xOr9wC
   15 SCSO-2020-002998 (1).JPG           https://drive.google.com/file/d/1ykNZKM_VS0NWdckqVToSmL-ujjTBl4zz
   16 SCSO-2020-002998 (2).JPG           https://drive.google.com/file/d/1i4s7_tiT5bdNWsydqIMDMFFRRrOx1-zZ
   17 SCSO-2020-002998 (3).JPG           https://drive.google.com/file/d/17K2GMKn6hx3CF_HrSuB8Z_HfPlUKmNkQ
   18 SCSO-2020-003173 (1).JPG           https://drive.google.com/file/d/14Ajb2y93NEJ6YC255-lHe361KoCF7OxP
   19 SCSO-2020-003173 (2).JPG           https://drive.google.com/file/d/1KsriWjDat6F2mz9Vy8FJMUWLRF6ViYO4
   20 SCSO-2020-003173 (3).JPG           https://drive.google.com/file/d/1l_fs1BP1FmQiuoQ7rJZQAh3dvpw5o-bQ
   21 SCSO-2020-003173 (4).JPG           https://drive.google.com/file/d/1cDq5H8QpzvowOJ1C3rLbraiNCJaoscTW
   22 SCSO-2020-003173 (5).JPG           https://drive.google.com/file/d/13zr1gip9mkaJSsXRnxU8lhZiR5cNYTKj
   23 SCSO-2020-003173 (6).JPG           https://drive.google.com/file/d/17ZvRkZWwxDTHCnrhbHOL7hh_L2MCnF7t
   24 SCSO-2020-003177 (1).JPG           https://drive.google.com/file/d/1xritPqOI-ng04v_yp203zM_3sG2-_Jb2
   25 SCSO-2020-003177 (2).JPG           https://drive.google.com/file/d/119rBz3sGpt6lPF4qQ90nWwALZ2W1iWJ3
   26 SCSO-2020-003177 (3).JPG           https://drive.google.com/file/d/1FfcBWZZlkmf88XOtq0xBIvgK6m_3qwkP
   27 SCSO-2020-003177 (4).JPG           https://drive.google.com/file/d/1WkNbhqgvDIWZJYbCObEI-j12Mz_g2CDJ
   28 SCSO-2020-003177 (5).JPG           https://drive.google.com/file/d/1rjCU9yHzIo6gFw41aPAtAMmr42-iAG1I
   29 SCSO-2020-003564 (1).JPG           https://drive.google.com/file/d/1wYsaD825xVjkJ7eCbve6DwflW5v1KYCx
   30 SCSO-2020-003564 (2).JPG           https://drive.google.com/file/d/1uwgrUG3MCA9AU6jue_7GtDZyoz5YDKxz
   31 SCSO-2020-003564 (3).JPG           https://drive.google.com/file/d/1AUscW2inUcTlCgps-qX0QrBmUKdLOE4h
   32 SCSO-2020-003564 (4).JPG           https://drive.google.com/file/d/1DwVB9wRN-mHBLKciGRinwMrdCZZgwIeI
   33 SCSO-2020-003564 (5).JPG           https://drive.google.com/file/d/1CTmhJEd-6vzlMZHv6iCeEcCjpc80Tjbs
   34 SCSO-2020-003688 (1).JPG           https://drive.google.com/file/d/1R0EUH3z8JRhliQuvpMogZK8l5Nzi80mw
   35 SCSO-2020-003688 (2).JPG           https://drive.google.com/file/d/1H62ZDnQT3s-k-aUXMJAFzWseMk79e_a7
   36 SCSO-2020-003688 (3).JPG           https://drive.google.com/file/d/1g00XTcJk5_tzb4Utdn_i2on_TYuwaXTV
   37 SCSO-2020-003688 (4).JPG           https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV
   38 SCSO-2020-003688 (5).JPG           https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV
   39 SCSO-2020-027797 (1).jpg           https://drive.google.com/file/d/19Vkh-Uc_7yR9HJcmQnsttIo6H5tmUYzK
   40 SCSO-2020-027797 (2).jpg           https://drive.google.com/file/d/1CjjAS46TX-RfeSYkhKmXVKsD94pwBX7b
   41 SCSO-2020-027797 (3).jpg           https://drive.google.com/file/d/1CQjwnrFkAxL9meg63z1ttdyz5Hczs5RM
   42 SCSO-2020-027797 (4).jpg           https://drive.google.com/file/d/1dfL4ca_lwe_CBDO1ttfYcL5d4_koopWC
   43 SCSO-2020-027797 (5).jpg           https://drive.google.com/file/d/1yGBIQbo20b6sPovrJkOOM9EXIUdPF2zQ
   44 SCSO-2020-027797 (6).JPG           https://drive.google.com/file/d/1pfbyK6dlsFKC1JTDaKxdvdCJQl1HX_3W
   45 SCSO-2020-028501 (1).JPG           https://drive.google.com/file/d/1adfRlVCkUn5H-eauU8pNtPogGlnsVwbP
   46 SCSO-2020-028501 (2).JPG           https://drive.google.com/file/d/1fxb8zTS2v19W5_iIjA3jaGxEaYpFROdO
   47 SCSO-2020-028501 (3).JPG           https://drive.google.com/file/d/1R14NXV0ziULhhv3tCfzxBuH-TDYv0iWy
   48 SCSO-2020-028501 (4).JPG           https://drive.google.com/file/d/1XvlYs2OHS0j6jbV5kYqhyYPb5JomMGH-
   49 SCSO-2020-028501-CORRECTED (1).jpg https://drive.google.com/file/d/1a4K323ZRoz6SkKUPCjR2ycM-AY5YpIAV
   50 SCSO-2020-040452 (1).JPG           https://drive.google.com/file/d/1xfJ2mYvxptHLldugAXjhEdASRJpWIzIK
   51 SCSO-2020-040452 (10).JPG          https://drive.google.com/file/d/1_VkPwS0UaoxPymS5rTYN3pKBSGtksw2E
   52 SCSO-2020-040452 (2).JPG           https://drive.google.com/file/d/1Tg6cFXH5dKEL8XaYYOG_YlvaOsDQcTWW
   53 SCSO-2020-040452 (3).JPG           https://drive.google.com/file/d/1U6CAQBk3f__piiQSSjPeInnKr8ao4wkj
   54 SCSO-2020-040452 (4).JPG           https://drive.google.com/file/d/1sbOUEgjK9AqrRrDRYa1EkU-ErkTXqURa
   55 SCSO-2020-040452 (5).JPG           https://drive.google.com/file/d/1gy68TFdZtye5l6beMmZBiUTYVXlJKe-i
   56 SCSO-2020-040452 (6).JPG           https://drive.google.com/file/d/1w9bTxJKvT5MUWmmqgIYY0DfayD5LOlSI
   57 SCSO-2020-040452 (7).JPG           https://drive.google.com/file/d/1CzN8beW0ZZdX090YOw2mEJIdCZC04PGW
   58 SCSO-2020-040452 (8).JPG           https://drive.google.com/file/d/1HvTGMksppPjm2DbP15TznxUefIsOMSXl
   59 SCSO-2020-040452 (9).JPG           https://drive.google.com/file/d/18lqeF2KZGTcP_y8stv8I7Vgj1eO3p9-N
   60 SCSO-2020-040845 (1).JPG           https://drive.google.com/file/d/16LJXiWdXHTHdjdu8RZljsP4QtcaLpb9o
   61 SCSO-2020-040845 (2).JPG           https://drive.google.com/file/d/1d66nKgEBDPUm_ZRRHGjtV21i5WlCQX11
   62 SCSO-2020-040845 (3).JPG           https://drive.google.com/file/d/1n9FR3MNUuqQTlOkdYa9D8ZePoGF8krpF
   63 SCSO-2020-040845 (4).JPG           https://drive.google.com/file/d/1M5z-B_Unn8kW3WXBFSBGL8wQXL5TU56v
   64 SCSO-2020-040845 (5).JPG           https://drive.google.com/file/d/1p2Jeu80lNBIuADhsbeDFPDhcP4qpwWhK
   65 SCSO-2020-040845 (6).JPG           https://drive.google.com/file/d/1vR6pvH9X3cVivusOdw1CO0AcOQZk-ItV
   66 SCSO-2020-040845 (7).JPG           https://drive.google.com/file/d/1PYhrVopmnkIXisUKQ-CeCzAKPQnMh2g3
   67 SCSO-2020-049517 (1).JPG           https://drive.google.com/file/d/1WhcxCTZt26-gh9t0ZQKk6wSUaYfKk2Cr
   68 SCSO-2020-049517 (2).JPG           https://drive.google.com/file/d/1toDPjjf-M__-QHDVXIDsII_J2RjBxckO
   69 SCSO-2020-049517 (3).JPG           https://drive.google.com/file/d/1qxFw216D3Wm4RU2qUI53A27LpvNtA6_a
   70 SCSO-2020-049517 (4).JPG           https://drive.google.com/file/d/1-jBAexBvmsXzXLw6v_QEHCu3OEqyng9i
   71 SCSO-2020-049517 (5).JPG           https://drive.google.com/file/d/17XwO7_Yb3AbU-IW0wKwl6fZiLciPdDs_
   72 SCSO-2020-049517 (6).JPG           https://drive.google.com/file/d/1iUkG4Wv02XKXMYZTuStZ5U6K1ZcdJ43r
   73 SCSO-2020-053053 (1).JPG           https://drive.google.com/file/d/1XNtAwHgD0SJwDHNqx9FKByY3U-TRuq3a
   74 SCSO-2020-053053 (2).JPG           https://drive.google.com/file/d/1cKcu6EM7KMztdSFgPNGysp6arvkQSYGM
   75 SCSO-2020-053053 (3).JPG           https://drive.google.com/file/d/1OVlZClO_mdtKK9A0rqBBf7zhsRz4mFqb
   76 SCSO-2020-053053 (4).JPG           https://drive.google.com/file/d/1M1xyGwyA-_1Dc0EEN-O-XX0iuq74GxTn
   77 SCSO-2020-053053 (5).JPG           https://drive.google.com/file/d/1V8rhIh-T6HXT5HBgrAynIEJ7FoDMTi4N
#>
