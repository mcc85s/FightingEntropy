using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Management;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Net;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;

namespace FightingEntropy
{
    // Format classes deal with DateTime and Size objects
    namespace Format
    {
        [Serializable]
        public struct ModDateTime
        {
            public DateTime Value;
            public ModDateTime(DateTime dt)
            {
                Value = dt;
            }
            public ModDateTime(string date)
            {
                if (!Regex.IsMatch(date,"\\d{2}\\/\\d{2}\\/\\d{4} \\d{2}:\\d{2}:\\d{2}"))
                    throw new Exception("Exception [!] Invalid date string");

                Value = DateTime.Parse(date);
            }
            public static implicit operator DateTime(ModDateTime fdt)
            {
                return fdt.Value;
            }
            public static implicit operator ModDateTime(DateTime dt)
            {
                return new ModDateTime(dt);
            }
            public static ModDateTime Now()
            {
                return new ModDateTime(DateTime.Now);
            }
            public string DateString()
            {
                return Value.ToString("MM/dd/yyyy HH:mm:ss");
            }
            public string DayString()
            {
                return Value.ToString("MM/dd/yyyy");
            }
            public string TimeString()
            {
                return Value.ToString("HH:mm:ss");
            }
            public string FileString()
            {
                return Value.ToString("yyyy_MM_dd-HH_mm_ss");
            }
            public string ArchiveString()
            {
                return Value.ToString("yyyy_MMdd-HHmmss");
            }
            public override string ToString()
            {
                return DateString();
            }
        }

        [Serializable]
        public struct ByteSize
        {
            public readonly string Name;
            public readonly long  Bytes;
            public readonly string Unit;
            public readonly string Size;
            public ByteSize(string name, long bytes)
            {
                Name  = name;
                Bytes = bytes;

                // Assign Unit
                if (bytes < 870)
                    Unit = "Byte";
                else if (bytes < 891289)
                    Unit = "Kilobyte";
                else if (bytes < 912680550)
                    Unit = "Megabyte";
                else if (bytes < 934584883609)
                    Unit = "Gigabyte";
                else
                    Unit = "Terabyte";

                // Assign Size
                if (Unit == "Byte")
                    Size = bytes.ToString() + " B";
                else if (Unit == "Kilobyte")
                    Size = (bytes / 1024.0).ToString("N2") + " KB";
                else if (Unit == "Megabyte")
                    Size = (bytes / 1048576.0).ToString("N2") + " MB";
                else if (Unit == "Gigabyte")
                    Size = (bytes / 1073741824.0).ToString("N2") + " GB";
                else
                    Size = (bytes / 1099511627776.0).ToString("N2") + " TB";
            }
            public override string ToString()
            {
                return Size;
            }
            public static ByteSize New(string name, long bytes)
            {
                return new ByteSize(name, bytes);
            }
        }

        [Serializable]
        public struct Version
        {
            public int    Major;
            public int    Minor;
            public int    Build;
            public int Revision;
            public Version(int major, int minor, int build)
            {
                Major    = major;
                Minor    = minor;
                Build    = build;
                Revision = -1;
            }
            public Version(int major, int minor, int build, int revision) : this(major, minor, build)
            {
                Revision = revision;
            }
            public override string ToString()
            {
                if (Revision < 0)
                    return Major + "." + Minor + "." + Build;

                return Major + "." + Minor + "." + Build + "." + Revision;
            }
        }

        public sealed class PercentIndex
        {
            public uint     Index { get; private set; }
            public uint   Current { get; private set; }
            public uint     Total { get; private set; }
            public string Percent { get; private set; }
            public PercentIndex(uint index, uint current, uint total)
            {
                Index   = index;
                Current = current;
                Total   = total;

                if (total == 0)
                {
                    Percent = "100%";
                }
                else
                {
                    double pct = (double)current / (double)total;
                    Percent    = pct.ToString("P2");
                }
            }
            public override string ToString()
            {
                if (Total == 0)
                {
                    return "100% (0/0)";
                }

                return string.Format("{0} ({1}/{2})", Percent, Current, Total);
            }
        }

        public sealed class PercentTracker
        {
            public uint            Total { get; private set; }
            public uint             Mode { get; private set; }
            public PercentIndex[] Output { get; private set; }
            public PercentTracker(uint count, string type)
            {
                Total = count;
                Initialize(type);
            }
            public PercentTracker(string type)
            {
                Total = GetRandom();
                Initialize(type);
            }
            private void Initialize(string type)
            {
                if (type == "EventLog")
                {
                    uint mode = 0;
                    uint[] range = null;

                    if (Total > 0 && Total <= 1000)
                    {
                        mode = 1;
                        range = new uint[] { 1 };
                    }
                    else if (Total > 1000 && Total <= 2000)
                    {
                        mode = 2;
                        range = new uint[] { 1, 2 };
                    }
                    else if (Total > 2000 && Total < 10000)
                    {
                        mode = 5;
                        range = new uint[] { 1, 2, 3, 4, 5 };
                    }
                    else if (Total >= 10000)
                    {
                        mode = 10;
                        range = new uint[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
                    }

                    Mode = mode;

                    if (range == null)
                    {
                        Output = new PercentIndex[0];
                        return;
                    }

                    double step = (double)Total / (double)mode;
                    Output = new PercentIndex[range.Length];

                    for (int i = 0; i < range.Length; i++)
                    {
                        double raw = step * (double)range[i];
                        uint current = (uint)System.Math.Round(raw);

                        if (current > Total)
                        {
                            current = Total;
                        }

                        Output[i] = new PercentIndex((uint)i, current, Total);
                    }
                }
                else
                {
                    // provide additional logic for other types later
                }
            }
            private uint GetRandom()
            {
                System.Random r = new System.Random();
                return (uint)r.Next(0, 500000);
            }
            public void Add(uint current)
            {
                int len = Output.Length;
                PercentIndex[] newArr = new PercentIndex[len + 1];

                for (int i = 0; i < len; i++)
                {
                    newArr[i] = Output[i];
                }

                newArr[len] = new PercentIndex((uint)len, current, Total);
                Output = newArr;
            }
        }

    }

    // Platform classes deal with CIM instances
    namespace Platform
    {
        public enum Affiliation
        {
            Workgroup = 0,
            Domain    = 1
        }

        [Serializable]
        public class Computer
        {
            public string             Name;
            public string      DisplayName;
            public Affiliation Affiliation;
            public string           Domain;
            public string        Workgroup;
            public string    UserDnsDomain;
            public Computer()
            {
                // Empty for serialization and Add-Type
            }
            public Computer(bool populate)
            {
                if (populate)
                {
                    PopulateFromSystem();
                    ComputeIdentity();
                }
            }
            public Computer(string name,
                            string displayName,
                            Affiliation affiliation,
                            string domain,
                            string workgroup,
                            string userDnsDomain)
            {
                Name          = name;
                DisplayName   = displayName;
                Affiliation   = affiliation;
                Domain        = domain;
                Workgroup     = workgroup;
                UserDnsDomain = userDnsDomain;
            }
            private void PopulateFromSystem()
            {
                Name = Environment.MachineName;

                string domain = Environment.GetEnvironmentVariable("USERDOMAIN");
                string machine = Environment.MachineName;

                if (domain != null && domain.ToUpper() != machine.ToUpper())
                {
                    Affiliation = Affiliation.Domain;
                    Domain      = domain;
                    Workgroup   = null;
                }
                else
                {
                    Affiliation = Affiliation.Workgroup;

                    try
                    {
                        var searcher = new ManagementObjectSearcher("SELECT Workgroup FROM Win32_ComputerSystem");
                        foreach (ManagementObject cs in searcher.Get())
                        {
                            Workgroup = Convert.ToString(cs["Workgroup"]);
                            break;
                        }
                    }
                    catch
                    {
                        Workgroup = null;
                    }

                    Domain = null;
                }

                UserDnsDomain = Environment.GetEnvironmentVariable("USERDNSDOMAIN");
            }
            public void ComputeIdentity()
            {
                if (Affiliation == Affiliation.Domain)
                {
                    if (!string.IsNullOrEmpty(Name) &&!string.IsNullOrEmpty(Domain))
                    {
                        DisplayName = Name.ToLower() + "." + Domain.ToLower();
                        return;
                    }

                    DisplayName = Name;
                    return;
                }

                if (Affiliation == Affiliation.Workgroup)
                {
                    if (!string.IsNullOrEmpty(Workgroup) && !string.IsNullOrEmpty(Name))
                    {
                        DisplayName = Workgroup.ToLower() + "\\" + Name.ToLower();
                        return;
                    }

                    DisplayName = Name;
                    return;
                }

                DisplayName = Name;
            }
            public string GetSafeDisplayName()
            {
                if (string.IsNullOrEmpty(DisplayName))
                    return DisplayName;

                // Replace invalid filename characters with '_'
                char[] invalid = System.IO.Path.GetInvalidFileNameChars();
                string safe = DisplayName;

                foreach (char c in invalid)
                    safe = safe.Replace(c, '_');

                return safe;
            }
            public override string ToString()
            {
                return DisplayName;
            }
        }

        [Serializable]
        public class Bios
        {
            public string            Name;
            public string    Manufacturer;
            public string    SerialNumber;
            public string         Version;
            public string     ReleaseDate;
            public bool     SmBiosPresent;
            public string   SmBiosVersion;
            public string     SmBiosMajor;
            public string     SmBiosMinor;
            public string SystemBiosMajor;
            public string SystemBiosMinor;
            public Bios()
            {
                try
                {
                    ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_BIOS");

                    foreach (ManagementObject bios in searcher.Get())
                    {
                        Name            = Convert.ToString(bios["Name"]);
                        Manufacturer    = Convert.ToString(bios["Manufacturer"]);
                        SerialNumber    = Convert.ToString(bios["SerialNumber"]);
                        Version         = Convert.ToString(bios["Version"]);
                        ReleaseDate     = Convert.ToString(bios["ReleaseDate"]);
                        SmBiosPresent   = bios["SmBiosPresent"] != null && (bool)bios["SmBiosPresent"];
                        SmBiosVersion   = Convert.ToString(bios["SMBIOSBIOSVersion"]);
                        SmBiosMajor     = Convert.ToString(bios["SMBIOSMajorVersion"]);
                        SmBiosMinor     = Convert.ToString(bios["SMBIOSMinorVersion"]);
                        SystemBiosMajor = Convert.ToString(bios["SystemBiosMajorVersion"]);
                        SystemBiosMinor = Convert.ToString(bios["SystemBiosMinorVersion"]);
                        break;
                    }
                }
                catch
                {
                    // If WMI fails, fields remain null/default.
                }
            }
            public override string ToString()
            {
                return Manufacturer + " | " + Name;
            }
        }

        [Serializable]
        public class OperatingSystem
        {
            public string Caption;
            public string Version;
            public string   Build;
            public string  Serial;
            public uint  Language;
            public uint   Product;
            public uint      Type;
            public OperatingSystem()
            {
                try
                {
                    ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_OperatingSystem");

                    foreach (ManagementObject os in searcher.Get())
                    {
                        Caption  = Convert.ToString(os["Caption"]);
                        Version  = Convert.ToString(os["Version"]);
                        Build    = Convert.ToString(os["BuildNumber"]);
                        Serial   = Convert.ToString(os["SerialNumber"]);
                        Language = os["OSLanguage"]     != null ? Convert.ToUInt32(os["OSLanguage"]) : 0;
                        Product  = os["OSProductSuite"] != null ? Convert.ToUInt32(os["OSProductSuite"]) : 0;
                        Type     = os["OSType"]         != null ? Convert.ToUInt32(os["OSType"]) : 0;
                        break;
                    }
                }
                catch
                {
                    // If WMI fails, fields remain default/null.
                }
            }
            public override string ToString()
            {
                return Caption + " " + Version + "-" + Build;
            }
        }

        [Serializable]
        public class ComputerSystem
        {
            public string Manufacturer;
            public string        Model;
            public string      Product;
            public string       Serial;
            public string       Memory;
            public string Architecture;
            public string         UUID;
            public string      Chassis;
            public string     BiosUefi;
            public string     AssetTag;
            public ComputerSystem()
            {
                try
                {
                    // Win32_ComputerSystem
                    ManagementObjectSearcher csSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystem");

                    foreach (ManagementObject cs in csSearcher.Get())
                    {
                        Manufacturer = Convert.ToString(cs["Manufacturer"]);
                        Model        = Convert.ToString(cs["Model"]);

                        try
                        {
                            ulong mem = cs["TotalPhysicalMemory"] != null ? (ulong)cs["TotalPhysicalMemory"] : 0;

                            Memory = (mem / (1024UL * 1024UL * 1024UL)).ToString() + " GB";
                        }
                        catch
                        {
                            Memory = null;
                        }

                        break;
                    }

                    // Win32_ComputerSystemProduct (UUID)
                    ManagementObjectSearcher uuidSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystemProduct");

                    foreach (ManagementObject prod in uuidSearcher.Get())
                    {
                        UUID = Convert.ToString(prod["UUID"]);
                        break;
                    }

                    // Win32_BaseBoard (Product + Serial)
                    ManagementObjectSearcher bbSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_BaseBoard");

                    foreach (ManagementObject bb in bbSearcher.Get())
                    {
                        Product = Convert.ToString(bb["Product"]);
                        Serial  = Convert.ToString(bb["SerialNumber"]);

                        if (Serial != null)
                        {
                            Serial = Serial.Replace(".", "");
                        }

                        break;
                    }

                    // BIOS vs UEFI detection
                    try
                    {
                        // If this WMI query succeeds, system is UEFI
                        ManagementObjectSearcher uefi = new ManagementObjectSearcher("SELECT * FROM Win32_ComputerSystem WHERE PCSystemTypeEx IS NOT NULL");

                        foreach (ManagementObject _ in uefi.Get())
                        {
                            BiosUefi = "UEFI";
                            break;
                        }
                    }
                    catch
                    {
                        BiosUefi = "BIOS";
                    }

                    // Win32_SystemEnclosure (Chassis + AssetTag)
                    ManagementObjectSearcher encSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_SystemEnclosure");

                    foreach (ManagementObject enc in encSearcher.Get())
                    {
                        AssetTag = Convert.ToString(enc["SMBIOSAssetTag"]);

                        try
                        {
                            ushort[] types = (ushort[])enc["ChassisTypes"];
                            if (types != null && types.Length > 0)
                            {
                                ushort t = types[0];

                                if ((t >= 8 && t <= 12) || t == 14 || t == 18 || t == 21)
                                    Chassis = "Laptop";
                                else if ((t >= 3 && t <= 7) || t == 15 || t == 16)
                                    Chassis = "Desktop";
                                else if (t == 23)
                                    Chassis = "Server";
                                else if (t >= 34 && t <= 36)
                                    Chassis = "Small Form Factor";
                                else if ((t >= 30 && t <= 32) || t == 13)
                                    Chassis = "Tablet";
                                else
                                    Chassis = null;
                            }
                        }
                        catch
                        {
                            Chassis = null;
                        }

                        break;
                    }

                    // Architecture
                    string arch = Environment.GetEnvironmentVariable("Processor_Architecture");
                    if (arch == "AMD64")
                        Architecture = "x64";
                    else if (arch == "x86")
                        Architecture = "x86";
                    else
                        Architecture = arch;
                }
                catch
                {
                    // If any WMI fails, fields remain default/null.
                }
            }
            public override string ToString()
            {
                return Manufacturer + " | " + Model;
            }
        }

        [Serializable]
        public class Partition
        {
            public string   Type;
            public string   Name;
            public Format.ByteSize Size;
            public uint     Boot;
            public uint  Primary;
            public uint     Disk;
            public uint    Index;
            public Partition(ManagementObject p)
            {
                Type      = Convert.ToString(p["Type"]);
                Name      = Convert.ToString(p["Name"]);

                Boot      = p[   "BootPartition"] != null ? (uint)p[   "BootPartition"] : 0;
                Primary   = p["PrimaryPartition"] != null ? (uint)p["PrimaryPartition"] : 0;
                Disk      = p[       "DiskIndex"] != null ? (uint)p[       "DiskIndex"] : 0;
                Index     = p[           "Index"] != null ? (uint)p[           "Index"] : 0;
                ulong raw = p[            "Size"] != null ? (ulong)p[           "Size"] : 0;
                Size      = new Format.ByteSize("Size", (long)raw);
            }
            public override string ToString()
            {
                return "[" + Name + "/" + Size.ToString() + "]";
            }
        }

        [Serializable]
        public class Partitions
        {
            public uint         Count;
            public Partition[] Output;
            public Partitions()
            {
                Output = new Partition[0];
                Count  = 0;
            }
            public void Add(Partition p)
            {
                Partition[] temp = new Partition[Count + 1];
                for (int i = 0; i < Count; i++)
                    temp[i] = Output[i];

                temp[Count] = p;
                Output      = temp;
                Count++;
            }
            public override string ToString()
            {
                string s = "";
                for (int i = 0; i < Count; i++)
                {
                    if (i > 0) s += ", ";
                    s += Output[i].ToString();
                }

                return "(" + Count.ToString() + ") " + s;
            }
        }

        [Serializable]
        public class Volume
        {
            public string       DriveID;
            public string   Description;
            public string    Filesystem;
            public Partition  Partition;
            public string    VolumeName;
            public string  VolumeSerial;
            public Format.ByteSize Free;
            public Format.ByteSize Used;
            public Format.ByteSize Size;
            public Volume(ManagementObject drive)
            {
                DriveID      = Convert.ToString(drive["Name"]);
                Description  = Convert.ToString(drive["Description"]);
                Filesystem   = Convert.ToString(drive["FileSystem"]);
                VolumeName   = Convert.ToString(drive["VolumeName"]);
                VolumeSerial = Convert.ToString(drive["VolumeSerialNumber"]);

                ulong free   = drive["FreeSpace"] != null ? (ulong)drive["FreeSpace"] : 0;
                ulong size   = drive[     "Size"] != null ? (ulong)drive[     "Size"] : 0;
                ulong used   = size > free ? size - free : 0;

                Free         = new Format.ByteSize("Free", (long)free);
                Used         = new Format.ByteSize("Used", (long)used);
                Size         = new Format.ByteSize("Size", (long)size);
            }
            public override string ToString()
            {
                // Example: "[C:\100 GB]"
                string partSize = Partition != null ? Partition.Size.ToString() : "";
                return DriveID + ":\\ (" + partSize + ")";
            }
        }

        [Serializable]
        public class Volumes
        {
            public uint      Count;
            public Volume[] Output;
            public Volumes()
            {
                Output = new Volume[0];
                Count  = 0;
            }
            public void Add(Volume v)
            {
                Volume[] temp = new Volume[Count + 1];

                for (int i = 0; i < Count; i++)
                {
                    temp[i] = Output[i];
                }

                temp[Count] = v;

                Output = temp;
                Count ++;
            }
            public override string ToString()
            {
                string s = "";

                for (int i = 0; i < Count; i ++)
                {
                    if (i > 0) s += ", ";
                    s += Output[i].ToString();
                }

                return "(" + Count.ToString() + ") " + s;
            }
        }
    }

    // Hardware classes deal with hardware-based CIM instances
    namespace Hardware
    {
        [Serializable]
        public class Processor
        {
            public uint           Rank;
            public string Manufacturer;
            public string         Name;
            public string      Caption;
            public uint          Cores;
            public uint           Used;
            public uint        Logical;
            public uint        Threads;
            public string  ProcessorId;
            public string     DeviceId;
            public uint          Speed;
            public Processor(uint rank, ManagementObject cpu)
            {
                Rank = rank;

                string m = Convert.ToString(cpu["Manufacturer"]);
                if (m != null)
                {
                    if (m.ToLower().Contains("intel"))
                        Manufacturer = "Intel";
                    else if (m.ToLower().Contains("amd"))
                        Manufacturer = "AMD";
                    else
                        Manufacturer = m;
                }

                Name        = CleanName(Convert.ToString(cpu["Name"]));
                Caption     = Convert.ToString(cpu["Caption"]);
                Cores       = cpu["NumberOfCores"] != null ? (uint)cpu["NumberOfCores"] : 0;
                Used        = cpu["NumberOfEnabledCore"] != null ? (uint)cpu["NumberOfEnabledCore"] : 0;
                Logical     = cpu["NumberOfLogicalProcessors"] != null ? (uint)cpu["NumberOfLogicalProcessors"] : 0;
                Threads     = cpu["ThreadCount"] != null ? (uint)cpu["ThreadCount"] : 0;
                ProcessorId = Convert.ToString(cpu["ProcessorId"]);
                DeviceId    = Convert.ToString(cpu["DeviceID"]);
                Speed       = cpu["MaxClockSpeed"] != null ? (uint)cpu["MaxClockSpeed"] : 0;
            }
            private string CleanName(string input)
            {
                if (input == null)
                    return null;

                string result = "";
                bool lastWasSpace = false;

                for (int i = 0; i < input.Length; i++)
                {
                    char c = input[i];

                    if (Char.IsWhiteSpace(c))
                    {
                        if (!lastWasSpace)
                        {
                            result += " ";
                            lastWasSpace = true;
                        }
                    }
                    else
                    {
                        result += c;
                        lastWasSpace = false;
                    }
                }

                return result;
            }
            public override string ToString()
            {
                return Name;
            }
        }

        [Serializable]
        public class Processors
        {
            public string        Name;
            public int          Count;
            public Processor[] Output;

            public Processors()
            {
                Name   = "Processor(s)";
                Count  = 0;
                Output = new Processor[0];

                Refresh();
            }
            public void Refresh()
            {
                try
                {
                    ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_Processor");

                    ManagementObjectCollection results = searcher.Get();

                    Output = new Processor[results.Count];
                    Count = 0;

                    foreach (ManagementObject cpu in results)
                    {
                        Output[Count] = new Processor((uint)Count, cpu);
                        Count++;
                    }
                }
                catch
                {
                    // If WMI fails, Output remains empty.
                }
            }
            public override string ToString()
            {
                return Name + "[" + Count.ToString() + "]";
            }
        }

        public enum OperationalStatus : ushort
        {
            Unknown                   = 0,
            Other                     = 1,
            OK                        = 2,
            Degraded                  = 3,
            Stressed                  = 4,
            PredictiveFailure         = 5,
            Error                     = 6,
            NonRecoverableError       = 7,
            Starting                  = 8,
            Stopping                  = 9,
            Stopped                   = 10,
            InService                 = 11,
            NoContact                 = 12,
            LostCommunication         = 13,
            Aborted                   = 14,
            Dormant                   = 15,
            SupportingEntityInError   = 16,
            Completed                 = 17
        }

        [Serializable]
        public class Disk
        {
            public uint                       Rank;
            public uint                      Index;
            public string                 DeviceId;
            public string                    Model;
            public string                   Serial;
            public string           PartitionStyle;
            public string         ProvisioningType;
            public string        OperationalStatus;
            public string             HealthStatus;
            public string                  BusType;
            public string                 UniqueId;
            public string                 Location;
            public Platform.Partition[] Partitions;
            public Platform.Volume[]       Volumes;
            public Disk(uint rank, ManagementObject disk)
            {
                Rank     = rank;
                Index    = disk["Index"] != null ? (uint)disk["Index"] : 0;
                DeviceId = Convert.ToString(disk["DeviceID"]);

                Partitions = new Platform.Partition[0];
                Volumes    = new Platform.Volume[0];

                LoadMsftDisk();
                LoadPartitions();
                LoadVolumes();
            }
            private string ConvertOperationalStatus(object raw)
            {
                if (raw == null)
                    return null;

                ushort[] arr = raw as ushort[];
                if (arr == null || arr.Length == 0)
                    return null;

                string s = "";
                for (int i = 0; i < arr.Length; i++)
                {
                    OperationalStatus st = (OperationalStatus)arr[i];

                    if (i > 0)
                        s += ", ";

                    s += st.ToString();
                }

                return s;
            }
            private string ExtractDeviceId(string wmiPath)
            {
                if (wmiPath == null)
                    return null;

                int idx = wmiPath.IndexOf("DeviceID=");
                if (idx < 0)
                    return null;

                idx += "DeviceID=".Length;

                int q1 = wmiPath.IndexOf('"', idx);
                if (q1 < 0)
                    return null;

                int q2 = wmiPath.IndexOf('"', q1 + 1);
                if (q2 < 0)
                    return null;

                return wmiPath.Substring(q1 + 1, q2 - q1 - 1);
            }
            private void LoadMsftDisk()
            {
                try
                {
                    ManagementObjectSearcher searcher = new ManagementObjectSearcher(@"ROOT\Microsoft\Windows\Storage","SELECT * FROM MSFT_Disk WHERE Number=" + Index);

                    foreach (ManagementObject d in searcher.Get())
                    {
                        Model             = Convert.ToString(d["Model"]);
                        Serial            = Convert.ToString(d["SerialNumber"]);
                        if (Serial != null) Serial = Serial.TrimStart(' ');

                        PartitionStyle    = Convert.ToString(d["PartitionStyle"]);
                        ProvisioningType  = Convert.ToString(d["ProvisioningType"]);
                        OperationalStatus = ConvertOperationalStatus(d["OperationalStatus"]);
                        HealthStatus      = Convert.ToString(d["HealthStatus"]);
                        BusType           = Convert.ToString(d["BusType"]);
                        UniqueId          = Convert.ToString(d["UniqueId"]);
                        Location          = Convert.ToString(d["Location"]);
                        break;
                    }
                }
                catch
                {
                    // If MSFT_Disk fails, fields remain null.
                }
            }
            private void LoadPartitions()
            {
                try
                {
                    ManagementObjectSearcher  searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskPartition WHERE DiskIndex=" + Index);
                    ManagementObjectCollection results = searcher.Get();

                    Partitions = new Platform.Partition[results.Count];

                    int i      = 0;
                    foreach (ManagementObject p in results)
                    {
                        Platform.Partition part = new Platform.Partition(p);

                        Partitions[i++] = part;
                    }
                }
                catch
                {
                    Partitions = new Platform.Partition[0];
                }
            }
            private void LoadVolumes()
            {
                try
                {
                    ManagementObjectSearcher  ldSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_LogicalDisk WHERE DriveType=3");
                    ManagementObjectCollection  logicals = ldSearcher.Get();
                    ManagementObjectSearcher mapSearcher = new ManagementObjectSearcher("SELECT * FROM Win32_LogicalDiskToPartition");
                    System.Collections.ArrayList    list = new System.Collections.ArrayList();

                    foreach (ManagementObject map in mapSearcher.Get())
                    {
                        string antecedent = Convert.ToString(map["Antecedent"]);
                        string dependent  = Convert.ToString(map["Dependent"]);

                        string partId = ExtractDeviceId(antecedent);
                        string volId  = ExtractDeviceId(dependent);

                        Platform.Partition part = null;
                        for (int i = 0; i < Partitions.Length; i++)
                        {
                            if (Partitions[i].Name == partId)
                            {
                                part = Partitions[i];
                                break;
                            }
                        }

                        if (part == null)
                            continue;

                        foreach (ManagementObject ld in logicals)
                        {
                            string drive = Convert.ToString(ld["DeviceID"]);
                            if (drive == volId)
                            {
                                Platform.Volume v = new Platform.Volume(ld);
                                v.Partition = part;

                                list.Add(v);
                                break;
                            }
                        }
                    }

                    Volumes = new Platform.Volume[list.Count];
                    for (int i = 0; i < list.Count; i++)
                        Volumes[i] = (Platform.Volume)list[i];
                }
                catch
                {
                    Volumes = new Platform.Volume[0];
                }
            }
            public override string ToString()
            {
                return Model + "(" + Rank.ToString() + ")";
            }
        }

        [Serializable]
        public class Disks
        {
            public string   Name;
            public int     Count;
            public Disk[] Output;
            public Disks()
            {
                Name   = "Disk(s)";
                Count  = 0;
                Output = new Disk[0];
                
                Refresh();
            }
            public void Refresh()
            {
                try
                {
                    ManagementObjectSearcher  searcher = new ManagementObjectSearcher("SELECT * FROM Win32_DiskDrive WHERE MediaType LIKE '%Fixed%'");
                    ManagementObjectCollection results = searcher.Get();

                    Output = new Disk[results.Count];
                    Count  = 0;

                    foreach (ManagementObject d in results)
                    {
                        Output[Count] = new Disk((uint)Count, d);
                        Count++;
                    }
                }
                catch
                {
                    Output = new Disk[0];
                    Count = 0;
                }
            }
            public override string ToString()
            {
                return Name + "[" + Count.ToString() + "]";
            }
        }

        [Serializable]
        public class NetworkAdapter
        {
            public uint           Rank;
            public string         Name;
            public string  AdapterType;
            public string Manufacturer;
            public string   MacAddress;
            public string  ServiceName;
            public string     DeviceId;
            public string  PnpDeviceId;
            public ulong         Speed;
            public Network.Interface[] Interfaces;
            public NetworkAdapter(ManagementObject adapter)
            {
                uint rank = 0;
                string devIdRaw = Convert.ToString(adapter["DeviceID"]);
                if (!string.IsNullOrEmpty(devIdRaw))
                {
                    uint.TryParse(devIdRaw, out rank);
                }

                Rank         = rank;
                Name         = Convert.ToString(adapter["Name"]);
                AdapterType  = Convert.ToString(adapter["AdapterType"]);
                Manufacturer = Convert.ToString(adapter["Manufacturer"]);
                MacAddress   = Convert.ToString(adapter["MACAddress"]);
                ServiceName  = Convert.ToString(adapter["ServiceName"]);
                DeviceId     = Convert.ToString(adapter["DeviceID"]);
                PnpDeviceId  = Convert.ToString(adapter["PNPDeviceID"]);
                Speed        = adapter["Speed"] != null ? (ulong)adapter["Speed"] : 0;

                Interfaces   = new FightingEntropy.Network.Interface[0];
            }
            public override string ToString()
            {
                return Name;
            }
        }

        [Serializable]
        public class NetworkAdapters
        {
            public string             Name;
            public uint              Count;
            public NetworkAdapter[] Output;
            public NetworkAdapters()
            {
                Name   = "NetworkAdapter(s)";
                Count  = 0;
                Output = new NetworkAdapter[0];

                Refresh();
            }
            public void Refresh()
            {
                // Reset
                Output = new NetworkAdapter[0];
                Count = 0;

                // 1. Enumerate physical adapters
                ManagementObjectSearcher    adapterSearch = new ManagementObjectSearcher("SELECT * FROM Win32_NetworkAdapter");
                ManagementObjectCollection adapterResults = adapterSearch.Get();

                foreach (ManagementObject a in adapterResults)
                {
                    Add(new NetworkAdapter(a));
                }

                // 2. Enumerate logical interfaces (configurations)
                ManagementObjectSearcher    cfgSearch = new ManagementObjectSearcher("SELECT * FROM Win32_NetworkAdapterConfiguration");
                ManagementObjectCollection cfgResults = cfgSearch.Get();

                foreach (ManagementObject cfg in cfgResults)
                {
                    string mac = Convert.ToString(cfg["MACAddress"]);
                    if (mac == null)
                        continue;

                    // Match interface to adapter by MAC
                    for (uint i = 0; i < Count; i++)
                    {
                        NetworkAdapter adapter = Output[i];

                        if (adapter.MacAddress != null && adapter.MacAddress.Equals(mac, StringComparison.OrdinalIgnoreCase))
                        {
                            AddInterface(adapter, new Network.Interface(cfg));
                            break;
                        }
                    }
                }

                // 3. Attach configurations (IPv4 + IPv6)
                for (uint i = 0; i < Count; i++)
                {
                    NetworkAdapter adapter = Output[i];

                    for (uint j = 0; j < adapter.Interfaces.Length; j++)
                    {
                        Network.Interface iface = adapter.Interfaces[j];

                        // Re-query configuration by Index
                        ManagementObjectSearcher s = new ManagementObjectSearcher("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE Index=" + iface.Index);

                        foreach (ManagementObject cfg in s.Get())
                        {
                            string[] ip      = cfg["IPAddress"] as string[];
                            string[] subnet  = cfg["IPSubnet"] as string[];
                            string[] gateway = cfg["DefaultIPGateway"] as string[];
                            string[] dns     = cfg["DNSServerSearchOrder"] as string[];
                            string dhcp      = Convert.ToString(cfg["DHCPServer"]);

                            if (ip == null)
                                continue;

                            for (int x = 0; x < ip.Length; x++)
                            {
                                string addr = ip[x];
                                if (addr == null)
                                    continue;

                                Network.ProtocolFamily proto = DetectProtocol(addr);

                                string mask    = (subnet != null && x < subnet.Length) ? subnet[x] : null;
                                string gw      = (gateway != null && x < gateway.Length) ? gateway[x] : null;
                                string dnsList = JoinList(dns);

                                AddConfiguration(iface,new Network.Configuration(proto,addr,mask,gw,dnsList,dhcp));
                            }
                        }
                    }
                }
            }
            private void AddInterface(NetworkAdapter adapter, Network.Interface iface)
            {
                uint count = (uint)adapter.Interfaces.Length;
                Network.Interface[] temp = new Network.Interface[count + 1];

                for (uint i = 0; i < count; i++)
                    temp[i] = adapter.Interfaces[i];

                temp[count] = iface;
                adapter.Interfaces = temp;
            }
            private void AddConfiguration(Network.Interface iface,Network.Configuration cfg)
            {
                uint count = (uint)iface.Configurations.Length;
                Network.Configuration[] temp = new Network.Configuration[count + 1];

                for (uint i = 0; i < count; i++)
                    temp[i] = iface.Configurations[i];

                temp[count] = cfg;
                iface.Configurations = temp;
            }
            private Network.ProtocolFamily DetectProtocol(string address)
            {
                if (address == null)           return Network.ProtocolFamily.Unknown;
                if (address.IndexOf(':') >= 0) return Network.ProtocolFamily.IPv6;
                if (address.IndexOf('.') >= 0) return Network.ProtocolFamily.IPv4;

                return Network.ProtocolFamily.Unknown;
            }
            private string JoinList(string[] arr)
            {
                if (arr == null) return null;

                string s = "";
                for (int i = 0; i < arr.Length; i++)
                {
                    if (arr[i] == null)
                        continue;

                    if (s.Length > 0)
                        s += ", ";

                    s += arr[i];
                }
                return s;
            }
            public void Add(NetworkAdapter a)
            {
                NetworkAdapter[] temp = new NetworkAdapter[Count + 1];

                for (int i = 0; i < Count; i++)
                    temp[i] = Output[i];

                temp[Count] = a;
                Output      = temp;
                Count++;
            }
            public override string ToString()
            {
                return Name + "[" + Count.ToString() + "]";
            }
        }

        
    }

    // Network classes deal with network interfaces + configurations
    namespace Network
    {
        public enum ProtocolFamily
        {
            Unknown = 0,
            IPv4    = 4,
            IPv6    = 6,
            IPX     = 7   // placeholder, extensible
        }

        [Serializable]
        public class Interface
        {
            public uint         Index;
            public string Description;
            public string ServiceName;
            public uint   DhcpEnabled;
            public string  MacAddress;
            public Configuration[] Configurations;
            public Interface(ManagementObject cfg)
            {
                Index       = cfg["Index"] != null ? (uint)cfg["Index"] : 0;
                Description = Convert.ToString(cfg["Description"]);
                ServiceName = Convert.ToString(cfg["ServiceName"]);
                DhcpEnabled = cfg["DHCPEnabled"] != null && (bool)cfg["DHCPEnabled"] ? 1u : 0u;
                MacAddress  = Convert.ToString(cfg["MACAddress"]);

                Configurations = new Configuration[0];
            }
            public override string ToString()
            {
                return Description;
            }
        }

        [Serializable]
        public class Configuration
        {
            public ProtocolFamily Protocol;
            public string          Address;
            public string       SubnetMask;
            public string          Gateway;
            public string       DnsServers;
            public string       DhcpServer;
            public Configuration(ProtocolFamily protocol,
                                 string address,
                                 string subnetMask,
                                 string gateway,
                                 string dnsServers,
                                 string dhcpServer)
            {
                Protocol   = protocol;
                Address    = address;
                SubnetMask = subnetMask;
                Gateway    = gateway;
                DnsServers = dnsServers;
                DhcpServer = dhcpServer;
            }
            public override string ToString()
            {
                return "[" + Protocol.ToString() + "] " + Address;
            }
        }
    }

    // Thread classes deal with managing multithreading
    namespace Thread
    {
        public enum State
        {
            Created,
            Started,
            Running,
            Completed,
            Faulted
        }

        public interface IProgressCallback
        {
            void Report(string key, string name, int current, int total, string message);
        }

        public class ProgressReporter : IProgressCallback
        {
            private Controller _controller;

            public ProgressReporter(Controller controller)
            {
                _controller = controller;
            }
            public void Report(string key, string name, int current, int total, string message)
            {
                _controller.UpdateStatus(key, name, current, total, message);

                // Also push a formatted message into the thread's message queue
                string line = message; // or include key/name if you want
                _controller.AddMessage(line);
            }
        }

        public enum IntensityType
        {
            Low    = 0,  // Minimal CPU usage, conservative thread count
            Medium = 1,  // Balanced throughput
            High   = 2   // Maximum throughput, highest CPU usage
        }

        public class IntensitySlot
        {
            public int          Index { get; private set; }
            public string        Name { get; private set; }
            public string Description { get; private set; }
            public bool      Selected { get; set; }
            public IntensitySlot(int index, string name, string description)
            {
                Index       = index;
                Name        = name;
                Description = description;
                Selected    = false;
            }
        }

        public class Instance
        {
            public int             Index { get; set; }
            public string           Name { get; set; }
            public int                Id { get; set; }
            public DateTime      Started { get; set; }
            public DateTime   LastReport { get; set; }
            public DateTime   NextReport { get; set; }
            public DateTime?   Completed { get; set; }
            public State          Status { get; set; }
            public bool        IsStarted 
            { 
                get 
                {
                    return (Status == State.Started  || Status == State.Running || Status == State.Completed); 
                } 
            }
            public bool        IsRunning
            {
                get
                {
                    return (Status == State.Running);
                }
            }
            public bool       IsComplete
            {
                get
                {
                    return (Status == State.Completed);
                }
            }
            public bool      HasDuration 
            { 
                get 
                { 
                    return (Status == State.Completed);
                } 
            }
            public Instance(int index, string name, int id)
            {
                Index      = index;
                Name       = name;
                Id         = id;
                Status     = State.Created;
            }
            public void Start()
            {
                Started    = DateTime.UtcNow;
                LastReport = Started;
                Status     = State.Started;
            }
            public void RunningUpdate()
            {
                LastReport = DateTime.UtcNow;
                Status     = State.Running;
            }
            public void Complete()
            {
                Completed  = DateTime.UtcNow;
                Status     = State.Completed;
            }
            public void Fault()
            {
                Completed  = DateTime.UtcNow;
                Status     = State.Faulted;
            }
            public TimeSpan Elapsed()
            {
                return DateTime.UtcNow - Started;
            }
            public TimeSpan Last()
            {
                return DateTime.UtcNow - LastReport;
            }
            public TimeSpan Duration
            {
                get
                {
                    if (Status == State.Completed && Completed.HasValue)
                        return Completed.Value - Started;

                    return DateTime.UtcNow - Started;
                }
            }
            public override string ToString()
            {
                return "[" + Index + "] " + Name + " (Thread " + Id + ", " + Status + ")";
            }
        }

        public class StatusEntry
        {
            public string           Key;
            public string          Name;
            public int          Current;
            public int            Total;
            public string       Message;
            public DateTime    StartUtc;
            public DateTime LastUpdated;
            public DateTime LastChanged;
            public bool      IsComplete;
            public bool       IsStalled;
            public StatusEntry()
            {
                Total        = -1;

                StartUtc     = DateTime.UtcNow;
                LastUpdated  = StartUtc;
                LastChanged  = StartUtc;

                IsComplete   = false;
                IsStalled    = false;
            }
            public override string ToString()
            {
                return Message;
            }
        }

        public class StatusBank
        {
            public System.Collections.Hashtable Table;
            public StatusBank()
            {
                Table = System.Collections.Hashtable.Synchronized(new System.Collections.Hashtable());
            }
            public void Update(string key, string name, int current, int total, string message)
            {
                StatusEntry entry;

                if (Table.ContainsKey(key))
                {
                    entry = (StatusEntry)Table[key];
                }
                else
                {
                    entry = new StatusEntry();
                    entry.Key = key;
                    Table[key] = entry;
                }

                entry.Name        = name;
                entry.Current     = current;
                entry.Total       = total;
                entry.Message     = message;
                entry.LastUpdated = DateTime.UtcNow;
            }
            public StatusEntry[] Snapshot()
            {
                System.Collections.ArrayList list = new System.Collections.ArrayList();

                foreach (object key in Table.Keys)
                {
                    list.Add(Table[key]);
                }

                StatusEntry[] arr = new StatusEntry[list.Count];
                for (int i = 0; i < list.Count; i++)
                    arr[i] = (StatusEntry)list[i];

                return arr;
            }
        }

        public enum SessionStateType
        {
            Assembly = 0,
            Function = 1,
            Variable = 2,
            Script   = 3
        }

        public enum SessionStatePhase
        {
            Assigned  = 0,
            Initial   = 1,
            Bootstrap = 2,
            Worker    = 3
        }

        public class SessionStateObject
        {
            public int               Index { get; set; }
            public SessionStateType   Type { get; set; }
            public SessionStatePhase Phase = SessionStatePhase.Assigned;
            public string             Name { get; set; }
            public string      Description { get; set; }
            public byte[]            Bytes { get; set; }
            public bool             Locked { get; private set; }
            public SessionStateObject(int index, string type, string phase, string name, string description, byte[] bytes)
            {
                Initialize(index, type, phase, name, description);

                Bytes = bytes;
            }
            public SessionStateObject(int index, string type, string phase, string name, string description, string[] content)
            {
                Initialize(index, type, phase, name, description);

                Bytes = System.Text.Encoding.UTF8.GetBytes(string.Join("\n", content));
            }
            public SessionStateObject(int index, string type, string phase, string name, string description, string path)
            {
                Initialize(index, type, phase, name, description);

                if (Directory.Exists(path))
                {
                    throw new InvalidOperationException(string.Format("Input [{0}] is a directory, not a file.", path));
                }
                else if (File.Exists(path))
                {
                    Bytes = File.ReadAllBytes(path);
                }
                else
                {
                    Bytes = System.Text.Encoding.UTF8.GetBytes(path);
                }
            }
            private void Initialize(int index, string type, string phase, string name, string description)
            {
                Index       = index;
                Type        = (SessionStateType)Enum.Parse(typeof(SessionStateType), type, true);
                Phase       = (SessionStatePhase)Enum.Parse(typeof(SessionStatePhase), phase, true);
                Name        = name;
                Description = description;
            }
            public void ToggleLock()
            {
                Locked = !Locked;
            }
            public string GetString()
            {
                return System.Text.Encoding.UTF8.GetString(Bytes);
            }
            public override string ToString()
            {
                return base.ToString();
            }
        }

        public enum ControllerState
        {
            Idle      = 0,
            Running   = 1,
            Resetting = 2,
            Faulted   = 3
        }

        public class Controller
        {
            public ConcurrentQueue<string>               Queue { get; set; }
            public ConcurrentBag<object>                   Bag { get; set; }
            public ConcurrentQueue<string>            Messages { get; set; }
            public ConcurrentDictionary<int, Instance> Threads { get; set; }
            public RunspacePool                           Pool { get; set; }
            public IntensitySlot[]                   Intensity { get; set; }
            private readonly PerformanceCounter     cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            public List<IAsyncResult>                     Jobs { get; set; }
            public int                              MaxThreads { get; set; }
            public DateTime                          StartTime { get; set; }
            public DateTime                        LastBeatUtc { get; set; }
            public int                              TotalItems { get; set; }
            public StatusBank                       StatusBank;
            public ControllerState                       State;
            public List<SessionStateObject>       SessionState { get; private set; }

            public Controller()
            {
                InitIntensity();
                AutoSelectIntensity();

                State = ControllerState.Idle;
                Reset();
            }
            private void InitIntensity()
            {
                Intensity = new[]
                {
                    new IntensitySlot((int)IntensityType.Low,"Low","Minimum CPU usage, longest processing time"),
                    new IntensitySlot((int)IntensityType.Medium,"Medium","Balanced CPU usage, average processing time"),
                    new IntensitySlot((int)IntensityType.High,"High","Maximum CPU usage, shortest processing time")
                };
            }
            public int GetCpuUsage()
            {
                try
                {
                    // First call always returns 0, so call twice
                    cpuCounter.NextValue();
                    System.Threading.Thread.Sleep(100);

                    return (int)cpuCounter.NextValue();
                }
                catch
                {
                    return -1; // fallback if counters unavailable
                }
            }
            public void AutoSelectIntensity()
            {
                int cpu   = GetCpuUsage();
                int index = 0;

                if (cpu >= 80)
                    index = 0;

                else if (cpu >= 40)
                    index = 1;

                else
                    index = 2;

                SelectIntensity((uint)index);
            }
            public void SelectIntensity(uint index)
            {
                if (Intensity == null || Intensity.Length == 0)
                    throw new InvalidOperationException("Intensity list not initialized.");

                int i;

                for (i = 0; i < Intensity.Length; i ++)
                {
                    Intensity[i].Selected = (Intensity[i].Index == index);
                }

                ComputeMaxThreads();
            }
            public void ComputeMaxThreads()
            {
                IntensitySlot selected = null;
                int i;

                for (i = 0; i < Intensity.Length; i ++)
                {
                    if (Intensity[i].Selected)
                    {
                        selected = Intensity[i];
                    }
                }

                if (selected == null)
                    throw new InvalidOperationException("No intensity slot is selected");

                int cores = Environment.ProcessorCount;
                int calc;

                switch (selected.Index)
                {
                    case 0: // Low
                        calc = Math.Max(1, cores / 2);
                        break;
                    
                    case 1: // Medium
                        calc = Math.Max(1, cores);
                        break;

                    case 2: // High
                        calc = Math.Max(2, (int)(cores * 1.5));
                        break;

                    default:
                        calc = Math.Max(1, cores);
                        break;
                }

                MaxThreads = calc;
            }
            public void Reset()
            {
                State = ControllerState.Resetting;

                if (Pool != null)
                {
                    bool closed   = true;
                    bool disposed = true;

                    try { Pool.Close();   } catch { closed   = false; }
                    try { Pool.Dispose(); } catch { disposed = false; }

                    if (!closed || !disposed)
                    {
                        System.Console.WriteLine("Exception [!] Unable to (close/dispose) the runspace pool");   
                        return;
                    }

                    Pool = null;
                }

                InitCollections();
                InitTime();

                State = ControllerState.Idle;
            }
            public void SetRunning()
            {
                State = ControllerState.Running;
            }
            public void SetIdle()
            {
                State = ControllerState.Idle;
            }
            public void InitCollections()
            {
                Queue        = new ConcurrentQueue<string>();
                Bag          = new ConcurrentBag<object>();
                Messages     = new ConcurrentQueue<string>();
                Threads      = new ConcurrentDictionary<int, Instance>();
                Jobs         = new List<IAsyncResult>();
                StatusBank   = new StatusBank();

                var preserved = new List<SessionStateObject>();

                if (SessionState != null)
                {
                    foreach (var obj in SessionState)
                    {
                        if (obj.Locked)
                            preserved.Add(obj);
                    }
                }

                SessionState = preserved;
            }
            public void InitTime()
            {
                StartTime    = DateTime.UtcNow;
                LastBeatUtc  = DateTime.UtcNow;
            }
            public void AddSessionStateObject(string type, string phase, string name, string description, byte[] bytes)
            {
                if (SessionStateNameExists(name))
                    throw new InvalidOperationException("SessionStateObject with name '" + name + "' already exists.");

                int index = SessionState.Count;
                SessionState.Add(new SessionStateObject(index, type, phase, name, description, bytes));
            }
            public void AddSessionStateObject(string type, string phase, string name, string description, string[] content)
            {
                if (SessionStateNameExists(name))
                    throw new InvalidOperationException("SessionStateObject with name '" + name + "' already exists.");

                int index = SessionState.Count;
                SessionState.Add(new SessionStateObject(index, type, phase, name, description, content));
            }
            public void AddSessionStateObject(string type, string phase, string name, string description, string path)
            {
                if (SessionStateNameExists(name))
                    throw new InvalidOperationException("SessionStateObject with name '" + name + "' already exists.");

                int index = SessionState.Count;
                SessionState.Add(new SessionStateObject(index, type, phase, name, description, path));
            }
            public bool SessionStateNameExists(string name)
            {
                if (SessionState == null)
                    return false;

                for (int i = 0; i < SessionState.Count; i++)
                {
                    SessionStateObject obj = SessionState[i];
                    if (obj != null && obj.Name != null && string.Compare(obj.Name, name, true) == 0)
                    {
                        return true;
                    }
                }

                return false;
            }
            public void UpdateStatus(string key, string name, int current, int total, string message)
            {
                StatusEntry entry;

                if (StatusBank.Table.ContainsKey(key))
                {
                    entry = (StatusEntry)StatusBank.Table[key];
                }
                else
                {
                    entry      = new StatusEntry();
                    entry.Key  = key;
                    entry.Name = name;
                    StatusBank.Table.Add(key, entry);
                }

                DateTime now = DateTime.UtcNow;

                // Detect progress change
                if (entry.Current != current || entry.Total != total)
                {
                    entry.Current     = current;
                    entry.Total       = total;
                    entry.LastChanged = now;

                    // Progress resumed → clear stall
                    entry.IsStalled   = false;
                }

                entry.Message     = message;
                entry.LastUpdated = now;

                int tid;
                if (Int32.TryParse(key, out tid))
                {
                    Instance inst;

                    // If the thread exists AND is complete, mark the entry complete
                    if (Threads.TryGetValue(tid, out inst))
                    {
                        if (inst.IsComplete)
                        {
                            entry.IsComplete = true;
                            entry.IsStalled  = false;
                        }
                    }
                }
            }
            public void InitializePool()
            {
                if (State == ControllerState.Running || State == ControllerState.Resetting)
                {
                    throw new InvalidOperationException("Exception [!] Cannot initialize pool while thread controller is (running/resetting).");
                }

                var iss = InitialSessionState.CreateDefault();

                foreach (var item in SessionState)
                {
                    if (item.Phase != SessionStatePhase.Initial)
                        continue;

                    switch (item.Type)
                    {
                        case SessionStateType.Assembly:
                            iss.Variables.Add(new SessionStateVariableEntry(item.Name, item.Bytes, item.Description));
                            break;

                        case SessionStateType.Function:
                            iss.Commands.Add(new SessionStateFunctionEntry(item.Name, item.GetString()));
                            break;

                        case SessionStateType.Variable:
                            iss.Variables.Add(new SessionStateVariableEntry(item.Name, item.Bytes, item.Description));
                            break;

                        case SessionStateType.Script:
                            iss.Commands.Add(new SessionStateFunctionEntry(item.Name, item.GetString()));
                            break;

                        default:
                            break;
                    }
                }

                Pool = RunspaceFactory.CreateRunspacePool(iss);
                Pool.SetMinRunspaces(1);
                Pool.SetMaxRunspaces(MaxThreads);
                Pool.Open();
            }
            public string BuildBootstrapBlock()
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                foreach (var item in SessionState)
                {
                    if (item.Phase != SessionStatePhase.Bootstrap)
                        continue;

                    switch (item.Type)
                    {
                        case SessionStateType.Assembly:
                            sb.AppendLine("# Load assembly: [" + item.Name + "]");
                            sb.AppendLine("[System.Reflection.Assembly]::Load($" + item.Name + ") | Out-Null");
                            sb.AppendLine();
                            break;

                        case SessionStateType.Function:
                            sb.AppendLine("# Define function: [" + item.Name + "]");
                            sb.AppendLine(item.GetString());
                            sb.AppendLine();
                            break;

                        case SessionStateType.Variable:
                            sb.AppendLine("# Set variable: [" + item.Name + "]");
                            sb.AppendLine("Set-Variable -Name \"" + item.Name + "\" -Value " + item.GetString());
                            sb.AppendLine();
                            break;

                        case SessionStateType.Script:
                                sb.AppendLine("# Execute script: [" + item.Name + "]");
                                sb.AppendLine(item.GetString());
                                sb.AppendLine();
                            break;

                        default:
                            break;
                    }
                }

                return sb.ToString();
            }
            public string BuildWorkerBlock()
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                foreach (var item in SessionState)
                {
                    if (item.Phase != SessionStatePhase.Worker)
                        continue;

                    switch (item.Type)
                    {
                        case SessionStateType.Assembly:
                            sb.AppendLine("# Load assembly (worker): [" + item.Name + "]");
                            sb.AppendLine("[System.Reflection.Assembly]::Load($" + item.Name + ") | Out-Null");
                            sb.AppendLine();
                            break;

                        case SessionStateType.Function:
                            sb.AppendLine("# Define function (worker): [" + item.Name + "]");
                            sb.AppendLine(item.GetString());
                            sb.AppendLine();
                            break;

                        case SessionStateType.Variable:
                            sb.AppendLine("# Set variable (worker): [" + item.Name + "]");
                            sb.AppendLine("Set-Variable -Name \"" + item.Name + "\" -Value " + item.GetString());
                            sb.AppendLine();
                            break;

                        case SessionStateType.Script:
                            sb.AppendLine("# Execute script (worker): [" + item.Name + "]");
                            sb.AppendLine(item.GetString());
                            sb.AppendLine();
                            break;

                        default:
                            break;
                    }
                }

                return sb.ToString();
            }
            public void EnqueueWork(string name)
            {
                Queue.Enqueue(name);
                TotalItems++;
            }
            public bool TryDequeueWork(ref string name)
            {
                return Queue.TryDequeue(out name);
            }
            public void AddThread(Instance t)
            {
                Threads[t.Id] = t;
            }
            public void RemoveThread(int id)
            {
                Instance tmp;
                Threads.TryRemove(id, out tmp);
            }
            public void AddMessage(string msg)
            {
                Messages.Enqueue(msg);
            }
            public string[] DrainMessages()
            {
                List<string> list = new List<string>();
                string msg;

                while (Messages.TryDequeue(out msg))
                {
                    list.Add(msg);
                }

                return list.ToArray();
            }
            public void AddResult(object item)
            {
                Bag.Add(item);
            }
            public void RegisterJob(IAsyncResult job)
            {
                Jobs.Add(job);
            }
            public bool HeartbeatDue(int seconds)
            {
                return (DateTime.UtcNow - LastBeatUtc).TotalSeconds >= seconds;
            }
            public void UpdateHeartbeat()
            {
                LastBeatUtc = DateTime.UtcNow;
            }
            public TimeSpan Elapsed()
            {
                return DateTime.UtcNow - StartTime;
            }
            public int ActiveJobs()
            {
                int count = 0;

                foreach (var job in Jobs)
                {
                    if (!job.IsCompleted)
                        count++;
                }

                return count;
            }
            public StatusEntry[] GetStatusSnapshot()
            {
                return StatusBank.Snapshot();
            }
            public string[] DetectStalls(int stallSeconds)
            {
                List<string> list = new List<string>();
                StatusEntry[] statuses = StatusBank.Snapshot();
                DateTime now = DateTime.UtcNow;

                for (int i = 0; i < statuses.Length; i++)
                {
                    StatusEntry s = statuses[i];

                    // Completed work is never stalled
                    if (s.IsComplete)
                    {
                        s.IsStalled = false;
                        continue;
                    }

                    // Key is now the thread ID
                    int tid;
                    if (!Int32.TryParse(s.Key, out tid))
                        continue;

                    Instance inst;
                    if (!Threads.TryGetValue(tid, out inst))
                        continue;

                    // Only running threads can stall
                    if (!inst.IsRunning)
                    {
                        s.IsStalled = false;
                        continue;
                    }

                    // Check time since last progress
                    TimeSpan since = now - s.LastChanged;
                    if (since.TotalSeconds < stallSeconds)
                    {
                        s.IsStalled = false;
                        continue;
                    }

                    // Already reported
                    if (s.IsStalled)
                        continue;

                    string msg = string.Format(
                        "Warning [!] Stalled: ({0}), Last: {1}, Now: {2}",
                        s.Name,
                        s.LastChanged.ToString("MM-dd-yyyy HH:mm:ss"),
                        now.ToString("MM-dd-yyyy HH:mm:ss")
                    );

                    list.Add(msg);
                    s.IsStalled = true;
                }

                return list.ToArray();
            }
            public override string ToString()
            {
                return "<FightingEntropy.Thread.Controller>";
            }
        }
 
    }

    // Security classes deal with SIDs, and Windows Identity
    namespace Security
    {
        public enum AuthenticationType
        {
            Unknown     = 0,
            Kerberos    = 1,
            NTLM        = 2,
            Negotiate   = 3,
            Basic       = 4,
            Digest      = 5,
            Certificate = 6,
            OAuth       = 7,
            Federated   = 8,
            Anonymous   = 9,
            CloudAP     = 10,
            LiveID      = 11,
        }

        public enum AccountType
        {
            Unknown        = 0,
            LocalSystem    = 1,
            LocalService   = 2,
            NetworkService = 3,
            User           = 4,
            BuiltinGroup   = 5,
        }

        [Serializable]
        public class Identifier
        {
            public int        BinaryLength;
            public string AccountDomainSid;
            public string             Name;
            public string            Value;
            public Identifier()
            {
                
            }
            public Identifier(SecurityIdentifier sid)
            {
                if (sid == null)
                    return;

                BinaryLength     = sid.BinaryLength;
                AccountDomainSid = sid.AccountDomainSid != null ? sid.AccountDomainSid.Value : null;
                Value            = sid.Value;

                try
                {
                    Name = sid.Translate(typeof(NTAccount)).ToString();
                }
                catch
                {
                    Name = sid.Value;
                }
            }
            public SecurityIdentifier ToSid()
            {
                if (Value == null)
                    return null;

                return new SecurityIdentifier(Value);
            }
            public override string ToString()
            {
                return Value;
            }
        }

        public class Role
        {
            public Identifier Sid;
            public string    Name;
            public Role(SecurityIdentifier sid)
            {
                if (sid == null)
                    return;

                Sid = new Identifier(sid);

                try
                {
                    NTAccount account = (NTAccount)sid.Translate(typeof(NTAccount));
                    Name = account.ToString();
                }
                catch
                {
                    Name = sid.Value;
                }
            }
            public override string ToString()
            {
                return Name;
            }
        }

        public class Account
        {
            public Identifier   Sid;
            public string      Name;
            public string    Domain;
            public AccountType Type;
            public Account(WindowsIdentity identity)
            {
                if (identity == null)
                    return;
                
                Name = identity.Name;

                if (identity.User != null)
                {
                    Sid  = new Identifier(identity.User);
                    Type = MapAccountType(identity.User);
                }
                else
                {
                    Type = AccountType.Unknown;   
                }

                // Domain/Username parsing.
                int idx = Name.IndexOf('\\');
                if (idx > 0)
                    Domain = Name.Substring(0, idx);
            }
            public static AccountType MapAccountType(SecurityIdentifier sid)
            {
                if (sid == null)
                    return AccountType.Unknown;

                if (sid.Value.StartsWith("S-1-5-18")) return AccountType.LocalSystem;
                if (sid.Value.StartsWith("S-1-5-19")) return AccountType.LocalService;
                if (sid.Value.StartsWith("S-1-5-20")) return AccountType.NetworkService;
                if (sid.Value.StartsWith("S-1-5-21")) return AccountType.User;
                if (sid.Value.StartsWith("S-1-5-22")) return AccountType.BuiltinGroup;

                return AccountType.Unknown;
            }
            public override string ToString()
            {
                return Name;
            }
        }

        public class PrincipalInfo
        {
            public Account             Account;
            public bool          Authenticated;
            public bool          Administrator;
            public AuthenticationType AuthType;
            public WindowsPrincipal  Principal;
            public WindowsIdentity    Identity;
            public List<Role>             Role;
            public PrincipalInfo(WindowsIdentity identity)
            {
                if (identity == null)
                    return;

                Account       = new Account(identity);
                Authenticated = identity.IsAuthenticated;
                AuthType      = MapAuthType(identity.AuthenticationType);
                
                Principal     = new WindowsPrincipal(identity);
                Identity      = identity;
                Administrator = Principal.IsInRole(WindowsBuiltInRole.Administrator);

                Refresh();
            }
            public void Clear()
            {
                Role          = new List<Role>();
            }
            public void Refresh()
            {
                Clear();

                if (Identity.Groups == null)
                    return;

                foreach (IdentityReference sid in Identity.Groups)
                    Role.Add(new Role((SecurityIdentifier)sid));
            }
            public static AuthenticationType MapAuthType(string value)
            {
                if (string.IsNullOrEmpty(value))
                    return AuthenticationType.Unknown;

                switch (value.ToLower())
                {
                    case "kerberos"  : return AuthenticationType.Kerberos;
                    case "ntlm"      : return AuthenticationType.NTLM;
                    case "negotiate" : return AuthenticationType.Negotiate;
                    case "basic"     : return AuthenticationType.Basic;
                    case "digest"    : return AuthenticationType.Digest;
                    case "x509"      : return AuthenticationType.Certificate;
                    case "oauth"     : return AuthenticationType.OAuth;
                    case "bearer"    : return AuthenticationType.OAuth;
                    case "federated" : return AuthenticationType.Federated;
                    case "anonymous" : return AuthenticationType.Anonymous;
                    case "cloudap"   : return AuthenticationType.CloudAP;
                    case "liveid"    : return AuthenticationType.LiveID;
                    default          : return AuthenticationType.Unknown;
                }
            }
            public static PrincipalInfo GetCurrent()
            {
                return new PrincipalInfo(WindowsIdentity.GetCurrent());
            }
            public override string ToString()
            {
                return Account != null ? Account.Name : base.ToString();
            }
        }

        // System.Security.Cryptography.X509Certificates.X509Certificate
    }

    // Theme classes deal with (parsing + formatting + stylizing) console output
    namespace Theme
    {
        public class InputLine
        {
            public uint    Index;
            public uint     Rank;
            public uint     Line;
            public string  Value;
            public uint   Length;
            public InputLine(uint index, uint rank, uint line, string value)
            {
                Index  = index;
                Rank   = rank;
                Line   = line;
                Value  = value;

                SetLength();
            }
            public void SetLength()
            {
                Length = (uint)Value.Length;
            }
            public override string ToString()
            {
                return (Value != null) ? Value.ToString() : "";
            }
        }

        public class InputContainer
        {
            public uint             Index;
            public uint              Rank;
            public string            Type;
            public uint             Count;
            public List<InputLine>   Line;
            public InputContainer(uint index, uint rank, string type, string[] lines)
            {
                Index = index;
                Rank  = rank;
                Type  = type;

                Refresh(lines);
            }
            public void Refresh(string[] lines)
            {
                Line  = new List<InputLine>();

                for (int x = 0; x < lines.Length; x++)
                {
                    InputLine line = new InputLine(Index, Rank, (uint)x, lines[x]);

                    Line.Add(line);
                }

                Count = (uint)lines.Length;
            }
            public override string ToString()
            {
                return string.Format("[{0}]({1})", Type, Count);
            }
        }

        public class InputItem
        {
            public uint                  Index;
            public string                 Type;
            public List<InputContainer> Output;
            public InputItem(uint index, string type)
            {
                Index  = index;
                Type   = type;
                Output = new List<InputContainer>();
            }
            public override string ToString()
            {
                return string.Format("[{0}]({1})", Type, Output.Count);
            }
        }

        public class InputObject
        {
            public TemplateType      Type;
            public uint            Height;
            public List<InputItem>  Input;
            public List<InputLine> Output;
            public InputObject(object[] inputObject)
            {
                BuildInput(inputObject);
                BuildOutput();
            }
            public InputObject(TemplateType type, object[] inputObject)
            {
                Type = type;
                BuildInput(inputObject);
                BuildOutput();
            }
            public string[] ConvertHashtable(Hashtable table)
            {
                List<string> lines = new List<string>();

                // Extract keys
                List<string> keys = new List<string>();
                foreach (object key in table.Keys)
                    keys.Add(key.ToString());

                // Compute longest key
                int buffer = GetMaxLength(keys);

                // Build aligned output
                foreach (object key in table.Keys)
                {
                    string k = key.ToString();
                    string v = (table[key] == null) ? "" : table[key].ToString();

                    string padded = k.PadRight(buffer, ' ');
                    lines.Add(padded + " : " + v);
                }

                return lines.ToArray();
            }
            public string[] ConvertObject(object obj)
            {
                List<string> lines = new List<string>();

                // Extract properties
                var pso = System.Management.Automation.PSObject.AsPSObject(obj);

                // Compute longest property name
                int buffer = 0;

                foreach (var prop in pso.Properties)
                {
                    if (prop.Name.Length > buffer)
                        buffer = prop.Name.Length;
                }

                // Build aligned output
                foreach (var prop in pso.Properties)
                {
                    string name  = prop.Name;
                    object value = (prop.Value == null) ? "" : prop.Value.ToString();

                    string padded = name.PadRight(buffer, ' ');
                    lines.Add(padded + " : " + value);
                }

                return lines.ToArray();
            }
            public string[] ConvertString(string input)
            {
                int width = 86;

                List<string> lines = new List<string>();
                string        line;
                string[]       raw;
                string[]     words;
                string        word;
                string      buffer;

                if (String.IsNullOrEmpty(input))
                {
                    lines.Add("");
                    return lines.ToArray();
                }

                // Normalize line endings
                input = input.Replace("\r\n", "\n");
                input = input.Replace("\r", "\n");
                raw   = input.Split(new char[] { '\n' }, StringSplitOptions.None);

                if (raw.Length == 1)
                {
                    lines.Add(raw[0]);
                    return lines.ToArray();
                }
                else
                {
                    for (int i = 0; i < raw.Length; i++)
                    {
                        line = raw[i];

                        if (String.IsNullOrEmpty(line))
                        {
                            lines.Add("");
                            continue;
                        }

                        if (System.Text.RegularExpressions.Regex.IsMatch(line, "[|_¯]"))
                        {
                            lines.Add(line);
                            continue;
                        }

                        words  = line.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        buffer = "";

                        for (int w = 0; w < words.Length; w++)
                        {
                            word = words[w];

                            // If the word alone exceeds width, force it as its own line
                            if (word.Length >= width)
                            {
                                if (buffer.Length > 0)
                                {
                                    lines.Add(buffer);
                                    buffer = "";
                                }

                                lines.Add(word);
                                continue;
                            }

                            // If adding this word would overflow, push current buffer
                            if (buffer.Length > 0)
                            {
                                if ((buffer.Length + 1 + word.Length) > width)
                                {
                                    lines.Add(buffer);
                                    buffer = word;
                                }
                                else
                                {
                                    buffer = buffer + " " + word;
                                }
                            }
                            else
                            {
                                buffer = word;
                            }
                        }

                        // Add final buffer for this line
                        if (buffer.Length > 0)
                            lines.Add(buffer);
                    }

                    return lines.ToArray();
                }
            }
            public string[] ConvertScript(string script)
            {
                List<string> lines = new List<string>();

                string pattern = "([\"']?)([A-Za-z_][A-Za-z0-9_-]*)\\1\\s*=\\s*(?:([\"'])(.*?)\\3|([^;]+))";

                string  scriptString = script.ToString().Replace("\r\n", "\n").Replace("\r", "\n");
                string[] scriptLines = scriptString.Split('\n');

                MatchCollection matches = Regex.Matches(scriptLines[0], pattern);

                if (matches.Count == 0)
                {
                    for (int x = 0; x < scriptLines.Length; x++)
                    {
                        lines.Add(scriptLines[x]);
                    }

                    return lines.ToArray();
                }

                // Collect keys and values
                List<string> names  = new List<string>();
                List<string> values = new List<string>();

                for (int i = 0; i < matches.Count; i++)
                {
                    Match m = matches[i];

                    names.Add(m.Groups[2].Value);

                    if (m.Groups[4].Success)
                        values.Add(m.Groups[4].Value);
                    else
                        values.Add(m.Groups[5].Value.Trim());
                }

                // Compute longest key
                int buffer = GetMaxLength(names);

                // Build aligned output
                for (int i = 0; i < names.Count; i++)
                {
                    string k = ((string)names[i]).PadRight(buffer, ' ');
                    string v = (string)values[i];
                    lines.Add(k + " : " + v);
                }

                return lines.ToArray();
            }
            public string[] ConvertByType(string type, object obj)
            {
                switch (type)
                {
                    case "String"      :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertString(s);
                    }
                    case "Hashtable"   :
                    {
                        return ConvertHashtable((Hashtable)obj);
                    }
                    case "ScriptBlock" :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertScript(s);
                    }
	                case "PSObject"    :
                    {
                        return ConvertObject(obj);
                    }
	                case "Int"         :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertString(s);
                    }
	                case "Object[]"    :
                    {
                        return null;
                    }
                    default            :
                    {
                        return null;
                    }
                }
            }
            public string DetermineType(object value)
            {
                // String
                if (value == null || value is string)
                    return "String";

                // Hashtable
                if (value is Hashtable)
                    return "Hashtable";

                // ScriptBlock
                if (value is System.Management.Automation.ScriptBlock)
                    return "ScriptBlock";

                // PSObject (but not Hashtable)
                if (value is System.Management.Automation.PSObject && value.GetType().Name != "Hashtable")
                    return "PSObject";

                // Numeric primitives
                if (value is int || value is double || value is decimal)
                    return "Int";

                // Array
                if (value is IEnumerable)
                    return "Object[]";

                // Fallback: CLR type name
                return value.GetType().Name;
            }
            public int GetMaxLength(IEnumerable list)
            {
                int buffer = 0;

                foreach (object obj in list)
                {
                    string s = (obj == null) ? "" : obj.ToString();

                    if (s.Length > buffer)
                        buffer = s.Length;
                }

                return buffer;
            }
            public void BuildInput(object[] inputObject)
            {
                Input = new List<InputItem>();

                foreach (object obj in inputObject)
                {
                    string    type = DetermineType(obj);

                    if (type != "Object[]")
                    {
                        string[] lines = ConvertByType(type, obj);

                        InputItem item = new InputItem((uint)Input.Count, type);

                        InputContainer container = new InputContainer(item.Index, 0, type, lines);

                        item.Output.Add(container);

                        Input.Add(item);
                    }
                    else
                    {
                        IEnumerable enumerable = (IEnumerable)obj;

                        InputItem item = new InputItem((uint)Input.Count, "Object[]");

                        foreach (object element in enumerable)
                        {
                            string etype = DetermineType(element);
                            string[] lines = ConvertByType(etype, element);

                            InputContainer container = new InputContainer(item.Index, (uint)item.Output.Count, etype, lines);

                            item.Output.Add(container);
                        }

                        Input.Add(item);
                    }
                }
            }
            public void BuildOutput()
            {
                Output = new List<InputLine>();

                for (int i = 0; i < Input.Count; i++)
                {
                    InputItem item = Input[i];

                    for (int c = 0; c < item.Output.Count; c++)
                    {
                        InputContainer container = item.Output[c];

                        // Emit all lines in this container
                        for (int l = 0; l < container.Line.Count; l++)
                        {
                            Output.Add(container.Line[l]);
                        }

                        // Padding between containers (Rule 3)
                        if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                        {
                            if (c < item.Output.Count - 1)
                            {
                                Output.Add(new InputLine((uint)Output.Count, item.Index, (uint)c, ""));
                            }
                        }
                    }

                    // Padding between items (Rule 4)
                    if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                    {
                        if (i < Input.Count - 1)
                        {
                            Output.Add(new InputLine((uint)Output.Count, item.Index, 0, ""));
                        }
                    }
                }

                Height = (uint)Output.Count;

                if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                {
                    if (Height > 1)
                    {
                        Type = TemplateType.Section;
                    }
                    else
                    {
                        string line = (Output.Count > 0) ? Output[0].ToString() : "";
                        Regex    rx = new Regex(@"^(\w+)\s(\[(\+|-|~|!)\])\s(.+)");
                        Match    mx = rx.Match(line);
                    
                        if (mx.Success)
                        {
                            Type = TemplateType.Action;
                        }
                        else
                        {
                            Type = TemplateType.Function;
                        }
                    }
                    
                    for (int i = 0; i < Output.Count; i ++)
                    {
                        Output[i].Index = (uint)i;
                    }
                }
            }
        }

        public class TemplateSlice
        {
            public uint       Rank;
            public string     Text;
            public uint? Foreground = null;
            public uint? Background = null;
            public bool      Locked = false;
            public TemplateSlice(uint rank, string text)
            {
                Rank       = rank;
                Text       = text;
            }
            public TemplateSlice(uint rank, string text, uint foreground, uint background)
            {
                Rank       = rank;
                Text       = text;
                Foreground = foreground;
                Background = background;
            }
        }

        public enum TemplateType
        {
            Function = 0,
            Action   = 1,
            Section  = 2,
            Table    = 3,
            Banner   = 4,
            Flag     = 5,
            General  = 6,
        }

        public enum TemplateTrackType
        {
            Template = 0,
            Single   = 1,
            Title    = 2,
            Body     = 3,
            Prompt   = 4,
        }
        
        public class TemplatePalette
        {
            public uint   Index;
            public uint[] Value;
            public TemplatePalette(uint index, uint[] value)
            {
                Index = index;
                Value = value;
            }
            public override string ToString()
            {
                return string.Format("({0}) {{{1},{2},{3},{4}}}", Index, Value[0], Value[1], Value[2], Value[3]);
            }
        }

        public class TemplateFace
        {
            public uint    Index;
            public string String;
            public char[]  Value;
            public uint[]  Bytes;
            public string    Hex;
            public TemplateFace(uint index, string hex)
            {
                Index = index;
                Hex   = hex;

                // Convert hex pairs into uint bytes
                Bytes = new uint[4];
                int b = 0;

                for (int i = 0; i < 8; i += 2)
                {
                    string pair = hex.Substring(i, 2);
                    Bytes[b]    = System.Convert.ToUInt32(pair, 16);
                    b++;
                }

                // Convert bytes to chars
                Value = new char[Bytes.Length];
                for (int i = 0; i < Bytes.Length; i++)
                {
                    Value[i] = (char)Bytes[i];
                }

                // Build string from chars
                String = new string(Value);
            }
            public override string ToString()
            {
                return string.Format("({0}) {{{1}}}", Index, String);
            }
        }

        public class TemplateBytes
        {
            public string       Type;
            public string     String;
            public List<uint>  Bytes;
            public TemplateBytes(string type, string inputString)
            {
                Bytes = new List<uint>();

                // Tokenizer pattern (same as your PowerShell)
                string pattern = @"@\((?:\d+[;,]?)+\)\*\d+|\d+";
                MatchCollection mx = Regex.Matches(inputString, pattern);

                for (int i = 0; i < mx.Count; i ++)
                {
                    string token = mx[i].Value;

                    // CASE 1 — plain number
                    if (Regex.IsMatch(token, @"^\d+$"))
                    {
                        Bytes.Add(Convert.ToUInt32(token));
                        continue;
                    }

                    // CASE 2 — single-value repetition @(5)*2
                    if (Regex.IsMatch(token, @"^@\(\d+\)\*\d+$"))
                    {
                        // Remove @( and ) then split on *
                        string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                        string[] split = cleaned.Split('*');

                        uint number = Convert.ToUInt32(split[0]);
                        uint factor = Convert.ToUInt32(split[1]);

                        for (uint x = 0; x < factor; x++)
                        {
                            Bytes.Add(number);
                        }

                        continue;
                    }

                    // CASE 3 — multi-value repetition @(8;9)*5
                    if (Regex.IsMatch(token, @"^@\(\d+[;,]\d+(?:[;,]\d+)*\)\*\d+$"))
                    {
                        string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                        string[] split = cleaned.Split('*');

                        // Split inner values on ; or ,
                        string[] range = Regex.Split(split[0], "[;,]");
                        uint factor = Convert.ToUInt32(split[1]);

                        for (uint x = 0; x < factor; x++)
                        {
                            for (int r = 0; r < range.Length; r++)
                            {
                                Bytes.Add(Convert.ToUInt32(range[r]));
                            }
                        }

                        continue;
                    }
                }
            }
            public override string ToString()
            {
                return "<FightingEntropy.Theme.TemplateBytes>";
            }
        }

        public class TemplateBlock
        {
            public uint        Index;
            public uint        Track;
            public uint         Rank;
            public string       Text;
            public uint   Foreground;
            public uint   Background;
            public bool       Locked = false;
            public TemplateBlock(uint track, uint rank, string text, uint foreground, uint background)
            {
                Track      = track;
                Rank       = rank;
                Text       = text;
                Foreground = foreground;
                Background = background;
            }
            public void Update(TemplateSlice slice)
            {
                Text       = slice.Text;
                Foreground = slice.Foreground.HasValue ? slice.Foreground.Value : Foreground;
                Background = slice.Background.HasValue ? slice.Background.Value : Background;
            }
            public void Assign(string text, uint foreground, uint background)
            {
                Text       = text;
                Foreground = foreground;
                Background = background;
            }
            public void Lock()
            {
                if (Locked != true)
                {
                    Locked = true;
                }
            }
            public override string ToString()
            {
                return Text;
            }
        }

        public class TemplateTrack
        {
            public uint                  Index;
            public uint                   Rank;
            internal uint                Total;
            public TemplateTrackType      Type;
            internal TemplateBytes        Mask;
            internal TemplateBytes  Foreground;
            internal TemplateBytes  Background;
            public List<TemplateBlock>   Block;
            public TemplateTrack(uint index, uint rank, string mask, string foreground, string background)
            {
                Index      = index;
                Rank       = rank;

                SetType("Template");

                Mask       = new TemplateBytes("Mask",mask);
                Foreground = new TemplateBytes("Foreground",foreground);
                Background = new TemplateBytes("Background",background);

                Clear();
            }
            public void SetType(string type)
            {
                switch (type)
                {
                    case "Template" : Type = TemplateTrackType.Template ; break;
                    case "Single"   : Type = TemplateTrackType.Single   ; break;
                    case "Title"    : Type = TemplateTrackType.Title    ; break;
                    case "Body"     : Type = TemplateTrackType.Body     ; break;
                    case "Prompt"   : Type = TemplateTrackType.Prompt   ; break;
                }
            }
            public string Draft()
            {
                int     width = (int)Total.ToString().Length;
                if (width < 2)
                {
                    width = 2;
                }

                string    rank = " " +  Rank.ToString("D" + width) + " ";
                string[] track = new string[30];

                for (int i = 0; i < 30; i++)
                {
                    track[i] = Block[i].Text;
                }

                return string.Format("|{0}|{1}|", rank, string.Join("|", track));
            }
            public string Text()
            {
                string[] track = new string[30];

                for (int i = 0; i < 30; i++)
                {
                    track[i] = Block[i].Text;
                }

                return string.Join("", track);
            }
            public uint[] GetBytes(string type)
            {
                switch (type)
                {
                    case "Mask"       : return Mask.Bytes.ToArray();
                    case "Foreground" : return Foreground.Bytes.ToArray();
                    case "Background" : return Background.Bytes.ToArray(); 
                    default           : return null;
                }
            }
            public uint[] GetForeground()
            {
                List<uint> list = new List<uint>();

                for (int i = 0; i < Block.Count; i++)
                {
                    list.Add((uint)Block[i].Foreground);
                }

                return list.ToArray();
            }
            public uint[] GetBackground()
            {
                List<uint> list = new List<uint>();

                for (int i = 0; i < Block.Count; i++)
                {
                    list.Add((uint)Block[i].Background);
                }

                return list.ToArray();
            }
            public void Lock(string line)
            {
                List<uint> list = new List<uint>();
                string[]  parts = line.Split(';');

                foreach (string item in parts)
                {
                    string[] split = item.Split('-');

                    if (split.Length > 1)
                    {
                        uint start = UInt32.Parse(split[0]);
                        uint end   = UInt32.Parse(split[1]);

                        uint x = start;
                        while (x <= end)
                        {
                            list.Add(x);
                            x++;
                        }
                    }
                    else
                    {
                        // Single number: "14"
                        list.Add(UInt32.Parse(item));
                    }
                }

                for (int i = 0; i < list.Count; i++)
                {
                    Block[(int)list[i]].Lock();
                }
            }
            public void Clear()
            {
                Block = new List<TemplateBlock>();
            }
        }

        public class TemplateDraft
		{
			public char[]      Face;
			public string RowHeader;
			public uint     Padding;
			public uint    MaxIndex;
			public int        Width;
            public TemplateDraft(List<TemplateTrack> tracks)
            {
                Face    = new char[] { '_', '¯','=' };

                Stage(tracks);
            }
            private void Stage(List<TemplateTrack> tracks)
            {
                MaxIndex = 0;

                for (int i = 0; i < tracks.Count; i++)
                {
                    if (tracks[i].Index > MaxIndex)
                        MaxIndex = tracks[i].Index;
                }

                Width    = MaxIndex.ToString().Length;

                if (Width <= 2)
                {
                    Width     = 2;
                    RowHeader = "|Line|Rank|";
                    Padding   = 161;
                }
                else if (Width == 3)
                {
                    RowHeader = "| Line|Rank|";
                    Padding   = 162;
                }
                else if (Width == 4)
                {
                    RowHeader = "| Line |Rank|";
                    Padding   = 163;
                }
            }
            public string Ruler(int slot)
            {
                string[] columns = new string[30];
                string    header;

                if (slot != 2)
                {
                    header = RowHeader;

                    for (int i = 0; i < 30; i++)
                    {
                        string s = i.ToString();
                        if (s.Length < 2)
                            s = Face[slot] + s;

                        columns[i] = Face[slot] + s + Face[slot];
                    }
                }
                else
                {
                    header = "|" + new string(Face[slot], RowHeader.Length - 2) + "|";

                    for (int i = 0; i < 30; i++)
                    {
                        columns[i] = "====";
                    }
                }

                return header + string.Join("|", columns) + "|";
            }
            public string Build(string name)
            {
                switch (name)
                {
                    case "HeaderFrame":
                    {
                        return new string(Face[0], (int)Padding);
                    }
                    case "HeaderRuler":
                    {
                        return Ruler(0);
                    }
                    case "Partition"  :
                    {
                        return Ruler(2);
                    }
                    case "FooterRuler":
                    {
                        return Ruler(1);
                    }
                    case "FooterFrame":
                    {
                        return new string(Face[1], (int)Padding);
                    }
                    default :
                    {
                        return null;
                    }
                }
            }
		}

        public class Controller
        {
            public TemplateType         Type;
            public TemplatePalette   Palette;
            public List<TemplateFace>   Face;
            public InputObject            IO;
            public Guid                 Guid;
            public Format.ModDateTime   Time;
            public string              Title;
            public string             Prompt;
            public List<TemplateTrack> Track;
            public Controller()
            {
                Initialize();
                Populate();
            }
            public static Controller Banner()
            {
                // static instance [Banner], starts w/ Initialize() and Populate()
                Controller c = new Controller();

                c.Refresh(TemplateType.Banner, c.BannerText());
                c.Write();

                return c;
            }
            public static Controller Flag()
            {
                // static instance [Flag], starts w/ Initialize() and Populate()
                Controller c = new Controller();

                c.Refresh(TemplateType.Flag, c.FlagText());
                c.Write();

                return c;
            }
            public Controller(object inputObject)
            {
                Initialize();
                Populate();
                Refresh(new object[]{ inputObject });
            }
            public Controller(object inputObject, string title)
            {
                Initialize();
                Populate(title);
                Refresh(new object[]{ inputObject });
            }
            public Controller(object inputObject, string title, string prompt)
            {
                Initialize();
                Populate(title, prompt);
                Refresh(new object[]{ inputObject });
            }
            public Controller(uint palette, object inputObject)
            {
                Initialize(palette);
                Populate();
                Refresh(new object[]{ inputObject });
            }
            public Controller(uint palette, object inputObject, string title)
            {
                Initialize(palette);
                Populate(title);
                Refresh(new object[]{ inputObject });
            }
            public Controller(uint palette, object inputObject, string title, string prompt)
            {
                Initialize(palette);
                Populate(title, prompt);
                Refresh(new object[]{ inputObject });
            }
            public Controller(object[] inputObject)
            {
                Initialize();
                Populate();
                Refresh(inputObject);
            }
            public Controller(object[] inputObject, string title)
            {
                Initialize();
                Populate(title);
                Refresh(inputObject);
            }
            public Controller(object[] inputObject, string title, string prompt)
            {
                Initialize();
                Populate(title, prompt);
                Refresh(inputObject);
            }
            public Controller(uint palette, object[] inputObject)
            {
                Initialize(palette);
                Populate();
                Refresh(inputObject);
            }
            public Controller(uint palette, object[] inputObject, string title)
            {
                Initialize(palette);
                Populate(title);
                Refresh(inputObject);
            }
            public Controller(uint palette, object[] inputObject, string title, string prompt)
            {
                Initialize(palette);
                Populate(title, prompt);
                Refresh(inputObject);
            }
            private void Initialize()
            {
                SetPalette(0);
                SetFace();
            }
            private void Initialize(uint palette)
            {
                SetPalette(palette);
                SetFace();
            }
            private void Populate()
            {
                Guid     = System.Guid.NewGuid();
                Time     = new Format.ModDateTime(DateTime.Now);
                Title    = Time.DateString();
                Prompt   = "<Press enter to continue>";
            }
            private void Populate(string title)
            {
                Guid     = System.Guid.NewGuid();
                Time     = new Format.ModDateTime(DateTime.Now);
                Title    = title;
                Prompt   = "<Press enter to continue>"; 
            }
            private void Populate(string title, string prompt)
            {
                Guid     = System.Guid.NewGuid();
                Time     = new Format.ModDateTime(DateTime.Now);
                Title    = title;
                Prompt   = prompt; 
            }
            public void Refresh(object[] inputObject)
            {
                IO       = new InputObject(inputObject);
                SetType((uint)IO.Type);
                GenerateTemplate();
                Reset();
            }
            public void Refresh(TemplateType type, object[] inputObject)
            {
                IO       = new InputObject(type, inputObject);
                SetType((uint)IO.Type);

                if (Type == TemplateType.Function || Type == TemplateType.Action || Type == TemplateType.Section)
                {
                    GenerateTemplate();   
                }
                else if (Type == TemplateType.Banner)
                {
                    GenerateBanner();
                }
                else if (Type == TemplateType.Flag)
                {
                    GenerateFlag();
                }
                
                Reset();
            }
            public uint[] PaletteBytes(uint index)
            {
                uint[][] arrays = new uint[][]
                {
                    new uint[]{10,12,15,00}, new uint[]{12,04,15,00}, new uint[] {10,02,15,00}, // Default, R*/Error,   G*/Success
                    new uint[]{01,09,15,00}, new uint[]{03,11,15,00}, new uint[] {13,05,15,00}, // B*/Info, C*/Verbose, M*/Feminine
                    new uint[]{14,06,15,00}, new uint[]{00,08,15,00}, new uint[] {07,15,15,00}, // Y*/Warn, K*/Evil,    W*/Host
                    new uint[]{04,12,15,00}, new uint[]{12,12,15,00}, new uint[] {04,04,15,00}, // R!,      R+,         R-
                    new uint[]{02,10,15,00}, new uint[]{10,10,15,00}, new uint[] {02,02,15,00}, // G!,      G+,         G-
                    new uint[]{09,01,15,00}, new uint[]{09,09,15,00}, new uint[] {01,01,15,00}, // B!,      B+,         B-
                    new uint[]{11,03,15,00}, new uint[]{11,11,15,00}, new uint[] {03,03,15,00}, // C!,      C+,         C-
                    new uint[]{05,13,15,00}, new uint[]{13,13,15,00}, new uint[] {05,05,15,00}, // M!,      M+,         M-
                    new uint[]{06,14,15,00}, new uint[]{14,14,15,00}, new uint[] {06,06,15,00}, // Y!,      Y+,         Y-
                    new uint[]{08,00,15,00}, new uint[]{08,08,15,00}, new uint[] {00,00,15,00}, // K!,      K+,         K-
                    new uint[]{15,07,15,00}, new uint[]{15,15,15,00}, new uint[] {07,07,15,00}, // W!,      W+,         W-
                    new uint[]{11,06,15,00}, new uint[]{06,11,15,00}, new uint[] {11,12,15,00}  // Steel*,  Steel!,     C+R+
                };

                return arrays[(uint)index];
            }
            public void SetPalette(uint index)
            {
                if (index > 35)
                {
                    throw new System.Exception("Invalid palette [" + index + "]");
                }

                Palette = new TemplatePalette(index, PaletteBytes((uint)index));
            }
            public void SetType(uint type)
            {
                if (type > 5)
                {
                    throw new Exception("Invalid type [" + type + "]");
                }

                switch (type)
                {
                    case 0 : Type = TemplateType.Function ; break;
                    case 1 : Type = TemplateType.Action   ; break;
                    case 2 : Type = TemplateType.Section  ; break;
                    case 3 : Type = TemplateType.Table    ; break;
                    case 4 : Type = TemplateType.Banner   ; break;
                    case 5 : Type = TemplateType.Flag     ; break;
                }
            }
            public string[] FaceHex()
            {
                return new string[]
                {
                    "20202020","5F5F5F5F","AFAFAFAF","2D2D2D2D","2020202F","5C202020",
                    "2020205C","2F202020","5C5F5F2F","2FAFAF5C","2FAFAFAF","AFAFAF5C",
                    "5C5F5F5F","5F5F5F2F","5B205F5F","5F5F205D","2A202020","20202A20",
                    "2020202A","202A2020","5B3D3D5D","5B2D2D5D","AFAFAF5D","5BAFAFAF",
                    "2020205D","5B5F5F5F","5F5F5F5D","5C5F5F5B","205F5F5F","5F5F5F20",
                    "5D5F5F2F","2FAFAF5B","5D202020"
                };
            }
            public void SetFace()
            {
                string[] faceHex = FaceHex();

                Face = new List<TemplateFace>();

                for (uint x = 0; x < faceHex.Length; x++)
                {
                    TemplateFace item = new TemplateFace(x,faceHex[x]);
                    Face.Add(item);
                }
            }
            public string[] TemplateMask()
            {
                string[] input = new string[17];
                
                input[00] = "0;1;@(0)*25;1;1;0";             // 00
                input[01] = "4;9;12;@(1)*23;13;9;8;7";       // 01
                input[02] = "6;8;10;@(2)*23;11;8;10;0";      // 02
                input[03] = "0;11;27;28;@(1)*22;30;10;0;0";  // 03
                input[04] = "0;0;@(2)*25;0;0;0";             // 04
                input[05] = "0;1;0;@(1)*25;0;0";             // 05
                input[06] = "4;9;8;10;@(2)*23;11;12;0";      // 06
                input[07] = "6;8;10;28;@(0)*23;13;9;5";      // 07
                input[08] = "0;11;12;@(1)*23;13;9;8;7";      // 08
                input[09] = "0;0;@(2)*25;0;2;0";             // 09
                input[10] = "6;8;10;@(2)*23;11;8;9;5";       // 10
                input[11] = "4;9;27;28;@(1)*21;29;30;9;8;7"; // 11
                input[12] = "6;8;10;@(2)*24;0;11;5";         // 12
                input[13] = "4;10;@(0)*26;4;7";              // 13
                input[14] = "6;5;@(0)*26;6;5";               // 14
                input[15] = "6;12;@(0)*25;13;9;5";           // 15
                input[16] = "4;9;12;@(1)*23;13;10;13;7";     // 16

                return input;
            }
            public string[] TemplateForeground()
            {
                string[] input = new string[17];

                input[00] = "@(0)*30";               // 00
                input[01] = "0;1;@(0)*25;1;1;0";     // 01
                input[02] = "0;1;@(1)*25;1;0;0";     // 02
                input[03] = "0;0;1;@(2)*23;1;0;0;0"; // 03
                input[04] = "@(0)*30";               // 04
                input[05] = "@(0)*30";               // 05
                input[06] = "0;1;0;@(1)*25;0;0";     // 06
                input[07] = "0;1;1;@(2)*24;1;1;0";   // 07
                input[08] = "0;0;@(1)*25;0;1;0";     // 08
                input[09] = "@(0)*30";               // 09
                input[10] = "0;@(1)*28;0";           // 10
                input[11] = "0;1;1;@(2)*23;1;0;1;0"; // 11
                input[12] = "0;1;@(0)*26;0;0";       // 12
                input[13] = "@(0)*30";               // 13
                input[14] = "0;0;@(2)*26;0;0";       // 14
                input[15] = "@(0)*28;1;0";           // 15
                input[16] = "0;1;@(0)*25;1;1;0";     // 16
                
                return input;
            }
            public string[] TemplateBackground()
            {
                string[] input = new string[17];

                input[00] = "@(3)*30"; // 00
                input[01] = "@(3)*30"; // 01
                input[02] = "@(3)*30"; // 02
                input[03] = "@(3)*30"; // 03
                input[04] = "@(3)*30"; // 04
                input[05] = "@(3)*30"; // 05
                input[06] = "@(3)*30"; // 06
                input[07] = "@(3)*30"; // 07
                input[08] = "@(3)*30"; // 08
                input[09] = "@(3)*30"; // 09
                input[10] = "@(3)*30"; // 10
                input[11] = "@(3)*30"; // 11
                input[12] = "@(3)*30"; // 12
                input[13] = "@(3)*30"; // 13
                input[14] = "@(3)*30"; // 14
                input[15] = "@(3)*30"; // 15
                input[16] = "@(3)*30"; // 16

                return input;
            }
            public string[] BannerText()
            {
                string[] input = new string[8];

                input[00] = "       Secure Digits Plus LLC (π)       "; // 09
                input[01] = "       --------------------------       "; // 10
                input[02] = "Dynamically Engineered Digital Security "; // 11
                input[03] = "--------------------------------------- "; // 12
                input[04] = "Application Development - Virtualization"; // 13
                input[05] = "----------------------------------------"; // 14
                input[06] = "    Network & Hardware Magistration     "; // 15
                input[07] = "    -------------------------------     "; // 16

                return input;
            }
            public string[] BannerMask()
            {
                string[] input = new string[25];

                input[00] = "0;1;@(0)*25;1;1;0";                         // 00
                input[01] = "4;9;12;@(1)*23;13;9;8;7";                   // 01
                input[02] = "6;8;10;@(2)*23;11;8;9;5";                   // 02
                input[03] = "4;9;27;28;@(1)*21;29;30;9;8;7";             // 03
                input[04] = "6;8;10;@(2)*24;0;11;5";                     // 04
                input[05] = "4;10;@(0)*26;4;7";                          // 05
                input[06] = "6;5;0;0;@(1)*22;0;0;6;5";                   // 06
                input[07] = "4;7;0;13;@(9;8)*5;10;11;@(8;9)*5;12;0;4;7"; // 07
                input[08] = "6;5;4;9;8;9;8;10;@(2)*14;11;8;9;8;9;5;6;5"; // 08
                input[09] = "4;7;6;8;9;8;10;@(0)*16;11;8;9;8;7;4;7";     // 09
                input[10] = "6;5;4;9;8;10;@(0)*18;11;8;9;5;6;5";         // 10
                input[11] = "4;7;6;8;9;5;@(0)*18;4;9;8;7;4;7";           // 11
                input[12] = "6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5";           // 12
                input[13] = "4;7;6;8;9;5;@(0)*18;4;9;8;7;4;7";           // 13
                input[14] = "6;5;4;9;8;7;@(0)*18;6;8;9;5;6;5";           // 14
                input[15] = "4;7;6;8;9;12;@(0)*18;13;9;8;7;4;7";         // 15
                input[16] = "6;5;4;9;8;9;12;@(0)*16;13;9;8;9;5;6;5";     // 16
                input[17] = "4;7;6;8;9;8;9;12;@(1)*14;13;9;8;9;8;7;4;7"; // 17
                input[18] = "6;5;0;11;@(8;9)*5;12;13;@(9;8)*5;10;0;6;5"; // 18
                input[19] = "4;7;0;0;@(2)*22;0;0;13;7";                  // 19
                input[20] = "6;12;@(0)*25;13;9;5";                       // 20
                input[21] = "4;9;12;@(1)*23;13;9;8;7";                   // 21
                input[22] = "6;8;10;@(2)*23;11;8;10;0";                  // 22
                input[23] = "0;11;27;28;@(1)*21;29;30;10;0;0";           // 23
                input[24] = "0;0;@(2)*25;0;0;0";                         // 24

                return input;
            }
            public string[] BannerForeground()
            {
                string[] input = new string[25];

                input[00] = "@(0)*30;";                                // 00
                input[01] = "0;1;@(0)*25;1;1;0";                       // 01
                input[02] = "0;@(1)*28;0";                             // 02
                input[03] = "0;1;1;@(2)*23;1;0;1;0";                   // 03
                input[04] = "0;1;@(0)*28;";                            // 04
                input[05] = "@(0)*30;";                                // 05
                input[06] = "@(0)*30;";                                // 06
                input[07] = "@(0)*4;@(1)*22;@(0)*4;";                  // 07
                input[08] = "@(0)*3;@(1)*4;@(0)*16;@(1)*4;@(0)*3";     // 08
                input[09] = "@(0)*3;@(1)*3;0;@(2)*16;0;@(1)*3;@(0)*3"; // 09
                input[10] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 10
                input[11] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 11
                input[12] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 12
                input[13] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 13
                input[14] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 14
                input[15] = "@(0)*3;@(1)*2;0;@(2)*18;0;@(1)*2;@(0)*3"; // 15
                input[16] = "@(0)*3;@(1)*3;0;@(2)*16;0;@(1)*3;@(0)*3"; // 16
                input[17] = "@(0)*3;@(1)*4;@(0)*16;@(1)*4;@(0)*3";     // 17
                input[18] = "@(0)*4;@(1)*22;@(0)*4";                   // 18
                input[19] = "@(0)*30";                                 // 19
                input[20] = "@(0)*28;1;0";                             // 20
                input[21] = "0;1;@(0)*25;1;1;0";                       // 21
                input[22] = "0;@(1)*27;0;0";                           // 22
                input[23] = "0;0;1;@(2)*23;1;0;0;0";                   // 23
                input[24] = "@(0)*30";                                 // 24

                return input;
            }
            public string[] BannerBackground()
            {
                string[] input = new string[25];

                input[00] = "@(3)*30"; // 00
                input[01] = "@(3)*30"; // 01
                input[02] = "@(3)*30"; // 02
                input[03] = "@(3)*30"; // 03
                input[04] = "@(3)*30"; // 04
                input[05] = "@(3)*30"; // 05
                input[06] = "@(3)*30"; // 06
                input[07] = "@(3)*30"; // 07
                input[08] = "@(3)*30"; // 08
                input[09] = "@(3)*30"; // 09
                input[10] = "@(3)*30"; // 10
                input[11] = "@(3)*30"; // 11
                input[12] = "@(3)*30"; // 12
                input[13] = "@(3)*30"; // 13
                input[14] = "@(3)*30"; // 14
                input[15] = "@(3)*30"; // 15
                input[16] = "@(3)*30"; // 16
                input[17] = "@(3)*30"; // 17
                input[18] = "@(3)*30"; // 18
                input[19] = "@(3)*30"; // 19
                input[20] = "@(3)*30"; // 20
                input[21] = "@(3)*30"; // 21
                input[22] = "@(3)*30"; // 22
                input[23] = "@(3)*30"; // 23
                input[24] = "@(3)*30"; // 24

                return input;
            }
            public string[] FlagText()
            {
                string    date = DateTime.Now.ToString("MM/dd/yyyy");
                string[] input = new string[12];

                input[00] = "[==[ Dynamically Engineered Digital Security ]_/"; // 10
                input[01] = "[_[ Application Development - Virtualization ]_/"; // 14
                input[02] = "[=====[ Network & Hardware Magistration ]======/"; // 18
                input[03] = "/ ____________________ \\";                        // 24
                input[04] = "\\ [FightingEntropy(π)] /";                        // 25
                input[05] = "/ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \\";                        // 26
                input[06] = "\\     ____________     /";                        // 27
                input[07] = "/     [" + date + "]     \\";                      // 28
                input[08] = "\\     ¯¯¯¯¯¯¯¯¯¯¯¯     /";                        // 29
                input[09] = "/ ____________________ \\";                        // 30
                input[10] = "\\ [Michael C Cook Sr.] /";                        // 31
                input[11] = "/ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \\";                        // 32

                return input;
            }
            public string[] FlagMask()
            {
                string[] input = new string[39];

                input[00] = "0;1;@(0)*25;1;1;0";                                              // 00
                input[01] = "4;9;12;@(1)*23;13;9;8;7";                                        // 01
                input[02] = "6;8;10;@(2)*23;11;8;9;5";                                        // 02
                input[03] = "4;9;27;28;@(1)*21;29;30;9;8;7";                                  // 03
                input[04] = "6;8;10;@(2)*24;0;11;5";                                          // 04
                input[05] = "4;10;@(0)*26;4;7";                                               // 05
                input[06] = "6;5;0;0;@(1)*22;0;0;6;5";                                        // 06
                input[07] = "4;7;0;4;10;@(2)*8;22;23;@(2)*10;11;5;0;4;7";                     // 07
                input[08] = "6;5;0;6;5;16;17;0;16;17;0;16;17;24;25;@(1)*10;13;7;0;6;5";       // 08
                input[09] = "4;7;0;4;7;18;0;19;18;0;19;18;0;24;23;@(2)*10;11;5;0;4;7";        // 09
                input[10] = "6;5;0;6;5;@(0)*8;24;25;@(1)*10;13;7;0;6;5";                      // 10
                input[11] = "4;7;0;4;7;16;17;0;16;17;0;16;17;24;23;@(2)*10;11;5;0;4;7";       // 11
                input[12] = "6;5;0;6;5;18;0;19;18;0;19;18;0;24;25;@(1)*10;13;7;0;6;5";        // 12
                input[13] = "4;7;0;4;7;@(0)*8;24;23;@(2)*10;11;5;0;4;7";                      // 13
                input[14] = "6;5;0;6;5;16;17;0;16;17;0;16;17;24;25;@(1)*10;13;7;0;6;5";       // 14
                input[15] = "4;7;0;4;7;18;0;19;18;0;19;18;0;24;23;@(2)*10;11;5;0;4;7";        // 15
                input[16] = "6;5;0;6;5;@(0)*8;24;25;@(1)*10;13;7;0;6;5";                      // 16
                input[17] = "4;7;0;4;7;16;17;0;16;17;0;16;17;24;23;@(2)*10;11;5;0;4;7";       // 17
                input[18] = "6;5;0;6;5;18;0;19;18;0;19;18;0;24;25;@(1)*10;13;7;0;6;5";        // 18
                input[19] = "4;7;0;4;7;16;17;0;16;17;0;16;17;24;23;@(2)*10;11;5;0;4;7";       // 19
                input[20] = "6;5;0;6;12;@(1)*8;26;25;@(1)*10;13;7;0;6;5";                     // 20
                input[21] = "4;7;0;4;10;@(2)*8;9;2;2;9;@(2)*8;11;5;0;4;7";                    // 21
                input[22] = "6;5;0;6;12;@(1)*7;9;8;20;20;8;9;@(1)*7;13;7;0;6;5";              // 22
                input[23] = "4;7;0;4;10;@(2)*6;9;8;10;2;2;11;8;9;@(2)*6;11;5;0;4;7";          // 23
                input[24] = "6;5;0;6;12;@(1)*6;8;@(0)*6;8;@(1)*6;13;7;0;6;5";                 // 24
                input[25] = "4;7;0;4;10;@(2)*6;9;@(0)*6;9;@(2)*6;11;5;0;4;7";                 // 25
                input[26] = "6;5;0;6;12;@(1)*5;9;8;@(0)*6;8;9;@(1)*5;13;7;0;6;5";             // 26
                input[27] = "4;7;0;4;10;2;2;2;2;9;8;9;@(0)*6;9;8;9;2;2;2;2;11;5;0;4;7";       // 27
                input[28] = "6;5;0;6;12;1;1;1;9;8;9;8;@(0)*6;8;9;8;9;1;1;1;13;7;0;6;5";       // 28
                input[29] = "4;7;0;4;10;2;2;9;8;9;8;9;@(0)*6;9;8;9;8;9;2;2;11;5;0;4;7";       // 29
                input[30] = "6;5;0;6;12;1;1;8;9;8;20;8;@(0)*6;8;20;8;9;8;1;1;13;7;0;6;5";     // 30
                input[31] = "4;7;0;4;10;2;2;9;8;10;2;11;@(2)*6;10;2;11;8;9;2;2;11;5;0;4;7";   // 31
                input[32] = "6;5;0;6;12;1;1;8;20;12;1;13;@(0)*6;12;1;13;20;8;1;1;13;7;0;6;5"; // 32
                input[33] = "4;7;0;0;@(2)*8;12;1;1;1;1;13;@(2)*8;0;0;13;7";                   // 33
                input[34] = "6;12;@(0)*25;13;9;5";                                            // 34
                input[35] = "4;9;12;@(1)*23;13;9;8;7";                                        // 35
                input[36] = "6;8;10;@(2)*23;11;8;10;0";                                       // 36
                input[37] = "0;11;27;28;@(1)*21;29;30;10;0;0";                                // 37
                input[38] = "0;0;@(2)*25;0;0;0";                                              // 38

                return input;
            }
            public string[] FlagForeground()
            {
                string[] input = new string[39];

                input[00] = "@(0)*30";                                                   // 00
                input[01] = "0;1;@(0)*25;1;1;0";                                         // 01
                input[02] = "0;@(1)*28;0";                                               // 02
                input[03] = "0;1;1;@(2)*23;1;0;1;0";                                     // 03
                input[04] = "0;1;@(0)*28";                                               // 04
                input[05] = "@(0)*30";                                                   // 05
                input[06] = "0;0;0;@(2)*24;@(0)*3";                                      // 06
                input[07] = "@(0)*3;@(2)*24;@(0)*3";                                     // 07
                input[08] = "@(0)*3;2;@(3)*8;@(2)*15;@(0)*3";                            // 08
                input[09] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 09
                input[10] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 10
                input[11] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 11
                input[12] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 12
                input[13] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 13
                input[14] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 14
                input[15] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 15
                input[16] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 16
                input[17] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 17
                input[18] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 18
                input[19] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 19
                input[20] = "@(0)*3;2;@(15)*8;@(0)*14;2;@(0)*3";                         // 20
                input[21] = "0;0;0;@(2)*10;0;2;2;0;@(2)*10;0;0;0";                       // 21
                input[22] = "@(0)*3;@(2)*9;@(0)*6;@(2)*9;@(0)*3";                        // 22
                input[23] = "@(0)*3;@(2)*8;0;0;@(2)*4;0;0;@(2)*8;@(0)*3";                // 23
                input[24] = "@(0)*3;@(2)*8;0;@(2)*6;0;@(2)*8;@(0)*3";                    // 24
                input[25] = "@(0)*3;@(2)*8;0;@(2)*6;0;@(2)*8;@(0)*3";                    // 25
                input[26] = "@(0)*3;@(2)*7;0;0;@(2)*6;0;0;@(2)*7;@(0)*3";                // 26
                input[27] = "@(0)*3;@(2)*6;0;0;1;@(2)*6;1;0;0;@(2)*6;@(0)*3";            // 27
                input[28] = "@(0)*3;@(2)*5;0;0;1;1;@(2)*6;1;1;0;0;@(2)*5;@(0)*3";        // 28
                input[29] = "@(0)*3;@(2)*4;0;0;1;1;0;@(2)*6;0;1;1;0;0;@(2)*4;@(0)*3";    // 29
                input[30] = "@(0)*3;@(2)*4;0;1;1;1;0;@(2)*6;0;1;1;1;0;@(2)*4;@(0)*3";    // 30
                input[31] = "@(0)*3;@(2)*4;0;1;@(0)*3;@(2)*6);@(0)*3;1;0;@(2)*4;@(0)*3"; // 31
                input[32] = "@(0)*3;@(2)*4;0;1;@(0)*3;@(2)*6);@(0)*3;1;0;@(2)*4;@(0)*3"; // 32
                input[33] = "@(0)*3;@(2)*9;@(2)*6;@(2)*9;@(0)*3";                        // 33
                input[34] = "@(0)*28;1;0";                                               // 34
                input[35] = "0;1;@(0)*25;1;1;0";                                         // 35
                input[36] = "0;@(1)*27;0;0";                                             // 36
                input[37] = "0;0;1;@(2)*23;1;0;0;0";                                     // 37
                input[38] = "@(0)*30";                                                   // 38
                
                return input;
            }
            public string[] FlagBackground()
            {
                string[] input = new string[39];
                
                input[00] = "@(3)*30";                                 // 00
                input[01] = "@(3)*30";                                 // 01
                input[02] = "@(3)*30";                                 // 02
                input[03] = "@(3)*30";                                 // 03
                input[04] = "@(3)*30";                                 // 04
                input[05] = "@(3)*30";                                 // 05
                input[06] = "@(3)*30";                                 // 06
                input[07] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 07
                input[08] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 08
                input[09] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 09
                input[10] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 10
                input[11] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 11
                input[12] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 12
                input[13] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 13
                input[14] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 14
                input[15] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 15
                input[16] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 16
                input[17] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 17
                input[18] = "@(3)*4;@(9)*10;@(15)*12;@(3)*4";          // 18
                input[19] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 19
                input[20] = "@(3)*4;@(9)*10;@(12)*12;@(3)*4";          // 20
                input[21] = "@(3)*4;@(15)*9;3;15;15;3;@(15)*9;@(3)*4"; // 21
                input[22] = "@(3)*4;@(15)*8;@(3)*6;@(15)*8;@(3)*4";    // 22
                input[23] = "@(3)*4;@(12)*7;@(3)*8;@(12)*7;@(3)*4";    // 23
                input[24] = "@(3)*4;@(12)*7;@(3)*8;@(12)*7;@(3)*4";    // 24
                input[25] = "@(3)*4;@(15)*7;@(3)*8;@(15)*7;@(3)*4";    // 25
                input[26] = "@(3)*4;@(15)*6;@(3)*10;@(15)*6;@(3)*4";   // 26
                input[27] = "@(3)*4;@(12)*5;@(3)*12;@(12)*5;@(3)*4";   // 27
                input[28] = "@(3)*4;@(12)*4;@(3)*14;@(12)*4;@(3)*4";   // 28
                input[29] = "@(3)*4;@(15)*3;@(3)*16;@(15)*3;@(3)*4";   // 29
                input[30] = "@(3)*4;@(15)*3;@(3)*16;@(15)*3;@(3)*4";   // 30
                input[31] = "@(3)*4;@(12)*3;@(3)*16;@(12)*3;@(3)*4";   // 31
                input[32] = "@(3)*4;@(12)*3;@(3)*16;@(12)*3;@(3)*4";   // 32
                input[33] = "@(3)*30";                                 // 33
                input[34] = "@(3)*30";                                 // 34
                input[35] = "@(3)*30";                                 // 35
                input[36] = "@(3)*30";                                 // 36
                input[37] = "@(3)*30";                                 // 37
                input[38] = "@(3)*30";                                 // 38

                return input;
            }
            public TemplateTrack BuildTrack(uint index, uint rank, string mask, string foreground, string background)
            {
                TemplateTrack track = new TemplateTrack(index, rank, mask, foreground, background);
                
                for (int x = 0; x < track.Mask.Bytes.Count; x++)
                {
                    string text = Face[(int)track.Mask.Bytes[x]].String;
                    uint   fore = track.Foreground.Bytes[x];
                    uint   back = track.Background.Bytes[x];
                
                    TemplateBlock block = new TemplateBlock(index, (uint)x, text, fore, back);
                
                    track.Block.Add(block);
                }

                return track;
            }
            public void GenerateTemplate()
            {
                Track         = new List<TemplateTrack>();

                string[] mask = TemplateMask();
                string[] fore = TemplateForeground();
                string[] back = TemplateBackground();

                uint    index = 0;

                switch (Type)
                {
                    case TemplateType.Function:
                    {
                        uint[] rankOrder = {0, 1, 2, 3, 4};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                            if (index == 3)
                            {
                                track.SetType("Single");
                            }

                            Track.Add(track);
                            index ++;
                        }
                        break;
                    }
                    case TemplateType.Action:
                    {
                        uint[] rankOrder = {5, 6, 7, 8, 9};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                            if (index == 2)
                            {
                                track.SetType("Single");
                            }

                            Track.Add(track);
                            index ++;
                        }
                        break;
                    }
                    case TemplateType.Section:
                    {
                        uint[] rankOrder = {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            if (rank != 14)
                            {
                                TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                                if (rank == 11)
                                {
                                    track.SetType("Title");
                                }
                                else if (rank == 3)
                                {
                                    track.SetType("Prompt");
                                }

                                Track.Add(track);
                                index ++;
                            }	
                            else
                            {
                                uint b = 0;
                                while (b < IO.Output.Count)
                                {
                                    TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                                    if (b % 2 == 1)
                                    {
                                        track.Block[ 0].Text = "   /";
                                        track.Block[ 1].Text = "/   ";
                                        track.Block[28].Text = "   /";
                                        track.Block[29].Text = "/   ";
                                    }

                                    track.SetType("Body");

                                    Track.Add(track);
                                    index ++;
                                    b ++;
                                }

                                if (b % 2 == 1)
                                {
                                    TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);
                                
                                    track.Block[0].Text  = "   /";
                                    track.Block[1].Text  = "/   ";
                                    track.Block[28].Text = "___/";
                                    track.Block[29].Text = "/   ";

                                    track.SetType("Body");

                                    Track.Add(track);
                                    index ++;
                                }
                                else
                                {
                                    Track[Track.Count - 1].Block[28].Text = "___/";
                                }
                            }
                        }
                        break;
                    }
                }

                SetTotal();
            }
            public void GenerateBanner()
            {
                Track         = new List<TemplateTrack>();

                string[] mask = BannerMask();
                string[] fore = BannerForeground();
                string[] back = BannerBackground();

                for (uint i = 0; i <= 24; i++)
                {
                    TemplateTrack track = BuildTrack(i, i, mask[i], fore[i], back[i]);

                    if (i == 3)
                    {
                        track.SetType("Title");
                    }
                    else if (i >= 9 && i <= 16)
                    {
                        track.SetType("Body");
                    }
                    else if (i == 23)
                    {
                        track.SetType("Prompt");
                    }
                
                    Track.Add(track);
                }

                SetTotal();
            }
            public void GenerateFlag()
            {
                string[] lstr = new string[8];

                lstr[0] = "4-25";
                lstr[1] = "4-12;14;15;17-25";
                lstr[2] = "4-11;18-25";
                lstr[3] = "4-10;19-25";
                lstr[4] = "4-9;20-25";
                lstr[5] = "4-8;21-25";
                lstr[6] = "4-7;22-25";
                lstr[7] = "4-6;23-25";

                Track         = new List<TemplateTrack>();

                string[] mask = FlagMask();
                string[] fore = FlagForeground();
                string[] back = FlagBackground();

                for (uint i = 0; i <= 38; i++)
                {                
                    TemplateTrack track = BuildTrack(i, i, mask[i], fore[i], back[i]);
                
                    if (i == 3)
                    {
                        track.SetType("Title");
                    }
                    else if (i == 10 || i == 14 || i == 18 || (i >= 24 && i <= 32))
                    {
                        track.SetType("Body");
                    }
                    else if (i == 37)
                    {
                        track.SetType("Prompt");
                    }
                    
                    if (i >= 7 && i <= 20)       // 07-20 lstr[0];
                        track.Lock(lstr[0]);
                    else if (i == 21)            //    21 lstr[1];
                        track.Lock(lstr[1]);
                    else if (i == 22)            //    22 lstr[2];
                        track.Lock(lstr[2]);
                    else if (i >=23 && i <= 25)  // 23-25 lstr[3];
                        track.Lock(lstr[3]);
                    else if (i == 26)            //    26 lstr[4];
                        track.Lock(lstr[4]);
                    else if (i == 27)            //    27 lstr[5];
                        track.Lock(lstr[5]);
                    else if (i == 28)            //    28 lstr[6];
                        track.Lock(lstr[6]);
                    else if (i >= 29 && i <= 32) //    29 lstr[7];
                        track.Lock(lstr[7]);
                
                    Track.Add(track);
                }

                SetTotal();
            }
            public void SetTotal()
            {
                for (int x = 0; x < Track.Count; x++)
                {
                    Track[x].Total = (uint)Track.Count;
                }
            }
            public TemplateTrack[] GetTrackByType(TemplateTrackType type)
            {
                List<TemplateTrack> list = new List<TemplateTrack>();

                for (int i = 0; i < Track.Count; i++)
                {
                    if (Track[i].Type == type)
                    {
                        list.Add(Track[i]);
                    }
                }
                return list.ToArray();
            }
            public string PrepareString(string text)
            {
                if (text.Length == 0)
                {
                    text = "  ";
                }
                else if (text.Length == 1)
                {
                    text = " " + text;       
                }
                else if (text.Length > 90)
                {
                    text = text.Substring(0, 87) + "...";
                }

                // Pad the string on both sides with a space
                text = " " + text + " ";

                return text;
            }
            public List<TemplateSlice> GenerateSlices(string text, uint startRank, uint foreground, uint background)
            {
                List<TemplateSlice> slices = new List<TemplateSlice>();

                // Pad text to 4-char boundary
                int remainder = text.Length % 4;
                if (remainder > 0)
                {
                    text = text + new string(' ', 4 - remainder);
                }

                int sliceCount = text.Length / 4;
                int x = 0;

                while (x < sliceCount)
                {
                    string part = text.Substring(x * 4, 4);

                    TemplateSlice slice = new TemplateSlice((uint)(startRank + x), part, foreground, background);

                    slices.Add(slice);
                    x ++;
                }

                return slices;
            }
            public List<TemplateSlice> GenerateSlices(string text, uint startRank)
            {
                List<TemplateSlice> slices = new List<TemplateSlice>();

                // Pad text to 4-char boundary
                int remainder = text.Length % 4;
                if (remainder > 0)
                {
                    text = text + new string(' ', 4 - remainder);
                }

                int sliceCount = text.Length / 4;
                int x = 0;

                while (x < sliceCount)
                {
                    string part = text.Substring(x * 4, 4);

                    TemplateSlice slice = new TemplateSlice((uint)(startRank + x), part);

                    slices.Add(slice);
                    x ++;
                }

                return slices;
            }
            public void LineInsertion(string type, string inputText, int startColumn, TemplateTrack track)
            {
                switch (type)
                {
                    case "Function":
                    {
                        // Prepare input string
                        string text    = PrepareString(inputText);
                        
                        List<TemplateSlice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }

                        int index = startColumn + slices.Count;

                        if (index == 25)
                        {
                            track.Block[26].Assign("]__/",1,3);
                        }
                        else if (index < 25)
                        {
                            track.Block[index].Assign("]___",1,3);
                                
                            index ++;

                            while (index <= 25)
                            {
                                track.Block[index].Assign("____",1,3);
                                index ++;
                            }

                            track.Block[index].Assign("___/",1,3);
                        }

                        break;
                    }
                    case "Action":
                    {
                        string text;

                        if (Type != TemplateType.Section)
                        {
                            text   = PrepareString(inputText);        
                        }
                        else
                        {
                            text   = inputText;
                        }

                        List<TemplateSlice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }
                        break;
                    }
                    case "Banner":
                    {
                        List<TemplateSlice> slices = GenerateSlices(inputText, (uint)startColumn);

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }
                        break;
                    }
                    case "Flag":
                    {
                        List<TemplateSlice> slices = GenerateSlices(inputText, (uint)startColumn);   

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }
                        break;
                    }
                }
            }
            public void Reset()
            {
                List<TemplateTrack> track = new List<TemplateTrack>();

                switch (Type)
                {
                    case TemplateType.Function: // {0, 1, 2, 3, 4}
                    {
                        // Set single
                        track.AddRange(GetTrackByType(TemplateTrackType.Single));

                        LineInsertion("Function", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Action: // {5, 6, 7, 8, 9}
                    {
                        // Set single
                        track.AddRange(GetTrackByType(TemplateTrackType.Single));

                        LineInsertion("Action", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Section: // {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};
                    {
                        // Set title
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            LineInsertion("Action", IO.Output[x].ToString(), 3, track[x]);
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Banner:
                    {
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            LineInsertion("Banner", IO.Output[x].ToString(), 10, track[x]);
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Flag:
                    {
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            string line = IO.Output[x].ToString();
                            if (line.Length == 48)
                            {
                                LineInsertion("Flag", line, 14, track[x]);
                            }
                            else
                            {
                                LineInsertion("Flag", line, 12, track[x]);
                            }
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                }
            }
            public string Draft()
            {
                TemplateDraft draft = new TemplateDraft(Track);

                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                // Header
                sb.AppendLine(draft.Build("HeaderFrame"));
                sb.AppendLine(draft.Build("HeaderRuler"));

                // Tracks
                for (int i = 0; i < Track.Count; i++)
                {
                    TemplateTrack t = Track[i];

                    string index = t.Index.ToString("D" + draft.Width);

                    sb.AppendLine(string.Format("| {0} {1}", index, t.Draft()));
                }

                // Footer
                sb.AppendLine(draft.Build("FooterRuler"));
                sb.AppendLine(draft.Build("FooterFrame"));

                return sb.ToString();
            }
            static Controller()
            {
                if (System.Console.OutputEncoding != System.Text.Encoding.UTF8)
                {
                    System.Console.OutputEncoding = System.Text.Encoding.UTF8;   
                }
            }
            public void Write()
            {
                for (int t = 0; t < Track.Count; t++)
                {
                    TemplateTrack track = Track[t];

                    for (int b = 0; b < track.Block.Count; b++)
                    {
                        TemplateBlock block = track.Block[b];

                        int fg;
                        int bg;

                        if (!block.Locked)
                        {
                            // Palette lookup
                            fg = (int)Palette.Value[(int)block.Foreground];
                            bg = (int)Palette.Value[(int)block.Background];
                        }
                        else
                        {
                            // Raw values
                            fg = (int)block.Foreground;
                            bg = (int)block.Background;
                        }

                        System.Console.ForegroundColor = (ConsoleColor)fg;
                        System.Console.BackgroundColor = (ConsoleColor)bg;
                        System.Console.Write(block.Text);
                    }

                    System.Console.WriteLine();
                }

                System.Console.ResetColor();
            }
            public void WriteTrack(uint index)
            {
                TemplateTrack track = Track[(int)index];

                string head = string.Format("| {0:D2} | {1:D2} |", track.Index, track.Rank);
                System.Console.Write(head);

                for (int i = 0; i < track.Block.Count; i++)
                {
                    TemplateBlock block = track.Block[i];

                    int fg;
                    int bg;

                    if (!block.Locked)
                    {
                        // Palette lookup
                        fg = (int)Palette.Value[(int)block.Foreground];
                        bg = (int)Palette.Value[(int)block.Background];
                    }
                    else
                    {
                        // Raw values
                        fg = (int)block.Foreground;
                        bg = (int)block.Background;
                    }

                    System.Console.ForegroundColor = (ConsoleColor)fg;
                    System.Console.BackgroundColor = (ConsoleColor)bg;
                    System.Console.Write(block.Text);
                    System.Console.ResetColor();
                    System.Console.Write("|");
                }

                System.Console.WriteLine();
            }
            public void DevMode()
            {
                TemplateDraft draft = new TemplateDraft(Track);

                // Header
                System.Console.WriteLine(draft.Build("HeaderFrame"));
                System.Console.WriteLine(draft.Build("HeaderRuler"));

                // Tracks
                for (int i = 0; i < Track.Count; i++)
                {
                    TemplateTrack t = Track[i];

                    string index = t.Index.ToString("D" + draft.Width);
                    string rank  = t.Rank.ToString("D" + 2);

                    // Write the left-hand header for the track
                    System.Console.Write(string.Format("| {0} | {1} |", index, rank));

                    // Now render each block with color
                    for (int b = 0; b < t.Block.Count; b++)
                    {
                        TemplateBlock block = t.Block[b];

                        int fg;
                        int bg;

                        if (!block.Locked)
                        {
                            // Palette lookup
                            fg = (int)Palette.Value[(int)block.Foreground];
                            bg = (int)Palette.Value[(int)block.Background];
                        }
                        else
                        {
                            // Raw values
                            fg = (int)block.Foreground;
                            bg = (int)block.Background;
                        }

                        System.Console.ForegroundColor = (ConsoleColor)fg;
                        System.Console.BackgroundColor = (ConsoleColor)bg;

                        System.Console.Write(block.Text);

                        System.Console.ResetColor();
                        System.Console.Write("|");
                    }

                    System.Console.WriteLine(); // finish the console line
                }

                // Footer
                System.Console.WriteLine(draft.Build("FooterRuler"));
                System.Console.WriteLine(draft.Build("FooterFrame"));
            }
            public void DevMode(int slot)
            {
                TemplateDraft draft = new TemplateDraft(Track);

                // Header
                System.Console.WriteLine(draft.Build("HeaderFrame"));
                System.Console.WriteLine(draft.Build("HeaderRuler"));

                // Tracks
                TemplateTrack track = Track[slot];

                string index = track.Index.ToString("D" + draft.Width);
                string rank  = track.Rank.ToString("D" + 2);

                // Write the left-hand header for the track
                System.Console.Write(string.Format("| {0} | {1} |", index, rank));
                
                // Now render each block with color
                for (int b = 0; b < track.Block.Count; b++)
                {
                    TemplateBlock block = track.Block[b];
            
                    int fg;
                    int bg;

                    if (!block.Locked)
                    {
                        // Palette lookup
                        fg = (int)Palette.Value[(int)block.Foreground];
                        bg = (int)Palette.Value[(int)block.Background];
                    }
                    else
                    {
                        // Raw values
                        fg = (int)block.Foreground;
                        bg = (int)block.Background;
                    }
            
                    System.Console.ForegroundColor = (ConsoleColor)fg;
                    System.Console.BackgroundColor = (ConsoleColor)bg;
                    System.Console.Write(block.Text);
                    System.Console.ResetColor();
                    System.Console.Write("|");
                }

                System.Console.WriteLine(); // finish the console line

                // Divider line aligned with Draft.Padding
                System.Console.WriteLine(draft.Build("Partition"));

                // Mask row
                uint[] mask = track.GetBytes("Mask");
                System.Console.Write("|  Face:  |");
                for (int i = 0; i < mask.Length; i++)
                {
                    System.Console.Write(string.Format(" {0,2} |", mask[i]));
                }
                System.Console.WriteLine();

                // Foreground row
                uint[] fore = track.GetForeground();
                System.Console.Write("|  Fore:  |");
                for (int i = 0; i < fore.Length; i++)
                {
                    System.Console.Write(string.Format(" {0,2} |", fore[i]));
                }
                System.Console.WriteLine();

                // Background row
                uint[] back = track.GetBackground();
                System.Console.Write("|  Back:  |");
                for (int i = 0; i < back.Length; i++)
                {
                    System.Console.Write(string.Format(" {0,2} |", back[i]));
                }
                System.Console.WriteLine();

                // Footer
                System.Console.WriteLine(draft.Build("FooterRuler"));
                System.Console.WriteLine(draft.Build("FooterFrame"));
            }
            public string Text()
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                foreach (TemplateTrack track in Track)
                {
                    sb.AppendLine(track.Text());
                }

                return sb.ToString();
            }
        }
    }

    // Console classes deal with logging
    namespace Console
    {
        public class TimeSlot
        {
            public string       Name;
            public Format.ModDateTime? Time;
            public uint          Set;
            public TimeSlot(string name)
            {
                Name = name;
                Time = null;
                Set  = 0;
            }
            public void Toggle()
            {
                Time = DateTime.Now;
                Set  = 1;
            }
            public DateTime? AsDateTime
            { 
                get
                {
                    if (!Time.HasValue) 
                        return null; 
                        
                    return Time.Value.Value;
                }
            }
            public override string ToString()
            {
                if (Time.HasValue)
                    return Time.Value.ToString();

                return "<unset>";
            }
        }

        public class Entry
        {
            public uint     Index;
            public string Elapsed;
            public int      State;
            public string  Status;
            [global::System.Management.Automation.Hidden]
            public string String;
            public Entry(uint index, string time, int state, string status)
            {
                Index   = index;
                Elapsed = time;
                State   = state;
                Status  = status;
                String  = ToString();
            }
            public override string ToString()
            {
                return string.Format("[{0}] (State: {1}/Status: {2})", Elapsed, State, Status);
            }
        }

        public class Controller
        {
            public uint      Mode;
            public TimeSlot Start;
            public TimeSlot   End;
            public string    Span;
            public Entry   Status;
            public ObservableCollection<Entry> Output;
            public Controller()
            {
                Reset();
            }
            public string Elapsed()
            {
                TimeSpan ts;

                if (End.Set == 0)
                {
                    ts = DateTime.Now - Start.Time.Value.Value;
                }
                else
                {
                    ts = End.Time.Value.Value - Start.Time.Value.Value;
                }

                return ts.ToString();
            }
            public void SetStatus()
            {
                Status = new Entry((uint)Output.Count,Elapsed(), Status.State, Status.Status);
            }
            public void SetStatus(int state, string status)
            {
                Status = new Entry((uint)Output.Count, Elapsed(), state, status);
            }
            public void Initialize()
            {
                if (Start.Set == 1)
                {
                    Update(-1, "Start [!] Error: Already initialized, try a different operation or reset.");
                    return;
                }

                Start.Toggle();
                Update(0, "Running [~] (" + Start.ToString() + ")");
            }
            public void Complete()
            {
                if (End.Set == 1)
                {
                    Update(-1, "End [!] Error: Already initialized, try a different operation or reset.");
                    return;
                }

                End.Toggle();
                Span = Elapsed();
                Update(100, "Complete [+] (" + End.ToString() + "), Total: (" + Span + ")");
            }
            public void Reset()
            {
                Start  = new TimeSlot("Start");
                End    = new TimeSlot("End");
                Span   = null;
                Status = null;
                Output = new ObservableCollection<Entry>();
            }
            public void Update(int state, string status)
            {
                SetStatus(state, status);
                Output.Add(Status);
                if (Mode == 0)
                {
                    System.Console.WriteLine(Last());
                }
            }
            public object Current()
            {
                Update(Status.State, Status.Status);
                return Last();
            }
            public object Last()
            {
                return Output[Output.Count - 1];
            }
            public object DumpConsole()
            {
                string[] arr = new string[Output.Count];

                for (int i = 0; i < Output.Count; i++)
                {
                    arr[i] = Output[i].ToString();
                }

                return arr;
            }
            public override string ToString()
            {
                return Span == null ? Elapsed() : Span;
            }
        }
    }

    // Toast classes deal with toast notifications
    namespace Toast
    {
        public enum TemplateType
        {
            ToastText01                 = 0,
            ToastText02                 = 1,
            ToastText03                 = 2,
            ToastText04                 = 3,
            ToastImageAndText01         = 4,
            ToastImageAndText02         = 5,
            ToastImageAndText03         = 6,
            ToastImageAndText04         = 7,
            ToastGeneric                = 8,
            ToastGenericHero            = 9,
            ToastGenericAppLogoOverride = 10,
            ToastGenericAttribution     = 11,
            ToastGenericProgress        = 12,
            ToastGenericGroup           = 13,
        }

        public enum TemplateImageSource
        {
            Web = 0,
            AppX = 1,
            File = 2,
        }

        public enum TemplateImageType
        {
            Png = 0,
            Jpg = 1,
            Gif = 2,
            Bmp = 3,
            Ico = 4,
            Tiff = 5,
            Other = 6,
        }

        public class TemplateImage
        {
            public TemplateImageSource Source;
            public TemplateImageType     Type;
            public string                Name;
            public string            Fullname;
            public bool                Exists;
            public bool             Supported;
            public TemplateImage(string fullname)
            {
                Fullname      = fullname;
                Name          = System.IO.Path.GetFileName(fullname);

                Clear();
            }
            public void SetSource(int slot)
            {
                Source = (TemplateImageSource)slot;
            }
            public void Clear()
            {                
                if (Regex.IsMatch(Fullname, "^(https?)://", RegexOptions.IgnoreCase))
                {
                    SetSource(0);
                }
                else if (Regex.IsMatch(Fullname, "^(ms-appx|ms-appdata):///", RegexOptions.IgnoreCase))
                {
                    SetSource(1);
                }
                else if (Regex.IsMatch(Fullname, "^[A-Za-z]:[\\\\/]", RegexOptions.IgnoreCase))
                {
                    SetSource(2);
                }
                else
                {
                    throw new Exception("Unsupported image source format: [" + Fullname + "]");
                }

                CheckSupported();
                CheckExistence();

                // if (Exists == true)
                // {
                //     Match m = RxFilename.Match(Fullname);
                //     if (m.Success)
                //     {
                //         Name = m.Value;
                //     }
                //     else
                //     {
                //         Name = Fullname;
                //     }
                // }
            }
            public void CheckSupported()
            {
                if ((int)Type <= 6)
                {
                    Supported = true;
                }
                else
                {
                    Supported = false;
                }
            }
            public void CheckExistence()
            {
                if ((int)Source == 2)
                {
                    Exists = System.IO.File.Exists(Fullname);
                }
                else
                {
                    Exists = false;
                }
            }
        }

        public class TemplateContent
        {
            public uint   Index;
            public string Value;
            public TemplateContent(uint index, string value)
            {
                Index = index;
                Value = value;
            }
            public override string ToString()
            {
                return Value;
            }
        }

        public class TemplateItem
        {
            public uint         Index;
            public TemplateType  Type;
            public bool          Text = true;
            public bool         Image = false;
            public bool         Valid = false;
            public int         Params;
            public List<TemplateContent> Content;
            public TemplateItem(string name, string[] template)
            {
                Type    = (TemplateType)Enum.Parse(typeof(TemplateType), name);
                Index   = (uint)Type;

                Content = new List<TemplateContent>();

                // Header
                Add(0, "<toast>");
                Add(1, "<visual>");

                // Body
                for (int i = 0; i < template.Length; i++)
                {
                    Add(2, template[i]);
                }

                // Footer
                Add(1, "</visual>");
                Add(0, "</toast>");

                GetParams();
            }
            public void Add(uint padding, string value)
            {
                int factor = (int)padding * 4;
                string line;

                if (factor > 0)
                {
                    string buffer = new string(' ', factor);
                    line = buffer + value;
                }
                else
                {
                    line = value;
                }

                Content.Add(new TemplateContent((uint)Content.Count, line));
            }
            public string GetContent()
            {
                StringBuilder sb = new StringBuilder();

                for (int i = 0; i < Content.Count; i++)
                {
                    if (i > 0)
                        sb.Append("`n");

                    sb.Append(Content[i].Value);
                }

                return sb.ToString();
            }
            public void GetParams()
            {
                string content = GetContent();
                Params = Regex.Matches(content, "\\{\\d+\\}").Count;
            }
            public override string ToString()
            {
                return Type.ToString();
            }
        }

        public class Controller
        {
            public Guid                   AppId;
            public List<TemplateItem>  Template;
            public TemplateType?        Current;
            public DateTime                Time;
            public string                 Title;
            public string[]                Body;
            public string[]             Message;
            public TemplateImage          Image;
            public string                   Xml;
            public object                 Toast;
            public Controller()
            {
                Stage();
            }
            public void Update()
            {
                Time   = DateTime.Now;
            }
            public void Clear()
            {
                Update();

                Current = null;
                Title   = null;
                Body    = null;
                Message = null;
                Image   = null;
                Xml     = null;
                Toast   = null;
            }
            public void Stage()
            {
                Clear();
                Template = new List<TemplateItem>();

                string[] names = Enum.GetNames(typeof(TemplateType));
                int[]      img = {4,5,6,7,9,10};

                for (int i = 0; i < names.Length; i++)
                {
                    string       name = names[i];
                    string[]    lines = GetTemplateLines(name);
                    TemplateItem item = new TemplateItem(name, lines);

                    for (int x = 0; x < img.Length; x ++)
                    {
                        if (img[x] == item.Index)
                        {
                            item.Image = true;
                        }
                    }

                    Add(item);
                }
            }
            public void SetCurrent(int index)
            {
                Current = (TemplateType)index;
            }
            public void SetImage(string fullName)
            {
                Image   = new TemplateImage(fullName);

                // set flags to lock the non-image templates
            }
            public void SetTitle(string title)
            {
                Title = title;
            }
            public void SetBody(string[] body)
            {
                string[] xbody = new string[body.Length];

                for (int x = 0; x < body.Length; x ++)
                {
                    xbody[x] = body[x];
                }

                Body = xbody;
            }
            public void SetMessage(string[] message)
            {
                string[] xmessage = new string[message.Length];

                for (int x = 0; x < message.Length; x ++)
                {
                    xmessage[x] = message[x];
                }

                Message = xmessage;
            }
            private string[] GetTemplateLines(string name)
            {
                switch (name)
                {
                    case "ToastText01": return ToastText01();
                    case "ToastText02": return ToastText02();
                    case "ToastText03": return ToastText03();
                    case "ToastText04": return ToastText04();
                    case "ToastImageAndText01": return ToastImageAndText01();
                    case "ToastImageAndText02": return ToastImageAndText02();
                    case "ToastImageAndText03": return ToastImageAndText03();
                    case "ToastImageAndText04": return ToastImageAndText04();
                    case "ToastGeneric": return ToastGeneric();
                    case "ToastGenericHero": return ToastGenericHero();
                    case "ToastGenericAppLogoOverride": return ToastGenericAppLogoOverride();
                    case "ToastGenericAttribution": return ToastGenericAttribution();
                    case "ToastGenericProgress": return ToastGenericProgress();
                    case "ToastGenericGroup": return ToastGenericGroup();
                }

                return new string[0];
            }
            public void Add(string name, string[] template)
            {
                Template.Add(new TemplateItem(name, template));
            }
            public void Add(TemplateItem item)
            {
                Template.Add(item);
            }
            public string[] ToastText01()
            {
                string[] list = new string[3];

                list[00] = "<binding template=\"ToastText01\">";
                list[01] = "    <text id=\"1\">{0}</text>";
                list[02] = "</binding>";
                
                return list;
            }
            public string[] ToastText02()
            {
                string[] list = new string[4];

                list[00] = "<binding template=\"ToastText02\">";
                list[01] = "    <text id=\"1\">{0}</text>";
                list[02] = "    <text id=\"2\">{1}</text>";
                list[03] = "</binding>";
                
                return list;
            }
            public string[] ToastText03()
            {
                string[] list = new string[5];

                list[00] = "<binding template=\"ToastText03\">";
                list[01] = "    <text id=\"1\">{0}</text>";
                list[02] = "    <text id=\"2\">{1}</text>";
                list[03] = "    <text id=\"3\">{2}</text>";
                list[04] = "</binding>";
                
                return list;
            }
            public string[] ToastText04()
            {
                string[] list = new string[5];

                list[00] = "<binding template=\"ToastText04\">";
                list[01] = "    <text id=\"1\">{0}</text>";
                list[02] = "    <text id=\"2\">{1}</text>";
                list[03] = "    <text id=\"3\">{2}</text>";
                list[04] = "</binding>";
                
                return list;
            }
            public string[] ToastImageAndText01()
            {
                string[] list = new string[4];

                list[00] = "<binding template=\"ToastImageAndText01\">";
                list[01] = "    <image id=\"1\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text id=\"1\">{2}</text>";
                list[03] = "</binding>";
                
                return list;
            }
            public string[] ToastImageAndText02()
            {
                string[] list = new string[5];

                list[00] = "<binding template=\"ToastImageAndText02\">";
                list[01] = "    <image id=\"1\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text id=\"1\">{2}</text>";
                list[03] = "    <text id=\"2\">{3}</text>";
                list[04] = "</binding>";
                
                return list;
            }
            public string[] ToastImageAndText03()
            {
                string[] list = new string[6];

                list[00] = "<binding template=\"ToastImageAndText03\">";
                list[01] = "    <image id=\"1\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text id=\"1\">{2}</text>";
                list[03] = "    <text id=\"2\">{3}</text>";
                list[04] = "    <text id=\"3\">{4}</text>";
                list[05] = "</binding>";
                
                return list;
            }
            public string[] ToastImageAndText04()
            {
                string[] list = new string[6];

                list[00] = "<binding template=\"ToastImageAndText04\">";
                list[01] = "    <image id=\"1\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text id=\"1\">{2}</text>";
                list[03] = "    <text id=\"2\">{3}</text>";
                list[04] = "    <text id=\"3\">{4}</text>";
                list[05] = "</binding>";
                
                return list;
            }
            public string[] ToastGeneric()
            {
                string[] list = new string[5];

                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <text>{0}</text>";
                list[02] = "    <text>{1}</text>";
                list[03] = "    <text>{2}</text>";
                list[04] = "</binding>";
                
                return list;
            }
            public string[] ToastGenericHero()
            {
                string[] list = new string[6];

                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <image placement=\"hero\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text>{2}</text>";
                list[03] = "    <text>{3}</text>";
                list[04] = "    <text>{4}</text>";
                list[05] = "</binding>";
                
                return list;
            }
            public string[] ToastGenericAppLogoOverride()
            {
                string[] list = new string[5];

                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <image placement=\"appLogoOverride\" hint-crop=\"circle\" src=\"{0}\" alt=\"{1}\"/>";
                list[02] = "    <text>{2}</text>";
                list[03] = "    <text>{3}</text>";
                list[04] = "</binding>";

                return list;
            }
            public string[] ToastGenericAttribution()
            {
                string[] list = new string[6];

                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <text>{0}</text>";
                list[02] = "    <text>{1}</text>";
                list[03] = "    <text>{2}</text>";
                list[04] = "    <text placement=\"attribution\">{3}</text>";
                list[05] = "</binding>";

                return list;
            }
            public string[] ToastGenericProgress()
            {
                string[] list = new string[8];

                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <text>{0}</text>";
                list[02] = "    <progress";
                list[03] = "        title={1}";
                list[04] = "        value={2}";
                list[05] = "        valueStringOverride={3}";
                list[06] = "        status={4}/>";
                list[07] = "</binding>";

                return list;
            }
            public string[] ToastGenericGroup()
            {
                string[] list = new string[12];
                
                list[00] = "<binding template=\"ToastGeneric\">";
                list[01] = "    <group>";
                list[02] = "        <subgroup>";
                list[03] = "            <text>{0}</text>";
                list[04] = "            <text>{1}</text>";
                list[05] = "        </subgroup>";
                list[06] = "        <subgroup>";
                list[07] = "            <text>{2}</text>";
                list[08] = "            <text>{3}</text>";
                list[09] = "        </subgroup>";
                list[10] = "    </group>";
                list[11] = "</binding>";

                return list;
            }
            public System.Type GetWinRtType(string fullName)
            {
                return System.Type.GetType(fullName + ", Windows.UI.Notifications, ContentType=WindowsRuntime");
            }
            public string GetXml()
            {
                TemplateItem source = Template[(int)Current];

                StringBuilder sb = new StringBuilder();

                for (int i = 0; i < source.Content.Count; i++)
                {
                    if (i > 0)
                        sb.Append("\n");

                    sb.Append(source.Content[i].Value);
                }

                string xml = sb.ToString();

                switch ((int)Current)
                {
                    case 0:
                    {
                        xml = string.Format(xml, Title);
                        break;
                    }
                    case 1:
                    {
                        xml = string.Format(xml, Title, Body[0]);
                        break;
                    }
                    case 2:
                    {
                        xml = string.Format(xml, Title, Body[0], Message[0]);
                        break;
                    }
                    case 3:
                    {
                        xml = string.Format(xml, Title, Body[0], Message[0]);
                        break;
                    }
                    case 4:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title);
                        break;
                    }
                    case 5:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title, Body[0]);
                        break;
                    }
                    case 6:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title, Body[0], Message[0]);
                        break;
                    }
                    case 7:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title, Body[0], Message[0]);
                        break;
                    }
                    case 8:
                    {
                        xml = string.Format(xml, Title, Body[0], Message[0]);
                        break;
                    }
                    case 9:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title, Body[0], Message[0]);
                        break;
                    }
                    case 10:
                    {
                        xml = string.Format(xml, Image.Fullname, Image.Name, Title, Body[0]);
                        break;
                    }
                    case 11:
                    {
                        xml = string.Format(xml, Body[0], Body[1], Message[0], Title);
                        break;
                    }
                    case 12:
                    {
                        xml = string.Format(xml, Title, Body[0], Body[1], Message[0], Message[1]);
                        break;
                    }
                    case 13:
                    {
                        xml = string.Format(xml, Body[0], Body[1], Message[0], Message[1]);
                        break;
                    }
                }

                return xml;
            }
            public object CreateXmlDocument(string xml)
            {
                System.Type xmlDocType = System.Type.GetType("Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType=WindowsRuntime");

                object xmlDoc = Activator.CreateInstance(xmlDocType);

                xmlDocType
                    .GetMethod("LoadXml", new Type[] { typeof(string) })
                    .Invoke(xmlDoc, new object[] { xml });

                return xmlDoc;
            }
            public object CreateToastNotification(object xmlDoc)
            {
                Type toastType = GetWinRtType("Windows.UI.Notifications.ToastNotification");

                return Activator.CreateInstance(toastType, new object[] { xmlDoc });
            }
            public object GetToastNotifier()
            {
                Type mgrType = GetWinRtType("Windows.UI.Notifications.ToastNotificationManager");

                return mgrType
                    .GetMethod("CreateToastNotifier", new Type[] { typeof(string) })
                    .Invoke(null, new object[] { AppId.ToString() });
            }
            public void ShowToast()
            {
                Xml             = GetXml();
                object   xmlDoc = CreateXmlDocument(Xml);
                Toast           = CreateToastNotification(xmlDoc);
                object notifier = GetToastNotifier();

                // notifier.Show(toast)
                notifier.GetType().GetMethod("Show").Invoke(notifier, new object[] { Toast });
            }
        }

    }

    // Module controller
    namespace Module
    {
        // former os types, current host types/classes
        public enum HostPropertyType
        {
            Key  = 0,
            Name = 1
        }

        public enum HostOSType
        {
            Win32_Client = 0,
            Win32_Server = 1,
            Win32_Based  = 2,
            Unix         = 3
        }

        public class HostProperty
        {
            public uint    Index;
            public string Source;
            public string   Type;
            public string   Name;
            public object  Value;
            public HostProperty(uint index, string source, string name, object value)
            {
                Index  = index;
                Source = source;
                Type   = (value != null) ? value.GetType().Name : null;
                Name   = name;
                Value  = (value != null) ? value : null;
            }
            public override string ToString()
            {
                return Name;
            }
        }

        public class HostPropertySet
        {
            public uint                  Index;
            public string               Source;
            public string              Command;
            public HostPropertyType       Type;
            public List<HostProperty> Property;
            private EngineIntrinsics   Context;
            public HostPropertySet(uint index, string source, string command, int type, EngineIntrinsics context)
            {
                Index    = index;
                Source   = source;
                Command  = command;
                Type     = (HostPropertyType)type;
                Context  = context;

                Clear();
                Refresh();
            }
            public void Add(string name, object value)
            {
                Property.Add(new HostProperty((uint)Property.Count, Source, name, value));
            }
            public void Clear()
            {
                Property = new List<HostProperty>();
            }
            public void Refresh()
            {
                Property.Clear();

                foreach (PSObject o in Context.InvokeCommand.InvokeScript(Command))
                {
                    PSPropertyInfo nameProp  = o.Properties[Type.ToString()];
                    PSPropertyInfo valueProp = o.Properties["Value"];

                    string name  = (nameProp != null && nameProp.Value != null) ? nameProp.Value.ToString() : "";
                    object value = null;

                    if (valueProp != null)
                    {
                        try
                        {
                            value = valueProp.Value;
                        }
                        catch
                        {
                            value = "<Unable to collect value>";
                        }
                    }

                    Add(name, value);
                }

                Sort();
                Rerank();
            }
            public void Sort()
            {
                Property.Sort(delegate(HostProperty a, HostProperty b)
                {
                    return string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase);
                });
            }
            public void Rerank()
            {
                for (uint i = 0; i < Property.Count; i++)
                {
                    Property[(int)i].Index = i;
                }
            }
            public override string ToString()
            {
                return Source;
            }
        }

        public class HostController
        {
            public HostOSType              Type;
            public string               Caption;
            public string              Platform;
            public Version            PSVersion;
            public List<HostPropertySet> Output;
            private EngineIntrinsics    Context;
            public HostController(EngineIntrinsics context)
            {
                if (Environment.OSVersion.Platform == PlatformID.Win32NT)
                {
                    Caption  = GetWinCaption();
                    Platform = "Win32NT";
                }
                else
                {
                    Caption  = GetLinuxCaption();
                    Platform = "Unix";
                }
                
                Type    = GetOSType();
                Context = context;

                Refresh();
            }
            public void Clear()
            {
                Output = new List<HostPropertySet>();
            }
            public void Refresh()
            {
                Clear();

                // Environment
                AddPropertySet("Environment", "Get-ChildItem Env:", 0);

                // Variables
                AddPropertySet("Variable", "Get-ChildItem Variable:", 1);

                // Host
                AddPropertySet("Host", "(Get-Host).PSObject.Properties", 1);

                // PowerShell
                AddPropertySet("PowerShell", "(Get-Variable PSVersionTable).Value.GetEnumerator()", 1);

                GetPSVersion();
            }
            public HostPropertySet Source(string source)
            {
                return Output.Where(delegate(HostPropertySet x)
                { 
                    return String.Equals(x.Source, source, StringComparison.OrdinalIgnoreCase);
                
                }).FirstOrDefault();
            }
            public HostProperty Property(string source, string name)
            {
                HostPropertySet set = Source(source);

                if (set == null || set.Property == null) return null;

                return set.Property.Where(delegate(HostProperty p)
                {
                    return String.Equals(p.Name, name, StringComparison.OrdinalIgnoreCase);
                
                }).FirstOrDefault();
            }
            public void Add(uint index, string name, object value)
            {
                HostPropertySet set = Output[(int)index];
                if (set != null)
                {
                    set.Add(name, value);
                }
            }
            public void AddPropertySet(string source, string command, int type)
            {
                Output.Add(new HostPropertySet((uint)Output.Count, source, command, type, Context));
            }
            public string GetWinCaption()
            {
                try
                {
                    ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT Caption FROM Win32_OperatingSystem");

                    foreach (ManagementObject obj in searcher.Get())
                    {
                        return Convert.ToString(obj["Caption"]);
                    }
                }
                catch { }
                return "Windows";
            }
            public string GetLinuxCaption()
            {
                // will have to ensure this is correct on linux... eventually
                try
                {
                    if (File.Exists("/usr/bin/hostnamectl"))
                    {
                        ProcessStartInfo psi = new ProcessStartInfo();

                        psi.FileName               = "/usr/bin/hostnamectl";
                        psi.Arguments              = "";
                        psi.RedirectStandardOutput = true;
                        psi.UseShellExecute        = false;

                        Process p                  = Process.Start(psi);
                        string output              = p.StandardOutput.ReadToEnd();

                        string[] lines             = output.Split('\n');
                        foreach (string line in lines)
                        {
                            if (line.Contains("Operating System"))
                            {
                                string[] parts = line.Split(':');
                                if (parts.Length > 1)
                                {
                                    return parts[1].Trim();
                                }
                            }
                        }
                    }
                }
                catch { }
                return "Linux";
            }
            public HostOSType GetWinType()
            {
                string caption = GetWinCaption();

                if (Regex.IsMatch(caption, "Windows (10|11)"))
                    return HostOSType.Win32_Client;

                else if (Regex.IsMatch(caption, "Windows Server"))
                    return HostOSType.Win32_Server;

                return HostOSType.Win32_Based;
            }
            public HostOSType GetOSType()
            {
                if (Environment.OSVersion.Platform == PlatformID.Win32NT)
                    return GetWinType();

                return HostOSType.Unix;
            }
            public void GetPSVersion()
            {
                HostProperty p = Property("PowerShell", "PSVersion");

                PSVersion = (p != null && p.Value != null) ? (Version)p.Value : null;
            }   
            public override string ToString()
            {
                return string.Format("{0}, {1}/{2}, PSVersion: {3}", Caption, Platform, Type, PSVersion);
            }
        }

        // registry types/classes
        public struct RegistryKeyTemplate
        {
			public string        Name;
            public string     Company;
            public string      Author;
            public string      Source;
            public string Description;
            public string   Copyright;
            public string        Guid;
            public string        Date;
            public string     Version;
            public string     Caption;
            public string    Platform;
            public string        Type;
            public string    Registry;
            public string    Resource;
            public string      Module;
            public string        File;
            public string    Manifest;
            public string    Shortcut;
        }

        public struct RegistryKeyProperty
        {
            public uint   Index;
            public string  Name;
            public object Value;
            public bool  Exists = false;
            public RegistryKeyProperty(uint index, string name, object value)
            {
                Index = index;
                Name  = name;
                Value = value;
            }
            public override string ToString()
            {
                return Name;
            }
        }

        public class RegistryKeyController
        {
            public string                        Drive; // PS drive/root
            public string                         Name; // PS name/leaf
            public string                     Fullname; // PS fullname
            public bool                         Exists;
            private string                        Root; // win32 hive name/string
            private string                        Path; // win32 full name/string
            private string                      Branch; // win32 branch/string
            private Microsoft.Win32.RegistryKey   Hive;
            private RegistryKeyTemplate       Template;
            public List<RegistryKeyProperty>  Property;
            public RegistryKeyController(string fullname)
            {
                Assign(fullname);
                Check();
                ReadRegistry();
                WriteTemplate();
            }
            public RegistryKeyController(string fullname, RegistryKeyTemplate template)
            {
                Assign(fullname);
                Template       = template;
                ReadTemplate();
                WriteRegistry();
            }
            private void Assign(string fullname)
            {
                string[] parts  = fullname.Split('\\');

                Drive    = parts[0];
                Name     = parts[parts.Length - 1];
                Fullname = fullname;
                
                MapHive(Drive);

                Path     = Root + "\\" + string.Join("\\", parts, 1, parts.Length - 1);
                Branch   = string.Join("\\", parts, 1, parts.Length - 2);

                Clear();
            }
            public void Check()
            {
                Exists   = false;

                using (var parent = Hive.OpenSubKey(Branch))
                {
                    if (parent == null) return;

                    using (var child = parent.OpenSubKey(Name))
                    {
                        Exists = (child != null);
                    }
                }
            }
            public void Clear()
            {
                Property = new List<RegistryKeyProperty>();
            }
            public void Refresh()
            {
                Check();
                Clear();

                if (Exists)
                    ReadRegistry();
            }
            public void Create()
            {
                Check();

                if (Exists)
                    throw new Exception("Exception [!] Path already exists");

                using (var parent = Hive.CreateSubKey(Branch))
                {
                    parent.CreateSubKey(Name);
                }

                Check();
            }
            public void Remove()
            {
                Check();

                if (!Exists)
                    throw new Exception("Exception [!] Path does not exist");

                using (var parent = Hive.OpenSubKey(Branch, writable: true))
                {
                    parent.DeleteSubKeyTree(Name);
                }

                Check();
            }
            private void MapHive(string root)
            {
                switch (root)
                {
                    case "HKLM:" : Root = "HKEY_LOCAL_MACHINE"  ; Hive = Microsoft.Win32.Registry.LocalMachine  ; break;
                    case "HKCU:" : Root = "HKEY_CURRENT_USER"   ; Hive = Microsoft.Win32.Registry.CurrentUser   ; break;
                    case "HKU:"  : Root = "HKEY_USERS"          ; Hive = Microsoft.Win32.Registry.Users         ; break;
                    case "HKCR:" : Root = "HKEY_CLASSES_ROOT"   ; Hive = Microsoft.Win32.Registry.ClassesRoot   ; break;
                    case "HKCC"  : Root = "HKEY_CURRENT_CONFIG" ; Hive = Microsoft.Win32.Registry.CurrentConfig ; break;
                    default      : throw new Exception("Unsupported registry hive: " + root);
                }
            }
            public RegistryKeyTemplate GetTemplate()
            {
                return Template;
            }
            public void ReadRegistry()
            {
                // registry => property list

                Clear();
                Check();

                if (!Exists)
                    throw new Exception("Exception [!] Registry path does not exist");

                using (var key = Hive.OpenSubKey(Branch + "\\" + Name))
                {
                    foreach (string name in key.GetValueNames())
                    {
                        Property.Add(new RegistryKeyProperty((uint)Property.Count, name, key.GetValue(name))
                        {
                            Exists = true
                        });
                    }
                }
            }
            public void WriteRegistry()
            {
                // property list => registry

                Check();
                if (!Exists)
                {
                    Create();
                }

                using (var parent = Hive.OpenSubKey(Branch, writable: true))
                using (var key = parent.CreateSubKey(Name))
                {   
                    foreach (RegistryKeyProperty prop in Property)
                        key.SetValue(prop.Name, prop.Value ?? "");
                }

                Check();
            }
            public void ReadTemplate()
            {
                // template => property list
                Clear();

                FieldInfo[] fields = GetFields();

                for (int i = 0; i < fields.Length; i++)
                {
                    Property.Add(new RegistryKeyProperty((uint)i, fields[i].Name, fields[i].GetValue(Template)));
                }
            }
            public void WriteTemplate()
            {
                // property list => template
                FieldInfo[] fields = GetFields();

                foreach (var prop in Property)
                {
                    fields[prop.Index].SetValueDirect(__makeref(Template), Convert.ToString(prop.Value));
                }
            }
            private FieldInfo[] GetFields()
            {
                return typeof(RegistryKeyTemplate).GetFields(BindingFlags.Public | BindingFlags.Instance);
            }
            public override string ToString()
            {
                return Fullname;
            }
        }

        // root types/classes
        public enum RootMode
        {
            Directory = 0,
            File      = 1,
        }

        public class RootProperty
        {
            public uint      Index;
            public RootMode   Mode;
            public string     Name;
            public string Fullname;
            public bool     Exists;
            public RootProperty(uint index, uint mode, string name, string fullname)
            {
                Index    = index;
                Mode     = (RootMode)mode;
                Name     = name;
                Fullname = fullname;

                Check();
            }
            public void Check()
            {
                Exists = System.IO.File.Exists(Fullname) || System.IO.Directory.Exists(Fullname);
            }
            public void Create()
            {
                Check();

                if (!Exists)
                {
                    if (Name == "Resource" || Name == "Module")
                    {
                        System.IO.Directory.CreateDirectory(Fullname);
                    }
                    else if (Name == "File" || Name == "Manifest")
                    {
                        System.IO.File.Create(Fullname).Dispose();
                    }

                    Check();
                }
            }
            public void Remove()
            {
                Check();

                if (Exists)
                {
                    if (Name == "Resource" || Name == "Module")
                    {
                        System.IO.Directory.Delete(Fullname, true);
                    }
                    else if (Name == "File" || Name == "Manifest" || Name == "Shortcut")
                    {
                        System.IO.File.Delete(Fullname);
                    }

                    Check();
                }
            }
            public override string ToString()
            {
                return Fullname;
            }
        }

        public class RootController
        {
            public RootProperty Registry;
            public RootProperty Resource;
            public RootProperty   Module;
            public RootProperty     File;
            public RootProperty Manifest;
            public RootProperty Shortcut;
            public RootController(RegistryKeyTemplate template)
            {
                Registry = Assign(0, 0, "Registry" , template.Registry);
                Resource = Assign(1, 0, "Resource" , template.Resource);
                Module   = Assign(2, 0, "Module"   , template.Module);
                File     = Assign(3, 1, "File"     , template.File);
                Manifest = Assign(4, 1, "Manifest" , template.Manifest);
                Shortcut = Assign(5, 1, "Shortcut" , template.Shortcut);
            }
            public RootProperty Assign(uint index, uint mode, string name, string fullname)
            {
                return new RootProperty(index, mode, name, fullname);
            }
            public RootProperty[] List()
            {
                return new RootProperty[] { Registry, Resource, Module, File, Manifest, Shortcut };
            }
            public void Refresh()
            {
                foreach (RootProperty prop in List())
                {
                    prop.Check();
                }
            }
            public override string ToString()
            {
                return base.ToString();
            }
        }

        // manifest types/classes
        public enum ManifestMode
        {
            Directory = 0,
            File      = 1,
        }

        public enum ManifestType
        {
            Control  = 0,
            Function = 1,
            Graphic  = 2,
        }

        public struct ManifestEntryContent
        {
            public uint Index;
            public string Line;
            public ManifestEntryContent(uint index, string line)
            {
                Index = index;
                Line  = line;
            }
            public override string ToString()
            {
                return Line;
            }
        }

        public class ManifestEntry
        {
            public uint               Index;
            public ManifestMode        Mode;
            public ManifestType        Type;
            public Format.ModDateTime? Date = null;
            public string              Name;
            public string       DisplayName;
            public string          Fullname;
            public Format.ByteSize     Size;
            public bool              Exists = false;
            public string            Source;
            public string              Hash;
            public bool               Match;
            public byte[]             Bytes;
            public ManifestEntry(uint index, uint type, string name)
            {
                Index       = index;
                Mode        = ManifestMode.Directory;
                Type        = (ManifestType)type;
                Name        = Path.GetFileName(name);
                Hash        = string.Empty;
            }
            public ManifestEntry(uint index, uint type, string name, string hash) : this (index, type, name)
            {
                Mode        = ManifestMode.File;
                Hash        = hash;
            }
            public void Assign(string displayname, string source)
            {
                DisplayName = displayname;
                Source      = source;
            }
            public void Clear()
            {
                Bytes       = new byte[0];
            }
            public void Check()
            {
                if (Mode == ManifestMode.Directory)
                {
                    DirectoryInfo info = new DirectoryInfo(Fullname);

                    Exists = info.Exists;
                    Size   = new Format.ByteSize("Directory", 0);
                    Date   = Exists ? new Format.ModDateTime(info.LastWriteTime) : null;
                }
                else
                {
                    FileInfo info = new FileInfo(Fullname);

                    Exists = info.Exists;
                    Size   = new Format.ByteSize("File", info.Length);
                    Date   = Exists ? new Format.ModDateTime(info.LastWriteTime) : null;
                }
            }
            public void Create()
            {
                Check();

                if (Mode == ManifestMode.Directory && Exists == false)
                {
                    Directory.CreateDirectory(Fullname);
                }
                else if (Mode == ManifestMode.File && Exists == false)
                {
                    File.Create(Fullname).Dispose();
                }

                Check();
            }
            public void Remove()
            {
                Check();

                if (Mode == ManifestMode.Directory && Exists == true)
                {
                    Directory.Delete(Fullname);
                }
                else if (Mode == ManifestMode.File && Exists == true)
                {
                    File.Delete(Fullname);
                }

                Check();
            }
            public void Read()
            {
                if (Mode != ManifestMode.File)
                    throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                Check();

                if (Exists)
                {
                    Clear();

                    Bytes = File.ReadAllBytes(Fullname);

                    Check();
                }
            }
            public void Write()
            {
                if (Mode != ManifestMode.File)
                    throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                Check();

                if (Exists == true)
                {
                    File.WriteAllBytes(Fullname, Bytes);

                    Check();
                }
            }
            public string[] Content()
            {
                if (Mode != ManifestMode.File)
                    throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                if (Bytes.Length > 0)
                {
                    string s = Encoding.UTF8.GetString(Bytes);

                    return s.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);
                }
                else
                {
                    return Array.Empty<string>();
                }
            }
            public ManifestEntryContent[] Lines()
            {
                string[] content = Content();

                List<ManifestEntryContent> lines = new List<ManifestEntryContent>();

                foreach (string line in content)
                {
                    lines.Add(new ManifestEntryContent((uint)lines.Count, line));
                }

                return lines.ToArray();
            }
            public void Download()
            {
                if (Mode != ManifestMode.File)
                    throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                Check();

                if (!Exists)
                    Create();

                int attempts   = 0;
                string content = null;

                while (content == null && attempts < 5)
                {
                    try
                    {
                        using (var wc = new WebClient())
                            content = wc.DownloadString(Source);
                    }
                    catch
                    {
                        
                    }

                    attempts ++;
                }

                if (content == null)
                    throw new Exception("Exception [!] File " + Name + " failed to download");

                Bytes = Encoding.UTF8.GetBytes(content);

                Write();
            }
            public override string ToString()
            {
                return Fullname;
            }
        }

        public class ManifestController
        {
            public string              Source;
            public string             Version;
            public string            Resource;
            public List<ManifestEntry> Output;
            public ManifestController(RegistryKeyTemplate template)
            {
                Source   = template.Source;
                Version  = template.Version;
                Resource = template.Resource;

                Clear();
            }
            public void Clear()
            {
                Output   = new List<ManifestEntry>();
            }
            public void AddFolder(uint type, string name)
            {
                ManifestEntry entry = new ManifestEntry((uint)Output.Count, type, name);

                SetFullname(entry);
                
                Output.Add(entry);
            }
            public void AddFile(uint type, string name, string hash)
            {
                ManifestEntry entry = new ManifestEntry((uint)Output.Count, type, name, hash);

                SetFullname(entry);
                SetSource(entry);

                Output.Add(entry);
            }
            public void SetFullname(ManifestEntry entry)
            {
                if (entry.Mode == ManifestMode.Directory)
                {
                    entry.Fullname = string.Format("{0}\\{1}", Resource, entry.Name);
                }
                else
                {
                    entry.Fullname = string.Format("{0}\\{1}\\{2}", Resource, entry.Type.ToString(), entry.Name);
                }

            }
            public void SetSource(ManifestEntry entry)
            {
                entry.Source = string.Format("{0}/blob/main/Version/{1}/{2}?raw=true", Source, Version, entry.Name);
            }
        }

        // remaining classes + factory controller
        public class ModuleVersion
        {
            public Version         Version;
            public Format.ModDateTime Time;
            public string             Date;
            public Guid               Guid;
            public ModuleVersion(Version version, Format.ModDateTime time, Guid guid)
            {
                Version  = version;
                Time     = time;
                Date     = Time.DateString();
                Guid     = guid;
            }
            public ModuleVersion(string line)
            {
                if (!Regex.IsMatch(line, VersionString()) || !Regex.IsMatch(line, DateString()) || !Regex.IsMatch(line, GuidString()))
                {
                    throw new Exception("Exception [!] Invalid input string");
                }

                Version  = new Version(Tx(0, line));
                Time     = new Format.ModDateTime(DateTime.Parse(Tx(1,line)));
                Date     = Time.DateString();
                Guid     = new Guid(Tx(2, line));
            }
            public ModuleVersion(bool createNew, int minor)
            {
                Version  = GenerateVersion(minor);
                Time     = new Format.ModDateTime(DateTime.Now);
                Date     = Time.DateString();
                Guid     = System.Guid.NewGuid();
            }
            public Version GenerateVersion(int minor)
            {
                string stamp = new Format.ModDateTime(DateTime.Now).Value.ToString("yyyy.MM.");
                return new Version(stamp + minor);
            }
            public string VersionString()
            {
                return "\\d{4}\\.\\d{1,}\\.\\d{1,}";
            }
            public string DateString()
            {
                return "\\d{2}\\/\\d{2}\\/\\d{4} \\d{2}:\\d{2}:\\d{2}";
            }
            public string GuidString()
            {
                return "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";
            }
            private string Tx(uint type, string line)
            {
                string[] pattern = new string[]{ VersionString(), DateString(), GuidString() };

                Match m = Regex.Match(line, pattern[type]);

                if (!m.Success)
                    throw new Exception("Exception [!] Invalid string input");

                return m.Value;
            }
            public override string ToString()
            {
                return Version.ToString();
            }
        }

        public class Controller
        {
            public Console.Controller       Console;
            public Security.PrincipalInfo Principal;
            public EngineIntrinsics         Context;
            public string                      Name;
            public string                   Company;
            public string                    Author;
            public string                    Source;
            public string               Description;
            public string                 Copyright;
            public Guid                        Guid;
            public Format.ModDateTime          Date;
            public ModuleVersion            Version;
            public HostController              Host;
            public RegistryKeyController   Registry;
            public RootController              Root;
            public ManifestController      Manifest;
            public Controller(EngineIntrinsics context)
            {
                // Initializes console
                Initialize(context);

                // Prime
                Prime();
            }
            private void Initialize(EngineIntrinsics context)
            {
                Principal = Security.PrincipalInfo.GetCurrent();

                if (!Principal.Administrator)
                    throw new InvalidOperationException("Exception [!] " + DisplayName() + "requires admin rights");

                if (Console == null)
                {
                    Console = new Console.Controller();
                    Console.Initialize();
                }

                if (Context == null)
                {
                    Context = context;
                }
            }
            public void Update(int state, string status)
            {
                // Updates the console, writes a message if in correct mode
                Console.Update(state, status);
            }
            public void Prime()
            {
                // Get host controller
                GetHostController();

                // Get registry key controller
                GetRegistryKeyController();

                // Get root controller
                GetRootController();

                // Manifest
                GetManifestController();
            }
            public string Env(string name)
            {
                HostProperty prop = Host.Property("Environment", name);

                if (prop == null)
                    return null;
                
                return prop.Value.ToString();
            }
            public string[] Defaults()
            {
                return new string[]
                {
                    DisplayName(),                                         // 0 Name
                    CompanyName(),                                         // 1 Company
                    AuthorName(),                                          // 2 Author
                    ProjectSource(),                                       // 3 Source
                    "Beginning the fight against ID theft and cybercrime", // 4 Description
                    "(c) 2026 (mcc85s/mcc85sx/sdp). All rights reserved.", // 5 Copyright
                    "7649d586-6a45-4dad-b24d-64eabde5f926",                // 6 Guid
                    "04/06/2026 16:30:21",                                 // 7 Date
                    CurrentVersion()                                       // 8 Version
                };
            }
            public string DisplayName()
            {
                return string.Format("[{0}(π)]", ProjectName());
            }
            public string ProjectName()
            {
                return "FightingEntropy";
            }
            public string ProjectSource()
            {
                return "https://www.github.com/mcc85s/FightingEntropy";
            }
            public string CompanyName()
            {
                return "Secure Digits Plus LLC";
            }
            public string AuthorName()
            {
                return "Michael C. Cook Sr.";
            }
            public string CurrentVersion()
            {
                return "2026.4.0";
            }
            public string Now()
            {
                return Format.ModDateTime.Now().ToString();
            }
            public string ProgramData()
            {
                return Env("ProgramData");
            }
            public string CurrentVersionSource()
            {
                return string.Format("{0}/blob/main/Version/{1}", ProjectSource(), CurrentVersion());
            }
            public string DefaultRegistryPath()
            {
                return string.Format("HKLM:\\Software\\Policies\\{0}\\{1}\\{2}", CompanyName(), ProjectName(), CurrentVersion());
            }
            public string DefaultResourcePath()
            {
                return string.Format("{0}\\{1}\\{2}\\{3}", ProgramData(), CompanyName(), ProjectName(), CurrentVersion());
            }
            public string DefaultModulePath()
            {
                if (Host == null)
                {
                    throw new Exception("Exception [!] Unable to determine PSModulePath");
                }

                char[]   c = new char[]{ ';', ':' };
                string   x = null;
                int      i = 0;
                string psm = Env("PSModulePath");

                if (Host.Platform == "Win32NT")
                {
                    x = Regex.Escape(Env("SystemRoot"));
                    i = 0;
                }
                else if (Host.Platform == "Unix")
                {
                    x = "PowerShell";
                    i = 1;
                }

                return psm.Split(c[i]).Where(p => p != null && Regex.IsMatch(p, x, RegexOptions.IgnoreCase)).FirstOrDefault();
            }
            private string DefaultShortcutPath()
            {
                return string.Format("{0}\\{1}.lnk", Environment.GetFolderPath(Environment.SpecialFolder.CommonDesktopDirectory), ProjectName());
            }
            public RegistryKeyTemplate DefaultTemplate()
            {
                // Populate registry template with default values
                RegistryKeyTemplate template = new RegistryKeyTemplate();

                string[] arthur      = Defaults();

                template.Name        = arthur[0];
                template.Company     = arthur[1];
                template.Author      = arthur[2];
                template.Source      = arthur[3];
                template.Description = arthur[4];
                template.Copyright   = arthur[5];
                template.Guid        = arthur[6];
                template.Date        = arthur[7];
                template.Version     = arthur[8];
                template.Caption     = Host.Caption;
                template.Platform    = Host.Platform;
                template.Type        = Host.Type.ToString();
                template.Registry    = DefaultRegistryPath();
                template.Resource    = DefaultResourcePath();
                template.Module      = DefaultModulePath();

                string       modpath = string.Format("{0}\\{1}\\{1}", template.Module, ProjectName());

                template.File        = modpath + ".psm1";
                template.Manifest    = modpath + ".psd1";

                template.Shortcut    = DefaultShortcutPath();

                return template;                
            }
            public void GetHostController()
            {
                if (Host != null)
                    throw new Exception("Exception [!] Host controller already loaded");

                Host = new HostController(Context);

                Update(0,"[+] <Operating System>");
            }
			public void GetRegistryKeyController()
            {
                if (Registry != null)
                    throw new Exception("Exception [!] Registry controller already loaded");

                // check for environment variable
                string FightingEntropy = Env("FightingEntropy");

                // select registry path
                string fullname        = FightingEntropy ?? DefaultRegistryPath();

                if (Microsoft.Win32.Registry.GetValue(fullname.Replace("HKLM:","HKEY_LOCAL_MACHINE"), "", null) != null)
                    Registry = new RegistryKeyController(fullname);
                else
                    Registry = new RegistryKeyController(fullname, DefaultTemplate());

                // test/set environment path for persistence
                if (FightingEntropy == null)
                    Environment.SetEnvironmentVariable("FightingEntropy", fullname, EnvironmentVariableTarget.Machine);

                // populate module properties
                RegistryKeyTemplate template = Registry.GetTemplate();
                
                Name        = template.Name;
                Company     = template.Company;
                Author      = template.Author;
                Source      = template.Source;
                Description = template.Description;
                Copyright   = template.Copyright;
                Guid        = new Guid(template.Guid);
                Date        = new Format.ModDateTime(template.Date);
                Version     = new ModuleVersion(new Version(template.Version), Date, Guid);

                Update(0,"[+] <Module Registy>");
            }
            public void GetRootController()
            {
                if (Root != null)
                    throw new Exception("Exception [!] Root controller already loaded");

                Root = new RootController(Registry.GetTemplate());

                Update(0,"[+] <Module Root>");
            }
            public void GetManifestController()
            {
                if (Manifest != null)
                    throw new Exception("Exception [!] Manifest controller already loaded");

                Manifest = new ManifestController(Registry.GetTemplate());

                // Load manifest
                LoadManifest();

                Update(0,"[+] <Module Manifest>");
            }
            public string[] LoadManifestControl()
            {
                return new string[]
                {
                    "Computer.png                    , 87EAB4F74B38494A960BEBF69E472AB0764C3C7E782A3F74111F993EA31D1075" ,
                    "DefaultApps.xml                 , EEC0F0DFEAC1B4172880C9094E997C8A5C5507237EB70A241195D7F16B06B035" ,
                    "down.png                        , 0F14F2184720CC89911DD0FB234954D83275672D5DBA3F48CBDAFA070C0376B4" ,
                    "failure.png                     , 59D479A0277CFFDD57AD8B9733912EE1F3095404D65AB630F4638FA1F40D4E99" ,
                    "FEClientMod.xml                 , 326C8D3852895A3135144ACCBB4715D2AE49101DCE9E64CA6C44D62BD4F33D02" ,
                    "FEServerMod.xml                 , 3EA9AF3FFFB5812A3D3D42E5164A58EF2FC744509F2C799CE7ED6D0B0FF9016D" ,
                    "header-image.png                , 38F1E2D061218D31555F35C729197A32C9190999EF548BF98A2E2C2217BBCB88" ,
                    "left.png                        , BE62B17A91BDCC936122557397BD90AA3D81F56DDA43D62B5FDBCEDD10C7AFFB" ,
                    "MDTClientMod.xml                , B2BA25AEB67866D17D8B22BFD31281AFFF0FFE1A7FE921A97C51E83BF46F8603" ,
                    "MDTServerMod.xml                , C4B12E67357B54563AB042617CEC2B56128FD03A9C029D913BB2B6CC65802189" ,
                    "MDT_LanguageUI.xml              , 8968A07D56B4B2A56F15C07FC556432430CB1600B8B6BBB13C332495DEE95503" ,
                    "PSDClientMod.xml                , C90146EECF2696539ACFDE5C2E08CFD97548E639ED7B1340A650C27F749AC9CE" ,
                    "PSDServerMod.xml                , C90146EECF2696539ACFDE5C2E08CFD97548E639ED7B1340A650C27F749AC9CE" ,
                    "right.png                       , A596F8859E138FA362A87E3253F64116368C275CEE0DA3FDD6A686CBE7C7069A" ,
                    "success.png                     , 46757AB0E2D3FFFFDBA93558A34AC8E36F972B6F33D00C4ADFB912AE1F6D6CE2" ,
                    "up.png                          , 09319D3535B26451D5B7A7F5F6F6897431EBDC6AED261288F13C2C65D50C4346" ,
                    "vendorlist.txt                  , A37B6652014467A149AC6277D086B4EEE7580DDB548F81B0B2AA7AC78C240874" ,
                    "warning.png                     , 845FEDFCB46ABDA1FDEBDE0BDC6A62853A4358E0435E8C8A3A60DC191D059EDD" ,
                    "Wifi.cs                         , 653A421E4F29882DA8276F9D543FD792D249BE141F2043BDC65C17C6B6FAC77B" ,
                    "zipcode.txt                     , E471E887F537FA295A070AB41E21DEE978181A92CB204CA1080C6DC32CBBE0D8" ,
                };
            }
            public string[] LoadManifestFunction()
            {
                return new string[]
                {
                    "Copy-FileStream.ps1             , 862B3E6913475FC321387FAAE8C0BA3298759D7F55D7E11D2FDDF6E34257BECC" ,
                    "Get-AssemblyList.ps1            , EBEF2B109FE5646522579BDBBC6BE7BD7465C0CA5D10405248A13C9495FA40E4" ,
                    "Get-ControlExtension.ps1        , A7ABC20AA24A13DDFBE38DA83CB1DC52032504C60A6EAA055816DCDE94B01966" ,
                    "Get-DcomSecurity.ps1            , 8507E507DECF99A078C45C3157F27D93DE35B0004F4C54DFBFF5ACB4559462A3" ,
                    "Get-EnvironmentKey.ps1          , AB1B926D0B567F9ED943D83C58BC0274129D9D0D2BFE7EAADEEBD99A6EAA448E" ,
                    "Get-EventLogArchive.ps1         , DFD1FF7AB141951938A931F3FDDFB275DC72C1151E02B2BFC3303080154E4995" ,
                    "Get-EventLogConfigExtension.ps1 , 48130EED8EED86A2B365912FF7BD440DE2310759159AE8EFCD8B03809C92BB5A" ,
                    "Get-EventLogController.ps1      , 644BDF1ECBC6BF4A0E9D611D0F8C30115019D996CCB07184FAADEF30A73EFEB8" ,
                    "Get-EventLogProject.ps1         , 29AEA454834222697F83400888FE74EEB77B6ABF43707D844AD5A7E77B24E3CB" ,
                    "Get-EventLogRecordExtension.ps1 , D0A6C8AD8801060EF0EE7CDF39065321E16B233E9755E714DB0C030AC95BF9A0" ,
                    "Get-EventLogXaml.ps1            , CD667980014974ABC7287678E19C3959CE87660C09DBF2EBB96D18B962C3D390" ,
                    "Get-FEADLogin.ps1               , C900FE37D5FC0F63A1E0BC5DD9B36C57448331A8A479C2E0A31880E8D9E35CF4" ,
                    "Get-FEDCPromo.ps1               , 4F668EE8E56F9E8C74D5C015411C439DDC54978B55D0CEB6786D7412098A47CB" ,
                    "Get-FEDevice.ps1                , 409D7C7F190FCD690A6618B542C0352B6D682D2C7DE0A62973A2B9CB6266F98F" ,
                    "Get-FEImageManifest.ps1         , F01DF0E164A47A56E2F9D9F4CD2F93F3C703B9AAA7C1C5750130623187BE1D5E" ,
                    "Get-FEModule.ps1                , 36E1668FDE016158458C663874CA8D41C6367DA5DBF31D600149025C85271D2A" ,
                    "Get-FENetwork.ps1               , 874C435C5AFB476FCFA707FEEDEAB03AEA1526B40AAD5F8D78C00181E08093F2" ,
                    "Get-FEProcess.ps1               , 0D8AA28C157D001A5A1222DA72076C168075CC431BE0C4C88FA64434B96FB29C" ,
                    "Get-FESystem.ps1                , 45125620B1AB92BD84FCC54BB823C35BADA82092BA08B835D1E5F68ECEDBCAA0" ,
                    "Get-MdtModule.ps1               , F4B9015A37930052ACDF583C8A35A22FF5C6F545720E2F888D671ADA811E79E7" ,
                    "Get-PowerShell.ps1              , 8E566FA8AD0C23919501012AA7266691729D327F83D6C0792E4539EB583CA041" ,
                    "Get-PropertyItem.ps1            , 92CF80AB4DD5115E333E1CE67F9E24DB7701FC0DEB15F16E11C06667325E5CD1" ,
                    "Get-PropertyObject.ps1          , 5F722AE1FAA35C89D6588768B106344B193D2500474E5186BC9B8D22A3130B52" ,
                    "Get-PsdLog.ps1                  , 6411411A6B660F72E872DDE58503039180380C39014983E51CE4D1DC40EE2882" ,
                    "Get-PsdLogGUI.ps1               , 468EC4816E873926BE27A1F8432131F360816DB0A0BBDD7E3773E5EAD061DF8C" ,
                    "Get-PsdModule.ps1               , 7CBDE4526EC57758002D00C6D8BE50C5E4E7292351C1E4ED2658224C40C407E7" ,
                    "Get-ThreadController.ps1        , 2E731F4282F6CA2281E168E8DB6C7E6ED3811AA6F15347C10581A943DB2117B5" ,
                    "Get-UserProfile.ps1             , 10E3A87935D90E61F0030011D4BEE99877E9B432A4B507EFE8577C87AEC2BE69" ,
                    "Get-ViperBomb.ps1               , 58C1491DE7B8C9FD243462BA1041BC3AE08330C43B44DA3DB7B8727B83795BDF" ,
                    "Get-WhoisUtility.ps1            , CFFCA2A3C03293F9119B9BFEC3A99E8C4902999F66480D7D1617D2E3D2359C50" ,
                    "Initialize-FeAdInstance.ps1     , BE6FEF0399DA960BB25BC7748C07FA194F12C361F4C59498A86495EFDA0D20CC" ,
                    "Initialize-VmNode.ps1           , 5A86F46A71E147D6F069A45403B6A550548B946039353ECA4C836EE04DBAD912" ,
                    "Install-IISServer.ps1           , C8C0EA6332560E3BCF0B37FBDF45436D54A65ED005705BE29AA25F18B33ABA54" ,
                    "Install-Psd.ps1                 , 7CF53D11B15CF7E712A8E35142094C4563A9DCD08917C65D2022C7B014BE4E9F" ,
                    "Invoke-cimdb.ps1                , 8835574220B607F27C45A831CD5CECBD6757364486AF9508DF71FC9495B82D0B" ,
                    "New-Document.ps1                , 342AE1373890D6036AECF2A53D93F3A2C67E0CE3A951E002BDA117FEBF4C62FC" ,
                    "New-EnvironmentKey.ps1          , 18A1BEBD461E666AAB42383B8C4ECA950929552B1C9704B53CBF6FF002936FFC" ,
                    "New-FEConsole.ps1               , 89412440E1C2A65D7F33A7A93CAEC8B26C6E2E2A9E41E1DE320A401C87A7F871" ,
                    "New-FEFormat.ps1                , 95126B932F16DB2634446B83372948F6538066D6B3A130D09D604AD315752099" ,
                    "New-FEInfrastructure.ps1        , D93A297BF83BEB130B9F9D24E855654F8FB670A594AC4AF8BC338C7CA6521F24" ,
                    "New-MarkdownFile.ps1            , 5A3D759D55390C4F72AFC546C977E69F0F9BE5AF2A45D96010E8550B0CF27C2B" ,
                    "New-TranscriptionCollection.ps1 , BC3B020A6F0CF8CD5CF8C06CF2EE725A7E3C2CC2886F471CB1806936032D4307" ,
                    "New-VmController.ps1            , CD7B43468F73E13595034206C10ADA34E05507C9D1ABACCF7B48B98F9E09ED98" ,
                    "Search-WirelessNetwork.ps1      , 30A3024E8FCFAFC93B953CE44CC1E03FA901313063F29500207854E8F0E856D2" ,
                    "Set-AdminAccount.ps1            , C5E6A661A7DEF8B8C791DE1AED278586B2709A0C6A550FFF690FF707464DF732" ,
                    "Set-ScreenResolution.ps1        , 9F14E7E9190ABD299F7A21F1E7A57809EBF0E5182099DE845573ABB2E55BDFCF" ,
                    "Show-ToastNotification.ps1      , 61BDDF6AF8143CEA43FA1648F2AF172D68A1CCE4750D326449EB50A742EAC04F" ,
                    "Start-TCPSession.ps1            , 878BA5EF733666431D5EC94C2C6C132B6E4F4F6DFA1664AE872F7F0F7FCD59CE" ,
                    "Update-PowerShell.ps1           , BA12BE91B23691DE30CCF7583CCFA397B56B7E9E8B89B157C9A79FC808F1F0C5" ,
                    "Write-Element.ps1               , D30BCDDD5352D70C730B70E458D4900CE7904EEDF9A387B29EA4F69EA3D16327" ,
                    "Write-Theme.ps1                 , 1FC13440093B76ABADBD6960FBE788F5029FF288E8B3ABE95781994FD14935BB" ,
                    "Write-Xaml.ps1                  , 33D7A14875469A67EB1DFEE2805DA27E734788A3CD001A45FAE46B6C7BDDC7CF"
                };
            }
            public string[] LoadManifestGraphic()
            {
                return new string[]
                {
                    "background.jpg                  , 94FD6CB32F8FF9DD360B4F98CEAA046B9AFCD717DA532AFEF2E230C981DAFEB5" ,
                    "banner.png                      , 057AF2EC2B9EC35399D3475AE42505CDBCE314B9945EF7C7BCB91374A8116F37" ,
                    "icon.ico                        , 594DAAFF448F5306B8B46B8DB1B420C1EE53FFD55EC65D17E2D361830659E58E" ,
                    "OEMbg.jpg                       , D4331207D471F799A520D5C7697E84421B0FA0F9B574737EF06FC95C92786A32" ,
                    "OEMlogo.bmp                     , 98BF79CAE27E85C77222564A3113C52D1E75BD6328398871873072F6B363D1A8" ,
                    "PSDBackground.bmp               , 05ABBABDC9F67A95D5A4AF466149681C2F5E8ECD68F11433D32F4C0D04446F7E" ,
                    "sdplogo.png                     , 87C2B016401CA3F8F8FAD5F629AFB3553C4762E14CD60792823D388F87E2B16C"
                };
            }
            private void LoadManifestType(uint type, string name, string[] list)
            {
                Manifest.AddFolder(type, name);
                // print string in console

                foreach (string line in list)
                {
                    string[] pair = line.Replace(" ","").Split(new char[]{','});

                    Manifest.AddFile(type, pair[0], pair[1]);
                    // print string in console
                }
            }
            private void LoadManifest()
            {
                // Control
                LoadManifestType(0, "Control", LoadManifestControl());

                // Functions
                LoadManifestType(1, "Functions", LoadManifestFunction());

                // Graphics
                LoadManifestType(0, "Graphics", LoadManifestGraphic());
            }
            public override string ToString()
            {
                return string.Format("<{0} Module Controller>", DisplayName());
            }
        }
    }
    
    // EventLog classes deal specifically with providers and individual event logs
    namespace EventLog
    {
        [Serializable]
        public class EventProperty
        {
            public int    Index;
            public string Value;
            public EventProperty()
            {
                
            }
            public EventProperty(int index, System.Diagnostics.Eventing.Reader.EventProperty p)
            {
                Index = index;
                Value = (p != null && p.Value != null) ? p.Value.ToString() : null;
            }
        }
        
        [Serializable]
        public class Entry
        {
            public uint                     Index;
            public uint                      Rank;
            public uint                  LogIndex;
            public string                Provider;
            public Format.ModDateTime TimeCreated;
            public string                    Date;
            public uint                        Id;
            public string                   Level;
            public string                 Message;
            public string[]               Content;
            public byte?                  Version;
            public ushort?             Qualifiers;
            public byte?                 LevelRaw;
            public ushort?                   Task;
            public byte?                   Opcode;
            public long?                 Keywords;
            public long?                 RecordId;
            public Guid?               ProviderId;
            public string                 LogName;
            public int?                 ProcessId;
            public int?                  ThreadId;
            public string             MachineName;
            public Security.Identifier     UserId;
            public Guid?               ActivityId;
            public Guid?        RelatedActivityId;
            public string            ContainerLog;
            public int[]          MatchedQueryIds;
            public string       OpcodeDisplayName;
            public string         TaskDisplayName;
            public string[]  KeywordsDisplayNames;
            public EventProperty[]     Properties;
            public bool                   IsError;
            public Entry(uint rank, uint logIndex, EventRecord e)
            {
                Rank        = rank;
                LogIndex    = logIndex;

                Provider    = e.ProviderName;
                DateTime dt = e.TimeCreated.HasValue ? e.TimeCreated.Value : DateTime.MinValue;
                TimeCreated = new Format.ModDateTime(dt);

                Date        = TimeCreated.ArchiveString();

                Id          = (uint)e.Id;
                Level       = e.LevelDisplayName;

                string msg  = e.FormatDescription();

                if (msg == null)
                {
                    Message = "-";
                    Content = new string[] { "-" };
                }
                else
                {
                    string[] parts = msg.Split(new[] { '\n' }, StringSplitOptions.None);
                    Message = parts.Length > 0 ? parts[0] : "-";
                    Content = parts.Length > 0 ? parts : new string[] { "-" };
                }

                EventLogRecord r = e as EventLogRecord;

                if (r != null)
                {
                    Version              = r.Version;
                    Qualifiers           = r.Qualifiers.HasValue ? (ushort?)((ushort)r.Qualifiers.Value) : null;
                    LevelRaw             = r.Level.HasValue ? (byte?)((byte)r.Level.Value) : null;
                    Task                 = r.Task.HasValue ? (ushort?)((ushort)r.Task.Value) : null;
                    Opcode               = r.Opcode.HasValue ? (byte?)((byte)r.Opcode.Value) : null;
                    Keywords             = (long?)r.Keywords;
                    RecordId             = r.RecordId;
                    ProviderId           = r.ProviderId;
                    LogName              = r.LogName;
                    ProcessId            = r.ProcessId;
                    ThreadId             = r.ThreadId;
                    MachineName          = r.MachineName;
                    UserId               = new Security.Identifier(r.UserId);
                    ActivityId           = r.ActivityId;
                    RelatedActivityId    = r.RelatedActivityId;
                    ContainerLog         = r.ContainerLog;
                    MatchedQueryIds      = r.MatchedQueryIds != null ? new List<int>(r.MatchedQueryIds).ToArray() : null;
                    OpcodeDisplayName    = r.OpcodeDisplayName;
                    TaskDisplayName      = r.TaskDisplayName;
                    KeywordsDisplayNames = r.KeywordsDisplayNames != null ? new List<string>(r.KeywordsDisplayNames).ToArray() : null;

                    if (r.Properties != null)
                    {
                        var list         = new List<EventProperty>();

                        for (int i = 0; i < r.Properties.Count; i++)
                            list.Add(new EventProperty(i, r.Properties[i]));

                        Properties       = list.ToArray();
                    }

                    IsError = false;
                }
            }
            public Entry(uint index, uint providerIndex, DateTime? timeCreated, Exception ex)
            {
                Index         = index;
                LogIndex      = providerIndex;
                DateTime dt;
                if (timeCreated.HasValue)
                    dt = timeCreated.Value;
                else
                    dt = DateTime.MinValue;

                TimeCreated   = new Format.ModDateTime(dt);
                Id            = 0;
                Level         = "Error";
                Message       = string.Format("Exception_Record {0}: {1}",ex.GetType().Name,ex.Message);
                IsError       = true;
            }
            public Entry(Entry archived)
            {
                Index                = archived.Index;
                Rank                 = archived.Rank;
                LogIndex             = archived.LogIndex;
                Provider             = archived.Provider;
                TimeCreated          = archived.TimeCreated;
                Date                 = archived.Date;
                Id                   = archived.Id;
                Level                = archived.Level;
                Message              = archived.Message;
                Content              = archived.Content;
                Version              = archived.Version;
                Qualifiers           = archived.Qualifiers;
                LevelRaw             = archived.LevelRaw;
                Task                 = archived.Task;
                Opcode               = archived.Opcode;
                Keywords             = archived.Keywords;
                RecordId             = archived.RecordId;
                ProviderId           = archived.ProviderId;
                LogName              = archived.LogName;
                ProcessId            = archived.ProcessId;
                ThreadId             = archived.ThreadId;
                MachineName          = archived.MachineName;
                UserId               = archived.UserId;
                ActivityId           = archived.ActivityId;
                RelatedActivityId    = archived.RelatedActivityId;
                ContainerLog         = archived.ContainerLog;
                MatchedQueryIds      = archived.MatchedQueryIds;
                OpcodeDisplayName    = archived.OpcodeDisplayName;
                TaskDisplayName      = archived.TaskDisplayName;
                KeywordsDisplayNames = archived.KeywordsDisplayNames;
                Properties           = archived.Properties;
                IsError              = archived.IsError;
            }
            public override string ToString()
            {
                return string.Format("{0} [{1}] {2}", Provider, Id, TimeCreated);
            }
        }

        public class Provider
        {
            public uint                        Index;
            public string                DisplayName;
            public string                       Name;
            public uint                        Total;
            public List<Entry>                Output;
            [System.Management.Automation.Hidden]
            public TimeSpan                 Duration { get; private set; }
            [System.Management.Automation.Hidden]
            public bool                     ReadOnly { get; private set; }
            public Thread.IProgressCallback Callback;
            public string                CallbackKey;
            public bool                    HadErrors = false;
            public Provider(uint index, string name, Thread.IProgressCallback callback, string callbackKey)
            {
                Initialize(index, name);
                ReadOnly    = false;
                Callback    = callback;
                CallbackKey = callbackKey;
                Collect();
            }
            public Provider(bool reconstitute, uint index, string name)
            {
                Initialize(index, name);
                ReadOnly   = true;
            }
            public void Initialize(uint index, string name)
            {
                Index           = index;
                DisplayName     = name;
                Name            = name.Replace("/", ".").Replace(" ", "_");
                Output          = new List<Entry>();
            }
            private void WriteStatus(string message, int current, int total)
            {
                int safeCurrent = (current >= 0) ? current : 0;
                int safeTotal   = (total   >= 0) ? total   : 0;

                Callback.Report(CallbackKey, DisplayName, safeCurrent, safeTotal, message);
            }
            private void WriteStatus(string message)
            {
                WriteStatus(message, -1, -1);
            }
            public void Collect()
            {
                if (ReadOnly)
                    throw new InvalidOperationException("Provider is in read-only mode");

                uint      count = 0;
                uint errorCount = 0;
                ulong  estTotal = 0;
                string      msg = null;
                
                string fileName = DisplayName.Replace("/", "%4") + ".evtx";
                string  logPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),"winevt", "Logs", fileName);

                DateTime lastGoodTime = File.GetCreationTime(logPath);

                // Try to get estimated total number of events (best effort only)
                try
                {
                    EventLogSession   session = new EventLogSession();
                    EventLogInformation  info = session.GetLogInformation(DisplayName, PathType.LogName);
                    estTotal                  = info.RecordCount.HasValue ? (ulong)info.RecordCount.Value : 0;
                }
                catch
                {
                    estTotal                  = 0;
                }

                // Only create a tracker if we actually have a non-zero estimate
                Format.PercentTracker tracker = null;
                int            nextCheckpoint = 0;

                if (estTotal > 0)
                {
                    tracker        = new Format.PercentTracker((uint)estTotal, "EventLog");
                    nextCheckpoint = 0;
                }

                // Start timing
                Stopwatch stopwatch = Stopwatch.StartNew();

                try
                {
                    EventLogQuery query = new EventLogQuery(DisplayName, PathType.LogName);

                    using (var reader = new EventLogReader(query))
                    {
                        System.Diagnostics.Eventing.Reader.EventRecord rec;
                        int index = 0;

                        while (true)
                        {
                            try
                            {
                                rec = reader.ReadEvent();
                            }
                            catch (Exception ex)
                            {
                                HadErrors = true;
                                errorCount ++;

                                Output.Add(new Entry((uint)index, Index, lastGoodTime, ex));
                                index ++;
                                continue;
                            }

                            if (rec == null)
                                break;

                            if (rec.TimeCreated.HasValue)
                                lastGoodTime = rec.TimeCreated.Value;

                            Output.Add(new Entry((uint)index, Index, rec));
                            count ++;
                            index ++;

                            // Checkpoint-based progress reporting only if we have a tracker
                            if (tracker != null && nextCheckpoint < tracker.Output.Length)
                            {
                                Format.PercentIndex pi = tracker.Output[nextCheckpoint];

                                if (count >= pi.Current)
                                {
                                    msg = string.Format("Processing [~] {0} {1}", DisplayName, pi.ToString());

                                    WriteStatus(msg, (int)pi.Current, (int)estTotal);
                                    nextCheckpoint ++;
                                }
                            }
                        }
                    }

                    // Final completion message
                    msg = string.Format("Completed [+] {0}, ({1}) records collected", DisplayName, count);

                    if (errorCount > 0)
                        msg += msg + string.Format(", ({0}) records failed", errorCount);

                    WriteStatus(msg, (int)count, (int)estTotal);
                }
                catch
                {
                    HadErrors = true;
                    WriteStatus(string.Format("Exception [!] {0}, error occurred during collection", DisplayName));
                }

                // Stop timing and store duration
                stopwatch.Stop();
                Duration = stopwatch.Elapsed;

                // Sort and reindex
                Output.Sort(delegate (Entry a, Entry b)
                {
                    return a.TimeCreated.Value.CompareTo(b.TimeCreated.Value);
                });

                for (int i = 0; i < Output.Count; i++)
                    Output[i].Rank = (uint)i;

                Total = (uint)Output.Count;
            }
            public override string ToString()
            {
                return DisplayName;
            }
        }

        public static class Merger
        {
            public static List<Entry> MergeAndSort(List<Provider> providers)
            {
                int total = 0;
                foreach (var p in providers)
                    total += p.Output.Count;

                var all = new List<Entry>(total);

                foreach (var p in providers)
                    all.AddRange(p.Output);

                all.Sort(delegate(Entry a, Entry b)
                {
                    return a.TimeCreated.Value.CompareTo(b.TimeCreated.Value);
                });

                for (int i = 0; i < all.Count; i++)
                {
                    all[i].Index = (uint)i;
                }

                return all;
            }
        }
    }

    // Ties together EventLog, Platform, Hardware stuff + threading
    namespace Snapshot
    {
        public enum Mode
        {
            Initial = 0,
            Create = 1,
            Restore = 2,
            Complete = 3
        }

        [Serializable]
        public class Metadata
        {
            public Format.ModDateTime    Start;
            public Format.ModDateTime?     End;
            public TimeSpan            Elapsed;
            public Platform.Computer  Computer;
            public Security.Identifier Account;
            public string          DisplayName;
            public Guid                   Guid;
            public Format.Version      Version;
            public Metadata(DateTime start, Platform.Computer computer, Security.Identifier account, Format.Version version)
            {
                Start        = new Format.ModDateTime(start);
                End          = null;
                Elapsed      = TimeSpan.Zero;

                Computer     = computer;
                DisplayName  = new Format.ModDateTime(start).ArchiveString() + "-" + computer.GetSafeDisplayName();

                Guid         = System.Guid.NewGuid();
                Account      = account;
                Version      = version;
            }
            public void Complete(string elapsedString)
            {
                Elapsed      = TimeSpan.Parse(elapsedString);
                End          = new Format.ModDateTime(Start.Value + Elapsed);
            }
        }

        [Serializable]
        public class Machine
        {
            public Platform.Bios               Bios;
            public Platform.OperatingSystem      OS;
            public Platform.ComputerSystem Computer;
            public Hardware.Processors   Processors;
            public Hardware.Disks             Disks;
            public Hardware.NetworkAdapters Network;
            public Machine()
            {
                Bios       = new Platform.Bios();
                OS         = new Platform.OperatingSystem();
                Computer   = new Platform.ComputerSystem();
                Processors = new Hardware.Processors();
                Disks      = new Hardware.Disks();
                Network    = new Hardware.NetworkAdapters();
            }
        }

        [Serializable]
        public class Event
        {
            public EventLog.Provider[] Provider;
            public uint                   Total;
            public EventLog.Entry[]      Output;
            public Event()
            {
                Clear();
            }
            public void Clear()
            {
                Provider = new EventLog.Provider[0];
                Total    = 0;
                Output   = new EventLog.Entry[0];
            }
            public string[] LogProviderNames()
            {
                List<string> safe = new List<string>();

                try
                {
                    var session = new EventLogSession();
                    var names   = session.GetLogNames();

                    if (names == null)
                        return Array.Empty<string>();

                    foreach (var name in names)
                    {
                        try
                        {
                            var info = session.GetLogInformation(name, PathType.LogName);

                            safe.Add(name);
                        }
                        catch
                        {
                            continue;
                        }
                    }

                    safe.Sort(StringComparer.OrdinalIgnoreCase);
                    return safe.ToArray();
                }
                catch
                {
                    return Array.Empty<string>();
                }
            }
        }

        [Serializable]
        public class Archive
        {
            public Metadata             Metadata;
            public Machine               Machine;
            public string[]            Providers;
            public List<EventLog.Entry>  Entries;
        }

        public static class BinarySerializer
        {
            public static byte[] Serialize(object obj)
            {
                using (var ms = new MemoryStream())
                {
                    var bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
                    bf.Serialize(ms, obj);
                    return ms.ToArray();
                }
            }
            public static T Deserialize<T>(byte[] data)
            {
                using (var ms = new MemoryStream(data))
                {
                    var bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
                    return (T)bf.Deserialize(ms);
                }
            }
        }

        public static class ArchiveWriter
        {
            private const int MaxEntriesPerChunk = 25000;
            public delegate void ProgressCallback(int processed, int total);
            public static void Write(string zipPath, Archive archive, ProgressCallback progress)
            {
                if (archive == null || archive.Entries == null)
                {
                    throw new ArgumentException("Archive object is null or contains (0) entries");
                }

                using (var fs = new FileStream(zipPath, FileMode.Create, FileAccess.Write, FileShare.None))
                using (var zip = new ZipArchive(fs, ZipArchiveMode.Create))
                {

                    var metaEntry = zip.CreateEntry("metadata.bin", CompressionLevel.Optimal);
                    using (var s = metaEntry.Open())
                    {
                        byte[] data = BinarySerializer.Serialize(archive.Metadata);
                        s.Write(data, 0, data.Length);
                    }

                    var machineEntry = zip.CreateEntry("machine.bin", CompressionLevel.Optimal);
                    using (var s = machineEntry.Open())
                    {
                        byte[] data = BinarySerializer.Serialize(archive.Machine);
                        s.Write(data, 0, data.Length);
                    }

                    // Write provider names
                    var provEntry = zip.CreateEntry("providers.bin", CompressionLevel.Optimal);
                    using (var s = provEntry.Open())
                    {
                        byte[] data = BinarySerializer.Serialize(archive.Providers);
                        s.Write(data, 0, data.Length);
                    }

                    int total      = archive.Entries.Count;
                    int processed  = 0;
                    int chunkIndex = 0;

                    while (processed < total)
                    {
                        int remaining = total - processed;
                        int take      = remaining < MaxEntriesPerChunk ? remaining : MaxEntriesPerChunk;

                        List<EventLog.Entry> chunk = new List<EventLog.Entry>();
                        for (int i = 0; i < take; i++)
                            chunk.Add(archive.Entries[processed + i]);

                        string name  = "entries_" + chunkIndex.ToString("D5") + ".bin";

                        var entEntry = zip.CreateEntry(name, CompressionLevel.Optimal);
                        using (var s = entEntry.Open())
                        {
                            byte[] data = BinarySerializer.Serialize(chunk);
                            s.Write(data, 0, data.Length);
                        }

                        processed += take;
                        chunkIndex++;

                        if (progress != null)
                            progress(processed, total);
                    }
                }
            }
        }

        public static class ArchiveReader
        {
            public delegate void ProgressCallback(int processed, int total);
            public static Archive Read(string zipPath, ProgressCallback progress)
            {
                if (!File.Exists(zipPath))
                    throw new FileNotFoundException("Archive file not found", zipPath);

                Archive archive = new Archive();
                archive.Entries = new List<EventLog.Entry>();

                using (var fs = new FileStream(zipPath, FileMode.Open, FileAccess.Read, FileShare.Read))
                using (var zip = new ZipArchive(fs, ZipArchiveMode.Read))
                {
                    var metaEntry = zip.GetEntry("metadata.bin");
                    using (var s = metaEntry.Open())
                    using (var ms = new MemoryStream())
                    {
                        s.CopyTo(ms);
                        archive.Metadata = BinarySerializer.Deserialize<Metadata>(ms.ToArray());
                    }

                    var machineEntry = zip.GetEntry("machine.bin");
                    using (var s = machineEntry.Open())
                    using (var ms = new MemoryStream())
                    {
                        s.CopyTo(ms);
                        archive.Machine = BinarySerializer.Deserialize<Machine>(ms.ToArray());
                    }

                    // Read provider names
                    var provEntry = zip.GetEntry("providers.bin");
                    using (var s = provEntry.Open())
                    using (var ms = new MemoryStream())
                    {
                        s.CopyTo(ms);
                        archive.Providers = BinarySerializer.Deserialize<string[]>(ms.ToArray());
                    }

                    List<ZipArchiveEntry> chunks = new List<ZipArchiveEntry>();

                    foreach (var entry in zip.Entries)
                    {
                        if (entry.Name.StartsWith("entries_") && entry.Name.EndsWith(".bin"))
                            chunks.Add(entry);
                    }

                    // Sort lexicographically
                    chunks.Sort(delegate(ZipArchiveEntry a, ZipArchiveEntry b)
                    {
                        return string.CompareOrdinal(a.Name, b.Name);
                    });

                    int total = chunks.Count;
                    int processed = 0;

                    // Read each chunk
                    foreach (var chunk in chunks)
                    {
                        using (var s = chunk.Open())
                        using (var ms = new MemoryStream())
                        {
                            s.CopyTo(ms);
                            List<EventLog.Entry> list =
                                BinarySerializer.Deserialize<List<EventLog.Entry>>(ms.ToArray());

                            if (list != null)
                                archive.Entries.AddRange(list);
                        }

                        processed++;

                        if (progress != null)
                            progress(processed, total);
                    }
                }

                return archive;
            }
        }
        
        public class Controller
        {
            public Mode                  Mode;
            public Console.Controller Console { get; private set; }
            public Thread.Controller   Thread { get; private set; }
            public object                Xaml { get; set; }
            public string                Path;
            public Metadata          Metadata;
            public Machine            Machine;
            public Event                Event;
            public Controller()
            {
                Console     = new FightingEntropy.Console.Controller();
                Console.Initialize();

                Mode        = Mode.Initial;

                Thread      = new FightingEntropy.Thread.Controller();
                string asmPath = System.Reflection.Assembly.GetExecutingAssembly().Location;

                Thread.AddSessionStateObject("Assembly","Initial","FightingEntropy","FightingEntropy ISS assembly bytes", asmPath);

                Thread.SessionState[0].ToggleLock();
            }
            public void Update(int state, string status)
            {
                Console.Update(state, status);
            }
            public void Clear()
            {
                EnsureCreateMode();

                Metadata = null;
                Machine  = null;
                Event    = null;
            }
            private void EnsureCreateMode()
            {
                if (Mode != Mode.Create)
                    throw new InvalidOperationException("Controller is not in [Create] mode.");
            }
            private void EnsureRestoreMode()
            {
                if (Mode != Mode.Restore)
                    throw new InvalidOperationException("Controller is not in [Restore] mode.");
            }
            public void SetCreatePath(string fullname)
            {
                if (string.IsNullOrWhiteSpace(fullname))
                    throw new ArgumentException("Path cannot be null or empty: " + fullname);

                fullname = System.IO.Path.GetFullPath(fullname);

                if (!Directory.Exists(fullname))
                    throw new DirectoryNotFoundException("Directory does not exist: " + fullname);

                Path = fullname;
                Mode = Mode.Create;
            }
            public void SetRestorePath(string fullname)
            {
                if (string.IsNullOrWhiteSpace(fullname))
                    throw new ArgumentException("Path cannot be null or empty: " + fullname);

                fullname = System.IO.Path.GetFullPath(fullname);

                if (!File.Exists(fullname))
                    throw new FileNotFoundException("Archive file does not exist: " + fullname);

                Path = fullname;

                // Attempt to enter Restore mode
                Mode = Mode.Restore;
            }
            private Security.Identifier GetCurrentAccount()
            {
                WindowsIdentity id = System.Security.Principal.WindowsIdentity.GetCurrent();

                if (id == null || id.User == null)
                    throw new InvalidOperationException("Unable to determine current Windows identity.");

                return new Security.Identifier(id.User);
            }
            private ulong ComputeGlobalCurrent(Thread.Controller tc)
            {
                ulong total = 0;

                Thread.StatusEntry[] statuses = tc.GetStatusSnapshot();

                for (int i = 0; i < statuses.Length; i++)
                {
                    Thread.StatusEntry s = statuses[i];

                    if (s.Total > 0 && s.Current > 0)
                        total += (ulong)s.Current;
                }

                return total;
            }
            public static ulong GetReadableRecordCount(string logName)
            {
                try
                {
                    EventLogQuery query = new EventLogQuery(logName, PathType.LogName);

                    using (EventLogReader reader = new EventLogReader(query))
                    {
                        EventRecord first = reader.ReadEvent();
                        if (first == null || !first.RecordId.HasValue)
                            return 0;

                        ulong firstId = (ulong)first.RecordId.Value;

                        EventRecord last = first;
                        EventRecord temp;

                        while ((temp = reader.ReadEvent()) != null)
                            last = temp;

                        if (!last.RecordId.HasValue)
                            return 0;

                        ulong lastId = (ulong)last.RecordId.Value;

                        return (lastId - firstId) + 1;
                    }
                }
                catch
                {
                    return 0;
                }
            }
            private void CollectEventLogs()
            {
                // Get provider names
                string[] names = Event.LogProviderNames();
                if (names == null || names.Length == 0)
                {
                    Event.Provider = new EventLog.Provider[0];
                    Event.Output   = new EventLog.Entry[0];
                    Event.Total    = 0;
                    return;
                }

                // Compute global total record count (only for accessible logs)
                ulong globalTotalRecords = 0;

                try
                {
                    EventLogSession session = new EventLogSession();

                    for (int i = 0; i < names.Length; i++)
                    {
                        string logName = names[i];

                        try
                        {
                            // Check if backing .evtx exists
                            string fileName = logName.Replace("/", "%4") + ".evtx";
                            string  logPath = string.Format("{0}\\{1}\\{2}\\{3}", Environment.GetFolderPath(Environment.SpecialFolder.System), "winevt", "Logs", fileName);

                            if (!File.Exists(logPath))
                                continue;

                            EventLogInformation info = session.GetLogInformation(logName, PathType.LogName);

                            if (info.RecordCount.HasValue)
                            {
                                ulong readable = GetReadableRecordCount(logName);
                                globalTotalRecords += readable;
                            }
                        }
                        catch
                        {
                            // Skip inaccessible logs
                        }
                    }
                }
                catch
                {
                    globalTotalRecords = 0;
                }

                // Build name → index map
                System.Collections.Hashtable map = new System.Collections.Hashtable();
                for (int i = 0; i < names.Length; i++)
                    map[names[i]] = i;

                // Shorten thread controller reference
                Thread.Controller tc = Thread;

                // Enqueue work
                for (int i = 0; i < names.Length; i++)
                    tc.EnqueueWork(names[i]);

                string bootstrapScript = string.Format("[System.Reflection.Assembly]::Load(${0}) | Out-Null", tc.SessionState[0].Name);

                tc.AddSessionStateObject("Script","Bootstrap","LoadFEassembly","Invokes FE assembly",bootstrapScript);

                string[] workerLines = new string[]
                {
                    "param([FightingEntropy.Thread.Controller]$TC,[hashtable]$Map)",
                    "",
                    "$tid = [System.Threading.Thread]::CurrentThread.ManagedThreadId",
                    "",
                    "while ($true)",
                    "{",
                    "    $name = $null",
                    "    if (!$TC.TryDequeueWork([ref]$name)) { break }",
                    "    if ([string]::IsNullOrWhiteSpace($name)) { continue }",
                    "",
                    "    try",
                    "    {",
                    "        $TC.AddMessage(\"Starting [~] $name\")",
                    "",
                    "        $logIndex = $Map[$name]",
                    "",
                    "        $inst = [FightingEntropy.Thread.Instance]::new($logIndex,$name,$tid)",
                    "        $inst.Start()",
                    "        $TC.AddThread($inst)",
                    "",
                    "        $callback = [FightingEntropy.Thread.ProgressReporter]::new($TC)",
                    "",
                    "        $provider = [FightingEntropy.EventLog.Provider]::new($logIndex, $name, $callback, $tid)",
                    "        $TC.AddResult($provider)",
                    "",
                    "        $inst.Complete()",
                    "        $TC.AddMessage(\"Complete [+] $name, ($($provider.Total)) events, total time: [$($inst.Duration)]\")",
                    "    }",
                    "    catch",
                    "    {",
                    "        $TC.AddMessage(\"Exception [!] $name, $($_.Exception.Message)\")",
                    "    }",
                    "    finally",
                    "    {",
                    "        if ($inst -ne $null) { $TC.RemoveThread($inst.Id) }",
                    "    }",
                    "}"
                };

                string workerScript = string.Join("\n", workerLines);

                tc.AddSessionStateObject("Script","Worker","WorkerScript","Multithreaded worker script",workerScript);

                Update(0, string.Format("Initializing [~] RunspacePool ({0}) threads",tc.MaxThreads));

                tc.InitializePool();

                // Launch workers
                for (int i = 0; i < tc.MaxThreads; i++)
                {
                    System.Management.Automation.PowerShell ps = System.Management.Automation.PowerShell.Create();

                    ps.RunspacePool = tc.Pool;

                    // Load the script AND allow parameter binding
                    ps.AddScript(tc.BuildBootstrapBlock(), false);
                    ps.Invoke();
                    ps.Commands.Clear();

                    ps.AddScript(tc.BuildWorkerBlock(), false);
                    ps.AddParameter("TC", tc);
                    ps.AddParameter("Map", map);
                    tc.RegisterJob(ps.BeginInvoke());
                }

                // Pump messages + heartbeat
                while (tc.ActiveJobs() > 0 || !tc.Messages.IsEmpty)
                {
                    // Provider messages (progress, 5-min heartbeats, completion)
                    string[] msgs = tc.DrainMessages();
                    for (int i = 0; i < msgs.Length; i++)
                        Update(0, msgs[i]);

                    // Heartbeat every 60s
                    if (tc.HeartbeatDue(60))
                    {
                        // Compute global progress
                        ulong globalCurrent = ComputeGlobalCurrent(tc);
                        ulong globalTotal   = globalTotalRecords;

                        double pct = 0;
                        if (globalTotal > 0)
                            pct = ((double)globalCurrent / (double)globalTotal) * 100.0;

                        int threads = tc.ActiveJobs();

                        string hb = string.Format("Heartbeat [~] {0:0.00}% ({1:N0}/{2:N0} records), ({3}) threads processing",
                                                  pct, globalCurrent, globalTotal, threads);

                        Update(0, hb);

                        // Stall detection
                        string[] stalls = tc.DetectStalls(120);
                        for (int i = 0; i < stalls.Length; i++)
                            Update(0, stalls[i]);

                        tc.UpdateHeartbeat();
                    }

                    System.Threading.Thread.Sleep(25);
                }

                // Ensure all jobs finished
                for (int i = 0; i < tc.Jobs.Count; i++)
                    tc.Jobs[i].AsyncWaitHandle.WaitOne();

                tc.Pool.Close();

                // Merge results
                List<EventLog.Provider> providers = new List<EventLog.Provider>();

                foreach (object obj in tc.Bag)
                {
                    EventLog.Provider p = obj as EventLog.Provider;
                    if (p != null)
                        providers.Add(p);
                }

                providers.Sort(delegate(EventLog.Provider a, EventLog.Provider b)
                {
                    if (a == null && b == null) return  0;
                    if (a == null)              return -1;
                    if (b == null)              return  1;
                    return a.Index.CompareTo(b.Index);
                });

                Event.Provider = providers.ToArray();

                // Flatten + sort entries
                List<EventLog.Entry> all = new List<EventLog.Entry>();

                for (int i = 0; i < Event.Provider.Length; i++)
                {
                    EventLog.Entry[] entries = Event.Provider[i].Output.ToArray();
                    if (entries != null)
                    {
                        for (int j = 0; j < entries.Length; j++)
                            all.Add(entries[j]);
                    }
                }

                all.Sort(delegate(EventLog.Entry a, EventLog.Entry b)
                {
                    return System.DateTime.Compare(a.TimeCreated.Value, b.TimeCreated.Value);
                });

                Event.Output = all.ToArray();

                for (int i = 0; i < Event.Output.Length; i++)
                {
                    Event.Output[i].Index = (uint)i;
                }

                Event.Total  = (uint)all.Count;

                Update(1, string.Format("Completed [+] Snapshot: Event logs ({0}), elapsed [{1}]", Event.Output.Length, tc.Elapsed().ToString()));
            }
            public void CreateSnapshot()
            {
                EnsureCreateMode();

                Update(0, string.Format("Capturing [~] Snapshot: [" + DateTime.Now.ToString() + "]"));

                // Capture snapshot metadata
                Update(0, "Collecting [~] Metadata");
                TimeSpan           baseline = TimeSpan.Parse(((Console.Entry)Console.Last()).Elapsed);
                DateTime      snapshotStart = DateTime.Now - baseline;
                Platform.Computer  computer = new Platform.Computer(true);
                Security.Identifier account = GetCurrentAccount();
                Format.Version      version = new Format.Version(2026,3,0);

                Metadata                    = new Metadata(snapshotStart, computer, account, version);

                // Capture snapshot machine information
                Update(0, "Collecting [~] Machine");
                Machine                     = new Machine();

                // Capture snaphot event logs
                Update(0, "Collecting [~] Event Logs");
                Event                       = new Event();
                CollectEventLogs();

                TimeSpan         endElapsed = TimeSpan.Parse(((Console.Entry)Console.Last()).Elapsed);
                TimeSpan    snapshotElapsed = endElapsed - baseline;

                Metadata.Complete(snapshotElapsed.ToString());

                Update(1, "Captured [+] Snapshot");

                // Export the snapshot to file
                string archivePath       = System.IO.Path.Combine(Path, Metadata.DisplayName + ".ela");

                Update(1, string.Format("Saving [~] Archive: [" + archivePath + "]"));

                Snapshot.Archive archive = new Snapshot.Archive();
                archive.Metadata         = Metadata;
                archive.Machine          = Machine;
                archive.Providers        = new string[Event.Provider.Length];
                for (int i = 0; i < Event.Provider.Length; i++)
                    archive.Providers[i] = Event.Provider[i].DisplayName;

                archive.Entries          = new List<EventLog.Entry>(Event.Output);

                Snapshot.ArchiveWriter.Write(archivePath,archive,
                delegate(int done, int total)
                {
                    int pct = (int)(((double)done / (double)total) * 100.0);
                    Update(0, "Saving [~] Archive: " + pct.ToString() + "% (" + done + "/" + total + ")");
                });

                if (!System.IO.File.Exists(archivePath))
                {
                    Update(-1,string.Format("Exception [!] Not found: [" + archivePath + "]"));
                    return;
                }
                    
                Update(1,string.Format("Complete [+] Snapshot: [" + archivePath + "]"));
                Mode = Mode.Complete;
            }
            public void RestoreSnapshot()
            {
                EnsureRestoreMode();

                Update(0, string.Format("Loading [~] Snapshot: [" + Path + "]"));

                // Deserialize the archive
                Snapshot.Archive archive = Snapshot.ArchiveReader.Read(Path,
                delegate(int done, int total)
                {
                    int pct = (int)(((double)done / (double)total) * 100.0);
                    Update(0, "Loading [~] Snapshot: " + pct.ToString() + "% (" + done + "/" + total + ")");
                });

                if (archive == null)
                {
                    Update(-1, "Exception [!] Invalid archive: [" + Path + "]");
                    throw new InvalidOperationException("Invalid archive.");
                }

                // Rehydrate metadata
                Metadata = archive.Metadata;
                if (Metadata == null)
                {
                    Update(-1, "Exception [!] Archive missing metadata");
                    throw new InvalidOperationException("Archive missing metadata.");
                }

                // Rehydrate machine
                Machine = archive.Machine;
                if (Machine == null)
                {
                    Update(-1, "Exception [!] Archive missing machine data");
                    throw new InvalidOperationException("Archive missing machine data.");
                }

                // Rehydrate event logs
                Event = new Event();

                // 1. Restore entries
                if (archive.Entries != null)
                {
                    Event.Output = archive.Entries.ToArray();
                    Event.Total  = (uint)archive.Entries.Count;
                }
                else
                {
                    Event.Output = new EventLog.Entry[0];
                    Event.Total  = 0;
                }

                // 2. Restore providers FIRST
                if (archive.Providers != null)
                {
                    string[] names = archive.Providers;

                    Event.Provider = new EventLog.Provider[names.Length];

                    for (uint i = 0; i < names.Length; i++)
                    {
                        // Read‑only provider reconstruction
                        Event.Provider[i] = new EventLog.Provider(true, i, names[i]);
                    }
                }
                else
                {
                    Event.Provider = new EventLog.Provider[0];
                }

                // 3. Assign entries to providers in a single pass
                for (int i = 0; i < Event.Output.Length; i++)
                {
                    EventLog.Entry e = Event.Output[i];

                    if (e.LogIndex < Event.Provider.Length)
                    {
                        Event.Provider[e.LogIndex].Output.Add(e);
                    }
                }

                // Lock controller
                Mode = Mode.Complete;

                // Final status update
                Update(1, string.Format("Restored [+] Snapshot: [" + Path + "]"));
            }
        }
    }

}
