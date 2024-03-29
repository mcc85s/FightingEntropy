[logo]: https://github.com/mcc85s/FightingEntropy/blob/main/Graphics/OEMlogo.bmp

<p align="center" width="100%">
    <img width="66%" src="https://github.com/mcc85s/FightingEntropy/blob/main/Graphics/banner.png">
</p>

| Logo    | Company                        | Project                  | Objective                                           |
|:--------|:-------------------------------|:-------------------------|:----------------------------------------------------|
| ![logo] | **Secure Digits Plus (π) LLC** | **[FightingEntropy(π)]** | Beginning the fight against ID theft and cybercrime |

# About
**[FightingEntropy(π)]** is a modification for **Windows PowerShell** that is meant for various tasks related to:
- [**system administration**]
- [**networking**]
- [**virtualization**]
- [**security**]
- [**graphic design**]
- [**system management/maintenance**]

# Demo
| Date       | Name                                             | Url                          |
|:-----------|:-------------------------------------------------|:-----------------------------|
| `10/28/22` | [**[FightingEntropy(π)][2022.10.1]**]            | https://youtu.be/S7k4lZdPE-I |
| `04/03/23` | [**Virtualization Lab - TCP Session**]           | https://youtu.be/09c-fFbEQrU |
| `03/20/23` | [**Virtualization Lab - Desktop Deployment**]    | https://youtu.be/i2_fafoIx6I |
| `01/31/23` | [**New-VmController [Flight Test v2.0] Part I**] | https://youtu.be/nqTOmNIilxw |
| `01/12/23` | [**Virtualization Lab - FEDCPromo**]             | https://youtu.be/9v7uJHF-cGQ |

This module is rather _experimental_ and incorporates a lot of moving parts, so it has many areas of development.
The end goal of this module, is to provide protection against:
- [**identity theft**]
- [**cybercriminals**]
- [**douchebags**]
- [**malware**]
- [**viruses**]
- [**ransomware**]
- [**hackers who have malicious intent**]

Many of the tools in the wild are able to be circumvented by some of these hackers and cybercriminals.
If you don't believe me...? That's fine. That's why [this link to a particular website about a particular event](https://en.wikipedia.org/wiki/2020_United_States_federal_government_data_breach), exists.

**[FightingEntropy(π)]** is meant to extend many of the capabilities that come with [**Windows**].

# Versions
| Version       | Date                  | Guid                                   |
|:--------------|:----------------------|:---------------------------------------|
| [**2024.1.0**](https://github.com/mcc85s/FightingEntropy/tree/main/Version/2024.1.0) | `01/21/2024 15:45:50` | `2a354137-91c8-49c3-92d0-ee6275dab2fc` |
| [**2023.8.0**](https://github.com/mcc85s/FightingEntropy/tree/main/Version/2023.8.0) | `08/07/2023 20:52:08` | `4b564727-b84b-4033-a716-36d1c5e3e62d` |
| [**2023.4.0**](https://github.com/mcc85s/FightingEntropy/tree/main/Version/2023.4.0) | `04/03/2023 18:53:49` | `75f64b43-3b02-46b1-b6a2-9e86cccf4811` |

# Prerequisites
1) A system running [**Windows PowerShell**] on: 
- [**Windows 10/11**]
- [**Windows Server 2016/2019/2021**]
   
2) [**Execution Policy**] must be set to [**bypass**]

3) Must be running a [**PowerShell**] session with [**administrative privileges**]

# Installation
1) [**Load the module into memory**], which can be done be using this command:
   
`irm https://github.com/mcc85s/FightingEntropy/blob/main/FightingEntropy.ps1?raw=true | iex`

...or just (copying + pasting) the content of the file...

`https://github.com/mcc85s/FightingEntropy/blob/main/FightingEntropy.ps1`

...into the [**PowerShell**] session, and pressing [**&lt;Enter&gt;**]... and then [**boom**].
You're rollin'.

2) Once the [**module is loaded into memory**], enter the following:

| Operation  | Instructions        | Description                                                                           |
|:-----------|:--------------------|:--------------------------------------------------------------------------------------|
| Latest     | `$Module.Latest()`  | Retrieves the latest zip archive and updates any outstanding files (fastest)          |

...or...

| Operation  | Instructions        | Description                                                                           |
|:-----------|:--------------------|:--------------------------------------------------------------------------------------|
| Install    | `$Module.Install()` | Installs the module by retrieving individual files in the manifest (thorough)         |
| Remove     | `$Module.Remove()`  | Removes all traces of the module from the system (does not consider extraneous paths) |

# Author
| Name                | Motto                                          | Contact                    | Resume           |
|:--------------------|:-----------------------------------------------|:---------------------------|:-----------------|
| **Michael C. Cook Sr.** | Sometimes you gotta take the throttle in life. | securedigitsplus@gmail.com | [Link](https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2022_1010-(MCC%20Short%20Resume).pdf) |

# Videos
These various videos demonstrate some portion of [**FightingEntropy(π)**] (newest to oldest)
| Index | Date      | Name                                             | Url                          |
|:------|:----------|:-------------------------------------------------|:-----------------------------|
|     0 | `01/06/24` | Virtualization Lab - Windows 10 22H2            | https://youtu.be/g3GJe00WJLg |
|     1 | `04/30/23` | Virtualization Lab - Windows 11                 | https://youtu.be/OmTRiYemQAI |
|     2 | `04/12/23` | Virtualization Lab - RHEL Deployment            | https://youtu.be/AucVPa_EpQc |
|     3 | `04/03/23` | Virtualization Lab - TCP Session                | https://youtu.be/09c-fFbEQrU |
|     4 | `03/20/23` | Virtualization Lab - Desktop Deployment         | https://youtu.be/i2_fafoIx6I |
|     5 | `01/12/23` | [**PowerShell Virtualization Lab + FEDCPromo**] | https://youtu.be/9v7uJHF-cGQ |
|     6 | `04/05/22` | [**Wireless Network Scanning Utility**]         | https://youtu.be/35EabWfh8dQ |
|     7 | `12/05/21` | [**[FightingEntropy(π)][FEInfrastructure**]]    | https://youtu.be/6yQr06_rA4I |
|     8 | `10/20/21` | [**Advanced Domain Controller Promotion**]      | https://youtu.be/O8A2PDfQOBs |
|     9 | `09/23/21` | [**PowerShell Deployment FE Wizard**]           | https://youtu.be/lZX5fAgczz0 |
|    10 | `09/08/21` | [**cimdb**]                                     | https://youtu.be/vA8_HLZ--mQ |
|    11 | `08/30/21` | [**Flight Test Part 2**]                        | https://youtu.be/vg359UlYVp8 |
|    12 | `08/26/21` | [**Flight Test Part 1**]                        | https://drive.google.com/file/d/1qdS_UVcLTsxHFCpuwK16NQs0xJL7fv0W |
|    13 | `06/30/21` | [**Windows Image Extraction**]                  | https://youtu.be/G10EuwlNAyo |
|    14 | `06/27/21` | [**Advanced System Administration Lab**]        | https://youtu.be/xgffIccX1eg |
|    15 | `06/20/21` | [**Install-pfSense**]                           | https://youtu.be/E_uFbzS0blQ |
|    16 | `03/09/21` | [**A Deep Dive: PowerShell and XAML**]          | https://youtu.be/NK4NuQrraCI |
|    17 | `11/28/19` | [**Methodologies**]                             | https://youtu.be/bZuSgBK36CE |
|    18 | `08/28/19` | [**Education/Exhibition Program Design**]       | https://youtu.be/v6RrrzR5v2E |
|    19 | `05/28/19` | [**Hybrid - Desired State Controller**]         | https://youtu.be/C8NYaaqJAlI |
|    20 | `01/25/19` | [**2019_0125-(Computer Answers - MDT**)]        | https://youtu.be/5Cyp3pqIMRs |
