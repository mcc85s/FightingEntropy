using System;
using System.Text;
using System.Runtime.InteropServices;

namespace Wifi
{
    public class ProfileManagement
    {
        [DllImport("wlanapi.dll", EntryPoint = "WlanOpenHandle")]
        public static extern uint WlanOpenHandle(
        [In] UInt32 clientVersion,
        [In, Out] IntPtr pReserved,
        [Out] out UInt32 negotiatedVersion,
        [Out] out IntPtr clientHandle);

        [DllImport("wlanapi.dll", EntryPoint = "WlanCloseHandle")]
        public static extern uint WlanCloseHandle(
        [In] IntPtr ClientHandle,
        IntPtr pReserved);

        [DllImport("wlanapi.dll", EntryPoint = "WlanFreeMemory")]
        public static extern void WlanFreeMemory(
        [In] IntPtr pMemory);

        [DllImport("wlanapi.dll", EntryPoint = "WlanEnumInterfaces", SetLastError = true)]
        public static extern uint WlanEnumInterfaces(
        [In] IntPtr hClientHandle,
        [In] IntPtr pReserved,
        [Out] out IntPtr ppInterfaceList);

        [DllImport("wlanapi.dll", EntryPoint = "WlanGetProfileList", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        public static extern uint WlanGetProfileList(
        [In] IntPtr clientHandle,
        [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid,
        [In] IntPtr pReserved,
        [Out] out IntPtr profileList);

        [DllImport("wlanapi.dll", EntryPoint = "WlanGetProfile")]
        public static extern uint WlanGetProfile(
        [In] IntPtr clientHandle,
        [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid,
        [In, MarshalAs(UnmanagedType.LPWStr)] string profileName,
        [In, Out] IntPtr pReserved,
        [Out, MarshalAs(UnmanagedType.LPWStr)] out string pstrProfileXml,
        [In, Out, Optional] ref uint flags,
        [Out, Optional] out uint grantedAccess);

        [DllImport("wlanapi.dll", EntryPoint = "WlanDeleteProfile")]
        public static extern uint WlanDeleteProfile(
        [In] IntPtr clientHandle,
        [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid,
        [In, MarshalAs(UnmanagedType.LPWStr)] string profileName,
        [In, Out] IntPtr pReserved);

        [DllImport("wlanapi.dll", EntryPoint = "WlanSetProfile", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern uint WlanSetProfile(
        [In] IntPtr clientHandle,
        [In] ref Guid interfaceGuid,
        [In] uint flags,
        [In] IntPtr ProfileXml,
        [In, Optional] IntPtr AllUserProfileSecurity,
        [In] bool Overwrite,
        [In, Out] IntPtr pReserved,
        [In, Out] ref IntPtr pdwReasonCode);

        [DllImport("wlanapi.dll", EntryPoint = "WlanReasonCodeToString", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern uint WlanReasonCodeToString(
        [In] uint reasonCode,
        [In] uint bufferSize,
        [In, Out] StringBuilder builder,
        [In, Out] IntPtr Reserved);

        [DllImport("wlanapi.dll", EntryPoint = "WlanGetAvailableNetworkList", SetLastError = true)]
        public static extern uint WlanGetAvailableNetworkList(
        [In] IntPtr hClientHandle,
        [In, MarshalAs(UnmanagedType.LPStruct)] Guid interfaceGuid,
        [In] uint dwFlags,
        [In] IntPtr pReserved,
        [Out] out IntPtr ppAvailableNetworkList);

        [DllImport("wlanapi.dll", EntryPoint = "WlanConnect", SetLastError = true)]
        public static extern uint WlanConnect(
        [In] IntPtr hClientHandle,
        [In] ref Guid interfaceGuid,
        [In] ref WLAN_CONNECTION_PARAMETERS pConnectionParameters,
        [In, Out] IntPtr pReserved);

        [DllImport("wlanapi.dll", EntryPoint = "WlanDisconnect", SetLastError = true)]
        public static extern uint WlanDisconnect(
        [In] IntPtr hClientHandle,
        [In] ref Guid interfaceGuid,
        [In, Out] IntPtr pReserved);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WLAN_CONNECTION_PARAMETERS
        {
            public WLAN_CONNECTION_MODE wlanConnectionMode;
            public string strProfile;
            public DOT11_SSID[] pDot11Ssid;
            public DOT11_BSSID_LIST[] pDesiredBssidList;
            public DOT11_BSS_TYPE dot11BssType;
            public uint dwFlags;
        }

        public struct DOT11_BSSID_LIST
        {
            public NDIS_OBJECT_HEADER Header;
            public ulong uNumOfEntries;
            public ulong uTotalNumOfEntries;
            public IntPtr BSSIDs;
        }

        public struct NDIS_OBJECT_HEADER
        {
            public byte Type;
            public byte Revision;
            public ushort Size;
        }

        public struct WLAN_PROFILE_INFO_LIST
        {
            public uint dwNumberOfItems;
            public uint dwIndex;
            public WLAN_PROFILE_INFO[] ProfileInfo;

            public WLAN_PROFILE_INFO_LIST(IntPtr ppProfileList)
            {
                dwNumberOfItems = (uint)Marshal.ReadInt32(ppProfileList);
                dwIndex = (uint)Marshal.ReadInt32(ppProfileList, 4);
                ProfileInfo = new WLAN_PROFILE_INFO[dwNumberOfItems];
                IntPtr ppProfileListTemp = new IntPtr(ppProfileList.ToInt64() + 8);

                for (int i = 0; i < dwNumberOfItems; i++)
                {
                    ppProfileList = new IntPtr(ppProfileListTemp.ToInt64() + i * Marshal.SizeOf(typeof(WLAN_PROFILE_INFO)));
                    ProfileInfo[i] = (WLAN_PROFILE_INFO)Marshal.PtrToStructure(ppProfileList, typeof(WLAN_PROFILE_INFO));
                }
            }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WLAN_PROFILE_INFO
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string strProfileName;
            public WlanProfileFlags ProfileFlags;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WLAN_AVAILABLE_NETWORK_LIST
        {
            public uint dwNumberOfItems;
            public uint dwIndex;
            public WLAN_AVAILABLE_NETWORK[] wlanAvailableNetwork;
            public WLAN_AVAILABLE_NETWORK_LIST(IntPtr ppAvailableNetworkList)
            {
                dwNumberOfItems = (uint)Marshal.ReadInt64(ppAvailableNetworkList);
                dwIndex = (uint)Marshal.ReadInt64(ppAvailableNetworkList, 4);
                wlanAvailableNetwork = new WLAN_AVAILABLE_NETWORK[dwNumberOfItems];
                for (int i = 0; i < dwNumberOfItems; i++)
                {
                    IntPtr pWlanAvailableNetwork = new IntPtr(ppAvailableNetworkList.ToInt64() + i * Marshal.SizeOf(typeof(WLAN_AVAILABLE_NETWORK)) + 8);
                    wlanAvailableNetwork[i] = (WLAN_AVAILABLE_NETWORK)Marshal.PtrToStructure(pWlanAvailableNetwork, typeof(WLAN_AVAILABLE_NETWORK));
                }
            }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WLAN_AVAILABLE_NETWORK
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string ProfileName;
            public DOT11_SSID Dot11Ssid;
            public DOT11_BSS_TYPE dot11BssType;
            public uint uNumberOfBssids;
            public bool bNetworkConnectable;
            public uint wlanNotConnectableReason;
            public uint uNumberOfPhyTypes;

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
            public DOT11_PHY_TYPE[] dot11PhyTypes;
            public bool bMorePhyTypes;
            public uint SignalQuality;
            public bool SecurityEnabled;
            public DOT11_AUTH_ALGORITHM dot11DefaultAuthAlgorithm;
            public DOT11_CIPHER_ALGORITHM dot11DefaultCipherAlgorithm;
            public uint dwFlags;
            public uint dwReserved;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public struct DOT11_SSID
        {
            public uint uSSIDLength;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
            public string ucSSID;
        }

        public enum DOT11_BSS_TYPE
        {
            Infrastructure = 1,
            Independent = 2,
            Any = 3,
        }

        public enum DOT11_PHY_TYPE
        {
            DOT11_PHY_TYPE_UNKNOWN = 0,
            DOT11_PHY_TYPE_ANY = 0,
            DOT11_PHY_TYPE_FHSS = 1,
            DOT11_PHY_TYPE_DSSS = 2,
            DOT11_PHY_TYPE_IRBASEBAND = 3,
            DOT11_PHY_TYPE_OFDM = 4,
            DOT11_PHY_TYPE_HRDSSS = 5,
            DOT11_PHY_TYPE_ERP = 6,
            DOT11_PHY_TYPE_HT = 7,
            DOT11_PHY_TYPE_VHT = 8,
            DOT11_PHY_TYPE_IHV_START = -2147483648,
            DOT11_PHY_TYPE_IHV_END = -1,
        }

        public enum DOT11_AUTH_ALGORITHM
        {
            DOT11_AUTH_ALGO_80211_OPEN = 1,
            DOT11_AUTH_ALGO_80211_SHARED_KEY = 2,
            DOT11_AUTH_ALGO_WPA = 3,
            DOT11_AUTH_ALGO_WPA_PSK = 4,
            DOT11_AUTH_ALGO_WPA_NONE = 5,
            DOT11_AUTH_ALGO_RSNA = 6,
            DOT11_AUTH_ALGO_RSNA_PSK = 7,
            DOT11_AUTH_ALGO_WPA3 = 8,
            DOT11_AUTH_ALGO_WPA3_SAE = 9,
            DOT11_AUTH_ALGO_OWE = 10,
            DOT11_AUTH_ALGO_WPA3_ENT = 11,
            DOT11_AUTH_ALGO_IHV_START = -2147483648,
            DOT11_AUTH_ALGO_IHV_END = -1,
        }

        public enum DOT11_CIPHER_ALGORITHM
        {
            DOT11_CIPHER_ALGO_NONE = 0,
            DOT11_CIPHER_ALGO_WEP40 = 1,
            DOT11_CIPHER_ALGO_TKIP = 2,
            DOT11_CIPHER_ALGO_CCMP = 4,
            DOT11_CIPHER_ALGO_WEP104 = 5,
            DOT11_CIPHER_ALGO_BIP = 6,
            DOT11_CIPHER_ALGO_GCMP = 8,
            DOT11_CIPHER_ALGO_GCMP_256 = 9,
            DOT11_CIPHER_ALGO_CCMP_256 = 10,
            DOT11_CIPHER_ALGO_BIP_GMAC_128 = 11,
            DOT11_CIPHER_ALGO_BIP_GMAC_256 = 12,
            DOT11_CIPHER_ALGO_BIP_CMAC_256 = 13,
            DOT11_CIPHER_ALGO_WPA_USE_GROUP = 256,
            DOT11_CIPHER_ALGO_RSN_USE_GROUP = 256,
            DOT11_CIPHER_ALGO_WEP = 257,
            DOT11_CIPHER_ALGO_IHV_START = -2147483648,
            DOT11_CIPHER_ALGO_IHV_END = -1,
        }

        public enum WLAN_CONNECTION_MODE
        {
            WLAN_CONNECTION_MODE_PROFILE,
            WLAN_CONNECTION_MODE_TEMPORARY_PROFILE,
            WLAN_CONNECTION_MODE_DISCOVERY_SECURE,
            WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE,
            WLAN_CONNECTION_MODE_AUTO,
            WLAN_CONNECTION_MODE_INVALID,
        }

        [Flags]
        public enum WlanConnectionFlag
        {
            Default = 0,
            HiddenNetwork = 1,
            AdhocJoinOnly = 2,
            IgnorePrivacyBit = 4,
            EapolPassThrough = 8,
            PersistDiscoveryProfile = 10,
            PersistDiscoveryProfileConnectionModeAuto = 20,
            PersistDiscoveryProfileOverwriteExisting = 40
        }

        [Flags]
        public enum WlanProfileFlags
        {
            AllUser = 0,
            GroupPolicy = 1,
            User = 2
        }

        public class ProfileInfo
        {
            public string ProfileName;
            public string ConnectionMode;
            public string Authentication;
            public string Encryption;
            public string Password;
            public bool ConnectHiddenSSID;
            public string EAPType;
            public string ServerNames;
            public string TrustedRootCA;
            public string Xml;
        }

        public struct WLAN_INTERFACE_INFO_LIST
        {
            public uint dwNumberOfItems;
            public uint dwIndex;
            public WLAN_INTERFACE_INFO[] wlanInterfaceInfo;
            public WLAN_INTERFACE_INFO_LIST(IntPtr ppInterfaceInfoList)
            {
                dwNumberOfItems = (uint)Marshal.ReadInt32(ppInterfaceInfoList);
                dwIndex = (uint)Marshal.ReadInt32(ppInterfaceInfoList, 4);
                wlanInterfaceInfo = new WLAN_INTERFACE_INFO[dwNumberOfItems];
                IntPtr ppInterfaceInfoListTemp = new IntPtr(ppInterfaceInfoList.ToInt64() + 8);
                for (int i = 0; i < dwNumberOfItems; i++)
                {
                    ppInterfaceInfoList = new IntPtr(ppInterfaceInfoListTemp.ToInt64() + i * Marshal.SizeOf(typeof(WLAN_INTERFACE_INFO)));
                    wlanInterfaceInfo[i] = (WLAN_INTERFACE_INFO)Marshal.PtrToStructure(ppInterfaceInfoList, typeof(WLAN_INTERFACE_INFO));
                }
            }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct WLAN_INTERFACE_INFO
        {
            public Guid Guid;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
            public string Description;
            public WLAN_INTERFACE_STATE State;
        }

        public enum WLAN_INTERFACE_STATE
        {
            NOT_READY = 0,
            CONNECTED = 1,
            AD_HOC_NETWORK_FORMED = 2,
            DISCONNECTING = 3,
            DISCONNECTED = 4,
            ASSOCIATING = 5,
            DISCOVERING = 6,
            AUTHENTICATING = 7
        }

        [DllImport("wlanapi.dll", EntryPoint = "WlanScan", SetLastError = true)]
        public static extern uint WlanScan(
        IntPtr hClientHandle,
        ref Guid pInterfaceGuid,
        IntPtr pDot11Ssid,
        IntPtr pIeData,
        IntPtr pReserved);
    }
}
