Function WDSServer # https://www.windows-noob.com/forums/topic/617-windows-deployment-services-registry-entries/
{
    $Collect = @( )

    Class WdsRegItem
    {
        [String] $Info
        [String] $Path
        [String] $Property
        [String] $Type
        [Object] $Value
        WdsRegItem([String]$Path,[String]$Property,[String]$Type,[Object]$Value)
        {
            $This.Path     = $Path
            $This.Property = $Property
            $This.Type     = $Type
            $This.Value    = $Value
        }
    }

    # Critical Providers for the WDSServer Service
    @{ 
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSDCMGR"
        Name  = "IsCritical"
        Type  = "REG_DWORD"
        Value = @{ 0 = "Not critical"; 1 = "Critical" }
    }

    # Client Answer Policy
    # Windows Deployment Services has a global on/off policy that controls whether or not client requests are answered. The policy is stored at
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "netbootAnswerRequests"
        Type  = "REG_SZ"
        Value = @{$False="Client requests will not be answered";$True="Client requests will be answered"}
    }

    # You can configure Windows Deployment Services to answer all incoming PXE requests or only those from prestaged clients (for example, WDSUTIL /Set-Server /AnswerClients:All). 
    @{ 
        Path   = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\Providers\BINLSVC"
        Name   = "netbootAnswerOnlyValidClients"
        Type   = "REG_SZ"
        Values = @{$False="All client requests will be answered";$True="Only prestaged clients will be answered"}
    }

    # Logging for the Windows Deployment Services Client
    # The values for logging level are stored in the following keys of the Windows Deployment Services server:
    @{ 
        Path   = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging"
        Name   = "Enabled"
        Type   = "REG_DWORD"
        Value  = @{0="DISABLED";1="ENABLED"}
    }

    @{
        Path   = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging"
        Name   = "LogLevel"
        Type   = "REG_DWORD"
        Value  = @{0="OFF";1="ERRORS";2="WARNINGS";3="INFO"}
    }

    # DHCP
    # DHCP Authorization
    # DHCP Authorization Cache
    # Configuring the PXE Server Not to Listen on UDP Port 67
    # Configuring the Server to Bind to UDP Port 67

    # DHCP Authorization
    # Specifies the amount of time (in seconds) that the PXE server will wait before rechecking its authorization. This time is only used when a successful authorization process has been performed, irrespective of whether the server was previously authorized.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE"
        Name  = "AuthRecheckTime"
        Type  = "REG_DWORD"
        Value = 3600 # Default / seconds
    }

    # Specifies the amount of time (in seconds) that the PXE server will wait if any step of authorization fails. So, if the PXE server is unable to query AD DS successfully, this value is used to determine the time before trying AD DS again.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE"
        Name  = "AuthFailureRetryTime"
        Type  = "REG_DWORD" 
        Value = 30 # Default / Seconds
    }

    # Rogue Detection
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE"
        Name  = "DisableRogueDetection"
        Type  = "REG_DWORD"
        Value = @{0="Enabled";1="Disabled"} # Default / 0
    }

    # DHCP Authorization Cache
    # Whenever the PXE server successfully queries AD DS, the results are cached under HKLM\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\AuthCache as follows:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\AuthCache"
        Name  = $Null #<domainname>
        Type  = "REG_DWORD"
        Value = @{0="Failed communication with ADDS, server not authorized";1="Successful communication with ADDS, server authorized"}
    }

    # The following table indicates that the last query to Localnetwork showed that the server was authorized, but Domain1 was denied.
    # Registry key name Type Value

    # Default
    # REG_SZ
    # Value not set

    # Localnetwork
    # REG_DWORD
    # 0x00000001 (1)

    # Domain1
    # REG_DWORD
    # 0x00000000 (0)

    # This cache is used whenever the PXE server receives an error while communicating with AD DS. 
    # The cached results are used to authorize or unauthorize DHCP, and then AuthFailureRetryTime is used 
    # to determine when to query AD DS again. 
    # Authorization of PXE servers occurs on the child objects of CN=NetServices, CN=Services, CN=Configuration, DC=Domain, and DC=com.

    # Configuring the PXE Server Not to Listen on UDP Port 67
    # Use this setting in configurations where the PXE server and DHCP are on different physical computers. 
    # This is the default value for the setting. 0 means that the PXE server will not listen on port 67. 
    # Use this setting in configurations where Windows Deployment Services and DHCP are located on the same physical computer.
    # You can configure this so that port 67 can be used by the DHCP server. 
    # The following registry value controls this behavior:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE"
        Name  = "UseDHCPPorts"
        Type  = "REG_DWORD"
        Value = @{0="PXE server will NOT listen on port 67";1="PXE server will listen on port 67"}
    }

    # Configuring the Server to Bind to UDP Port 67
    # There are some scenarios (particularly those that require running a DHCP server) that do not support adding custom 
    # DHCP option 60 on the same physical computer as the Windows Deployment Services server. 
    # In these circumstances, you can configure the server to bind to UDP Port 67 in nonexclusive mode by passing the 
    # SO_REUSEADDR option. For more information, see “Using SO_REUSEADDR and SO_EXCLUSIVEADDRUSE” 
    # (http://go.microsoft.com/fwlink/?LinkId=82387). The following is the registry key that contains the configuration required to have the server listen in nonexclusive mode by passing the SO_REUSEADDR flag:

    # Path: "HKLM:\System\CurrentControlSet\Services\WDSServer\Parameters"
    # Name: "SharedPorts"
    # Type: "REG_DWORD"

    # -----
    # PXE
    # Architecture Detection
    # Response Delay
    # Banned GUIDs
    # Order of PXE Providers
    # PXE Providers That Are Registered
    # Bind Policy for Network Interfaces
    # Location of TFTP Files

    # ----------------------
    # Architecture Detection
    # ----------------------
    # When you enable architecture detection, the following registry value is configured:
    @{
        Path  = "HKLM\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "DisableArchDisc"
        Type  = "REG_DWORD"
        Value = @{0="Architecture discovery is enabled";1="Architecture discovery is disabled"} # Default / Disabled
    }

    # ------------------
    # PXE Response Delay
    # ------------------
    # The following is the registry key that holds the PXE response delay:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "ResponseDelay"
        Type  = "REG_DWORD"
        Value = 0 # <delay time, in seconds>
    }

    # ------------
    # Banned GUIDs
    # ------------
    # The registry location of the banned GUIDs is as follows:
    # The correct format is as follows: {1acbf4473993e543a92afadb5140f1c8}, 
    # which should match what you see when you perform a PXE boot on a client (without dashes).
    @{
        Path  = "HKLM:\SYSTEM\CurrentControlSet\Services\WDSServer\Providers\WDSPXE"
        Name  = "BannedGuids"
        Type  = "REG_MULTI_SZ"
        Value = "{00000000000000000000000000000000}" # GUID strings minus hypens, one string per line.
    }

    # ----------------------
    # Order of PXE Providers
    # ----------------------
    # A registering provider can select its order in the existing provider list. The provider order is maintained in the registry at the following location:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE"
        Name  = "ProvidersOrder"
        Type  = "MULTI_SZ"
        Value = "WDSDCPXE" # Default / Ordered list of providers
    }
    
    # ---------------------------------
    # PXE Providers That Are Registered
    # ---------------------------------
    # PXE providers register with the server by doing the following:
    # Creating a valid key (to represent their provider) in the following folder: 
    # HKLM\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers

    # Creating a registry entry pointing to their .dll at the following location:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\<Custom Provider Name>"
        Name  = "ProviderDLL"
        Type  = "REG_SZ"
        Value = "%systemroot%\system32\wdspxe.dll" # Default / The full path and file name of the provider .dll
    }

    # Designating the provider as critical by adding the IsCritical registry setting (optional)
    # Specifying the entry point routine in the provider .dll

    # ----------------------------------
    # Bind Policy for Network Interfaces
    # ----------------------------------
    # There are various possible network adapter configurations that you can use, including the following:
    # One network adapter with a single IP address
    # One network adapter with multiple IP addresses bound to the single adapter
    # Two or more network adapters, each with one IP address
    # Two or more network adapters, with at least one having more than one IP address
    # The first option listed is considered the standard server configuration, 
    # and all of the other cases are more advanced networking scenarios. 
    # To satisfy all four configurations, WDSPXE has the ability to listen only on particular network interfaces. These interfaces may be specified either by IP address or by MAC address. During installation, the PXE server is automatically configured to listen on all active (that is, nondisabled) interfaces. After installation, you can adjust the default behavior by using the settings for the registry keys listed in the following table. These settings are stored in the following folder:

    # Entry Data type Description and values
    # Specifies the default binding behavior and determines whether the PXE server binds to all IP addresses 
    # or to none. This can be either of the following values:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE" 
        Name  = "BindPolicy"
        Type  = "REG_DWORD"
        Value = @{0="Defined bind interfaces excluded";1="Defined bind interfaces included"}
    }

    # --------------
    # BindInterfaces
    # --------------
    # Changes to BindPolicy are automatically picked up by the PXE server and do not require a service restart.
    # Lists all interfaces that the PXE server should listen on or exclude, based on the setting of BindPolicy:
    # If BindPolicy is set to 1 (include), set BindInterfaces to the IP addresses or MAC addresses for the interfaces that you want to exclude.
    # If BindPolicy is set to 0 (exclude), set BindInterfaces to the IP addresses or MAC addresses for the interfaces that you want to include. 
    # The default value is blank (no interfaces are excluded or included). You can specify MAC addresses as a sequence of hexadecimal characters, and you can format them with uppercase or lowercase hexadecimal characters, raw, or separated by colons or dashes. IP addresses must use dotted notation (for example, MAC:ABCDEFABCDEForIP:10.10.2.2.). To add a MAC address to the BindInterfaces list, you can use the WDSUTIL command-line tool. To add an IP address, you must edit the registry value manually.
    # Caution
    # Make sure that the IP or MAC addresses you enter are correct. Otherwise, the service will start, log an event, and then stop.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE"
        Name  = "BindInterfaces"
        Type  = "REG_MULTI_SZ"
        Value = @{$Null="";0="Exclude, set BindInterfaces to IP/MAC for interfaces you want to include";1="Include, set BindInterfaces to IP/MAC for interfaces you want to exclude"}
    }

    # Location of TFTP Files
    # The TFTP root is the parent folder that contains all files available for download by client computers. By default, the TFTP root is set to the RemoteInstall folder as specified in the following registry setting:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSTFTP"
        Name  = "RootFolder"
        Type  = "REG_SZ"
        Value = "C:\RemoteInstall" # Default / <full path and folder name of the TFTP root>
    }

    # Unattended Installation
    # Server Unattend Policy
    # Per Architecture Unattend Policy
    # Server Unattend Policy

    # This policy is defined in the Windows Deployment Services server registry at the following location:
    @{
        Path  = "HKLM\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\WdsImgSrv\Unattend"
        Name  = "Enabled"
        Type  = "REG_DWORD"
        Value = @{0="Disabled";1="Enabled"}
    }

    # Per-Architecture Unattend Policy
    # Unattend files are architecture specific, so you need a unique file for each architecture. These values are stored in the registry at the following location (where <arch> is either x86, x64, or ia64):
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\WdsImgSrv\Unattend\<arch>"
        Name  = "WDSUnattendFilePath"
        Type  = "REG_SZ"
        Value = $Null # The file path to the Windows Deployment Services client unattend file (for example, D:\RemoteInstall\WDSClientUnattend\WDSClientUnattend.xml).
    }

    # Network Boot Programs
    # Per-Client NBP
    # Unknown Clients Automatically PXE Boot
    # .n12 NBP
    # Resetting the NBP to the Default on the Next Boot
    # Per-Client NBP
    # There are two keys that define the NBP:
    # Configuring a network boot program (NBP) for each server is the default method. You can override this method on a per-client basis. The NBP is defined by the following registry settings (where <arch> is either x86, x64, or IA64): 
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\BootPrograms\<arch>"
        Name  = "Default"
        Type  = "REG_SZ"
        Value = $Null # The relative path to the default NBP that all booting clients of this architecture should receive (for example, boot\x86\pxeboot.com).
    }

    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\BootPrograms\<arch>"
        Name  = ".n12"
        Type  = "REG_SZ"
        Value = $Null # The relative path to the NBP that will be sent by using the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12). For more information, see Unknown Clients Automatically PXE Boot.
    }
    # Unknown Clients Automatically PXE Boot
    # In some cases, it may be useful to further segment the server NBP so that the following are true:
    # Known clients receive the per-server default (presumably a NBP that requires pressing the F12 key).
    # Unknown clients receive a NBP that will cause them to perform a PXE boot automatically.
    # This configuration is particularly useful in a lab environment where you want to immediately image new computers, but you want to ensure that existing computers are not sent through the imaging process by accidentally booting from the network. The policy setting for unknown clients to perform a PXE boot automatically is stored in the following registry key:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\"
        Name  = "AllowN12ForNewClients"
        Type  = REG_DWORD
        Value = @{0="Not Enabled";1="Unknown allowed"} # means that unknown clients are sent the .n12 NBP.
    }

    # .n12 NBP
    # Windows Deployment Services sends the defined .n12 NBP according to the following registry settings (where <arch> is either x86, x64, or IA64):
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\BootPrograms\<arch>"
        Name  = ".n12"
        Type  = "REG_SZ"
        Value = $Null # The relative path to the NBP that will be sent according to the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12).
    }

    # Note
    # Although the setting implies that new and unknown clients will receive the .n12 NBP, you can also configure the any other combination by specifying an NBP other than.n12.
    # Resetting the NBP to the Default on the Next Boot
    # When implementing a fully automated experience of booting from the network, it is often necessary to do the following:
    # Set the network as the first device in the client’s BIOS boot order.
    # Send a specific client an .n12 NBP.
    # If you combine these two configurations, the client will automatically boot from the network without requiring user intervention and the computer will end up in a circular loop (always booting from the network and never booting from the hard disk drive). The following registry key controls these settings:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "ResetBootProgram"
        Type  = "REG_DWORD"
        Value = @{0="No Action";1="Reset netbootMachineFilePath"} 
    }

    # or not set means no action.
    # 1 means that during the imaging process, the value stored in the netbootMachineFilePath attribute in AD DS for the prestaged device will be cleared. The value for the referral server is also stored in the netbootMachineFilePath attribute. Therefore, when you specify 1 and this value is cleared, any server in the domain can answer the client the next time it reboots.
    # Using this option ensures that on the next boot, the computer will receive the default server NBP (commonly the .com version). Therefore, the computer will try to boot from the network (because the network is listed first in the BIOS boot order), but the computer will be sent the .com NBP. After allowing sufficient time for the user to press the F12 key, this option will time out and the device will boot from the hard disk drive. The value is cleared after the image is applied, as one of the final actions performed by Windows Deployment Services.

    # Auto-Add Devices Database
    # If a computer requires approval before the installation will start, the computer will be in a pending state. One of the advantages of using the pending functionality is that at the time the device is approved, you can specify settings that control the client’s installation experience. These settings can be global, per architecture, or specified for each approved computer.
    # Auto-Add Policy
    # Message Displayed to a Pending User
    # Time-Out Value
    # Settings for Approved Client Computers
    # Auto-Add Policy
    # The following registry settings control the Auto-Add policy:
    # or not present means no Auto-Add policy (no action); 1 means pending.
    @{    
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove"
        Name  = "Policy"
        Type  = "REG_DWORD"
        Value = @{0="No action";1="Pending"}
    }

    # Message Displayed to a Pending User
    # The following registry key contains the text message that is displayed to the user by Wdsnbp.com 
    # when the device is in a pending state:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove"
        Name  = "PendingMessage"
        Type  = "REG_SZ"
        Value = $Null # Message shown to the user by Wdsnbp.com. The default setting is for this to be blank.
    }

    # Time-Out Value
    # The client state is not maintained on the server. Rather, the Wdsnbp.com program polls the server for the settings in the following keys after it has paused the client’s boot. The values for these settings are sent to the client by the server in the DHCP options field of the DHCP acknowledge control packet (ACK). The default setting for these values is to poll the server every 10 seconds for 2,160 tries, bringing the total default time-out to six hours.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove"
        Name  = "PollInterval"
        Type  = "REG_DWORD"
        Value = $Null # The amount of time (in seconds) between polls of the server
    }

    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove"
        Name  = "PollMaxRetry"
        Type  = "REG_DWORD"
        Value = 2160 # The number of times the server will be polled before a time-out occurs
    }

    # Settings for Approved Client Computers
    # The following registry settings control additional properties that you can set on an approved pending device (where <arch> is either x86, x64, or ia64). These settings are defined per architecture, and they apply to all approved devices unless they are manually overridden when the device is approved. They are located at the following location:

    # Configuration setting Registry value
    # The name of the Windows Deployment Services server that the client should download the NBP from.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "ReferralServer"
        Type  = "REG_SZ"
        Value = $Null # The name of the server to refer the client to. The default setting is for this value to be blank (no server name).
    }

    # The name of the NBP that the client should download.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "BootProgramPath"
        Type  = "REG_SZ"
        Value = $Null # The partial path and NBP that the client should receive. The default setting is for this value to be blank (no path).
    }

    # The name of the boot image, which the client should receive. Setting this value means that the client will not see a boot menu because the specified boot image will be processed automatically.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "BootImagePath"
        Type  = "REG_SZ"
        Value = $Null # The name of the boot image that the client should receive. The default setting is for this value to be blank (no boot image).
    }

    # The primary user associated with the generated computer account. This user will be granted JoinRights authorization, as defined later in this section.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "User"
        Type  = "REG_SZ"
        Value = "Domain Admins" # The owner of the computer account that was created. The default setting is the domain administrator.
    }

    # Specifies whether or not the device should be joined to the domain.
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "JoinDomain"
        Type  = "REG_DWORD"
        Value = @{0="Join the domain";1="Do not join the domain"} # 0 or not defined means that the computer should be joined to the domain / 1 means that the computer should not be joined to the domain.
    }

    # Specifies the type of rights to be assigned to the user.
    # JoinOnly requires the administrator to reset the computer account before the user can join the computer to the domain.
    # Full gives full permissions to the user (including the right to join the domain).
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC\AutoApprove\<arch>"
        Name  = "JoinRights"
        Type  = "REG_DWORD"
        Value = @{0="Join Only";1="Full"} # 0 or not defined means JoinOnly / 1 means Full.
    }

    # Domain Controllers and the Global Catalog
    # Static Configuration
    # Search Order
    # Static Configuration
    # In some circumstances, you may want to statically configure the domain controller and the global catalog that Windows Deployment Services will use. The settings for these options are as follows:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "DefaultServer"
        Type  = "REG_SZ"
        Value =  $Env:ComputerName # The name of domain controller that Windows Deployment Services should use. This can be either the NETBIOS name or the fully qualified domain name (FQDN). Note that you cannot use read-only domain controllers with Windows Deployment Services, so this value must be a writable domain controller.
    }

    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "DefaultGCServer"
        Type  = "REG_SZ"
        Value = $Env:ComputerName # The name of the global catalog that Windows Deployment Services should use. This can be either the NETBIOS name or the FQDN.
    }
    # Search Order
    # 1 or not set means that the global catalog will be searched first, and then the domain controller; 
    # 1 means that the domain controller will be searched first, and then the global catalog. 
    # Setting this value to 1 may lead to less efficient use of AD DS in a multidomain environment. 
    # If a prestaged device is not found in the local domain controller, Windows Deployment Services must 
    # perform an additional query against a global catalog because the domain controller is not guaranteed 
    # to have knowledge of all objects. 
    # Therefore, if this value is set to 1, Windows Deployment Services may have to perform two searches to 
    # find the prestaged computer object when it otherwise would have needed to do only one search.
    # The following registry key controls the preferred search order:
    @{
        Path  = "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WDSPXE\Providers\BINLSVC"
        Name  = "ADSearchOrder"
        Type  = "REG_SZ"
        Value = @{0="Search global catalog First";1="Search domain controller first"}
    }
}
