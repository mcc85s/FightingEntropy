// 08/20/2026 Roslyn Compiler Controller (Windows/Linux)
using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Threading.Tasks;

namespace Compiler
{
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
                throw new Exception("Exception [!] Invalid date format MM/dd/yyyy HH:mm:ss");

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

    public static class Byte
    {
        public const ulong  B = 1UL;
        public const ulong KB = 1024UL;
        public const ulong MB = KB * KB;
        public const ulong GB = KB * MB;
        public const ulong TB = KB * GB;
        public const ulong PB = KB * TB;
        public const ulong EB = KB * PB;
        public const ulong KB_Max = (ulong)(KB * 0.85);
        public const ulong MB_Max = (ulong)(MB * 0.85);
        public const ulong GB_Max = (ulong)(GB * 0.85);
        public const ulong TB_Max = (ulong)(TB * 0.85);
        public const ulong PB_Max = (ulong)(PB * 0.85);
        public const ulong EB_Max = (ulong)(EB * 0.85);
        public static ulong _KB(double value) => (ulong)(value * KB);
        public static ulong _MB(double value) => (ulong)(value * MB);
        public static ulong _GB(double value) => (ulong)(value * GB);
        public static ulong _TB(double value) => (ulong)(value * TB);
        public static ulong _PB(double value) => (ulong)(value * PB);
        public static ulong _EB(double value) => (ulong)(value * EB);
    }

    public struct ByteSize
    {
        public string Name;
        public ulong Bytes;
        public string Unit;
        public string Size;
        public ByteSize(string name, ulong bytes)
        {
            Name  = name;
            Bytes = bytes;

            if      (bytes < Byte.KB_Max) Set("Byte");
            else if (bytes < Byte.MB_Max) Set("Kilobyte");
            else if (bytes < Byte.GB_Max) Set("Megabyte");
            else if (bytes < Byte.TB_Max) Set("Gigabyte");
            else if (bytes < Byte.PB_Max) Set("Terabyte");
            else if (bytes < Byte.EB_Max) Set("Petabyte");
            else                          Set("Exabyte");
        }
        public void Set(string unit)
        {
            Unit         = unit;
            
            ulong   size = 0;
            string label = null;

            switch (unit)
            {
                case "Byte"     : size = Byte.B ; label = " B"; break;
                case "Kilobyte" : size = Byte.KB; label = "KB"; break;
                case "Megabyte" : size = Byte.MB; label = "MB"; break;
                case "Gigabyte" : size = Byte.GB; label = "GB"; break;
                case "Terabyte" : size = Byte.TB; label = "TB"; break;
                case "Petabyte" : size = Byte.PB; label = "PB"; break;
                case "Exabyte"  : size = Byte.EB; label = "EB"; break;
            }

            Size = string.Format("{0:N2} {1}", (Bytes/size), label);
        }
        public override string ToString()
        {
            return Size;
        }
        public static ByteSize New(string name, ulong bytes)
        {
            return new ByteSize(name, bytes);
        }
    }

    public enum DotNetVersion : uint
    {
        Net8 = 8,
        Net9 = 9,
        Net10 = 10,       
    }

    public enum Platform
    {
        Windows = 0,
        Linux = 1,
    }

    public enum EntryMode
    {
        Unspecified,
        File,
        Directory
    }

    public enum EntryType
    {
        Source     = 0,
        Target     = 1,
        Dependency = 2,
        Reference  = 3,
    }

    public class Entry
    {
        public uint            Index { get; set; }
        public EntryMode        Mode { get; set; }
        public EntryType        Type { get; set; }
        public string    DisplayName { get; set; }
        [System.Management.Automation.Hidden]
        public ModDateTime?  Created { get; set; }
        public ModDateTime? Modified { get; set; }
        public string           Name { get; set; }
        public string      Extension { get; set; }
        public ByteSize?        Size { get; set; }
        public bool           Exists { get; set; }
        public string       Fullname { get; set; }
        public string      Directory { get; set; }
        public Entry(uint index, EntryType type, string displayname, string fullname)
        {
            Index       = index;
            Type        = type;
            DisplayName = displayname;
            Fullname    = fullname;

            Refresh();
        }
        public void Check()
        {
            if (System.IO.File.Exists(Fullname))
            {
                Exists = true;
                Mode   = EntryMode.File;
                return;
            }
            if (System.IO.Directory.Exists(Fullname))
            {
                Exists = true;
                Mode   = EntryMode.Directory;
                return;
            }

            Exists     = false;
            Mode       = EntryMode.Unspecified;
        }
        public void Clear()
        {
            Modified  = null;
            Created   = null;
            Name      = null;
            Directory = null;
            Extension = null;
            Size      = new ByteSize("Null", 0);
        }
        public void Refresh()
        {
            Check();

            if (!Exists)
            {
                Clear();
                return;
            }

            if (Mode == EntryMode.File)
            {
                FileInfo file     = new FileInfo(Fullname);

                Modified          = new ModDateTime(file.LastWriteTime);
                Created           = new ModDateTime(file.CreationTime);
                Name              = file.Name;
                Directory         = file.DirectoryName;
                Extension         = System.IO.Path.GetExtension(Fullname).Trim(new char[]{'.'});
                Size              = new ByteSize("File", (ulong)file.Length);
            }
            else if (Mode == EntryMode.Directory)
            {
                DirectoryInfo dir = new DirectoryInfo(Fullname);

                Modified          = new ModDateTime(dir.LastWriteTime);
                Created           = new ModDateTime(dir.CreationTime);
                Name              = dir.Name;
                Directory         = dir.Parent?.FullName;
                Extension         = "";
                Size              = new ByteSize("Directory", 0);
            }
        }
        public override string ToString()
        {
            return Fullname;
        }
    }

    public class Source : Entry
    {
        public Source(uint index, EntryType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Target : Entry
    {
        public Target(uint index, EntryType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Dependency : Entry
    {
        public Dependency(uint index, EntryType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Reference : Dependency
    {
        public Reference(uint index, EntryType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public enum ErrorType
    {
        Normal   = 0,
        Metadata = 1,
        Fatal    = 2,
    }

    public class Error
    {
        public uint     Index { get; set; }
        public ErrorType Type { get; set; }
        public uint      Line { get; set; }
        public string    Code { get; set; }
        public string Message { get; set; }
        public Error(uint index, uint line, string code, string message)
        {
            Index   = index;
            Line    = line;
            Code    = code;
            Message = message;
        }
        public override string ToString()
        {
            return string.Format("[{0}] (Line {1}) {2}: {3}", Index, Line, Code, Message);
        }
    }

    public class Argument
    {
        public uint         Index { get; set; }
        public string DisplayName { get; set; }
        public string     Content { get; set; }
        public Argument(uint index, string displayname, string content)
        {
            Index       = index;
            DisplayName = displayname;
            Content     = content;
        }
        public override string ToString()
        {
            return Content;
        }
    }

    public class Controller
    {
        public DateTime                Date { get; set; }
        public Platform            Platform { get; set; }
        public Source                Source { get; set; }
        public Target                Target { get; set; }
        public DotNetVersion     NetVersion { get; set; }
        public string                   Tfm { get; set; }
        public List<Dependency>  Dependency { get; set; }
        public List<Reference>    Reference { get; set; }
        public List<Argument>      Argument { get; set; }
        public System.Diagnostics.ProcessStartInfo Process { get; set; }
        public DateTime?              Start { get; set; }
        public DateTime?                End { get; set; }
        public TimeSpan?               Span { get; set; }
        public List<Error>            Error { get; set; }
        private static readonly Regex   Rx = new Regex(Pattern(), RegexOptions.Compiled);
        private static string Pattern()
        {
            return @"^(?:(?<Path>.+?)\((?<Line>\d+),\d+\):\s*)?error\s+(?<Code>CS\d+):\s+(?<Message>.+)$";
        }
        public Controller() : this(DotNetVersion.Net9) { }
        public Controller(DotNetVersion version)
        {
            Platform   = Environment.OSVersion.Platform == PlatformID.Win32NT ? Platform.Windows : Platform.Linux;
            NetVersion = version;
            Tfm        = $"net{(uint)NetVersion}.0";

            Initialize();
        }
        private string VersionPrefix()
        {
            return $"{NetVersion:D}.";
        }
        public void Initialize()
        {
            Date       = DateTime.Now;
            Start      = null;
            End        = null;
            Span       = null;

            Source     = null;
            Target     = null;
            Process    = null;

            Clear();
        }
        public void Clear()
        {
            if (Dependency == null)
                Dependency = new List<Dependency>();
            else
                Dependency.Clear();

            if (Reference == null)
                Reference = new List<Reference>();
            else
                Reference.Clear();

            if (Argument == null)
                Argument = new List<Argument>();
            else
                Argument.Clear();

            if (Error == null)
                Error = new List<Error>();
            else
                Error.Clear();
        }
        public void SetSource(string source)
        {
            if (!System.IO.File.Exists(source))
                throw new Exception("Exception [!] Invalid <source> path: <" + source + ">");

            Source = new Source(0, EntryType.Source, "Source", source);
        }
        public void SetTarget(string target)
        {
            string parent = System.IO.Path.GetDirectoryName(target);
            if (!Directory.Exists(parent))
                throw new Exception("Exception [!] Invalid <target> directory: <" + parent + ">");

            Target = new Target(0, EntryType.Target, "Target", target);
        }
        public string RuntimePath()
        {
            if (Platform == Platform.Windows)
                return System.IO.Path.Combine(Environment.GetEnvironmentVariable("ProgramFiles"), "dotnet", "shared", "Microsoft.NETCore.App");
            else if (Platform == Platform.Linux)
            {
                string fullname = "/usr/lib64/dotnet/shared/Microsoft.NETCore.App";
                if (System.IO.Directory.Exists(fullname))
                    return fullname;
                 
                return "/usr/share/dotnet/shared/Microsoft.NETCore.App";
            }
            else
            {
                return null;
            }
        }
        public string NormalizePath(string path)
        {
            return Platform == Platform.Windows ? path.Replace('/', '\\') : path.Replace('\\', '/');
        }
        public Dependency GetDependency(string displayname)
        {
            return Dependency.Where(e => e.DisplayName == displayname).FirstOrDefault();
        }
        public Reference GetReference(string displayname)
        {
            return Reference.Where(e => e.DisplayName == displayname).FirstOrDefault();
        }
        public Argument GetArgument(string displayname)
        {
            return Argument.Where(e => e.DisplayName == displayname).FirstOrDefault();
        }
        public void AddDependency(string displayname, string fullname)
        {
            if (GetDependency(displayname) != null)
            {
                Console.WriteLine($"Dependency [!] Duplicate: {displayname}");
                return;
            }
                
            if (!System.IO.File.Exists(fullname) && !System.IO.Directory.Exists(fullname))
            {
                Console.WriteLine($"Dependency [!] Missing: {displayname}");
                return;
            }

            Dependency dep = new Dependency((uint)Dependency.Count, EntryType.Dependency, displayname, fullname);

            Dependency.Add(dep);

            Console.WriteLine("Dependency [+] Added: " + displayname);
        }
        public void AddReference(string displayname, string fullname)
        {
            fullname       = NormalizePath(fullname);
            Reference xref = GetReference(displayname);
            string   label = "";

            if (xref != null)
                label = "Duplicate";
            else if (!System.IO.File.Exists(fullname))
                label = "Missing";   

            if (!string.IsNullOrEmpty(label))
            {
                Console.WriteLine($"Reference [!] Failed ({label}): {displayname}");
                return;
            }
            else
            {
                AddArgument(displayname, $"/reference:{fullname}");

                Reference.Add(new Reference((uint)Reference.Count, EntryType.Reference, displayname, fullname));

                Console.WriteLine($"Reference [+] Added: {displayname}");
            }
        }
        public void AddArgument(string displayname, string argstr)
        {
            Argument arg = GetArgument(displayname);
            if (arg != null)
                throw new Exception("Exception [!] Argument type exists");

            Argument.Add(new Argument((uint)Argument.Count, displayname, argstr));
        }
        public void AddError(uint line, string code, string message)
        {
            Error err = new Error((uint)Error.Count, line, code, message);
            Error.Add(err);
            Console.WriteLine(err);
        }
        public void FindCompiler()
        {
            string          compiler = null;
            IEnumerable<string> sdks = null;

            if (Platform == Platform.Linux)
            {
                string[] roots = new[]{ "/usr/lib64/dotnet/sdk", "/usr/share/dotnet/sdk", "/opt/dotnet/sdk" };

                sdks           = roots.Where(Directory.Exists).SelectMany(Directory.GetDirectories)
                    .Where(x => System.IO.Path.GetFileName(x).StartsWith(VersionPrefix()))
                    .OrderByDescending(System.IO.Path.GetFileName);
            }
            else
            {
                string root    = System.IO.Path.Combine(Environment.GetEnvironmentVariable("ProgramFiles"), "dotnet", "sdk");

                if (!Directory.Exists(root))
                    throw new Exception("Exception [!] dotnet SDK directory missing");

                sdks           = Directory.GetDirectories(root)
                    .Where(x => System.IO.Path.GetFileName(x).StartsWith(VersionPrefix()))
                    .OrderByDescending(System.IO.Path.GetFileName);
            }

            compiler           = sdks.Select(x => System.IO.Path.Combine(x, "Roslyn", "bincore", "csc.dll")).FirstOrDefault(System.IO.File.Exists);

            if (compiler == null)
                throw new Exception($"Exception [!] <dotnet-sdk-{(uint)NetVersion}.0> not detected");

            AddDependency("Roslyn", compiler);
        }
        public void FindRuntime()
        {
            string root = RuntimePath();

            if (!Directory.Exists(root))
                throw new Exception("Exception [!] Runtime directory missing");

            string runtime = Directory.GetDirectories(root)
                    .Where(x => System.IO.Path.GetFileName(x).StartsWith(VersionPrefix()))
                    .OrderByDescending(System.IO.Path.GetFileName)
                    .FirstOrDefault();

            if (runtime == null)
                throw new Exception("Exception [!] Runtime libraries not found in runtime directory");

            AddDependency("Runtime", runtime);
        }
        public void FindReference()
        {
            string[] names = new[] { "Microsoft.NETCore.App.Ref", "Microsoft.WindowsDesktop.App.Ref" };
            string[]    id = new[] { "Core", "Windows" };
            string    root = null;
            int        max = 1;

            if (Platform == Platform.Windows)
            {
                root = System.IO.Path.Combine(Environment.GetEnvironmentVariable("ProgramFiles"), "dotnet", "packs");
                max ++;
            }
            else if (Platform == Platform.Linux)
            {
                root = "/usr/share/dotnet/packs";
            }

            for (int x = 0; x < max; x++)
            {
                string[] packlist = Directory.GetDirectories(root, names[x] + "*");

                string   packroot = packlist.FirstOrDefault();
                if (packroot == null)
                    continue;
            
                string    version = Directory.GetDirectories(packroot)
                    .Where(d => System.IO.Path.GetFileName(d).StartsWith(VersionPrefix()))
                    .OrderByDescending(System.IO.Path.GetFileName)
                    .FirstOrDefault();
                    
                if (version == null)
                    continue;
            
                string     dir = System.IO.Path.Combine(version, "ref", Tfm);
                if (!Directory.Exists(dir))
                    continue;
            
                AddDependency(id[x], dir);
            }
        }
        public void FindEngine()
        {
            string asm = typeof(System.Management.Automation.PSObject).Assembly.Location;

            if (string.IsNullOrWhiteSpace(asm))
                throw new Exception("Exception [!] PS Engine not found");

            AddDependency("Engine", System.IO.Path.GetDirectoryName(asm));
        }
        public void FindGAC()
        {
            if (!OperatingSystem.IsWindows())
                return;

            string dir = Environment.GetFolderPath(Environment.SpecialFolder.Windows);
            string gac = System.IO.Path.Combine(dir, "Microsoft.NET", "assembly", "GAC_MSIL");

            if (System.IO.Directory.Exists(gac))
                AddDependency("GAC", gac);
        }
        public void AddFrom(string dependencyname, string[] files)
        {
            Dependency dep = GetDependency(dependencyname);
            if (dep == null)
                throw new Exception($"Exception [!] Dependency <{dependencyname}> not found");

            string basedir = dep.Mode == EntryMode.File ? dep.Directory : dep.Fullname;

            foreach (string file in files)
            {
                string    fullname = System.IO.Path.Combine(basedir, file);
                string displayname = System.IO.Path.GetFileNameWithoutExtension(file);
                Reference     xref = GetReference(displayname);
                
                if (xref != null)
                    Console.WriteLine($"Reference [!] Exists: {displayname}");
                else if (xref == null)
                    AddReference(displayname, fullname);
            }
        }
        public void AddSource()
        {
            if (Source == null || !Source.Exists)
                throw new Exception("Exception [!] Invalid source designated");
            
            AddArgument("Source", Source.Fullname);
        }
        public string[][] PrimaryArgs()
        {
            if (Source == null || Target == null)
                throw new Exception("Exception [!] <Source> + <Target> must both be set");

            Dependency dep = GetDependency("Roslyn");
            if (dep == null)
                throw new Exception("Exception [!] Roslyn missing and is required");

            return new string[][]
            {
                new string[]{"Exec",                       "exec"},
                new string[]{"Compiler",             dep.Fullname},
                new string[]{"Target",          "/target:library"},
                new string[]{"LangVersion", "/langversion:latest"},
                new string[]{"Unsafe",                  "/unsafe"},
                new string[]{"Out",              "/out:" + Target},
            };
        }
        public void Prime()
        {
            if (Source == null)
                throw new Exception("Exception [!] Must assign source");

            if (Target == null)
                throw new Exception("Exception [!] Must assign target");

            // Dependencies first
            FindCompiler();
            FindRuntime();
            FindEngine();

            if (Platform == Platform.Windows)
                FindGAC();

            FindReference();

            // Generate argumentlist first
            foreach (string[] item in PrimaryArgs())
            {
                AddArgument(item[0], item[1]);
            }
        }
        public void Stage(bool stdout = true, bool stderr = true)
        {
            Process                        = new System.Diagnostics.ProcessStartInfo();
            Process.FileName               = "dotnet";
            Process.RedirectStandardOutput = stdout;
            Process.RedirectStandardError  = stderr;
            Process.UseShellExecute        = false;
            Process.CreateNoWindow         = true;

            foreach (Argument argument in Argument)
                Process.ArgumentList.Add(argument.Content);
        }
        public void Execute()
        {
            ExecuteAsync().GetAwaiter().GetResult();
        }
        private async Task ExecuteAsync()
        {
            Error.Clear();
            Source.Refresh();

            Start             = DateTime.Now;
            Console.WriteLine("Starting [~] " + Start);

            using (var proc   = System.Diagnostics.Process.Start(Process))
            {
                string stdout = await proc.StandardOutput.ReadToEndAsync();
                string stderr = await proc.StandardError.ReadToEndAsync();

                await proc.WaitForExitAsync();

                proc.Close();
                proc.Dispose();

                if (stdout.Length > 0)
                {
                    foreach (string line in stdout.Split(new char[]{'\n'}))
                    {
                        var mx = Rx.Match(line);

                        if (mx.Success)
                        {
                            uint  xline = uint.TryParse(mx.Groups["Line"].Value, out uint v) ? v : 0;
                            string code = mx.Groups["Code"].Value;
                            string  msg = mx.Groups["Message"].Value;

                            AddError(xline, code, msg);
                        }
                    }
                }

                if (stderr.Length > 0)
                {
                    foreach (string line in stdout.Split(new char[]{'\n'}))
                    {
                        System.Console.WriteLine(line);
                    }
                }

                Error.Sort((a,b) => a.Line.CompareTo(b.Line));
                
                for (int i = 0; i < Error.Count; i++)
                {
                    Error[i].Index = (uint)i;
                }

                End           = DateTime.Now;
                Span          = End - Start;

                Console.WriteLine(string.Format("Complete [+] " + Span));

                Target.Refresh();
            }
        }
        public void Print()
        {
            // Compute column widths
            int a = Math.Max("Index".Length,   Error.Max(x => x.Index.ToString().Length));
            int b = Math.Max("Type".Length,    Error.Max(x =>  x.Type.ToString().Length));
            int c = Math.Max("Line".Length,    Error.Max(x =>  x.Line.ToString().Length));
            int d = Math.Max("Code".Length,    Error.Max(x => x != null && x.Code    != null ?    x.Code.Length : 0));
            int e = Math.Max("Message".Length, Error.Max(x => x != null && x.Message != null ? x.Message.Length : 0));

            int[] widths = { a, b, c, d, e };
            string  mask = string.Join(" ", Enumerable.Range(0, widths.Length).Select(i => "{" + i + ",-" + widths[i] + "}"));

            // Print header (single continuous line)
            Console.Write("\n");
            Console.Write(string.Format(mask, "Index", "Type", "Line", "Code", "Message") + "\n");
            Console.Write(string.Format(mask, "-----", "----", "----", "----", "-------") + "\n");

            // Print rows
            foreach (var x in Error)
            {
                Console.Write(string.Format(mask, x.Index, x.Type, x.Line, x.Code, x.Message) + "\n");
            }

            Console.Write("\n");
        }
    }
}