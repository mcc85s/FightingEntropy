Function Get-Vault7
{
    Class Part
    {
        [UInt32]         $Index
        [String]          $Name
        [String]   $Description
        [String]           $URL
        Part([UInt32]$Index,[String]$Name,[String]$Description,[String]$URL)
        {
            $This.Index       = $Index
            $This.Name        = $Name
            $This.Description = $Description
            $This.URL         = $URL
        }
    }

    Class Vault_7
    {
        Hidden [Object] $PartNames = @("Vault_7","YearZero","DarkMatter","Marble","Grasshopper","HIVE","WeepingAngel",
        "Scribbles","Archimedes","AfterMidnightAssassin","Athena","Pandemic","CherryBlossom","BrutalKangaroo","Elsa",
        "OutlawCountry","BothanSpy","Highrise","UCL_Raytheon","Imperial","Dumbo","CouchPotato","ExpressLane","Angelfire",
        "Protego")
        [Object] $Output
        Vault_7()
        {
            $This.Output      = @( )
            $This.PartNames   | % { $This.AddPart($_) }
        }
        [String] GetURL([String]$Name)
        {
            Return "https://wikileaks.org/vault7/#$Name"
        }
        [Object] GetPart([String]$Name)
        {
            $X = $Null
            If ($Name -in $This.PartNames)
            {
                $X = Switch -Regex ($Name)
                {
                    Vault_7
                    {
                        0,
                        ('Vault 7 is a series of documents that WikiLeaks began to publish on 7 March 2017, detailing the activities and capabilities of'+
                        ' the United States Central Intelligence Agency to perform electronic surveillance and cyber warfare. The files, dating from 2013 '+
                        'to 2016, include details on the agency&apos;s software capabilities, such as the ability to compromise cars, smart TVs,[1] web br'+
                        'owsers (including Google Chrome, Microsoft Edge, Mozilla Firefox, and Opera),[2][3][4] and the operating systems of most smartpho'+
                        'nes (including Apple&apos;s iOS and Google&apos;s Android), as well as other operating systems such as Microsoft Windows, macOS, '+
                        'and Linux.[5][6] A CIA internal audit identified 91 malware tools out of more than 500 tools in use in 2016 being compromised by '+
                        'the release.[7]'),
                        'https://wikileaks.org/vault7'
                    }
                    YearZero    
                    {
                        1,
                        ('The first batch of documents named "Year Zero" was published by WikiLeaks on 7 March 2017, consisting of 7,818 web pages with '+
                        '943 attachments, purportedly from the Center for Cyber Intelligence,[22] which already contains more pages than former NSA contra'+
                        'ctor and leaker, Edward Snowden&apos;s NSA release.[23] WikiLeaks did not name the source, but said that the files had "circulate'+
                        'd among former U.S. government hackers and contractors in an unauthorized manner, one of whom has provided WikiLeaks with portion'+
                        's of the archive."[1] According to WikiLeaks, the source "wishes to initiate a public debate about the security, creation, use, p'+
                        'roliferation and democratic control of cyberweapons" since these tools raise questions that "urgently need to be debated in publi'+
                        'c, including whether the C.I.A.&apos;s hacking capabilities exceed its mandated powers and the problem of public oversight of the'+
                        ' agency."[1]'),
                        'https://wikileaks.org/ciav7p1/index.html'
                    }
                    DarkMatter  
                    { 
                        2,
                        ('On 23 March 2017 WikiLeaks published Vault 7 part 2 "Dark Matter". The publication included documentation for several CIA effo'+
                        'rts to hack Apple&apos;s iPhones and Macs.[30][31][32] These included the "Sonic Screwdriver" malware that could use the thunderb'+
                        'olt interface to bypass Apple&apos;s password firmware protection.[33]'),
                        'https://wikileaks.org/vault7/#Dark%20Matter'
                    }
                    Marble
                    { 
                        3,
                        ('On 31 March 2017, WikiLeaks published Vault 7 part 3 "Marble". It contained 676 source code files for the CIA&apos;s Marble Fr'+
                        'amework. It is used to obfuscate, or scramble, malware code in an attempt to make it so that anti-virus firms or investigators ca'+
                        'nnot understand the code or attribute its source. According to WikiLeaks, the code also included a de-obfuscator to reverse the o'+
                        'bfuscation effects.[34][35][36]'),
                        "https://wikileaks.org/vault7/#Marble%20Framework"
                    }
                    Grasshopper
                    { 
                        4,
                        ('On 7 April 2017, WikiLeaks published Vault 7 part 4 dubbed "Grasshopper". The publication contains 27 documents from the CIA&a'+
                        'pos;s Grasshopper framework, which is used by the CIA to build customized and persistent malware payloads for the Microsoft Windo'+
                        'ws operating systems. Grasshopper focused on Personal Security Product (PSP) avoidance. PSPs are antivirus software such as MS Se'+
                        'curity Essentials, Symantec Endpoint or Kaspersky IS.[36][37]'),
                        "https://wikileaks.org/vault7/#Grasshopper"
                    }
                    HIVE
                    { 
                        5,
                        ('On 14 April 2017, WikiLeaks published Vault 7 part 5, titled "HIVE". Based on the CIA top-secret virus program created by its '+
                        '"Embedded Development Branch" (EDB). The six documents published by WikiLeaks are related to the HIVE multi-platform CIA malware '+
                        'suite. A CIA back-end infrastructure with a public-facing HTTPS interface used by CIA to transfer information from target desktop'+
                        ' computers and smartphones to the CIA, and open those devices to receive further commands from CIA operators to execute specific '+
                        'tasks, all the while hiding its presence behind unsuspicious-looking public domains through a masking interface known as "Switchb'+
                        'lade". Also called Listening Post (LP) and Command and Control (C2).[38]'),
                        "https://wikileaks.org/vault7/#Hive"
                    }
                    WeepingAngel
                    {
                        6,
                        ('On 21 April 2017, WikiLeaks published Vault 7 part 6, code-named "Weeping Angel", a hacking tool co-developed by the CIA and M'+
                        'I5 used to exploit a series of smart TVs for the purpose of covert intelligence gathering. Once installed in suitable televisions'+
                        ' with a USB stick, the hacking tool enables those televisions&apos; built-in microphones and possibly video cameras to record the'+
                        'ir surroundings, while the televisions falsely appear to be turned off. The recorded data is then either stored locally into the '+
                        'television&apos;s memory or sent over the internet to the CIA. Allegedly both the CIA and MI5 agencies collaborated to develop th'+
                        'at malware and coordinated their work in Joint Development Workshops.[39][40] As of this part 6 publication, "Weeping Angel" is t'+
                        'he second major CIA hacking tool which notably references the British television show, Doctor Who, alongside "Sonic Screwdriver" '+
                        'in "Dark Matter".[41][42]'),
                        "https://wikileaks.org/vault7/#Weeping%20Angel"
                    }
                    Scribbles
                    { 
                        7,
                        ('On 28 April 2017, WikiLeaks published Vault 7 part 7 "Scribbles". The leak includes documentation and source code of a tool in'+
                        'tended to track documents leaked to whistleblowers and journalists by embedding web beacon tags into classified documents to trac'+
                        'e who leaked them.[43][44] The tool affects Microsoft Office documents, specifically "Microsoft Office 2013 (on Windows 8.1 x64),'+
                        ' documents from Office versions 97-2016 (Office 95 documents will not work!) and documents that are not locked, encrypted, or pas'+
                        'sword-protected".[45] When a CIA watermarked document is opened, an invisible image within the document that is hosted on the age'+
                        'ncy&apos;s server is loaded, generating a HTTP request. The request is then logged on the server, giving the intelligence agency '+
                        'information about who is opening it and where it is being opened. However, if a watermarked document is opened in an alternative '+
                        'word processor the image may be visible to the viewer. The documentation also states that if the document is viewed offline or in'+
                        ' protected view, the watermarked image will not be able to contact its home server. This is overridden only when a user enables e'+
                        'diting.[46]'),
                        "https://wikileaks.org/vault7/#Scribbles"
                    }
                    Archimedes
                    { 
                        8,
                        ('On 5 May 2017, WikiLeaks published Vault 7 part 8 "Archimedes". According to U.S. SANS Institute instructor Jake Williams, who'+
                        ' analyzed the published documents, Archimedes is a virus previously codenamed "Fulcrum". According to cyber security expert and E'+
                        'NISA member Pierluigi Paganini, the CIA operators use Archimedes to redirect local area network (LAN) web browser sessions from a'+
                        ' targeted computer through a computer controlled by the CIA before the sessions are routed to the users. This type of attack is k'+
                        'nown as man-in-the-middle (MitM). With their publication WikiLeaks included a number of hashes that they claim can be used to pot'+
                        'entially identify the Archimedes virus and guard against it in the future. Paganini stated that potential targeted computers can '+
                        'search for those hashes on their systems to check if their systems had been attacked by the CIA.[47]'),
                        "https://wikileaks.org/vault7/#Archimedes"
                    }
                    AfterMidnightAssassin
                    { 
                        9,
                        ('AfterMidnight is a malware installed on a target personal computer and disguises as a DLL file, which is executed while the us'+
                        'er&apos;s computer reboots. It then triggers a connection to the CIA&apos;s Command and Control (C2) computer, from which it down'+
                        'loads various modules to run. As for Assassin, it is very similar to its AfterMidnight counterpart, but deceptively runs inside a'+
                        ' Windows service process. CIA operators reportedly use Assassin as a C2 to execute a series of tasks, collect, and then periodica'+
                        'lly send user data to the CIA Listening Post(s) (LP). Similar to backdoor Trojan behavior. Both AfterMidnight and Assassin run on'+
                        ' Windows operating system, are persistent, and periodically beacon to their configured LP to either request tasks or send private'+
                        ' information to the CIA, as well as automatically uninstall themselves on a set date and time.[48][49]'),
                        "https://wikileaks.org/vault7/#AfterMidnight"
                    }
                    Athena
                    { 
                        10,
                        ('On 19 May 2017, WikiLeaks published Vault 7 part 10 "Athena". The published user guide, demo, and related documents were crea'+
                        'ted between September 2015 and February 2016. They are all about a malware allegedly developed for the CIA in August 2015, roughl'+
                        'y one month after Microsoft released Windows 10 with their firm statements about how difficult it was to compromise. Both the pri'+
                        'mary "Athena" malware and its secondary malware named "Hera" are similar in theory to Grasshopper and AfterMidnight malware but w'+
                        'ith some significant differences. One of those differences is that Athena and Hera were developed by the CIA with a New Hampshire'+
                        ' private corporation called Siege Technologies. During a Bloomberg 2014 interview the founder of Siege Technologies confirmed and'+
                        ' justified their development of such malware. Athena malware completely hijacks Windows&apos; Remote Access services, while Hera '+
                        'hijacks Windows Dnscache service. Also both Athena and Hera affect all current versions of Windows including, but not limited to,'+
                        ' Windows Server 2012 and Windows 10. Another difference is in the types of encryption used between the infected computers and the'+
                        ' CIA Listening Posts (LP). As for the similarities, they exploit persistent DLL files to create a backdoor to communicate with CI'+
                        'A&apos;s LP, steal private data, then send it to CIA servers, or delete private data on the target computer, as well as Command a'+
                        'nd Control (C2) for CIA operatives to send additional malicious software to further run specific tasks on the attacked computer. '+
                        'All of the above designed to deceive computer security software. Beside the published detailed documents, WikiLeaks has not provi'+
                        'ded any evidence suggesting the CIA used Athena or not.[50][51][52]'),
                        'https://wikileaks.org/vault7/#Athena'
                    }
                    Pandemic
                    { 
                        11,
                        ('On 1 June 2017, WikiLeaks published Vault 7 part 11 "Pandemic". This tool serves as a persistent implant affecting Windows ma'+
                        'chines with shared folders. It functions as a file system filter driver on an infected computer, and listens for Server Message B'+
                        'lock traffic while detecting download attempts from other computers on a local network. "Pandemic" will answer a download request'+
                        ' on behalf of the infected computer. However, it will replace the legitimate file with malware. In order to obfuscate its activit'+
                        'ies, "Pandemic" only modifies or replaces the legitimate file in transit, leaving the original on the server unchanged. The impla'+
                        'nt allows 20 files to be modified at a time, with a maximum individual file size of 800MB. While not stated in the leaked documen'+
                        'tation, it is possible that newly infected computers could themselves become "Pandemic" file servers, allowing the implant to rea'+
                        'ch new targets on a local network.[53]'),
                        'https://wikileaks.org/vault7/#Pandemic'
                    }
                    CherryBlossom
                    { 
                        12,
                        ('June 15th 2017, WikiLeaks publishes documents from the CherryBlossom project of the CIA that was developed and implemented wi'+
                        'th the help of the US nonprofit Stanford Research Institute (SRI International). CherryBlossom provides a means of monitoring the'+
                        ' Internet activity of and performing software exploits on Targets of interest. In particular, CherryBlossom is focused on comprom'+
                        'ising wireless networking devices, such as wireless routers and access points (APs), to achieve these goals. Such Wi-Fi devices a'+
                        're commonly used as part of the Internet infrastructure in private homes, public spaces (bars, hotels or airports), small and med'+
                        'ium sized companies as well as enterprise offices. Therefore these devices are the ideal spot for "Man-In-The-Middle" attacks, as'+
                        ' they can easily monitor, control and manipulate the Internet traffic of connected users. By altering the data stream between the'+
                        ' user and Internet services, the infected device can inject malicious content into the stream to exploit vulnerabilities in appli'+
                        'cations or the operating system on the computer of the targeted user'),
                        'https://wikileaks.org/vault7/#Cherry%20Blossom'
                    }
                    BrutalKangaroo
                    { 
                        13,
                        ('Today, June 22nd 2017, WikiLeaks publishes documents from the Brutal Kangaroo project of the CIA. Brutal Kangaroo is a tool s'+
                        'uite for Microsoft Windows that targets closed networks by air gap jumping using thumbdrives. Brutal Kangaroo components create a'+
                        ' custom covert network within the target closed network and providing functionality for executing surveys, directory listings, an'+
                        'd arbitrary executables. The documents describe how a CIA operation can infiltrate a closed network (or a single air-gapped compu'+
                        'ter) within an organization or enterprise without direct access. It first infects a Internet-connected computer within the organi'+
                        'zation (referred to as "primary host") and installs the BrutalKangeroo malware on it. When a user is using the primary host and i'+
                        'nserts a USB stick into it, the thumbdrive itself is infected with a separate malware. If this thumbdrive is used to copy data be'+
                        'tween the closed network and the LAN/WAN, the user will sooner or later plug the USB disk into a computer on the closed network. '+
                        'By browsing the USB drive with Windows Explorer on such a protected computer, it also gets infected with exfiltration/survey malw'+
                        'are. If multiple computers on the closed network are under CIA control, they form a covert network to coordinate tasks and data e'+
                        'xchange. Although not explicitly stated in the documents, this method of compromising closed networks is very similar to how Stux'+
                        'net worked.'),
                        'https://wikileaks.org/vault7/#Brutal%20Kangaroo'
                    }
                    Elsa
                    { 
                        14,
                        ('June 28th 2017, WikiLeaks publishes documents from the ELSA project of the CIA. ELSA is a geo-location malware for WiFi-enabl'+
                        'ed devices like laptops running the Micorosoft Windows operating system. Once persistently installed on a target machine using se'+
                        'parate CIA exploits, the malware scans visible WiFi access points and records the ESS identifier, MAC address and signal strength'+
                        ' at regular intervals. To perform the data collection the target machine does not have to be online or connected to an access poi'+
                        'nt; it only needs to be running with an enabled WiFi device. If it is connected to the internet, the malware automatically tries '+
                        'to use public geo-location databases from Google or Microsoft to resolve the position of the device and stores the longitude and '+
                        'latitude data along with the timestamp. The collected access point/geo-location information is stored in encrypted form on the de'+
                        'vice for later exfiltration. The malware itself does not beacon this data to a CIA back-end; instead the operator must actively r'+
                        'etrieve the log file from the device - again using separate CIA exploits and backdoors. The ELSA project allows the customization'+
                        ' of the implant to match the target environment and operational objectives like sampling interval, maximum size of the logfile an'+
                        'd invocation/persistence method. Additional back-end software (again using public geo-location databases from Google and Microsof'+
                        't) converts unprocessed access point information from exfiltrated logfiles to geo-location data to create a tracking profile of t'+
                        'he target device.'),
                        'https://wikileaks.org/vault7/#Elsa'
                    }
                    OutlawCountry
                    { 
                        15,
                        ('June 30th 2017, WikiLeaks publishes documents from the OutlawCountry project of the CIA that targets computers running the Li'+
                        'nux operating system. OutlawCountry allows for the redirection of all outbound network traffic on the target computer to CIA cont'+
                        'rolled machines for ex- and infiltration purposes. The malware consists of a kernel module that creates a hidden netfilter table '+
                        'on a Linux target; with knowledge of the table name, an operator can create rules that take precedence over existing netfilter/ip'+
                        'tables rules and are concealed from an user or even system administrator. The installation and persistence method of the malware '+
                        'is not described in detail in the document; an operator will have to rely on the available CIA exploits and backdoors to inject t'+
                        'he kernel module into a target operating system. OutlawCountry v1.0 contains one kernel module for 64-bit CentOS/RHEL 6.x; this m'+
                        'odule will only work with default kernels. Also, OutlawCountry v1.0 only supports adding covert DNAT rules to the PREROUTING chai'+
                        'n.'),
                        'https://wikileaks.org/vault7/#OutlawCountry'
                    }
                    BothanSpy
                    { 
                        16,
                        ('July 6th 2017, WikiLeaks publishes documents from the BothanSpy and Gyrfalcon projects of the CIA. The implants described in '+
                        'both projects are designed to intercept and exfiltrate SSH credentials but work on different operating systems with different att'+
                        'ack vectors. BothanSpy is an implant that targets the SSH client program Xshell on the Microsoft Windows platform and steals user'+
                        ' credentials for all active SSH sessions. These credentials are either username and password in case of password-authenticated SS'+
                        'H sessions or username, filename of private SSH key and key password if public key authentication is used. BothanSpy can exfiltra'+
                        'te the stolen credentials to a CIA-controlled server (so the implant never touches the disk on the target system) or save it in a'+
                        'n enrypted file for later exfiltration by other means. BothanSpy is installed as a Shellterm 3.x extension on the target machine.'+
                        'Gyrfalcon is an implant that targets the OpenSSH client on Linux platforms (centos,debian,rhel,suse,ubuntu). The implant can not '+
                        'only steal user credentials of active SSH sessions, but is also capable of collecting full or partial OpenSSH session traffic. Al'+
                        'l collected information is stored in an encrypted file for later exfiltration. It is installed and configured by using a CIA-deve'+
                        'loped root kit (JQC/KitV) on the target machine.'),
                        'https://wikileaks.org/vault7/#BothanSpy'
                    }
                    Highrise
                    { 
                        17,
                        ('July 13th 2017, WikiLeaks publishes documents from the Highrise project of the CIA. HighRise is an Android application design'+
                        'ed for mobile devices running Android 4.0 to 4.3. It provides a redirector function for SMS messaging that could be used by a num'+
                        'ber of IOC tools that use SMS messages for communication between implants and listening posts. HighRise acts as a SMS proxy that '+
                        'provides greater separation between devices in the field ("targets") and the listening post (LP) by proxying "incoming" and "outg'+
                        'oing" SMS messages to an internet LP. Highrise provides a communications channel between the HighRise field operator and the LP w'+
                        'ith a TLS/SSL secured internet communication.'),
                        'https://wikileaks.org/vault7/#Highrise'
                    }
                    UCL_Raytheon
                    { 
                        18,
                        ('July 19th 2017, WikiLeaks publishes documents from the CIA contractor Raytheon Blackbird Technologies for the "UMBRAGE Compon'+
                        'ent Library" (UCL) project. The documents were submitted to the CIA between November 21st, 2014 (just two weeks after Raytheon ac'+
                        'quired Blackbird Technologies to build a Cyber Powerhouse) and September 11th, 2015. They mostly contain Proof-of-Concept ideas a'+
                        'nd assessments for malware attack vectors - partly based on public documents from security researchers and private enterprises in'+
                        ' the computer security field. Raytheon Blackbird Technologies acted as a kind of "technology scout" for the Remote Development Br'+
                        'anch (RDB) of the CIA by analysing malware attacks in the wild and giving recommendations to the CIA development teams for furthe'+
                        'r investigation and PoC development for their own malware projects.'),
                        'https://wikileaks.org/vault7/#UCL%20/%20Raytheon'
                    }
                    Imperial
                    { 
                        19,
                        ('July 27th 2017, WikiLeaks publishes documents from the Imperial project of the CIA. Achilles is a capability that provides an'+
                        ' operator the ability to trojan an OS X disk image (.dmg) installer with one or more desired operator specified executables for a'+
                        ' one-time execution. Aeris is an automated implant written in C that supports a number of POSIX-based systems (Debian, RHEL, Sola'+
                        'ris, FreeBSD, CentOS). It supports automated file exfiltration, configurable beacon interval and jitter, standalone and Collide-b'+
                        'ased HTTPS LP support and SMTP protocol support - all with TLS encrypted communications with mutual authentication. It is compati'+
                        'ble with the NOD Cryptographic Specification and provides structured command and control that is similar to that used by several '+
                        'Windows implants. SeaPea is an OS X Rootkit that provides stealth and tool launching capabilities. It hides files/directories, so'+
                        'cket connections and/or processes. It runs on Mac OSX 10.6 and 10.7.'),
                        'https://wikileaks.org/vault7/#Imperial'
                    }
                    Dumbo
                    { 
                        20,
                        ('August 3rd 2017 WikiLeaks publishes documents from the Dumbo project of the CIA. Dumbo is a capability to suspend processes u'+
                        'tilizing webcams and corrupt any video recordings that could compromise a PAG deployment. The PAG (Physical Access Group) is a sp'+
                        'ecial branch within the CCI (Center for Cyber Intelligence); its task is to gain and exploit physical access to target computers '+
                        'in CIA field operations. Dumbo can identify, control and manipulate monitoring and detection systems on a target computer running'+
                        ' the Microsoft Windows operating sytem. It identifies installed devices like webcams and microphones, either locally or connected'+
                        ' by wireless (Bluetooth, WiFi) or wired networks. All processes related to the detected devices (usually recording, monitoring or'+
                        ' detection of video/audio/network streams) are also identified and can be stopped by the operator. By deleting or manipulating re'+
                        'cordings the operator is aided in creating fake or destroying actual evidence of the intrusion operation. Dumbo is run by the fie'+
                        'ld agent directly from an USB stick; it requires administrator privileges to perform its task. It supports 32bit Windows XP, Wind'+
                        'ows Vista, and newer versions of Windows operating system. 64bit Windows XP, or Windows versions prior to XP are not supported.'),
                        'https://wikileaks.org/vault7/#Dumbo'
                    }
                    CouchPotato
                    { 
                        21,
                        ('August 10th 2017, WikiLeaks publishes the the User Guide for the CoachPotato project of the CIA. CouchPotato is a remote tool'+
                        ' for collection against RTSP/H.264 video streams. It provides the ability to collect either the stream as a video file (AVI) or c'+
                        'apture still images (JPG) of frames from the stream that are of significant change from a previously captured frame. It utilizes '+
                        'ffmpeg for video and image encoding and decoding as well as RTSP connectivity. CouchPotato relies on being launched in an ICE v3 '+
                        'Fire and Collect compatible loader.'),
                        'https://wikileaks.org/vault7/#CouchPotato'
                    }
                    ExpressLane
                    { 
                        22,
                        ('August 24th 2017, WikiLeaks publishes secret documents from the ExpressLane project of the CIA. These documents show one of t'+
                        'he cyber operations the CIA conducts against liaison services -- which includes among many others the National Security Agency (N'+
                        'SA), the Department of Homeland Security (DHS) and the Federal Bureau of Investigation (FBI). The OTS (Office of Technical Servic'+
                        'es), a branch within the CIA, has a biometric collection system that is provided to liaison services around the world -- with the'+
                        ' expectation for sharing of the biometric takes collected on the systems. But this "voluntary sharing" obviously does not work or'+
                        ' is considered insufficient by the CIA, because ExpressLane is a covert information collection tool that is used by the CIA to se'+
                        'cretly exfiltrate data collections from such systems provided to liaison services. ExpressLane is installed and run with the cove'+
                        'r of upgrading the biometric software by OTS agents that visit the liaison sites. Liaison officers overseeing this procedure will'+
                        ' remain unsuspicious, as the data exfiltration disguises behind a Windows installation splash screen. The core components of the '+
                        'OTS system are based on products from Cross Match, a US company specializing in biometric software for law enforcement and the In'+
                        'telligence Community. The company hit the headlines in 2011 when it was reported that the US military used a Cross Match product '+
                        'to identify Osama bin Laden during the assassination operation in Pakistan.'),
                        'https://wikileaks.org/vault7/#ExpressLane'
                    }
                    Angelfire
                    { 
                        23,
                        ('August 31st 2017, WikiLeaks publishes documents from the Angelfire project of the CIA. Angelfire is an implant comprised of f'+
                        'ive components: Solartime, Wolfcreek, Keystone (previously MagicWand), BadMFS, and the Windows Transitory File system. Like previ'+
                        'ously published CIA projects (Grasshopper and AfterMidnight) in the Vault7 series, it is a persistent framework that can load and'+
                        ' execute custom implants on target computers running the Microsoft Windows operating system (XP or Win7). Solartime modifies the '+
                        'partition boot sector so that when Windows loads boot time device drivers, it also loads and executes the Wolfcreek implant, that'+
                        ' once executed, can load and run other Angelfire implants. According to the documents, the loading of additional implants creates'+
                        ' memory leaks that can be possibly detected on infected machines. Keystone is part of the Wolfcreek implant and responsible for s'+
                        'tarting malicious user applications. Loaded implants never touch the file system, so there is very little forensic evidence that '+
                        'the process was ever ran. It always disguises as "C:\Windows\system32\svchost.exe" and can thus be detected in the Windows task m'+
                        'anager, if the operating system is installed on another partition or in a different path. BadMFS is a library that implements a c'+
                        'overt file system that is created at the end of the active partition (or in a file on disk in later versions). It is used to stor'+
                        'e all drivers and implants that Wolfcreek will start. All files are both encrypted and obfuscated to avoid string or PE header sc'+
                        'anning. Some versions of BadMFS can be detected because the reference to the covert file system is stored in a file named "zf".  '+
                        'The Windows Transitory File system is the new method of installing AngelFire. Rather than lay independent components on disk, the'+
                        ' system allows an operator to create transitory files for specific actions including installation, adding files to AngelFire, rem'+
                        'oving files from AngelFire, etc. Transitory files are added to the "UserInstallApp".'),
                        'https://wikileaks.org/vault7/#Angelfire'
                    }
                    Protego
                    { 
                        24,
                        ('September 7th 2017, WikiLeaks publishes four secret documents from the Protego project of the CIA, along with 37 related docu'+
                        'ments (proprietary hardware/software manuals from Microchip Technology Inc.). The project was maintained between 2014 and 2015. P'+
                        'rotego is not the "usual" malware development project like all previous publications by WikiLeaks in the Vault7 series. Indeed th'+
                        'ere is no explicit indication why it is part of the project repositories of the CIA/EDG at all. The Protego project is a PIC-base'+
                        'd missile control system that was developed by Raytheon. The documents indicate that the system is installed on-board a Pratt & W'+
                        'hitney aircraft (PWA) equipped with missile launch systems (air-to-air and/or air-to-ground). Protego consists of separate micro-'+
                        'controller units that exchange data and signals over encrypted and authenticated channels: -o On-board TWA are the "Master Proces'+
                        'sor" (MP) and the "Deployment Box". Both systems are layed-out with master/slave redundancy. -o The missle system has micro-contr'+
                        'ollers for the missle itself ("Missle Smart Switch", MSS), the tube ("Tube Smart Switch", TSS) and the collar (which holds the mi'+
                        'ssile before and at launch time). The MP unit receives three signals from a beacon: "In Border" (PWA is within the defined area o'+
                        'f an operation), "Valid GPS" (GPS signal available) and "No End of Operational Period" (current time is within the defined timefr'+
                        'ame for an operation). Missiles can only be launched if all signals received by MP are set to "true". Similary safeguards are in '+
                        'place to auto-destruct encryption and authentication keys for various scenarios (like "leaving a target area of operation" or "mi'+
                        'ssing missle").'),
                        'https://wikileaks.org/vault7/#Protego'
                    }
                }

                Return [Part]::New($X[0],$Name,$X[1],$X[2])
            }
            Else
            {
                Return "Invalid entry"
            }
        }
        AddPart([String]$Name)
        {
            $Item = $This.GetPart($Name)
            If ($Item -ne $Null -and $Item.Name -notin $This.Output.Name)
            {
                $This.Output += $Item
            }
        }
        [Object[]] GetOutput()
        {
            Return @( Switch ($This.Output.Count)
            {
                0 { $Null } 1 { $This.Output } Default { $This.Output[0..($This.Output.Count-1)] }
            })
        }
        [Void] Draw()
        {
            ForEach ($Part in $This.Output)
            {
                Write-Theme -InputObject $Part -Title $Part.Name -Prompt $Part.URL
            }
        }
    }
    [Vault_7]::New()
}
