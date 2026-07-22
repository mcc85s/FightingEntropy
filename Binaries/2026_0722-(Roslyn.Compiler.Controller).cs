// 07/22/2026 Linux-based Roslyn Compiler Controller

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

    public enum FileType
    {
        Source     = 0,
        Target     = 1,
        Dependency = 2,
        Reference  = 3,
    }

    public class File
    {
        public uint            Index { get; set; }
        [System.Management.Automation.Hidden]
        public FileType         Type { get; set; }
        [System.Management.Automation.Hidden]
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
        public File(uint index, FileType type, string displayname, string fullname)
        {
            Index       = index;
            Type        = type;
            DisplayName = displayname;
            Fullname    = fullname;

            Refresh();
        }
        public void Check()
        {
            Exists     = System.IO.File.Exists(Fullname);
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

            if (Exists)
            {
                FileInfo file = new FileInfo(Fullname);

                Modified  = new ModDateTime(file.LastWriteTime);
                Created   = new ModDateTime(file.CreationTime);
                Name      = file.Name;
                Directory = file.DirectoryName;
                Extension = Path.GetExtension(Fullname).Trim(new char[]{'.'});
                Size      = new ByteSize("File", (ulong)file.Length);
            }
            else
            {
                Clear();
            }
        }
        public void Remove() {}
        public void Create() {}
        public void Update() {}
        public override string ToString()
        {
            return Fullname;
        }
    }

    public class Source : File
    {
        public Source(uint index, FileType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Target : File
    {
        public Target(uint index, FileType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Dependency : File
    {
        public Dependency(uint index, FileType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
    }

    public class Reference : Dependency
    {
        public Reference(uint index, FileType type, string displayname, string fullname) : base(index, type, displayname, fullname) { }
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
        public DateTime               Date { get; set; }
        public Source               Source { get; set; }
        public Target               Target { get; set; }
        public List<Dependency> Dependency { get; set; }
        public List<Reference>   Reference { get; set; }
        public List<Argument>     Argument { get; set; }
        public System.Diagnostics.ProcessStartInfo Process { get; set; }
        public DateTime?             Start { get; set; }
        public DateTime?               End { get; set; }
        public TimeSpan?              Span { get; set; }
        public List<Error>           Error { get; set; }
        private static readonly Regex   Rx = new Regex(Pattern(), RegexOptions.Compiled);
        private static string Pattern()
        {
            return @"^(?:(?<Path>.+?)\((?<Line>\d+),\d+\):\s*)?error\s+(?<Code>CS\d+):\s+(?<Message>.+)$";
        }
        public Controller()
        {
            Initialize();
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

            Source = new Source(0, FileType.Source, "Source", source);
        }
        public void SetTarget(string target)
        {
            string parent = Path.GetDirectoryName(target);
            if (!Directory.Exists(parent))
                throw new Exception("Exception [!] Invalid <target> directory: <" + parent + ">");

            Target = new Target(0, FileType.Target, "Target", target);
        }
        public Dependency GetDependency(string displayname)
        {
            return Dependency.Where(e => e.DisplayName == displayname).FirstOrDefault();
        }
        public void AddDependency(string displayname, string fullname)
        {
            Dependency dep = GetDependency(displayname);
            if (dep != null)
                throw new Exception("Exception [!] Duplicate dependency detected");

            dep = new Dependency((uint)Dependency.Count, FileType.Dependency, displayname, fullname);

            Dependency.Add(dep);

            Console.WriteLine("Dependency [+] Added: " + displayname);
        }
        public Reference GetReference(string displayname)
        {
            return Reference.Where(e => e.DisplayName == displayname).FirstOrDefault();
        }
        public void AddReference(string displayname, string fullname)
        {
            Reference xref = GetReference(displayname);
            if (xref != null)
                throw new Exception("Exception [!] Duplicate reference detected");

            else if (!System.IO.File.Exists(fullname))
                throw new Exception("Exception [!] Reference does not exist");

            AddArgument(displayname, "/reference:" + fullname);

            Reference.Add(new Reference((uint)Reference.Count, FileType.Reference, displayname, fullname));

            Console.WriteLine("Reference [+] Added: " + displayname);
        }
        public Argument GetArgument(string displayname)
        {
            return Argument.Where(e => e.DisplayName == displayname).FirstOrDefault();
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
            string[] roots        = new string[]{ "/usr/share/dotnet", "/usr/lib", "/usr/lib64" };

            var compiler          = roots
                .SelectMany(r     => Directory.Exists(r) ? Directory.GetFiles(r, "csc.dll", SearchOption.AllDirectories) : Array.Empty<string>())
                .FirstOrDefault(f => Regex.IsMatch(f, "Roslyn.+bincore", RegexOptions.IgnoreCase));

            if (compiler == null)
                throw new Exception("Exception [!] (Roslyn/dotnet-sdk-8.0) not detected");

            AddDependency("Roslyn", compiler);
        }
        public void FindRuntime()
        {
            string root = "/usr/share/dotnet/shared/Microsoft.NETCore.App";

            if (!Directory.Exists(root))
                throw new Exception("Exception [!] Runtime directory missing");

            var runtime = Directory.GetDirectories(root).OrderByDescending(Path.GetFileName).FirstOrDefault();

            if (runtime == null)
                throw new Exception("Exception [!] Runtime libraries not found in runtime directory");

            AddDependency("Runtime", runtime);
        }
        public void FindSMA()
        {
            var asm = typeof(System.Management.Automation.PSObject).Assembly.Location;

            if (string.IsNullOrWhiteSpace(asm))
                throw new Exception("Exception [!] System.Management.Automation.dll not found");

            AddDependency("Sysman", asm);
        }
        public void AddFromRuntime(string[] files)
        {
            Dependency         dep = GetDependency("Runtime");

            foreach (string file in files)
            {
                string displayname = Path.GetFileNameWithoutExtension(file);

                if (GetReference(displayname) == null)
                {
                    AddReference(displayname, dep.Fullname + "/" + file);
                }
            }
        }
        public void AddFromSystem(string[] files)
        {
            Dependency dep = GetDependency("Sysman");

            foreach (string file in files)
            {
                string displayname = Path.GetFileNameWithoutExtension(file);

                if (GetReference(displayname) == null)
                {
                    AddReference(displayname, dep.Directory + "/" + file);
                }
            }
        }
        public void AddSystem()
        {
            Dependency dep = GetDependency("Sysman");

            AddReference("System.Management.Automation", dep.Fullname);
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
            FindSMA();

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

                Error.Sort((a,b) => a.Line.CompareTo(b.Line));
                
                for (int i = 0; i < Error.Count; i++)
                {
                    Error[i].Index = (uint)i;
                }

                End           = DateTime.Now;
                Span          = End - Start;

                Console.WriteLine(string.Format("Complete [+] " + Span));
            }
        }
    }
}
