// FightingEntropy.Windows
using System.Runtime.InteropServices;
using FightingEntropy.Core;

namespace FightingEntropy
{
    namespace Windows
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
                    Configuration = new Configuration.Controller();
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

            public class Provider : Core.Platform.Configuration.Provider
            {
                private Microsoft.Win32.RegistryKey Hive { get; set; }
                public Provider() : base()
                {
                    
                }
                public void Load(string fullname)
                {
                    Initialize(fullname);
                    Refresh();
                }
                protected void Initialize(string fullname)
                {
                    string[] parts = fullname.Split('\\');

                    Drive    = parts[0];
                    Name     = parts[parts.Length - 1];
                    Fullname = fullname;

                    SetHive(Drive);

                    Path   = Root + "\\" + string.Join("\\", parts, 1, parts.Length - 1);
                    Branch = string.Join("\\", parts, 1, parts.Length - 2);

                    Property.Clear();
                }
                public void Refresh()
                {
                    Check();
                    Property.Clear();

                    if (Exists)
                        Read();
                }
                public void Check()
                {
                    Exists = false;

                    using (var parent = Hive.OpenSubKey(Branch))
                    {
                        if (parent == null) return;

                        using (var child = parent.OpenSubKey(Name))
                        {
                            Exists = (child != null);
                        }
                    }
                }
                public void Read()
                {
                    Property.Clear();
                    Check();

                    if (!Exists)
                        throw new Exception("Registry path does not exist");

                    using var key = Hive.OpenSubKey(Branch + "\\" + Name);
                    foreach (string name in key.GetValueNames())
                    {
                        Property.Add(new Configuration.Property
                        {
                            Index  = (uint)Property.Count,
                            Name   = name,
                            Value  = key.GetValue(name),
                            Exists = true
                        });
                    }
                }
                public void Write()
                {
                    Check();
                    if (!Exists)
                        Create();

                    using var parent = Hive.OpenSubKey(Branch, writable: true);
                    using var key = parent.CreateSubKey(Name);

                    foreach (var prop in Property)
                    {
                        key.SetValue(prop.Name, prop.Value ?? "");
                        prop.Exists = true;
                    }

                    Check();
                }
            }

            public class Controller : Core.Module.Interop.Configuration
            {
                protected override Property CreateProperty(uint index, string name, object value)
                {
                    return new Property(index, name, value);
                }
            }
        }

        namespace FileSystem
        {
            public class Raw : Core.Platform.FileSystem.Raw { }
            public class Entry : Core.Platform.FileSystem.Entry
            {
                public Entry(uint index, Raw raw)
                {
                    Index     = index;
                    Type      = raw.IsDirectory ? Core.Platform.FileSystem.Type.Directory : Core.Platform.FileSystem.Type.File;
                    Created   = new Format.ModDateTime(raw.Created);
                    Modified  = new Format.ModDateTime(raw.Modified);

                    Fullname  = raw.Fullname;
                    Name      = raw.Name;
                    Extension = raw.IsDirectory ? "" : Path.GetExtension(raw.Fullname).TrimStart('.');
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
                    Bytes     = File.ReadAllBytes(Fullname);
                }
                public override string ToString()
                {
                    return Name;
                }
            }

            public class DirectoryScan
            {
                static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

                [StructLayout(LayoutKind.Sequential)]
                public struct FILETIME
                {
                    public uint dwLowDateTime;
                    public uint dwHighDateTime;
                }
                
                [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
                public struct WIN32_FIND_DATA
                {
                    public FileAttributes Attributes;
                    public FILETIME          Created;
                    public FILETIME         Modified;
                    public FILETIME         Accessed;
                    public uint             SizeHigh;
                    public uint              SizeLow;
                    public uint            Reserved0;
                    public uint            Reserved1;

                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
                    public string               Name;

                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 14)]
                    public string          Alternate;
                }

                [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
                static extern IntPtr FindFirstFileW(string lpFileName, out WIN32_FIND_DATA lpFindFileData);

                [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
                static extern bool FindNextFileW(IntPtr hFindFile, out WIN32_FIND_DATA lpFindFileData);

                [DllImport("kernel32.dll")]
                static extern bool FindClose(IntPtr hFindFile);
                public List<RawEntry> Scan(string root, bool recurse)
                {
                    List<RawEntry> results = new List<RawEntry>();
                    Stack<string>    stack = new Stack<string>();

                    stack.Push(root);

                    while (stack.Count > 0)
                    {
                        string current = stack.Pop();
                        string pattern = Path.Combine(current, "*");

                        WIN32_FIND_DATA data;
                        IntPtr handle = FindFirstFileW(pattern, out data);

                        if (handle == INVALID_HANDLE_VALUE)
                            continue;

                        try
                        {
                            bool more = true;

                            while (more)
                            {
                                string name = data.Name;

                                if (name != "." && name  != "..")
                                {
                                    string  fullname = Path.GetFullPath(Path.Combine(current, name));

                                    bool       isDir = (data.Attributes & FileAttributes.Directory) != 0;
                                    bool   isReparse = (data.Attributes & FileAttributes.ReparsePoint) != 0;

                                    string       ext = isDir ? "" : Path.GetExtension(name).TrimStart('.');

                                    ulong       size = ((ulong)data.SizeHigh << 32) | data.SizeLow;
                                    ulong  createdTx = ((ulong)data.Created.dwHighDateTime << 32)  | (ulong)data.Created.dwLowDateTime;
                                    ulong modifiedTx = ((ulong)data.Modified.dwHighDateTime << 32) | (ulong)data.Modified.dwLowDateTime;

                                    results.Add(new RawEntry
                                    {
                                        Name         = name,
                                        Fullname     = fullname,
                                        IsDirectory  = isDir,
                                        IsReparse    = isReparse,
                                        Size         = size,
                                        Created      = DateTime.FromFileTimeUtc((long)createdTx),
                                        Modified     = DateTime.FromFileTimeUtc((long)modifiedTx)
                                    });

                                    if (isDir && recurse && !isReparse)
                                        stack.Push(fullname);
                                }

                                more = FindNextFileW(handle, out data);
                            }
                        }
                        finally
                        {
                            FindClose(handle);
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
                public Controller(string fullname, uint mode, bool recurse, string filter)
                {
                    Index    = 0;
                    Type     = Core.Platform.FileSystem.Type.Directory;
                    Label    = "";
                    Fullname = fullname;
                    Name     = Path.GetFileName(fullname);

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
                    DirectoryInfo di = new DirectoryInfo(Fullname);

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
                    if (!string.IsNullOrEmpty(Filter))
                    {
                        try { rx = new Regex(Filter, RegexOptions.IgnoreCase); } catch { rx = null; }
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

                    Size  = Recurse ? GetRecursiveBytes() : GetListBytes();
                }
                protected Entry CreateEntry(uint index, Raw raw)
                {
                    return new Entry
                    {
                        Index      = index,
                        Type       = raw.IsDirectory ? Type.Directory : Type.File,
                        Name       = raw.Name,
                        Fullname   = raw.Fullname,
                        Extension  = raw.IsDirectory ? "" : Path.GetExtension(raw.Name).TrimStart('.'),
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

                    foreach (Entry entry in Entry)
                    {
                        if (entry.Type == FileSystem.Type.File)
                            totalBytes += entry.Size.Bytes;
                    }

                    return new Format.ByteSize("Directory", totalBytes);
                }
                public Format.ByteSize GetRecursiveBytes()
                {
                    try
                    {
                        System.Type fsoType = System.Type.GetTypeFromProgID("Scripting.FileSystemObject");
                        if (fsoType == null)
                            return Empty();

                        object fso    = Activator.CreateInstance(fsoType);
                        if (fso == null)
                            return Empty();

                        object folder = fsoType.InvokeMember("GetFolder", BindingFlags.InvokeMethod, null, fso, new object[]{ Fullname });
                        
                        if (folder == null)
                            return Empty();

                        System.Type folderType = folder.GetType();
                        object sizeObj = folderType.InvokeMember("Size", BindingFlags.GetProperty, null, folder, null);

                        ulong bytes   = (ulong)Convert.ToInt64(sizeObj);

                        return new Format.ByteSize("Directory", bytes);
                    }
                    catch
                    {
                        return Empty();
                    }
                }
                public override string ToString()
                {
                    return Fullname;
                }
            }

            public class Transfer
            {
                FileStream      Source;
                FileStream Destination;
                byte[]          Buffer;
                public Transfer(string source, string destination)
                {
                    if (!File.Exists(source))
                    {
                        throw new Exception("Exception [!] Invalid source file");
                    }

                    // check destination directory
                    string parent = Path.GetDirectoryName(destination);

                    if (!Directory.Exists(parent))
                    {
                        Directory.CreateDirectory(parent);

                        if (!Directory.Exists(parent))
                            throw new Exception("Exception [!] Unable to create parent directory");
                    }

                    Source        = File.OpenRead(source);
                    Destination   = File.OpenWrite(destination);

                    string   mask = "{0} [~] File  : ({1:0.00}%) {2} -> {3}";

                    Write(string.Format(mask, "Copying", 0.0, source, destination));
                    try
                    {
                        Buffer      = new byte[4096];

                        long  total = 0;
                        int   count = 0;

                        double size = Source.Length / 1_048_576.0;
                        int updates = (int)Math.Round(Math.Log(size + 1, 2) * 8);

                        updates     = Clamp(updates, 0, 100);

                        long factor = updates > 0 ? Source.Length / updates : long.MaxValue;
                        long   next = factor;

                        while ((count = Source.Read(Buffer, 0, Buffer.Length)) > 0)
                        {
                            Destination.Write(Buffer, 0, count);
                            total += count;
                            
                            if (total >= next)
                            {
                                double p = (double)total / Source.Length * 100.0;
                                Write(string.Format(mask, "Copying", p, source, destination));
                                next += factor;
                            }
                        }
                    }
                    finally
                    {
                        Source.Dispose();
                        Destination.Dispose();

                        Write(string.Format(mask, "Copied", 100.0, source, destination), true);
                    }
                }
                public void Write(string text)
                {
                    System.Console.Write("\r" + new string(' ', System.Console.BufferWidth - 1) + "\r" + text);
                }
                public void Write(string text, bool newline)
                {
                    Write(text);
                    System.Console.WriteLine();
                }
                public int Clamp(int value, int min, int max)
                {
                    if (value < min) return min;
                    if (value > max) return max;
                    return value;
                }
                public override string ToString()
                {
                    return null;
                }
            }
        }
    
    }
}