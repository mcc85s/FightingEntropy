// FightingEntropy.Windows
using System.Runtime.InteropServices;
using FightingEntropy.Core;

namespace FightingEntropy
{
    namespace Windows
    {
        using System.Management;
        using System.Management.Automation;
        using System.Management.Automation.Runspaces;
        using Microsoft.Win32;
        using Microsoft.VisualBasic;
        using Microsoft.Management.Infrastructure;
        using Microsoft.Management.Infrastructure.Options;

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
                public Entry() : base() { }
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

        namespace Management
        {
            public sealed class Connection
            {
                public ManagementScope Scope;
                public Connection(string computer = ".", string ns = "root\\cimv2")
                {
                    Scope = new ManagementScope(string.Format("\\\\{0}\\{1}", computer, ns));
                    Scope.Connect();
                }
                public ManagementObjectCollection Query(string wql)
                {
                    var searcher = new ManagementObjectSearcher(Scope, new ObjectQuery(wql));
                    return searcher.Get();
                }
            }
        
            public sealed class Class
            {
                public ManagementClass ClassObject;
                public Class(Connection connection, string className)
                {
                    ClassObject = new ManagementClass(connection.Scope, new ManagementPath(className), null);
                }
                public IEnumerable GetInstances()
                {
                    foreach (ManagementObject obj in ClassObject.GetInstances())
                        yield return new Instance(obj);
                }
            }
        
            public sealed class Instance
            {
                public ManagementObject Object;
                public Instance(ManagementObject obj)
                {
                    Object = obj;
                }
                public object Get(string property)
                {
                    return Object[property];
                }
                public T GetValue<T>(string property)
                {
                    return (T)Object[property];
                }
            }
        
            public class Instrumentation
            {
                public string             Path;
                public string     ComputerName;
                public string           Branch;
                public string        ClassName;
                public Connection   Connection;
                public Class             Class;
                public List<Instance> Instance;
                private static readonly Regex rxA = new Regex("^\\\\\\\\(?<Computer>[^\\\\]+)\\\\(?<Namespace>[^:]+):(?<Class>.+)$", RegexOptions.Compiled);
                private static readonly Regex rxB = new Regex("^(?<Root>.+?):(?<Class>[^.]+)\\.(?<Key>[^=]+)=\\\"(?<Value>[^\\\"]+)\\\"$", RegexOptions.Compiled);
                private static readonly Regex rxC = new Regex("^(?<Root>.+?):(?<Class>[^.]+)\\.(?<Keys>.+)$", RegexOptions.Compiled);
                public Instrumentation(string path)
                {
                    Path     = path;
                    Instance = new List<Instance>();
                    Resolve();
                }
                public void Clear()
                {
                    Instance.Clear();
                    ComputerName = null;
                    Branch       = null;
                    ClassName    = null;
                    Connection   = null;
                    Class        = null;
                }
                public string Pattern(string type)
                {
                    string output = null;
        
                    switch (type)
                    {
                        case "Controller" : output = "^\\\\(?<Computer>[^\\]+)\\(?<Namespace>[^:]+):(?<Class>.+)$"; break;
                        case "SingleKey"  : output = "^(?<Root>.+?):(?<Class>[^.]+)\\.(?<Key>[^=]+)=\\\"(?<Value>[^\\\"]+)\\\"$"; break;
                        case "MultiKey"   : output = "^(?<Root>.+?):(?<Class>[^.]+)\\.(?<Keys>.+)$"; break;
                    }
        
                    return output;
                }
                public void Resolve()
                {
                    Resolve(Path);
                }
                public void Resolve(string input)
                {
                    Clear();
        
                    if (string.IsNullOrWhiteSpace(input))
                        throw new ArgumentException("Exception [!] WMI string is (null/empty)");
        
                    string s = input.Trim();
        
                    if (TryHandleQuery(s))
                        return;
        
                    if (TryHandleMoniker(s))
                        return;
        
                    if (TryHandlePath(s))
                        return;
        
                    throw new ArgumentException("Exception [!] Input string is invalid");
                }
                private bool TryHandleQuery(string s)
                {
                    // Direct query: SELECT / ASSOCIATORS OF / REFERENCES OF
                    if (StartsWithQueryKeyword(s))
                    {
                        ComputerName = ".";
                        Branch       = "root\\cimv2";
                        Connection   = new Connection(ComputerName, Branch);
        
                        ManagementObjectCollection col = Connection.Query(s);
                        foreach (ManagementObject obj in col)
                            Instance.Add(new Instance(obj));
        
                        return true;
                    }
        
                    // Namespace/host-prefixed query: root\cimv2:SELECT ...
                    int colon = s.IndexOf(':');
                    if (colon > 0)
                    {
                        string left  = s.Substring(0, colon).Trim();
                        string right = s.Substring(colon + 1).Trim();
        
                        if (StartsWithQueryKeyword(right))
                        {
                            ParseHostAndNamespace(left, out string host, out string ns);
        
                            ComputerName = host;
                            Branch       = ns;
                            Connection   = new Connection(ComputerName, Branch);
        
                            ManagementObjectCollection col = Connection.Query(right);
                            foreach (ManagementObject obj in col)
                                Instance.Add(new Instance(obj));
        
                            return true;
                        }
                    }
        
                    return false;
                }
                private bool TryHandleMoniker(string s)
                {
                    const string prefix = "winmgmts:";
                    if (!s.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                        return false;
        
                    string rest = s.Substring(prefix.Length).Trim();
        
                    // Strip optional options block: {impersonationLevel=impersonate}!\\host\ns:...
                    int bangIdx = rest.IndexOf('!');
                    if (bangIdx >= 0)
                    {
                        // options = rest.Substring(0, bangIdx); // currently ignored
                        rest = rest.Substring(bangIdx + 1).Trim();
                    }
        
                    // Now "rest" is a normal WMI path (UNC / namespace / class / object / query)
                    // Re-enter main path handling.
                    if (TryHandleQuery(rest))
                        return true;
        
                    if (TryHandlePath(rest))
                        return true;
        
                    return false;
                }
                private bool TryHandlePath(string s)
                {
                    // UNC host?
                    if (s.StartsWith("\\\\"))
                    {
                        ParseHostAndNamespaceAndTail(s, out string host, out string ns, out string tail);
                        ComputerName = host;
                        Branch       = ns;
        
                        if (string.IsNullOrEmpty(tail))
                        {
                            // Namespace-only
                            Connection = new Connection(ComputerName, Branch);
                            return true;
                        }
        
                        return HandleClassOrObject(ComputerName, Branch, tail);
                    }
        
                    // Has colon: namespace:class/object
                    int colon = s.IndexOf(':');
                    if (colon > 0)
                    {
                        string left  = s.Substring(0, colon).Trim();
                        string right = s.Substring(colon + 1).Trim();
        
                        ParseHostAndNamespace(left, out string host, out string ns);
        
                        ComputerName = host;
                        Branch       = ns;
        
                        if (StartsWithQueryKeyword(right))
                        {
                            // Already handled in TryHandleQuery, but if we get here, treat as query anyway
                            Connection = new Connection(ComputerName, Branch);
                            ManagementObjectCollection col = Connection.Query(right);
                            foreach (ManagementObject obj in col)
                                Instance.Add(new Instance(obj));
                            return true;
                        }
        
                        return HandleClassOrObject(ComputerName, Branch, right);
                    }
        
                    // No colon: could be namespace-only, class-only, or object-only
                    if (IsNamespaceOnly(s))
                    {
                        ComputerName = ".";
                        Branch       = NormalizeNamespace(s);
                        Connection   = new Connection(ComputerName, Branch);
                        return true;
                    }
        
                    // Object-only or class-only in default namespace
                    ComputerName = ".";
                    Branch       = "root\\cimv2";
        
                    return HandleClassOrObject(ComputerName, Branch, s);
                }
                private bool HandleClassOrObject(string host, string ns, string tail)
                {
                    // tail: "Win32_Process" or "Win32_Process.Handle=\"1234\"" or "Win32_Service.Name=\"Spooler\",StartMode=\"Auto\""
                    int dotIdx = tail.IndexOf('.');
                    if (dotIdx < 0)
                    {
                        // Class-only
                        ClassName  = tail;
                        Connection = new Connection(host, ns);
                        Class      = new Class(Connection, ClassName);
        
                        IEnumerable instEnum = Class.GetInstances();
                        foreach (object o in instEnum)
                        {
                            Instance inst = o as Instance;
                            if (inst != null)
                                Instance.Add(inst);
                        }
        
                        return true;
                    }
        
                    ClassName = tail.Substring(0, dotIdx).Trim();
                    string keySpec = tail.Substring(dotIdx + 1).Trim();
        
                    if (string.IsNullOrEmpty(keySpec))
                    {
                        // No keys, treat as class
                        Connection = new Connection(host, ns);
                        Class      = new Class(Connection, ClassName);
        
                        IEnumerable instEnum = Class.GetInstances();
                        foreach (object o in instEnum)
                        {
                            Instance inst = o as Instance;
                            if (inst != null)
                                Instance.Add(inst);
                        }
        
                        return true;
                    }
        
                    // Default instance: "@"
                    if (keySpec == "@")
                    {
                        Connection = new Connection(host, ns);
                        string fullPath = string.Format("{0}:{1}=@", ns, ClassName);
                        ManagementObject obj = new ManagementObject(fullPath);
                        Instance.Add(new Instance(obj));
                        return true;
                    }
        
                    // Multi-key or single-key: Key="Value",Key2="Value2"
                    string where = BuildWhereFromKeySpec(keySpec);
        
                    Connection = new Connection(host, ns);
                    string wql = string.Format("SELECT * FROM {0} WHERE {1}", ClassName, where);
                    ManagementObjectCollection col = Connection.Query(wql);
        
                    foreach (ManagementObject obj in col)
                        Instance.Add(new Instance(obj));
        
                    return true;
                }
                private static bool StartsWithQueryKeyword(string s)
                {
                    if (s.Length < 6) return false;
        
                    if (s.StartsWith("SELECT"         , StringComparison.OrdinalIgnoreCase)) return true;
                    if (s.StartsWith("ASSOCIATORS OF" , StringComparison.OrdinalIgnoreCase)) return true;
                    if (s.StartsWith("REFERENCES OF"  , StringComparison.OrdinalIgnoreCase)) return true;
        
                    return false;
                }
                private static void ParseHostAndNamespace(string s, out string host, out string ns)
                {
                    s = s.Trim();
        
                    if (s.StartsWith("\\\\"))
                    {
                        // \\HOST\NAMESPACE
                        int nextSlash = s.IndexOf('\\', 2);
                        if (nextSlash < 0)
                        {
                            host = s.Substring(2).Trim();
                            ns   = "root\\cimv2";
                            return;
                        }
        
                        host = s.Substring(2, nextSlash - 2).Trim();
                        ns   = s.Substring(nextSlash + 1).Trim();
                        ns   = NormalizeNamespace(ns);
                    }
                    else
                    {
                        host = ".";
                        ns   = NormalizeNamespace(s);
                    }
                }
                private static void ParseHostAndNamespaceAndTail(string s, out string host, out string ns, out string tail)
                {
                    // s: \\HOST\NAMESPACE:TAIL or \\HOST\NAMESPACE
                    int firstSlash = s.IndexOf('\\', 2);
                    if (firstSlash < 0)
                    {
                        host = s.Substring(2).Trim();
                        ns   = "root\\cimv2";
                        tail = "";
                        return;
                    }
        
                    host = s.Substring(2, firstSlash - 2).Trim();
                    string rest = s.Substring(firstSlash + 1).Trim();
        
                    int colon = rest.IndexOf(':');
                    if (colon < 0)
                    {
                        ns   = NormalizeNamespace(rest);
                        tail = "";
                    }
                    else
                    {
                        ns   = NormalizeNamespace(rest.Substring(0, colon).Trim());
                        tail = rest.Substring(colon + 1).Trim();
                    }
                }
                private static bool IsNamespaceOnly(string s)
                {
                    // crude but effective: starts with "root\" or "root/"
                    s = s.Trim();
                    return s.StartsWith("root\\", StringComparison.OrdinalIgnoreCase) ||
                        s.StartsWith("root/",  StringComparison.OrdinalIgnoreCase);
                }
                private static string NormalizeNamespace(string ns)
                {
                    ns = ns.Trim();
                    ns = ns.Replace('/', '\\');
                    return ns;
                }
                private static string BuildWhereFromKeySpec(string keySpec)
                {
                    // keySpec: "Key=\"Value\",Key2=\"Value2\"" or "Key=Value,Key2=Value2"
                    // We preserve each part and join with AND.
                    string[] parts = keySpec.Split(',');
                    List<string> conditions = new List<string>();
        
                    foreach (string raw in parts)
                    {
                        string part = raw.Trim();
                        if (string.IsNullOrEmpty(part))
                            continue;
        
                        // If it doesn't contain '=', it's invalid; we just keep it as-is.
                        int eqIdx = part.IndexOf('=');
                        if (eqIdx < 0)
                        {
                            conditions.Add(part);
                            continue;
                        }
        
                        string key = part.Substring(0, eqIdx).Trim();
                        string val = part.Substring(eqIdx + 1).Trim();
        
                        // If value is not quoted, leave as-is (could be numeric/bool).
                        // If quoted, keep as-is.
                        conditions.Add(string.Format("{0}={1}", key, val));
                    }
        
                    if (conditions.Count == 0)
                        throw new ArgumentException("Invalid WMI key specification: " + keySpec);
        
                    return string.Join(" AND ", conditions);
                }
            }
        }

        namespace Registry
        {
            public class Property
            {
                public uint   Index;
                public string  Name;
                public object Value;
                public bool  Exists = false;
                public Property(uint index, string name, object value)
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

            public class Provider
            {
                public string                        Drive { get; set;}
                public string                         Name { get; set;}
                public string                     Fullname { get; set;}
                public bool                         Exists { get; set;}
                private string                        Root { get; set;}
                private string                        Path { get; set;}
                private string                      Branch { get; set;}
                private Microsoft.Win32.RegistryKey   Hive { get; set;}
                public List<Property>             Property { get; set;}
                public Provider()
                {
                    
                }
                public void Load(string fullname)
                {
                    Initialize(fullname);
                    Refresh();
                }
                protected void Initialize(string fullname)
                {
                    string[] parts  = fullname.Split('\\');

                    Drive    = parts[0];
                    Name     = parts[parts.Length - 1];
                    Fullname = fullname;
                    
                    SetHive(Drive);

                    Path     = Root + "\\" + string.Join("\\", parts, 1, parts.Length - 1);
                    Branch   = string.Join("\\", parts, 1, parts.Length - 2);

                    Clear();
                }
                public void Refresh()
                {
                    Check();
                    Clear();

                    if (Exists)
                        ReadRegistry();
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
                    if (Property == null)
                        Property = new List<Property>();
                    else
                        Property.Clear();
                }
                public void Create()
                {
                    Check();

                    if (Exists)
                        throw new Exception("Exception [!] Path already exists");

                    using var parent = Hive.CreateSubKey(Branch);
                    parent.CreateSubKey(Name);

                    Check();
                }
                public void Remove()
                {
                    Check();

                    if (!Exists)
                        throw new Exception("Exception [!] Path does not exist");

                    using var parent = Hive.OpenSubKey(Branch, writable: true);
                    parent.DeleteSubKeyTree(Name);

                    Check();
                }
                public void Read()
                {
                    // registry => property list

                    Clear();
                    Check();

                    if (!Exists)
                        throw new Exception("Exception [!] Registry path does not exist");

                    using var key = Hive.OpenSubKey(Branch + "\\" + Name);
                    foreach (string name in key.GetValueNames())
                    {
                        Property.Add(new Property((uint)Property.Count, name, key.GetValue(name))
                        {
                            Exists = true
                        });
                    }
                }
                public void Write()
                {
                    // property list => registry

                    Check();
                    if (!Exists)
                    {
                        Create();
                    }

                    using var parent = Hive.OpenSubKey(Branch, writable: true);
                    using var key = parent.CreateSubKey(Name);

                    foreach (RegistryKeyProperty prop in Property)
                    {
                        key.SetValue(prop.Name, prop.Value ?? "");
                        prop.Exists = true;
                    }

                    Check();
                }
                protected void SetHive(string root)
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
                public static string GetHivePath(string pspath)
                {
                    string result = null;

                    switch (pspath)
                    {
                        case string s when Regex.IsMatch(s, "^HKLM:", RegexOptions.IgnoreCase) : result = s.Replace("HKLM:","HKEY_LOCAL_MACHINE")  ; break;
                        case string s when Regex.IsMatch(s, "^HKCU:", RegexOptions.IgnoreCase) : result = s.Replace("HKCU:","HKEY_CURRENT_USER")   ; break;
                        case string s when Regex.IsMatch(s, "^HKU:",  RegexOptions.IgnoreCase) : result = s.Replace("HKU:" ,"HKEY_USERS")           ; break;                    
                        case string s when Regex.IsMatch(s, "^HKCR:", RegexOptions.IgnoreCase) : result = s.Replace("HKCR:","HKEY_CLASSES_ROOT")   ; break;
                        case string s when Regex.IsMatch(s, "^HKCC:", RegexOptions.IgnoreCase) : result = s.Replace("HKCC:","HKEY_CURRENT_CONFIG") ; break;
                    }

                    return result;
                }
                public static string GetFull(string root)
                {
                    string result;

                    switch (root)
                    {
                        case "HKLM:" : result = "HKEY_LOCAL_MACHINE"  ; break;
                        case "HKCU:" : result = "HKEY_CURRENT_USER"   ; break;
                        case "HKU:"  : result = "HKEY_USERS"          ; break;
                        case "HKCR:" : result = "HKEY_CLASSES_ROOT"   ; break;
                        case "HKCC"  : result = "HKEY_CURRENT_CONFIG" ; break;
                        default      : result = null                  ; break;
                    }

                    return result;
                }
                public static bool PathExists(string fullname)
                {
                    if (string.IsNullOrEmpty(fullname))
                        return false;

                    Match m = Regex.Match(fullname, @"^(HKLM|HKCU|HKCR|HKU|HKCC):\\(.*)$", RegexOptions.IgnoreCase);

                    if (m.Success)
                    {
                        string shorthive = m.Groups[1].Value.ToUpper();
                        string rest      = m.Groups[2].Value;
                        string fullhive  = null;

                        switch (shorthive)
                        {
                            case "HKLM" : xhive = "HKEY_LOCAL_MACHINE"  ; break;
                            case "HKCU" : xhive = "HKEY_CURRENT_USER"   ; break;
                            case "HKCR" : xhive = "HKEY_CLASSES_ROOT"   ; break;
                            case "HKU"  : xhive = "HKEY_USERS"          ; break;
                            case "HKCC" : xhive = "HKEY_CURRENT_CONFIG" ; break;
                        }

                        if (fullhive != null)
                            fullname = fullhive + "\\" + rest;
                    }

                    int i = fullname.IndexOf('\\');
                    if (i < 0)
                        return false;

                    string hive = fullname.Substring(0, i);
                    string sub  = fullname.Substring(i + 1);

                    Microsoft.Win32.RegistryKey root = null;

                    switch (hive)
                    {
                        case "HKEY_LOCAL_MACHINE"  : root = Microsoft.Win32.Registry.LocalMachine  ; break;
                        case "HKEY_CURRENT_USER"   : root = Microsoft.Win32.Registry.CurrentUser   ; break;
                        case "HKEY_CLASSES_ROOT"   : root = Microsoft.Win32.Registry.ClassesRoot   ; break;
                        case "HKEY_USERS"          : root = Microsoft.Win32.Registry.Users         ; break;
                        case "HKEY_CURRENT_CONFIG" : root = Microsoft.Win32.Registry.CurrentConfig ; break;
                        default                    : return false;
                    }

                    if (root == null)
                        return false;

                    using (var key = root.OpenSubKey(sub))
                    {
                        return key != null;
                    }
                }
                public override string ToString()
                {
                    if (string.IsNullOrEmpty(Fullname))
                    {
                        return string.Format("<{0}>", base.ToString());   
                    }
                    else
                    {   
                        return Fullname;
                    }
                }
            }

            public class Controller : Provider
            {
                private Module.Template Template;
                public void Assign(string fullname)
                {
                    Initialize(fullname);
                    Check();
                    Read();
                    WriteTemplate();
                }
                public void Assign(string fullname, Module.Template template)
                {
                    Initialize(fullname);
                    Template = template;
                    ReadTemplate();
                    Write();
                }
                public void ReadTemplate()
                {
                    Clear();
                    FieldInfo[] fields = typeof(Module.Template)
                        .GetFields(BindingFlags.Public | BindingFlags.Instance);

                    for (int i = 0; i < fields.Length; i++)
                    {
                        Property.Add(new Property((uint)i, fields[i].Name, fields[i].GetValue(Template)));
                    }
                }
                public void WriteTemplate()
                {
                    FieldInfo[] fields = typeof(Module.Template)
                        .GetFields(BindingFlags.Public | BindingFlags.Instance);

                    foreach (var prop in Property)
                    {
                        fields[prop.Index].SetValueDirect(__makereg(Template), Convert.ToString(prop.Value));
                    }
                }
            }
        }
    }
}