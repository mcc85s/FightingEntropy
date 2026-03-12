using System;
using System.IO;
using System.IO.Compression;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Management;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Security.Principal;
using System.ComponentModel;
using FightingEntropy.Format;

namespace FightingEntropy
{
    namespace Format
    {
        [Serializable]
        public struct ModDateTime
        {
            public DateTime Value;
            public ModDateTime(DateTime dt)
            {
                this.Value = dt;
            }
            public static implicit operator DateTime(ModDateTime fdt)
            {
                return fdt.Value;
            }
            public static implicit operator ModDateTime(DateTime dt)
            {
                return new ModDateTime(dt);
            }
            public string DateString()
            {
                return this.Value.ToString("MM/dd/yyyy HH:mm:ss");
            }
            public string FileString()
            {
                return this.Value.ToString("yyyy_MM_dd-HH_mm_ss");
            }
            public string ArchiveString()
            {
                return this.Value.ToString("yyyy_MMdd-HHmmss");
            }
            public override string ToString()
            {
                return this.DateString();
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
    }

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
                return this.DisplayName;
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
                Boot      = p["BootPartition"] != null ? (uint)p["BootPartition"] : 0;
                Primary   = p["PrimaryPartition"] != null ? (uint)p["PrimaryPartition"] : 0;
                Disk      = p["DiskIndex"] != null ? (uint)p["DiskIndex"] : 0;
                Index     = p["Index"] != null ? (uint)p["Index"] : 0;
                ulong raw = p["Size"] != null ? (ulong)p["Size"] : 0;
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
                Count = 0;
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
            public string      DriveID;
            public string  Description;
            public string   Filesystem;
            public Partition Partition;
            public string   VolumeName;
            public string VolumeSerial;
            public Format.ByteSize       Free;
            public Format.ByteSize       Used;
            public Format.ByteSize       Size;
            public Volume(ManagementObject drive)
            {
                DriveID      = Convert.ToString(drive["Name"]);
                Description  = Convert.ToString(drive["Description"]);
                Filesystem   = Convert.ToString(drive["FileSystem"]);
                VolumeName   = Convert.ToString(drive["VolumeName"]);
                VolumeSerial = Convert.ToString(drive["VolumeSerialNumber"]);

                ulong free   = drive["FreeSpace"] != null ? (ulong)drive["FreeSpace"] : 0;
                ulong size   = drive["Size"] != null ? (ulong)drive["Size"] : 0;
                ulong used   = size > free ? size - free : 0;

                Free         = new Format.ByteSize("Free", (long)free);
                Used         = new Format.ByteSize("Used", (long)used);
                Size         = new Format.ByteSize("Size", (long)size);
            }
            public override string ToString()
            {
                // Example: "[C:\100 GB]"
                string partSize = Partition != null ? Partition.Size.ToString() : "";
                return "[" + DriveID + partSize + "]";
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

        public class Context
        {
            public string  Name;
            public int    Index;
            public int    Total;

            public Context(string name, int index, int total)
            {
                Name  = name;
                Index = index;
                Total = total;
            }
            public override string ToString()
            {
                return Name;
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
                State = ControllerState.Idle;
                Reset();
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

                InitThreadCount();
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
            public void InitThreadCount()
            {
                int cpu = Environment.ProcessorCount;
                int calc = (int)(cpu * 1.5);

                if (calc < 2) calc = 2;

                MaxThreads = calc;
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
                    entry.IsStalled = false;
                }

                entry.Message     = message;
                entry.LastUpdated = now;

                // COMPLETION ALWAYS OVERRIDES STALL
                if (message.StartsWith("Completed [+]"))
                {
                    entry.IsComplete = true;
                    entry.IsStalled  = false;
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

                    // Completed providers cannot be stalled
                    if (s.IsComplete)
                    {
                        s.IsStalled = false;
                        continue;
                    }

                    // Expected next progress report (5 minutes after last change)
                    DateTime expected = s.LastChanged.AddMinutes(5);

                    // If not late → not stalled
                    if (now < expected.AddSeconds(stallSeconds))
                    {
                        s.IsStalled = false;
                        continue;
                    }

                    // If already marked stalled → don't report again
                    if (s.IsStalled)
                        continue;

                    // First time detecting stall
                    string msg = string.Format(
                        "Warning [!] Possible stall: {0} (Key: {1}), LastChanged: {2}, ExpectedReport: {3}, Now: {4}",
                        s.Name,
                        s.Key,
                        s.LastChanged.ToString("u"),
                        expected.ToString("u"),
                        now.ToString("u")
                    );

                    list.Add(msg);

                    // Mark as stalled so we don't repeat
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

    namespace Security
    {
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
                    Name = sid.Translate(typeof(System.Security.Principal.NTAccount)).ToString();
                }
                catch
                {
                    Name = sid.Value; // fallback
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
                return this.Value;
            }
        }
    }

    namespace Console
    {
        public class TimeSlot
        {
            public string       Name;
            public Format.ModDateTime? Time;
            public uint          Set;
            public TimeSlot(string name)
            {
                this.Name = name;
                this.Time = null;
                this.Set  = 0;
            }
            public void Toggle()
            {
                this.Time = DateTime.Now;
                this.Set  = 1;
            }
            public DateTime? AsDateTime
            { 
                get
                {
                    if (!this.Time.HasValue) 
                        return null; 
                        
                    return this.Time.Value.Value;
                }
            }
            public override string ToString()
            {
                if (this.Time.HasValue)
                    return this.Time.Value.ToString();

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
                this.Index   = index;
                this.Elapsed = time;
                this.State   = state;
                this.Status  = status;
                this.String  = this.ToString();
            }
            public override string ToString()
            {
                return string.Format("[{0}] (State: {1}/Status: {2})", this.Elapsed, this.State, this.Status);
            }
        }

        public class Controller
        {
            public TimeSlot Start;
            public TimeSlot   End;
            public string    Span;
            public Entry   Status;
            public uint      Mode;
            public ObservableCollection<Entry> Output;
            public Controller()
            {
                this.Reset();
            }
            public string Elapsed()
            {
                TimeSpan ts;

                if (this.End.Set == 0)
                {
                    ts = DateTime.Now - this.Start.Time.Value.Value;
                }
                else
                {
                    ts = this.End.Time.Value.Value - this.Start.Time.Value.Value;
                }

                return ts.ToString();
            }
            public void SetStatus()
            {
                this.Status = new Entry((uint)this.Output.Count,this.Elapsed(), this.Status.State,this.Status.Status);
            }
            public void SetStatus(int state, string status)
            {
                this.Status = new Entry((uint)this.Output.Count, this.Elapsed(), state, status);
            }
            public void Initialize()
            {
                if (this.Start.Set == 1)
                {
                    this.Update(-1, "Start [!] Error: Already initialized, try a different operation or reset.");
                    return;
                }

                this.Start.Toggle();
                this.Update(0, "Running [~] (" + this.Start.ToString() + ")");
            }
            public void Complete()
            {
                if (this.End.Set == 1)
                {
                    this.Update(-1, "End [!] Error: Already initialized, try a different operation or reset.");
                    return;
                }

                this.End.Toggle();
                this.Span = this.Elapsed();
                this.Update(100, "Complete [+] (" + this.End.ToString() + "), Total: (" + this.Span + ")");
            }
            public void Reset()
            {
                this.Start  = new TimeSlot("Start");
                this.End    = new TimeSlot("End");
                this.Span   = null;
                this.Status = null;
                this.Output = new ObservableCollection<Entry>();
            }
            public void Update(int state, string status)
            {
                this.SetStatus(state, status);
                this.Output.Add(this.Status);
                if (this.Mode == 0)
                {
                    System.Console.WriteLine(this.Last());
                }
            }
            public object Current()
            {
                this.Update(this.Status.State, this.Status.Status);
                return this.Last();
            }
            public object Last()
            {
                return this.Output[this.Output.Count - 1];
            }
            public object DumpConsole()
            {
                string[] arr = new string[this.Output.Count];

                for (int i = 0; i < this.Output.Count; i++)
                {
                    arr[i] = this.Output[i].ToString();
                }

                return arr;
            }
            public override string ToString()
            {
                return this.Span == null ? this.Elapsed() : this.Span;
            }
        }
    }

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
                }
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
            private double                   emaRate = 0;
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

                uint   count    = 0;
                ulong  estTotal = 0;
                string msg      = null;

                // Try to get estimated total number of events (best effort only)
                try
                {
                    EventLogSession      session = new EventLogSession();
                    EventLogInformation  info    = session.GetLogInformation(this.DisplayName, PathType.LogName);
                    estTotal                      = info.RecordCount.HasValue ? (ulong)info.RecordCount.Value : 0;
                }
                catch
                {
                    estTotal = 0;
                }

                // Start timing
                Stopwatch stopwatch   = Stopwatch.StartNew();
                DateTime  lastReport  = DateTime.UtcNow;
                int       reportEveryMinutes = 5;   // detailed progress cadence

                try
                {
                    EventLogQuery query = new EventLogQuery(DisplayName, PathType.LogName);

                    using (var reader = new EventLogReader(query))
                    {
                        System.Diagnostics.Eventing.Reader.EventRecord rec;

                        while ((rec = reader.ReadEvent()) != null)
                        {
                            Output.Add(new Entry(count, Index, rec));
                            count++;

                            // Time-based progress (every ~5 minutes per provider)
                            if (estTotal > 0 && count > 0)
                            {
                                DateTime now = DateTime.UtcNow;
                                if ((now - lastReport).TotalMinutes >= reportEveryMinutes)
                                {
                                    double pct = ((double)count / (double)estTotal) * 100.0;

                                    double currentRate = count / stopwatch.Elapsed.TotalSeconds;

                                    if (emaRate == 0)
                                    {
                                        emaRate = currentRate;
                                    }
                                    else
                                    {
                                        emaRate = (emaRate * 0.85) + (currentRate * 0.15);
                                    }

                                    TimeSpan eta = TimeSpan.Zero;

                                    if (emaRate > 0)
                                    {
                                        double remaining = estTotal - count;
                                        double etaSec = remaining / emaRate;

                                        if (etaSec < 0) etaSec = 0;

                                        eta = TimeSpan.FromSeconds(etaSec);
                                    }

                                    msg = string.Format("Processing [~] {0} {1:N2}% ({2}/{3}) ETA [{4}]", DisplayName, pct, count, estTotal, eta.ToString(@"hh\:mm\:ss"));

                                    WriteStatus(msg, (int)count, (int)estTotal);
                                    lastReport = now;
                                }
                            }
                        }
                    }

                    msg = string.Format("Completed [+] {0}, ({1}) records collected", DisplayName, count.ToString());
                    WriteStatus(msg, (int)count, (int)estTotal);
                }
                catch
                {
                    WriteStatus(string.Format("Exception [!] {0}, error occurred during collection", DisplayName));
                }

                // Stop timing and store duration
                stopwatch.Stop();
                Duration = stopwatch.Elapsed;

                Output.Sort(delegate(Entry a, Entry b)
                {
                    return a.TimeCreated.Value.CompareTo(b.TimeCreated.Value);
                });

                for (int i = 0; i < Output.Count; i++)
                    Output[i].Rank = (uint)i;

                Total = (uint)Output.Count;
            }
            public override string ToString()
            {
                return this.DisplayName;
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
                try
                {
                    var session = new EventLogSession();
                    var names   = session.GetLogNames();

                    if (names == null)
                        return Array.Empty<string>();

                    // Convert to List<string>, sort, and return as array
                    List<string> list = new List<string>(names);
                    list.Sort(StringComparer.OrdinalIgnoreCase);

                    return list.ToArray();
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
                this.Console.Initialize();

                Mode        = Mode.Initial;

                this.Thread = new FightingEntropy.Thread.Controller();
                string asmPath = System.Reflection.Assembly.GetExecutingAssembly().Location;

                this.Thread.AddSessionStateObject("Assembly","Initial","FightingEntropy","FightingEntropy ISS assembly bytes",asmPath);

                this.Thread.SessionState[0].ToggleLock();
            }
            public void Update(int state, string status)
            {
                this.Console.Update(state, status);
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
            private string HeartbeatStatus(uint bags, uint names, uint threads)
            {
                double percent = 0;

                if (names != 0)
                    percent = Math.Round(((double)bags / (double)names) * 100.0, 2);

                return string.Format(
                    "Heartbeat [~] {0:N2}% ({1}/{2}) logs complete, ({3}) active threads",
                    percent, bags, names, threads
                );
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
            private TimeSpan ComputeGlobalEta(DateTime start, ulong current, ulong total)
            {
                if (current == 0 || total == 0 || current > total)
                    return TimeSpan.Zero;

                TimeSpan elapsed = DateTime.UtcNow - start;

                double fraction = (double)current / (double)total;

                if (fraction <= 0.0 || fraction >= 1.0)
                    return TimeSpan.Zero;

                double totalSeconds = elapsed.TotalSeconds / fraction;
                double remainingSeconds = totalSeconds - elapsed.TotalSeconds;

                if (remainingSeconds < 0)
                    remainingSeconds = 0;

                return TimeSpan.FromSeconds(remainingSeconds);
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

                // Compute global total record count (without reading logs)
                ulong globalTotalRecords = 0;

                try
                {
                    EventLogSession session = new EventLogSession();

                    foreach (string logName in names)
                    {
                        try
                        {
                            EventLogInformation info = session.GetLogInformation(logName, PathType.LogName);

                            if (info.RecordCount.HasValue)
                                globalTotalRecords += (ulong)info.RecordCount.Value;
                        }
                        catch
                        {
                            // Ignore logs that cannot be queried
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
                Thread.Controller tc = this.Thread;

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
                    "        $key      = \"$tid/$name\"",
                    "",
                    "        $provider = [FightingEntropy.EventLog.Provider]::new($logIndex, $name, $callback, $key)",
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

                        TimeSpan eta = ComputeGlobalEta(tc.StartTime, globalCurrent, globalTotal);

                        string hb = string.Format(
                            "Heartbeat [~] {0:00.00}% ({1:N0}/{2:N0} records) ETA [{3}]",
                            pct,
                            globalCurrent,
                            globalTotal,
                            eta.ToString(@"hh\:mm\:ss")
                        );

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

                Update(1, "Indexing [~] Snapshot: Event logs (" + Event.Output.Length + ") records");
                for (int i = 0; i < Event.Output.Length; i++)
                {
                    Event.Output[i].Index = (uint)i;
                }

                Event.Total  = (uint)all.Count;

                Update(1, "Completed [+] Snapshot: Event log collection [" + tc.Elapsed().ToString() + "]");
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

                Update(0, string.Format("Loading [~] Snapshot: [" + this.Path + "]"));

                // Deserialize the archive
                Snapshot.Archive archive = Snapshot.ArchiveReader.Read(this.Path,
                delegate(int done, int total)
                {
                    int pct = (int)(((double)done / (double)total) * 100.0);
                    Update(0, "Loading [~] Snapshot: " + pct.ToString() + "% (" + done + "/" + total + ")");
                });

                if (archive == null)
                {
                    Update(-1, "Exception [!] Invalid archive: [" + this.Path + "]");
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
                Update(1, string.Format("Restored [+] Snapshot: [" + this.Path + "]"));
            }
        }
    }

}