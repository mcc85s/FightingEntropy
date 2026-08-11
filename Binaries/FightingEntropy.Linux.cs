// FightingEntropy.Linux
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using FightingEntropy.Core;
using FightingEntropy.Core.Interop;

namespace FightingEntropy
{
    namespace Linux
    {
        namespace Interop
        {
            public sealed class Controller : FightingEntropy.Core.Interop.Controller
            {
                public override IConfiguration Configuration
                {
                    get;
                }
                public override IFileSystem FileSystem => throw new NotImplementedException();
                public override IProcess       Process => throw new NotImplementedException();
                public override IService       Service => throw new NotImplementedException();
                public override ICommand       Command => throw new NotImplementedException();
                public override INetwork       Network => throw new NotImplementedException();
                public override ISecurity     Security => throw new NotImplementedException();
                public override IHardware     Hardware => throw new NotImplementedException();
                public Controller()
                {
                    Configuration = new Configuration.Manager();
                }
            }
        }

        namespace Configuration
        {
            public class Property : Core.Platform.Configuration.Property
            {
                public Property() : base() { }
                public Property(uint index, string name, object value) : base()
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

            public class Manager : Core.Interop.Configuration
            {
                public Manager() : base()
                {
                    Type = Core.Platform.Configuration.Type.FileSystem;
                    Clear();
                }
                public override List<Version> GetVersions()
                {
                    System.IO.DirectoryInfo root = new System.IO.DirectoryInfo(ConfigurationPath());
                    List<Version>       versions = new List<Version>();

                    if (!root.Exists)
                        return versions;

                    foreach (System.IO.DirectoryInfo dir in root.GetDirectories().Where(x => Regex.IsMatch(x.Name, @"^\d{4}\.\d{1,}\.\d{1}$")))
                    {
                        versions.Add(Version.Parse(dir.Name));
                    }

                    return versions;
                }
                public override Version GetLatestVersion()
                {
                    List<Version> versions = GetVersions();

                    if (versions.Count == 0)
                        return null;

                    return versions.Max();
                }
                public override Version GenerateVersion()
                {
                    return Version.Parse(DateTime.Now.ToString("yyyy.M.0"));
                }
                public override void Load(string fullname)
                {
                    Initialize(fullname);
                    Refresh();
                }
                public override void Initialize()
                {
                    string root = ConfigurationPath();

                    if (!System.IO.Directory.Exists(root))
                        System.IO.Directory.CreateDirectory(root);

                    // version
                    string path = $"{root}/{DateTime.Now.ToString("yyyy.M.0")}";

                    if (!System.IO.Directory.Exists(path))
                        System.IO.Directory.CreateDirectory(path);

                    // create the configuration

                    Clear();
                }
                public override void Initialize(string fullname)
                {
                    Fullname = fullname;

                    Name     = System.IO.Path.GetFileNameWithoutExtension(fullname);   // "2026.4.0"
                    Branch   = System.IO.Path.GetDirectoryName(fullname);              // /etc/.../FightingEntropy
                    Root     = Branch;                                                 // Linux "drive" = config root
                    Path     = fullname;

                    Drive    = Root;

                    Clear();
                }
                public override void Refresh()
                {
                    Check();
                    Clear();

                    if (Exists)
                    {
                        Read();
                    }
                }
                public override void Check()
                {
                    // Directory must exist
                    if (Branch == null || Branch == "")
                    {
                        Exists = false;
                        return;
                    }

                    if (!System.IO.Directory.Exists(Branch))
                    {
                        Exists = false;
                        return;
                    }

                    // File must exist
                    if (Path == null || Path == "")
                    {
                        Exists = false;
                        return;
                    }

                    Exists = System.IO.File.Exists(Path);
                    ulong xsize = 0;

                    if (Exists)
                    {
                        xsize = (uint)new System.IO.FileInfo(Path).Length;
                    }

                    Size   = new Format.ByteSize("File", xsize);
                }
                public override void Clear()
                {
                    if (Property == null)
                        Property = new List<Core.Platform.Configuration.Property>();
                    else
                        Property.Clear();
                }
                public override void Read()
                {
                    Clear();
                    Check();

                    if (!Exists)
                    {
                        throw new Exception("Exception [!] Config file does not exist");
                    }

                    System.IO.FileStream   fs = System.IO.File.OpenRead(Path);
                    System.IO.BinaryReader br = new System.IO.BinaryReader(fs);

                    uint count = br.ReadUInt32();
                    uint i     = 0;

                    while (i < count)
                    {
                        uint index        = br.ReadUInt32();

                        // name
                        uint      nameLen = br.ReadUInt32();
                        byte[]  nameBytes = br.ReadBytes((int)nameLen);
                        string       name = System.Text.Encoding.UTF8.GetString(nameBytes);

                        // value
                        uint     valueLen = br.ReadUInt32();
                        byte[] valueBytes = br.ReadBytes((int)valueLen);
                        string      value = System.Text.Encoding.UTF8.GetString(valueBytes);

                        // exists
                        byte   existsByte = br.ReadByte();
                        bool       exists = (existsByte != 0);

                        Property p        = new Property(index, name, value);
                        p.Exists          = exists;

                        Property.Add(p);

                        i++;
                    }

                    br.Close();
                    fs.Close();
                }
                public override void Write()
                {
                    Check();
                    if (!Exists)
                    {
                        Create();
                    }

                    System.IO.FileStream   fs = System.IO.File.Open(Path, System.IO.FileMode.Create, System.IO.FileAccess.Write);
                    System.IO.BinaryWriter bw = new System.IO.BinaryWriter(fs);

                    bw.Write((uint)Property.Count);

                    // iterate all properties
                    for (int i = 0; i < Property.Count; i++)
                    {
                        Core.Platform.Configuration.Property prop = Property[i];

                        // name
                        bw.Write(prop.Index);

                        string name       = (prop.Name != null) ? prop.Name : "";
                        byte[] nameBytes  = System.Text.Encoding.UTF8.GetBytes(name);

                        bw.Write((uint)nameBytes.Length);
                        bw.Write(nameBytes);

                        // value
                        string value      = (System.Convert.ToString(prop.Value) != null) ? System.Convert.ToString(prop.Value) : "";
                        byte[] valueBytes = System.Text.Encoding.UTF8.GetBytes(value);

                        bw.Write((uint)valueBytes.Length);
                        bw.Write(valueBytes);

                        bw.Write((byte)(prop.Exists ? 1 : 0));
                    }

                    bw.Close();
                    fs.Close();

                    Check();
                }
                public override void Create()
                {
                    Check();

                    if (Exists)
                    {
                        throw new Exception("Exception [!] Config file already exists");
                    }

                    if (!System.IO.Directory.Exists(Branch))
                    {
                        System.IO.Directory.CreateDirectory(Branch);
                    }

                    System.IO.FileStream   fs = System.IO.File.Create(Path);
                    System.IO.BinaryWriter bw = new System.IO.BinaryWriter(fs);

                    // Empty property list
                    bw.Write((uint)0);

                    bw.Close();
                    fs.Close();

                    Check();
                }
                public override void Remove()
                {
                    Check();

                    if (!Exists)
                    {
                        throw new Exception("Exception [!] Config file does not exist");
                    }

                    System.IO.File.Delete(Path);

                    Check();
                }
                public override string ConfigurationPath()
                {
                    string company = CompanyName().ToLower().Replace(" ","-");
                    string project = ProjectName().ToLower().Replace(" ","");

                    return $"/etc/{company}/{project}";
                }
                public override void Resolve()
                {
                    // [Configuration Path] if default does NOT exist, create it, otherwise proceed
                    string root = ConfigurationPath();

                    if (!System.IO.Directory.Exists(root))
                        System.IO.Directory.CreateDirectory(root);

                    // [Configuration Version] -> Get versions
                    List<Version>      versions = new List<Version>();
                    System.IO.DirectoryInfo  di = new System.IO.DirectoryInfo(root);

                    foreach (System.IO.DirectoryInfo dir in di.GetDirectories().Where(x => Regex.IsMatch(x.Name, @"^\d{4}\.\d{1,}\.\d{1}$")))
                    {
                        versions.Add(Version.Parse(dir.Name));
                    }

                    // if no versions found, generate new version, otherwise grab latest and proceed
                    Version latest = (versions.Count == 0) ? GenerateVersion() : versions.Max();

                    // [Configuration Path + Version] -> Test the path and create if it doesn't exist
                    string xpath = $"{root}/{latest.ToString()}";

                    if (!System.IO.Directory.Exists(xpath))
                        System.IO.Directory.CreateDirectory(xpath);

                    // [Configuration File] -> Test the path and create it if it doesn't exist
                    string config = $"{xpath}/config.bin";

                    if (!System.IO.File.Exists(config))
                        System.IO.File.Create(config).Close();

                    if (new System.IO.FileInfo(config) != null)
                    {
                        Fullname = config;
                        Path     = config;
                        Branch   = xpath;
                        Root     = root;
                        Drive    = root;
                    }

                    Check();
                }
                public override string ToString()
                {
                    if (Fullname == null || Fullname == "")
                    {
                        return string.Format("<{0}>", base.ToString());
                    }
                    return Fullname;
                }
            }
        }

        namespace FileSystem
        {
            public class Raw : Core.Platform.FileSystem.Raw { }
            public class Entry : Core.Platform.FileSystem.Entry
            {
                public Entry() : base() { }
                public Entry(uint index, Raw raw) : base()
                {
                    Index     = index;
                    Type      = raw.IsDirectory ? Core.Platform.FileSystem.Type.Directory : Core.Platform.FileSystem.Type.File;
                    Created   = new Format.ModDateTime(raw.Created);
                    Modified  = new Format.ModDateTime(raw.Modified);

                    Fullname  = raw.Fullname;
                    Name      = raw.Name;
                    Extension = raw.IsDirectory ? "" : System.IO.Path.GetExtension(raw.Fullname).TrimStart('.');
                    Size      = new Format.ByteSize(Type.ToString(), raw.Size);
                    Exists    = true;
                }
                public void Clear()
                {
                    Bytes     = null;
                }
                public void ReadAllBytes()
                {
                    Clear();
                    Bytes     = System.IO.File.ReadAllBytes(Fullname);
                }
                public override string ToString()
                {
                    return Name;
                }
            }

            public class DirectoryScan
            {
                [StructLayout(LayoutKind.Sequential)]
                private struct dirent
                {
                    public ulong     d_ino;
                    public long      d_off;
                    public ushort d_reclen;
                    public byte     d_type;

                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
                    public string   d_name;
                }

                [StructLayout(LayoutKind.Sequential)]
                private struct FileStat
                {
                    public ulong     st_dev;
                    public ulong     st_ino;
                    public ulong   st_nlink;
                    public uint     st_mode;
                    public uint      st_uid;
                    public uint      st_gid;
                    public ulong    st_rdev;
                    public long     st_size;
                    public long  st_blksize;
                    public long   st_blocks;
                    public long    st_atime;
                    public long    st_mtime;
                    public long    st_ctime;
                }

                [DllImport("libc", SetLastError = true)]
                private static extern IntPtr opendir(string name);
                [DllImport("libc", SetLastError = true)]
                private static extern IntPtr readdir(IntPtr dir);
                [DllImport("libc", SetLastError = true)]
                private static extern int closedir(IntPtr dir);
                [DllImport("libc", SetLastError = true)]
                private static extern int stat(string path, out FileStat buf);
                private const byte DT_DIR = 4;
                private const byte DT_LNK = 10;
                public List<Raw> Scan(string root, bool recurse)
                {
                    List<Raw> results   = new List<Raw>();
                    Stack<string> stack = new Stack<string>();

                    stack.Push(root);

                    while (stack.Count > 0)
                    {
                        string current = stack.Pop();
                        System.IntPtr dir = opendir(current);

                        if (dir == IntPtr.Zero)
                            continue;

                        try
                        {
                            IntPtr entry;
                            while ((entry = readdir(dir)) != IntPtr.Zero)
                            {
                                var d = Marshal.PtrToStructure<dirent>(entry);

                                string name = d.d_name;
                                if (name == "." || name == "..")
                                    continue;

                                string fullname = System.IO.Path.Combine(current, name);
                                bool isDir      = d.d_type == DT_DIR;
                                bool isReparse  = d.d_type == DT_LNK;

                                // stat() for size + timestamps
                                ulong size = 0;
                                DateTime created  = DateTime.MinValue;
                                DateTime modified = DateTime.MinValue;

                                if (stat(fullname, out var s) == 0)
                                {
                                    size     = (ulong)Math.Max(0, s.st_size);
                                    modified = DateTimeOffset.FromUnixTimeSeconds(s.st_mtime).UtcDateTime;
                                    created  = DateTimeOffset.FromUnixTimeSeconds(s.st_ctime).UtcDateTime;
                                }

                                // Build Raw object
                                results.Add(new Raw
                                {
                                    Name        = name,
                                    Fullname    = System.IO.Path.GetFullPath(fullname),
                                    Extension   = isDir ? "" : System.IO.Path.GetExtension(name),
                                    IsDirectory = isDir,
                                    IsReparse   = isReparse,
                                    Size        = size,
                                    Created     = created,
                                    Modified    = modified
                                });

                                // Recurse
                                if (isDir && recurse && !isReparse)
                                    stack.Push(fullname);
                            }
                        }
                        finally
                        {
                            closedir(dir);
                        }
                    }

                    return results;
                }
            }

            public class Controller : Core.Platform.FileSystem.Directory
            {
                public Controller(string fullname) : this(fullname, 2, false, null) { }
                public Controller(string fullname, uint mode) : this(fullname, mode, false, null) { }
                public Controller(string fullname, uint mode, bool recurse) : this(fullname, mode, recurse, null) { }
                public Controller(string fullname, uint mode, bool recurse, string filter) : base()
                {
                    Index    = 0;
                    Type     = Core.Platform.FileSystem.Type.Directory;
                    Label    = "";
                    Fullname = fullname;
                    Name     = System.IO.Path.GetFileName(fullname);
            
                    SetMode(mode);
                    SetRecurse(recurse);
                    SetFilter(filter);
            
                    Refresh();
                }
                public void SetLabel(string label)    => Label = label;
                public void SetMode(uint mode)        => Option.Mode    = (Core.Platform.FileSystem.Mode)mode;
                public void SetRecurse(bool recurse)  => Option.Recurse = recurse;
                public void SetFilter(string pattern) => Option.Filter  = pattern;
                public void Check()
                {
                    System.IO.DirectoryInfo di = new System.IO.DirectoryInfo(Fullname);

                    Exists           = di.Exists;
                    if (Exists)
                    {
                        Created      = new Format.ModDateTime(di.CreationTime);
                        Modified     = new Format.ModDateTime(di.LastWriteTime);
                    }
                    else
                    {
                        Created     = null;
                        Modified    = null;
                    }
                }
                public void Clear()
                {
                    if (Entry == null)
                        Entry = new List<Core.Platform.FileSystem.Entry>();
                    else
                        Entry.Clear();
                }
                public void Refresh()
                {
                    Clear();
                    Check();
            
                    if (!Exists)
                    {
                        Size = new Format.ByteSize("Directory", 0);
                        return;
                    }
            
                    Regex rx = null;
                    if (!string.IsNullOrEmpty(Option.Filter))
                    {
                        try { rx = new Regex(Option.Filter, RegexOptions.IgnoreCase); } catch { rx = null; }
                    }

                    bool    includeDirs = Option.Mode == Core.Platform.FileSystem.Mode.All || Option.Mode == Core.Platform.FileSystem.Mode.Directory;
                    bool   includeFiles = Option.Mode == Core.Platform.FileSystem.Mode.All || Option.Mode == Core.Platform.FileSystem.Mode.File;
            
                    List<Raw> raw = new DirectoryScan().Scan(Fullname, Option.Recurse);
            
                    raw.Sort((a, b) => string.Compare(a.Fullname, b.Fullname, StringComparison.OrdinalIgnoreCase));

                    foreach (var r in raw)
                    {
                        if (r.IsDirectory)
                        {
                            if (!includeDirs || r.IsReparse)
                                continue;
                        }
                        else if (!includeFiles)
                        {
                            continue;
                        }

                        var e = CreateEntry((uint)Entry.Count, r);

                        if (rx == null || rx.IsMatch(e.Name))
                            Entry.Add(e);
                    }
            
                    Size = Option.Recurse ? GetRecursiveBytes() : GetListBytes();
                }
                protected FileSystem.Entry CreateEntry(uint index, Raw raw)
                {
                    return new FileSystem.Entry
                    {
                        Index      = index,
                        Type       = raw.IsDirectory ? Core.Platform.FileSystem.Type.Directory : Core.Platform.FileSystem.Type.File,
                        Name       = raw.Name,
                        Fullname   = raw.Fullname,
                        Extension  = raw.IsDirectory ? "" : System.IO.Path.GetExtension(raw.Name).TrimStart('.'),
                        Created    = new Format.ModDateTime(raw.Created),
                        Modified   = new Format.ModDateTime(raw.Modified),
                        Size       = new Format.ByteSize(raw.IsDirectory ? "Directory" : "File",raw.Size),
                        Exists     = true
                    };
                }
                public Format.ByteSize Empty()
                {
                    return new Format.ByteSize("Directory", 0);
                }
                public Format.ByteSize GetListBytes()
                {
                    ulong totalBytes = 0;
            
                    foreach (var entry in Entry)
                    {
                        if (entry.Type == Core.Platform.FileSystem.Type.File)
                            totalBytes += entry.Size.Bytes;
                    }
            
                    return new Format.ByteSize("Directory", totalBytes);
                }
                public Format.ByteSize GetRecursiveBytes()
                {
                    try
                    {
                        var psi = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName               = "du",
                            Arguments              = "-sb \"" + Fullname + "\"",
                            RedirectStandardOutput = true,
                            UseShellExecute        = false,
                            CreateNoWindow         = true
                        };
            
                        using (var p = System.Diagnostics.Process.Start(psi))
                        {
                            string  output = p.StandardOutput.ReadToEnd().Trim();
                            string[] parts = output.Split('\t', ' ');
            
                            if (ulong.TryParse(parts[0], out ulong bytes))
                                return new Format.ByteSize("Directory", bytes);
                        }
                    }
                    catch { }
            
                    return Empty();
                }
                public override string ToString()
                {
                    return Fullname;
                }
            }

            // end namespace [FileSystem]
        }


    }
}