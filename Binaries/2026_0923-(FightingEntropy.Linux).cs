// FightingEntropy.Linux
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Principal;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Text.RegularExpressions;
using FightingEntropy.Core;
using FightingEntropy.Core.Interop;
using FightingEntropy.Core.Platform.Security;
using FightingEntropy.Core.Platform.Security.Certificate;
using System.Runtime.InteropServices.Marshalling;
using FightingEntropy.Linux.Process;
using System.Xml;
using System.Diagnostics.CodeAnalysis;
using FightingEntropy.Linux.Security;
using System.Text.Unicode;

namespace FightingEntropy
{
    namespace Linux
    {
        namespace Interop
        {
            public sealed class Controller : Core.Interop.Controller
            {
                public override IProcess                Process { get; }
                public override ISecurity              Security { get; }
                public override IConfiguration    Configuration { get; }
                public override IFileSystem          FileSystem { get; }
                public override IService                Service => throw new NotImplementedException(); // { get; }
                public override ICommand                Command => throw new NotImplementedException(); // { get; }
                public override INetwork                Network => throw new NotImplementedException(); // { get; }
                public override IHardware              Hardware => throw new NotImplementedException(); // { get; }
                public Controller()
                {
                    // Set the bridge
                    Bridge        = Forward;

                    // Assign the controllers
                    Process       = new       Process.Manager(GetConsole, Bridge);
                    Security      = new      Security.Manager(GetConsole, Bridge);
                    Configuration = new Configuration.Manager(GetConsole, Bridge);
                    FileSystem    = new    FileSystem.Manager(GetConsole, Bridge);
                }
                public override void LoadDependencies()
                {
                    // Process dependencies (none atm)
                    // Process.LoadDependencies();

                    // Security dependencies
                    Security.LoadDependencies();

                    // Configuration dependencies (moved to filesystem)
                    // Configuration.LoadDependencies();

                    // FileSystem dependencies
                    FileSystem.LoadDependencies();
                }
                public override void Initialize()
                {
                    // Process
                    Process.Initialize();

                    // Security
                    Security.Initialize(null);

                    // Configuration
                    Configuration.Initialize();

                    // FileSystem
                    FileSystem.Initialize();
                }
                public override void Initialize(Core.Platform.Security.Credential credential)
                {
                    // Process
                    Process.Initialize();

                    // Security
                    Security.Initialize(credential);

                    // Configuration
                    Configuration.Initialize();

                    // FileSystem
                    FileSystem.Initialize();
                }
                protected object Forward(string name)
                {
                    return name switch
                    {
                        "Process"       => Process,
                        "Security"      => Security,
                        "Configuration" => Configuration,
                        "FileSystem"    => FileSystem,
                        _               => null
                    };
                }
            }
        }

        namespace Process
        {
            public enum SudoStatus
            {
                Unspecified = 0,
                Prompted    = 1,
                Sent        = 2,
                Rejected    = 3,
                Expired     = 4,
                Accepted    = 5,    
            }

            public class Sudo
            {
                public SudoStatus        Status { get; private set; }
                public bool            Prompted { get; private set; }
                public bool                Sent { get; private set; }
                public bool            Accepted { get; private set; }
                public bool               Valid => Accepted && Expires != null && DateTime.Now < Expires.Value;
                public int             ExitCode { get; private set; }
                public DateTime         Current => DateTime.Now;
                public DateTime?           Last { get; private set; }
                public DateTime?        Expires { get; private set; }
                public void Reset()
                {
                    SetStatus(SudoStatus.Unspecified, false, false, false, -1, null, null);
                }
                private void SetStatus(SudoStatus status, bool prompted, bool sent, bool accepted, int exitcode, DateTime? last, DateTime? expires)
                {
                    Status   = status;
                    Prompted = prompted;
                    Sent     = sent;
                    Accepted = accepted;
                    // get valid

                    ExitCode = exitcode;
                    Last     = last;
                    Expires  = expires;
                }
                public void MarkAccepted()
                {
                    var now = DateTime.Now;

                    SetStatus(SudoStatus.Accepted, true, true, true, 0, now, now.AddMinutes(5));
                }
                public void MarkRejected()
                {
                    SetStatus(SudoStatus.Rejected, true, true, false, -1, DateTime.Now, null);
                }
                public void Refresh()
                {
                    Last     = DateTime.Now;
                }
                public void ApplyCode(int code)
                {
                    if (code == 0)
                        MarkAccepted();
                    else
                        MarkRejected();
                }
            }

            public class Manager : Core.Interop.Process
            {
                private Func<string, object> Bridge { get; set; }
                public Sudo                    Sudo { get; set; }
                [DllImport("libc", SetLastError = true, CharSet = CharSet.Ansi)]
                private static extern int readlink(string path, StringBuilder buffer, int bufferSize);
                private static readonly Regex RxMem = new Regex(@"VmSize:\s+(\d+)\s+kB[\s\S]*?VmRSS:\s+(\d+)\s+kB[\s\S]*?VmSwap:\s+(\d+)\s+kB", RegexOptions.Multiline | RegexOptions.Compiled);
                public Manager(Func<Core.Console.Controller> console, Func<string, object> bridge) : base(console)
                {
                    Bridge = bridge;
                    Sudo   = new Sudo();
                }
                public Security.Manager           Security() =>      (Security.Manager)Bridge("Security");
                public Configuration.Manager Configuration() => (Configuration.Manager)Bridge("Configuration");
                public FileSystem.Manager       FileSystem() =>    (FileSystem.Manager)Bridge("FileSystem");
                public override void Initialize()
                {
                    // null right now
                }
                public override void LoadDependencies()
                {
                    // null right now
                }
                public static string ReadLink(string path)
                {
                    const int bufferSize = 4096;
                    var buffer = new StringBuilder(bufferSize);

                    int result = readlink(path, buffer, bufferSize);

                    if (result < 0)
                        return null; // readlink failed

                    return buffer.ToString(0, result);
                }
                public override void Refresh()
                {
                    Clear("Entry");

                    foreach (var dir in System.IO.Directory.GetDirectories("/proc"))
                    {
                        var name = System.IO.Path.GetFileName(dir);
                        if (!int.TryParse(name, out int pid))
                            continue;

                        var entry = ParseEntry(pid);
                        if (entry != null)
                            Entry.Add(entry);
                    }
                }
                public Core.Platform.Process.Entry ParseEntry(int pid)
                {
                    Core.Platform.Process.Entry proc;

                    string   pathcomm = $"/proc/{pid}/comm";
                    string    pathexe = $"/proc/{pid}/exe";
                    string    pathcmd = $"/proc/{pid}/cmdline";
                    string   pathstat = $"/proc/{pid}/stat";
                    string pathstatus = $"/proc/{pid}/status";

                    string       name = null;
                    string       path = null;
                    string    arglist = null;

                    long        utime = 0;
                    long        stime = 0;
                    long        ticks = 100;
                    double        cpu = 0;
                    string[]   status = Array.Empty<string>();

                    ulong[]       mem = null;
                    ulong      vmsize = 0;
                    ulong       vmrss = 0;
                    ulong      vmswap = 0;
                    int           uid = 0;

                    // cmdline, name + path + arguments
                    if (System.IO.File.Exists(pathcmd))
                    {
                        var raw = System.IO.File.ReadAllText(pathcmd);

                        if (!string.IsNullOrWhiteSpace(raw))
                        {
                            var cmdline = raw.Replace('\0', ' ').Trim();
                            var parts   = cmdline.Split(' ', 2);
                            
                            path        = parts.Length > 0 ? parts[0] : null;
                            arglist     = parts.Length > 1 ? parts[1] : null;

                            if (!string.IsNullOrWhiteSpace(path))
                                name = System.IO.Path.GetFileName(path);
                        }
                    }

                    // comm - if name still empty, get name
                    if (string.IsNullOrWhiteSpace(name) && System.IO.File.Exists(pathcomm))
                    {
                        var comm = System.IO.File.ReadAllText(pathcomm).Trim();

                        if (!string.IsNullOrWhiteSpace(comm))
                            name = comm;
                    }

                    // exe
                    if (string.IsNullOrWhiteSpace(path) && System.IO.File.Exists(pathexe))
                    {
                        var exe = ReadLink(pathexe);

                        if (!string.IsNullOrWhiteSpace(exe))
                        {
                            // set path if cmdline failed to
                            if (string.IsNullOrWhiteSpace(path))
                                path = exe;

                            // if name still empty, get name from exe path
                            if (string.IsNullOrWhiteSpace(name))
                                name = System.IO.Path.GetFileName(exe);
                        }
                    }

                    // stat
                    if (System.IO.File.Exists(pathstat))
                    {
                        var stat  = System.IO.File.ReadAllText(pathstat);
                        var fields = stat.Split(' ');

                        if (fields.Length > 14)
                        {
                            utime = long.Parse(fields[13]);
                            stime = long.Parse(fields[14]);
                        }

                        // if name still empty, get name from stat
                        if (string.IsNullOrWhiteSpace(name))
                        {
                            int start = stat.IndexOf('(');
                            int end   = stat.IndexOf(')');

                            if (start >= 0 && end > start)
                            {
                                var statname = stat.Substring(start + 1, end - start - 1);
                                if (!string.IsNullOrWhiteSpace(statname))
                                {
                                    name = statname;
                                }
                            }
                        }
                    }

                    // if name still null, use PID
                    if (string.IsNullOrWhiteSpace(name))
                        name = $"[{pid}]";

                    // status
                    cpu     = (utime + stime) / (double)ticks;

                    if (System.IO.File.Exists(pathstatus))
                        status = System.IO.File.ReadAllLines(pathstatus);

                    mem        = GetMem(status);
                    if (mem != null)
                    {
                        vmrss  = mem[0];
                        vmsize = mem[1];
                        vmswap = mem[2];
                    }

                    uid    = GetUid(status);

                    proc   = new Core.Platform.Process.Entry(pid, name, path ?? string.Empty, arglist, false, uid, vmrss, vmsize, vmswap, 0, TimeSpan.FromSeconds(cpu), IntPtr.Zero);
                        
                    // dependency lookup for guid
                    var dependency = Dependency.FirstOrDefault(x => x.Id == pid);
                    if (dependency != null)
                        proc.Guid  = dependency.Guid;

                    return proc;
                }
                public ulong[] GetMem(string[] status)
                {
                    string text = string.Join("\n", status);

                    var m = RxMem.Match(text);

                    if (!m.Success)
                        return new ulong[] { 0, 0, 0 };

                    ulong vmSize = ulong.Parse(m.Groups[1].Value) * 1024;
                    ulong vmRSS  = ulong.Parse(m.Groups[2].Value) * 1024;
                    ulong vmSwap = ulong.Parse(m.Groups[3].Value) * 1024;

                    return new ulong[] { vmSize, vmRSS, vmSwap };
                }
                public int GetUid(string[] status)
                {
                    var line = status.FirstOrDefault(x => x.StartsWith("Uid:"));
                    if (line == null) return 0;

                    var parts = line.Split(':')[1].Trim().Split('\t');
                    return int.Parse(parts[0]);
                }
                private int EnableSudo()
                {
                    var psi = new ProcessStartInfo
                    {
                        FileName               = "sudo",
                        Arguments              = "-S -p '' -v",
                        RedirectStandardInput  = true,
                        RedirectStandardOutput = true,
                        RedirectStandardError  = true,
                        UseShellExecute        = false
                    };

                    using var proc = System.Diagnostics.Process.Start(psi);

                    var security = Security();
                    if (security?.Credential?.Password == null)
                        return 1;

                    IntPtr ptr = Marshal.SecureStringToGlobalAllocUnicode(security.Credential.Password);
                    try
                    {
                        string pwd = Marshal.PtrToStringUni(ptr);
                        proc.StandardInput.WriteLine(pwd);
                        proc.StandardInput.Flush();
                    }
                    finally
                    {
                        Marshal.ZeroFreeGlobalAllocUnicode(ptr);
                    }

                    proc.WaitForExit();
                    return proc.ExitCode;
                }
                public void VerifySudoCapability()
                {
                    var psi                    = new ProcessStartInfo
                    {
                        FileName               = "sudo",
                        Arguments              = "-n true",
                        RedirectStandardError  = true,
                        RedirectStandardOutput = true,
                        UseShellExecute        = false
                    };

                    using var proc             = System.Diagnostics.Process.Start(psi);
                    proc.WaitForExit();

                    Sudo.ApplyCode(proc.ExitCode);
                }
                public void VerifySudoCredential()
                {
                    var security = Security();
                    if (security?.Credential?.Password == null)
                    {
                        Update(-1, "Exception [!] Unable to verify credential");
                        return;
                    }

                    var psi                    = new ProcessStartInfo
                    {
                        FileName               = "sudo",
                        Arguments              = "-S -p '' -v",
                        RedirectStandardInput  = true,
                        RedirectStandardOutput = true,
                        RedirectStandardError  = true,
                        UseShellExecute        = false,
                        CreateNoWindow         = true
                    };

                    using var proc             = System.Diagnostics.Process.Start(psi);

                    System.Console.CancelKeyPress += (sender, e) =>
                    {
                        e.Cancel    = true;
                        try { proc.Kill(); } catch {}
                    };

                    var     errTask = proc.StandardError.ReadToEndAsync();

                    IntPtr      ptr = Marshal.SecureStringToGlobalAllocUnicode(security.Credential.Password);
                    try
                    {
                        string  pwd = Marshal.PtrToStringUni(ptr);

                        byte[] utf8 = System.Text.Encoding.UTF8.GetBytes(pwd + "\n");

                        proc.StandardInput.BaseStream.Write(utf8, 0, utf8.Length);
                        proc.StandardInput.BaseStream.Flush();
                        proc.StandardInput.Close();
                    }
                    finally
                    {
                        Marshal.ZeroFreeGlobalAllocUnicode(ptr);
                    }

                    proc.WaitForExit();
                    _ = errTask.Result;

                    Sudo.ApplyCode(proc.ExitCode);
                }
                public override string Start(Core.Platform.Process.Dependency dep)
                {
                    if (dep == null)
                        return null;

                    if (dep.Admin && !Sudo.Valid)
                    {
                        // Debug("[sudo] NeedsReauth() → Reset()");
                        Sudo.Reset();

                        int code = EnableSudo();
                        Sudo.ApplyCode(code);

                        if (!Sudo.Valid)
                        {
                            Update(-1, "Denied [!] Administrative access");
                            return null;
                        }
                    }

                    var psi = new System.Diagnostics.ProcessStartInfo
                    {
                        FileName               = dep.Admin ? "sudo" : dep.Fullname,
                        Arguments              = dep.Admin ? $"{dep.Fullname} {dep.Argument}" : dep.Argument,
                        WorkingDirectory       = dep.WorkingDirectory == null ? Environment.CurrentDirectory : dep.WorkingDirectory,
                        UseShellExecute        = dep.UseShellExecute,
                        RedirectStandardOutput = dep.RedirectStdOut,
                        RedirectStandardError  = dep.Admin ? true : dep.RedirectStdErr,
                        RedirectStandardInput  = dep.Admin ? true : dep.RedirectStdIn,
                        CreateNoWindow         = dep.CreateNoWindow,
                    };

                    var proc = System.Diagnostics.Process.Start(psi);

                    if (proc == null)
                    {
                        dep.MarkFaulted();
                        // Debug("[error] Process.Start returned null");
                        Update(-1, $"Exception [!] Process faulted: '{dep.DisplayName}/{dep.Guid}'");
                        return string.Empty;
                    }

                    dep.MarkStart(proc.Id);
                    // Debug($"[proc] Started PID={proc.Id}");

                    string stdout = dep.RedirectStdOut ? proc.StandardOutput.ReadToEnd() : null;
                    string stderr = dep.RedirectStdErr ?  proc.StandardError.ReadToEnd() : null;

                    proc.WaitForExit();
                    dep.MarkEnd(proc.ExitCode);

                    if (dep.Admin)
                    {
                        Sudo.ApplyCode(proc.ExitCode);
                        // Debug(Sudo.Valid ? "[sudo] Accepted" : "[sudo] Invalid");
                    }

                    Update(1, $"Started [+] Pid: {dep.Id}, Name/Guid: {dep.DisplayName}/{dep.Guid}");

                    return stdout?.TrimEnd() ?? string.Empty;
                }
                private void Debug(string message)
                {
                    Update(-10, message);
                }
                public override void Stop(Core.Platform.Process.Dependency dependency)
                {
                    if (dependency == null)
                        return;

                    var entry = GetProcess(dependency.Id);
                    if (entry == null)
                    {
                        Update(-1, $"Exception [!] Process '{dependency.DisplayName}/{dependency.Guid}' is not running");
                        return;
                    }

                    try
                    {
                        var proc = System.Diagnostics.Process.GetProcessById(entry.Id);
                        proc.Kill();
                        proc.WaitForExit();
                        
                        dependency.State  = Core.Platform.Process.State.Stopped;
                        entry.HasExited = true;

                    }
                    catch
                    {
                        dependency.State = Core.Platform.Process.State.Faulted;
                        Update(-1, $"Exception [!] Process '{dependency.DisplayName}/{dependency.Guid}' faulted");
                    }
                }
                public string Run(string name, string arguments, bool sudo = false)
                {
                    string execution           = arguments != null ? $"{name} {arguments}" : name;

                    var psi                    = new ProcessStartInfo
                    {
                        FileName               = sudo ? "sudo" : name,
                        Arguments              = sudo ? $"-S -n -p '' {execution}" : arguments,
                        RedirectStandardInput  = sudo,
                        RedirectStandardError  = true,
                        RedirectStandardOutput = true,
                        UseShellExecute        = false
                    };

                    using var proc = System.Diagnostics.Process.Start(psi);

                    if (sudo)
                    {
                        var security   = Security();
                        var credential = security.Credential;

                        if (credential == null || credential.Password == null)
                        {
                            Update(-1, "Exception [!] Sudo execution requires credentials");
                            return null;
                        }
                    
                        IntPtr ptr = Marshal.SecureStringToGlobalAllocUnicode(credential.Password);
                        try
                        {
                            string pwd = Marshal.PtrToStringUni(ptr);
                            proc.StandardInput.WriteLine(pwd);
                            proc.StandardInput.Flush();
                        }
                        finally
                        {
                            Marshal.ZeroFreeGlobalAllocUnicode(ptr);
                        }
                    }

                    string output = proc.StandardOutput.ReadToEnd();
                    proc.WaitForExit();

                    return output != null ? output.TrimEnd() : null;
                }
                public string Run(string name, string arguments)
                {
                    var psi                    = new ProcessStartInfo
                    {
                        FileName               = name,
                        Arguments              = arguments != null ? arguments : null,
                        RedirectStandardError  = true,
                        RedirectStandardOutput = true,
                        UseShellExecute        = false
                    };

                    using var proc = System.Diagnostics.Process.Start(psi);
                    string output  = proc.StandardOutput.ReadToEnd();

                    proc.WaitForExit();

                    return output != null ? output.TrimEnd() : null;
                }
                public override string ToString()
                {
                    return $"<{base.ToString()}>";
                } 
            }
        }

        namespace Security
        {
            public class Identifier : Core.Platform.Security.Identifier
            {
                public Identifier() { }
                public Identifier(string name, string sid) : base(name, sid) { }
                public Identifier(string name, int? uid, int? gid, string sid) : base(name, uid, gid, sid) { }
                public override string ToString()
                {
                    if (!string.IsNullOrEmpty(Sid))
                        return Sid;
                    
                    return $"Uid={Uid}, Gid={Gid}";
                }
            }

            public class Role : Core.Platform.Security.Role
            {
                public Role() { }
                public Role(string line)
                {
                    string[] split = line.Split(':');

                    Name    = split[0];
                    Gid     = int.Parse(split[2]);
                    Rid     = null;
                    Sid     = null;
                    
                    Members = split[3].Split(',').Where(x => x.Length > 0).ToList();
                }
            }

            public class Identity : Core.Platform.Security.Identity
            {
                public Identity() { }
                public Identity(Core.Platform.Security.Account account, List<Role> roles, bool isAdmin)
                {
                    AuthenticationType = Core.Platform.Security.AuthenticationType.Local;
                    ImpersonationLevel = Core.Platform.Security.ImpersonationLevel.None;
                    
                    IsAuthenticated    = account != null;
                    IsGuest            = account.Uid == 65534;
                    IsSystem           = account.Uid == 0;
                    IsAdministrator    = account.Uid == 0 || isAdmin;

                    Name               = account.Username;
                    Domain             = account.Domain ?? "";
                    Id                 = account.Uid.ToString();
                    Role               = roles.Cast<Core.Platform.Security.Role>().ToList();
                }
                public override string ToString()
                {
                    return $"{Name} ({Id})";
                }
            }

            public class Claim : Core.Platform.Security.Claim
            {
                public Claim() { }
                public Claim(string type, string value)
                {
                    Type           = type;
                    Value          = value;

                    Issuer         = null;
                    OriginalIssuer = null;
                    ValueType      = null;
                }
            }

            public class Account : Core.Platform.Security.Account
            {
                public Account() { }
                public Account(uint index, string line)
                {
                    Index             = index;

                    string[] split    = line.Split(':');

                    Username          = split[0];
                    DisplayName       = split[4];
                    UserPrincipalName = null;
                    SamAccountName    = null;
                    Domain            = null;
                    Uid               = int.Parse(split[2]);
                    Gid               = int.Parse(split[3]);
                    Sid               = null;
                    Home              = split[5];
                    Shell             = split[6];
                }
                public Account(uint index, string sam, string name, string dn, string domain, string upn, Identifier sid)
                {
                    Index             = index;       
                    Username          = sam;
                    DisplayName       = name;
                    DistinguishedName = dn;
                    UserPrincipalName = upn;
                    SamAccountName    = sam;
                    Domain            = domain;
                    Uid               = null;
                    Gid               = null;
                    Sid               = sid;
                    Home              = null;
                    Shell             = null;
                }
            }

            public class Principal : Core.Platform.Security.Principal
            {
                public Principal() { }
            }

            public class Context : Core.Platform.Security.Context
            {
                public Context() { }
                public Context(Principal principal, List<Certificate.Entry> certificates)
                {
                    Principal   = principal;

                    if (certificates?.Count > 0)
                        Certificate = certificates.Cast<Core.Platform.Security.Certificate.Entry>().ToList();
                }
            }

            public class Credential : Core.Platform.Security.Credential
            {
                public Credential() { }
            }

            namespace Certificate
            {
                public class Entry : Core.Platform.Security.Certificate.Entry
                {
                    public Entry() { }
                    public Entry(uint index, System.IO.FileInfo file, Store store)
                    {
                        Index         = index;
                        Name          = file.Name;
                        StoreName     = store.DisplayName;
                        StoreLocation = store.Location;

                        if (!string.IsNullOrEmpty(file.LinkTarget))
                        {
                            Symlink  = file.FullName;
                            Fullname = System.IO.Path.GetFullPath(System.IO.Path.Combine(file.DirectoryName, file.LinkTarget));
                        }
                        else
                        {
                            Symlink  = null;
                            Fullname = file.FullName;
                        }

                        Exists       = System.IO.File.Exists(Fullname);
                    }
                }

                public class Store : Core.Platform.Security.Certificate.Store
                {
                    public Store() { }
                    public Store(uint index, string displayname, string fullname)
                    {
                        Index       = index;
                        DisplayName = displayname;

                        Name        = System.IO.Path.GetFileName(fullname);
                        Fullname    = fullname;

                        Refresh();
                    }
                    public void SetStoreLocation()
                    {
                        if (Fullname.StartsWith("/etc/ssl"))
                            Location = Core.Platform.Security.Certificate.StoreLocation.System;

                        else if (Fullname.StartsWith("/usr/local/share"))
                            Location = Core.Platform.Security.Certificate.StoreLocation.App;

                        else if (Fullname.Contains(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)))
                            Location = Core.Platform.Security.Certificate.StoreLocation.User;

                        else
                            Location = Core.Platform.Security.Certificate.StoreLocation.Unspecified;
                    }
                    public void Check()
                    {
                        Exists = System.IO.Directory.Exists(Fullname);
                    }
                    public void Clear()
                    {
                        Certificate.Clear();
                    }
                    public void Refresh()
                    {
                        Clear();
                        Check();

                        if (Exists)
                        {
                            SetStoreLocation();

                            foreach (System.IO.FileInfo file in new System.IO.DirectoryInfo(Fullname).GetFiles())
                            {
                                Certificate.Add(new Entry((uint)Certificate.Count, file, this));
                            }
                        }
                    }
                }
            }

            public class Domain : Core.Platform.Security.Identifier
            {
                public string Principal { get; set; }
                public string Dc        { get; set; }
                public string BaseDn    { get; set; }
                public Domain() : base() { } 
                public Domain(string name, string sid, string principal, string dc, string baseDn) : base(name, sid)
                {
                    Principal = principal;
                    Dc        = dc;
                    BaseDn    = baseDn;
                }
                public void Assign(string name, string sid, string principal, string dc, string baseDn)
                {
                    Name = name;
                    SetSid(sid);

                    Principal = principal;
                    Dc        = dc;
                    BaseDn    = baseDn;
                }
                public void Clear()
                {
                    Name             = null;
                    Sid              = null;
                    Rid              = null;
                    AccountDomainSid = null;
                    BinaryLength     = null;

                    Principal        = null;
                    Dc               = null;
                    BaseDn           = null;
                }
                public override string ToString()
                {
                    return Sid;
                }
            }

            public class Manager : Core.Interop.Security
            {
                [DllImport("libc")]
                public static extern uint geteuid();
                [DllImport("libc")]
                private static extern uint getegid();

                private Func<string, object>             Bridge { get; set; }
                public Domain                            Domain { get; set; }
                public List<Role>                          Role { get; set; }
                public List<Identity>                  Identity { get; set; }
                public List<Claim>                        Claim { get; set; }

                private Dictionary<string, List<string>> ClaimMap = new();
                public Manager(Func<Core.Console.Controller> console, Func<string, object> bridge) : base(console)
                {
                    Bridge     = bridge;

                    Role       = new List<Role>();
                    Identity   = new List<Identity>();
                    Claim      = new List<Claim>();
                }
                public Process.Manager             Process() =>       (Process.Manager)Bridge("Process");
                public Configuration.Manager Configuration() => (Configuration.Manager)Bridge("Configuration");
                public FileSystem.Manager       FileSystem() =>    (FileSystem.Manager)Bridge("Configuration");
                public override void LoadDependencies()
                {
                    var process = (Process.Manager)Bridge("Process");

                    // string source, string displayname, string name, string fullname
                    process.Add("Security", "openssl"    , "openssl"    , process.Run("command", "-v openssl"    ));
                    process.Add("Security", "sssctl"     , "sssctl"     , process.Run("command", "-v sssctl"     ));
                    process.Add("Security", "kinit"      , "kinit"      , process.Run("command", "-v kinit"      ));
                    process.Add("Security", "klist"      , "klist"      , process.Run("command", "-v klist"      ));
                    process.Add("Security", "ldapsearch" , "ldapsearch" , process.Run("command", "-v ldapsearch" ));
                }
                public void Prime()
                {
                    // ResolveAccountList();
                    // ResolveDomain();
                    // ResolveStoreList();
                    // ResolveReferenceList();
                    // ResolveRoleList();
                    // ResolveIdentityList();
                    // ResolveClaimList();
                    // ResolveContext();
                }
                public override void Initialize()
                {
                    Initialize(null);
                }
                public override void Initialize(Core.Platform.Security.Credential credential)
                {
                    RefreshAccounts("Local");

                    var     process = Process();
                    uint     userid = GetUserId();

                    Update(0, "Requesting [~] (Security) Administrative access");

                    if (credential == null)
                        ValidateCredential();

                    else if (credential != null)
                    {
                        var account = GetAccount(credential.Username);

                        if (account == null)
                        {
                            Update(-1, $"Exception [!] Invalid account: {credential.Username}");
                            return;
                        }

                        if (account != null && account?.Uid != null)
                        {
                            userid  = (uint)account.Uid;
                            ValidateCredential(credential);
                        }
                    }

                    if (!process.Sudo.Valid)
                        process.Sudo.ApplyCode(userid == 0 ? 0 : 1);

                    if (!process.Sudo.Valid)
                        Update(-1, "Denied [!] (Security) Administrative access");
                    else
                        Update(1, "Granted [+] (Security) Administrative access");
                }
                public override void ValidateCredential()
                {
                    ValidateCredential(Environment.UserName);
                }
                public override void ValidateCredential(string username)
                {
                    var     process = Process();

                    bool       pass = false;
                    int       limit = 0;

                    while (limit < 3 && !pass)
                    {
                        Update(0, $"Attempt {limit + 1 }/3");

                        SetCredential(username);

                        process.VerifySudoCredential();

                        pass = process.Sudo.Accepted && process.Sudo.Valid;

                        if (!pass)
                            Update(-1, "Exception [!] Invalid password");

                        limit ++;
                    }

                    if (!pass)
                        Update(-1, "Denied [!] Invalid password");
                    else
                        Update(1, $"Accepted [+] Username: {username}");
                }
                public override void ValidateCredential(string username, string password)
                {
                    var secure = new SecureString();
                    foreach (char c in password)
                        secure.AppendChar(c);

                    secure.MakeReadOnly();

                    ValidateCredential(new Core.Platform.Security.Credential(username, secure));
                }
                public override void ValidateCredential(string username, SecureString securestring)
                {
                    ValidateCredential(new Core.Platform.Security.Credential(username, securestring));
                }
                public override void ValidateCredential(Core.Platform.Security.Credential credential)
                {
                    var process  = Process();

                    Credential   = credential;

                    process.VerifySudoCredential();

                    bool pass = process.Sudo.Accepted && process.Sudo.Valid;

                    if (!pass)
                        Update(-1, "Denied [!] Invalid password");
                    else
                        Update(1, $"Accepted [+] Username: {credential.Username}");
                }
                public string SidBase64(string sidbase64)
                {
                    byte[]       b = System.Convert.FromBase64String(sidbase64);

                    if (b.Length < 8 || b.Length < 8 + (b[1] * 4))
                    {
                        Update(-1, "Exception [!] Invalid SID data");
                        return null;
                    }

                    // IdentifierAuthority is 6 bytes, big-endian
                    long     iauth = (long)b[2] << 40 | (long)b[3] << 32 |(long)b[4] << 24 | (long)b[5] << 16 |(long)b[6] << 8 | (long)b[7];
                    var  sauthlist = new List<uint>();

                    int    off = 8;
                    for (int i = 0; i < (uint)b[1]; i++)
                    {
                        // Each subauthority is 4 bytes, little-endian
                        uint sauth = (uint)b[off] | (uint)b[off + 1] << 8 | (uint)b[off + 2] << 16 | (uint)b[off + 3] << 24;
                    
                        sauthlist.Add(sauth);
                        off += 4;
                    }

                    // Build SID string
                    string sid = $"S-{(uint)b[0]}-{iauth}";
                    foreach (uint sa in sauthlist)
                        sid += $"-{sa}";

                    return sid;
                }
                public override void ResolveDomain()
                {
                    Domain = null;
                    try
                    {
                        var process = Process();

                        string output;
                        Match   match;

                        // ensure dependencies exist
                        var sssctl     = process.GetDependency("Security", "sssctl");
                        var kinit      = process.GetDependency("Security","kinit");
                        var klist      = process.GetDependency("Security","klist");
                        var ldapsearch = process.GetDependency("Security","ldapsearch");

                        if (!sssctl.Exists)
                        {
                            Update(-1, "Exception [!] sssctl not installed");
                            return;
                        }
                     
                        if (!kinit.Exists)
                        {
                            Update(-1, "Exception [!] kinit not installed");
                            return;
                        }

                        if (!klist.Exists)
                        {
                            Update(-1, "Exception [!] klist not installed");
                            return;
                        }

                        if (!ldapsearch.Exists)
                        {
                            Update(-1, "Exception [!] ldapsearch not installed");
                            return;
                        }

                        // get (domain/list)
                        sssctl.Argument = "domain-list";
                        sssctl.Admin    = true;

                        output          = process.Start(sssctl);
                        if (string.IsNullOrWhiteSpace(output))
                        {
                            Update(-1, "Exception [!] Domain list empty");
                            return;
                        }

                        string domain     = output.Split('\n').Select(l => l.Trim()).FirstOrDefault(l => l.Length > 0);
                        string principal  = $"{Environment.GetEnvironmentVariable("HOSTNAME")}$@{domain.ToUpper()}";

                        sssctl.Argument   = $"domain-status {domain}";
                        output            = process.Start(sssctl);
                        
                        string dc         = output.Split('\n').Select(l => l.Trim())
                            .Where(l      => l.StartsWith("AD Domain Controller:", StringComparison.OrdinalIgnoreCase))
                            .Select(l     => l.Substring("AD Domain Controller:".Length).Trim()).FirstOrDefault();

                        // if (string.IsNullOrWhiteSpace(dc))
                        // {
                        //     Update(-1, "Exception [!] Domain controller null");
                        //     return;
                        // }

                        // KInit/KList
                        if (!System.IO.File.Exists("/etc/krb5.keytab"))
                        {
                            Update(-1, "Exception [!] Keytab (/etc/krb5.keytab) not found");
                            return;
                        }

                        try
                        {
                            kinit.Argument = $"-k {principal}";
                            kinit.Admin    = true;
                            process.Start(kinit);
                        }
                        catch
                        {
                            Update(-1, $"Exception [!] Unable to log in using {principal}");
                            return;
                        }

                        klist.Admin        = true;
                        output             = process.Start(klist);

                        if (string.IsNullOrWhiteSpace(output))
                        {
                            Update(-1, "Failed [!] klist returned null");
                            return;
                        }

                        match  = Regex.Match(output, @"(?<=Default principal:\s*)(.*)");

                        if (!match.Success || match.Value.Trim() != principal)
                        {
                            Update(-1, $"Exception [!] Machine Principal '{principal}' not found");
                            return;
                        }

                        // query ldap
                        string basedn  = string.Join(",", domain.Split('.', StringSplitOptions.RemoveEmptyEntries).Select(p => $"DC={p}"));

                        ldapsearch.Argument  = $"-LLL -H ldap://{dc} -Y GSSAPI -N -b {basedn} -s base (objectClass=domain) objectSid";
                        ldapsearch.Admin     = true;
                        output               = process.Start(ldapsearch);

                        if (string.IsNullOrWhiteSpace(output))
                        {
                            Update(-1, $"Failed [!] ldapsearch for '{ldapsearch.Argument}'");
                            return;
                        }

                        match = Regex.Match(output, @"^objectSid::\s*(.*)$", RegexOptions.Multiline);

                        if (!match.Success)
                        {
                            Update(-1, $"Exception [!] Domain SID not found");
                            return;
                        }

                        string    sid = SidBase64(match.Groups[1].Value.Trim());

                        Domain        = new Domain(domain, sid, principal, dc, basedn);

                        if (Domain != null)
                            Update(1, $"Domain [+] Name: {Domain.Name}, SID: {Domain.Sid}");
                        else
                            Update(-1, "Domain [!] Not found");
                    }
                    catch
                    {
                        Update(-1, "Domain [!] Not found");
                        return;
                    }
                }
                public void AddStore(string displayname, string fullname)
                {
                    if (string.IsNullOrWhiteSpace(displayname))
                    {
                        Update(-1, "Exception [!] Store name cannot be null or empty");
                        return;
                    }
                    else if (Store.Any(e => e.DisplayName == displayname))
                    {
                        Update(-1, $"Exception [!] Store '{displayname}' already exists.");
                        return;
                    }
                    else
                    {
                        var store = new Certificate.Store((uint)Store.Count, displayname, fullname);

                        if (store != null)
                            Store.Add(store);
                    }
                }
                public override void ResolveStoreList()
                {
                    Store.Clear();

                    AddStore("System CA", "/etc/ssl/certs");
                    AddStore("Local CA", "/usr/local/share/ca-certificates");
                    AddStore("User NSSDB", $"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}/.pki/nssdb");
                }
                public override void ResolveReferenceList()
                {
                    GetReference();

                    if (Domain == null || string.IsNullOrEmpty(Domain.AccountDomainSid))
                    {
                        Update(-1, "Missing [!] Domain.AccountDomainSid");
                        return;
                    }

                    foreach (var r in Reference)
                    {
                        r.Identifier = new Identifier(r.Name, r.Value.Replace(@"S-1-5-21-domain", Domain.AccountDomainSid));
                    }
                }
                private string Extract(string block, string pattern)
                {
                    Match mx = Regex.Match(block, pattern, RegexOptions.Multiline);

                    return (mx.Success) ? mx.Groups[1].Value : null;
                }
                public string ExtractDomainFromDn(string dn)
                {
                    return string.Join(".", dn.Split(',').Where(p => p.StartsWith("DC=")).Select(p => p.Substring(3)));
                }
                public override void RefreshAccounts(string type)
                {
                    var process   = (Process.Manager)Bridge("Process");
                    var ldapsearch = process.GetDependency("Security", "ldapsearch");

                    Account.Clear();

                    if (type == "All" || type == "Local")
                    {
                        // Local accounts
                        Update(0, "Resolving [~] Local Unix Accounts");

                        foreach (string line in System.IO.File.ReadAllLines("/etc/passwd"))
                        {
                            var item = new Account((uint)Account.Count, line);
                            
                            if (item.Uid == 0)
                                item.SetAccountType(Core.Platform.Security.AccountType.LocalSystem);
                            else if (item.Uid < 1000)
                                item.SetAccountType(Core.Platform.Security.AccountType.LocalService);
                            else
                                item.SetAccountType(Core.Platform.Security.AccountType.User);

                            Account.Add(item);
                        }
                    }

                    if (type == "All" || type == "Domain")
                    {
                        // Domain accounts
                        if (Domain != null && ldapsearch != null)
                        {
                            Update(0, "Resolving [~] Domain Accounts");

                            ldapsearch.Argument = $"-LLL -H ldap://{Domain.Dc} -Y GSSAPI -N -b {Domain.BaseDn} (objectClass=user) sAMAccountName cn dn userPrincipalName objectSid";
                            ldapsearch.Admin    = true;

                            string output = process.Start(ldapsearch);
                            if (string.IsNullOrWhiteSpace(output))
                            {
                                Update(0, "Warning [!] LDAP user enumeration returned empty");
                                return;
                            }

                            List<string>   blocks = new List<string>();
                            StringBuilder current = new StringBuilder();

                            foreach (string raw in output.Split('\n'))
                            {
                                string line = raw.TrimEnd();

                                if (Regex.IsMatch(line, @"^\s*$"))
                                {
                                    if (current.Length > 0)
                                    {
                                        blocks.Add(current.ToString());
                                        current.Clear();
                                    }
                                }

                                if (Regex.IsMatch(line, @"^\s+.*"))
                                {
                                    current.Append(line.Trim());
                                }
                                else
                                {
                                    current.AppendLine(line.Trim());
                                }
                            }

                            if (current.Length > 0)
                                blocks.Add(current.ToString());

                            foreach (string block in blocks)
                            {
                                string       dn = Extract(block, @"^dn:\s*(.+)$");
                                if (dn == null)
                                    continue;

                                string     name = Extract(block, @"^cn:\s*(.+)$");
                                string      sam = Extract(block, @"^sAMAccountName:\s*(.+)$");
                                string      upn = Extract(block, @"^userPrincipalName:\s*(.+)$");
                                string    sid64 = Extract(block, @"^objectSid::\s*(.+)$");

                                string   domain = ExtractDomainFromDn(dn);

                                Identifier  sid = new Identifier(name, SidBase64(sid64));

                                Account    item = new Account((uint)Account.Count, sam, name, dn, domain, upn, sid);
                                item.SetAccountType(Core.Platform.Security.AccountType.User);

                                Account.Add(item);
                            }
                        }
                    }
                }
                public bool IsInAdminGroup(Core.Platform.Security.Account account)
                {
                    var groups = ResolveAccountGroups(account);
                    return groups.Any(g => g.Name == "sudo" || g.Name == "wheel");
                }
                public List<Identifier> ResolveAccountGroups(Core.Platform.Security.Account account)
                {
                    var process = (Process.Manager)Bridge("Process");
                    var result  = new List<Identifier>();

                    foreach (var groupName in process.Run("id", $"-nG {account.Username}", true).Split(' ', StringSplitOptions.RemoveEmptyEntries))
                    {
                        string[] groupInfo = process.Run("getent", $"group {groupName}", true).Split(':', StringSplitOptions.RemoveEmptyEntries);

                        if (groupInfo.Length >= 3 && int.TryParse(groupInfo[2], out int gid))
                        {
                            result.Add(new Identifier(groupName, (int?)null, gid, (string)null));
                        }
                    }

                    return result;
                }
                public List<Claim> ResolveUserClaims(Core.Platform.Security.Account account, List<Identifier> groups)
                {
                    var claims = new List<Claim>();

                    claims.Add(new Claim("uid", account.Uid.ToString()));
                    claims.Add(new Claim("gid", account.Gid.ToString()));

                    foreach (var g in groups)
                        claims.Add(new Claim("group", g.Name));

                    return claims;
                }
                public override void ResolveIdentityList()
                {
                    Identity.Clear();

                    foreach (var account in Account)
                    {
                        var roles    = GetRolesForUser(account.Username);
                        bool isAdmin = roles.Any(r => r.Name == "sudo" || r.Name == "wheel");

                        Identity.Add(new Linux.Security.Identity(account, roles, isAdmin));
                    }
                }
                public override void ResolveRoleList()
                {
                    Role.Clear();

                    foreach (string line in System.IO.File.ReadAllLines("/etc/group"))
                    {
                        Role.Add(new Role(line));
                    }
                }
                public Store CreateStore(string displayname, string fullname)
                {
                    if (!Store.Any(e => e.DisplayName == displayname))
                        return new Certificate.Store((uint)Store.Count, displayname, fullname);
                    else
                        return null;
                }
                public Principal CreatePrincipal(Core.Platform.Security.Account account, Identity identity, List<string> claims)
                {
                    int uid        = account.Uid.HasValue ? (int)account.Uid.Value : 0;
                    int gid        = account.Gid.HasValue ? (int)account.Gid.Value : 0;

                    return new Principal
                    {
                        Account    = account,
                        Identifier = account.Sid,
                        Role       = identity.Role,
                        Claim      = claims.Select(c => new Core.Platform.Security.Claim { Type  = "role", Value = c }).ToList()
                    };
                }
                public override void ResolveClaimList()
                {
                    ClaimMap.Clear();

                    foreach (var id in Identity)
                    {
                        var list = new List<string>();

                        foreach (var role in Role)
                            if (role.Members.Contains(id.Name))
                                list.Add(role.Name);

                        ClaimMap[id.Id] = list;
                    }
                }
                public override void ResolveContext()
                {
                    // Debug("Checking [~] Current User Id");
                    int uid             = (int)GetUserId();

                    // Debug("Checking [~] Account");
                    var account         = Account.FirstOrDefault(a => a.Uid == uid);
                    if (account == null)
                        return;

                    // Debug("Checking [~] Identity");
                    var identity        = Identity.FirstOrDefault(i => i.Id == uid.ToString());
                    if (identity == null)
                        return;

                    // Debug("Checking [~] Claims");
                    if (!ClaimMap.TryGetValue(identity.Id, out var claimNames))
                        claimNames      = new List<string>();

                    // Debug("Checking [~] Roles");
                    var roles           = Role.Where(r => r.Members.Contains(identity.Name)).ToList();

                    // Debug("Checking [~] Principal");

                    var principal       = CreatePrincipal(account, identity, claimNames);

                    // Debug("Creating [~] Security context");

                    Context             = new Context
                    {
                        Identity        = identity,
                        Principal       = principal,
                        Credential      = (Credential != null) ? Credential : null,
                        Certificate     = new List<Core.Platform.Security.Certificate.Entry>(),

                        IsAdministrator = uid == 0,
                        IsAuthenticated = true,
                        Platform        = "Linux",

                        Domain          = Domain.Name,
                        Username        = identity.Name,
                        UserId          = account.Uid?.ToString() ?? "0",
                        GroupId         = account.Gid?.ToString() ?? "0",
                    };
                }
                public override void Refresh()
                {
                    Initialize();
                    ResolveDomain();
                    ResolveReferenceList();
                    RefreshAccounts("All");
                    ResolveStoreList();
                    ResolveRoleList();
                    ResolveIdentityList();
                    ResolveClaimList();
                    ResolveContext();
                }
                public uint GetUserId()
                {
                    return geteuid();
                }
                public uint GetGroupId()
                {
                    return getegid();
                }
                public Core.Platform.Security.Account GetAccountByUid(int uid)
                {
                    return Account.FirstOrDefault(a => a.Uid == uid) as Linux.Security.Account;
                }
                public List<Role> GetRolesForUser(string username)
                {
                    return Role.Where(r => r.Members.Contains(username)).ToList();
                }
                public bool IsAdmin(string username)
                {
                    var process   = (Process.Manager)Bridge("Process");
                    string output = process.Run("sudo", $"-n -l -U {username}", true);

                    if (string.IsNullOrWhiteSpace(output))
                        return false;

                    return Regex.IsMatch(output, @"\(ALL.*\)\s+(NOPASSWD:\s*)?ALL", RegexOptions.Multiline);
                }
                public void Populate(Core.Platform.Security.Certificate.Entry entry)
                {
                    var process   = (Process.Manager)Bridge("Process");
                    var openssl   = process.GetDependency("Security", "openssl");

                    openssl.Argument = $"x509 -in \"{entry.Fullname}\" -text -noout";
                    openssl.Admin    = true;

                    string raw    = process.Start(openssl);

                    if (string.IsNullOrWhiteSpace(raw))
                        return;

                    entry.Type        = EntryType.Certificate;
                    try
                    {
                        entry.Certificate = new X509Certificate2(entry.Fullname);
                    }
                    catch
                    {
                        entry.Certificate = null;
                    }

                    entry.Thumbprint  = ParseThumbprint(raw);
                    entry.Subject     = ParseField(raw, "Subject:");
                    entry.Issuer      = ParseField(raw, "Issuer:");
                    entry.NotBefore   = new Format.ModDateTime(ParseField(raw, "Not Before:"));
                    entry.NotAfter    = new Format.ModDateTime(ParseField(raw, "Not After :"));
                    entry.HasPrivateKey = System.IO.File.Exists(entry.Fullname.Replace(".crt", ".key"));
                }
                public string ParseThumbprint(string raw)
                {
                    return ParseField(raw, "SHA256 Fingerprint");
                }
                public string ParseField(string raw, string field)
                {
                    var line = raw.Split('\n').FirstOrDefault(l => Regex.IsMatch(l, field));

                    if (line == null) return null;

                    if (field == "SHA256 Fingerprint")
                    {
                        return line.Replace("SHA256 Fingerprint=","").Replace(":","").Trim();
                    }

                    return line.Replace(field, "").Replace(":","").Trim();
                }
                public override string ToString()
                {
                    return $"<{base.ToString()}>";
                } 
            }
        }

        namespace Configuration
        {
            public class Property : Core.Platform.Configuration.Property
            {
                public Property() : base() { }
                public Property(uint index, string name, string value) : base(index, name, value)
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
                private Func<string, object> Bridge { get; set; }
                public Manager(Func<Core.Console.Controller> console, Func<string, object> bridge) : base(console)
                {
                    Bridge = bridge;

                    Type   = Core.Platform.Configuration.Type.FileSystem;
                }
                public Process.Manager       Process() =>    (Process.Manager)Bridge("Process");
                public Security.Manager     Security() =>   (Security.Manager)Bridge("Security");
                public FileSystem.Manager FileSystem() => (FileSystem.Manager)Bridge("FileSystem");
                public override void LoadDependencies()
                {
                    // var process = (Process.Manager)Bridge("Process");

                    // string source, string displayname, string name, string fullname
                    // process.Add("Configuration", "stat",  "stat",  process.Run("command", "-v stat"));
                    // process.Add("Configuration", "chown", "chown", process.Run("command", "-v chown"));
                }
                public override void Initialize()
                {
                    Root   = ConfigurationPath();

                    if (!System.IO.Directory.Exists(Root))
                        return;

                    Branch = $"{Root}/{GetLatestVersion()}";
                    if (!System.IO.Directory.Exists(Branch))
                        return;

                    Fullname  = $"{Branch}/config.bin";

                    Refresh();
                }
                private void Construct(string path, bool file)
                {
                    string output;

                    var process  = Process();
                    var security = Security();
                    var cred     = security.Credential;

                    if (cred == null || string.IsNullOrEmpty(cred.Username) || cred.Password == null)
                    {
                        Update(-1, $"Exception [!] Invalid (credential/password)");
                        return;
                    }

                    string owner = $"{cred.Username}:{cred.Username}";

                    var     stat = process.GetDependency("FileSystem",  "stat");
                    var    chown = process.GetDependency("FileSystem", "chown");

                    if (file)
                    {
                        if (!System.IO.File.Exists(path))
                        {
                            using (var fs = System.IO.File.Create(path)) { }
                        }
                    }
                    else
                    {
                        if (!System.IO.Directory.Exists(path))
                            System.IO.Directory.CreateDirectory(path);
                    }

                    stat.Argument = $"-c %U {path}";
                    output        = process.Start(stat);

                    if (stat.ExitCode != 0 || output.Trim() != cred.Username)
                    {
                        chown.Argument = $"{owner} {path}";
                        chown.Admin    = true;

                        output         = process.Start(chown);

                        if (chown.ExitCode != 0)
                        {
                            Update(-1, $"Exception [!] Ownership failed: '{path}'");
                            return;
                        }
                    }
                }
                public override void Install(Core.Module.Template template)
                {
                    Construct(Root, false);
                    Construct(Branch, false);

                    Create();

                    Clear();

                    var pso = System.Management.Automation.PSObject.AsPSObject(template);

                    foreach (var prop in pso.Properties)
                        Add(prop.Name, prop.Value.ToString() ?? "");

                    Write();

                    Refresh();
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
                public override string ConfigurationPath()
                {
                    string company = CompanyName().ToLower().Replace(" ", "-");
                    string project = ProjectName().ToLower().Replace(" ", "");

                    return $"/var/lib/{company}/{project}";
                }
                public override void Refresh()
                {
                    Check();

                    if (Exists)
                        Read();
                }
                public override void Check()
                {
                    System.IO.FileInfo fi = new System.IO.FileInfo(Fullname);

                    Exists = fi.Exists;

                    if (Exists)
                        Size   = new Format.ByteSize("File", (uint)fi.Length);
                }
                public override void Read()
                {
                    Clear();
                    Check();

                    if (!Exists)
                    {
                        Update(-1, "Exception [!] Config file does not exist");
                        return;
                    }

                    System.IO.FileStream   fs = System.IO.File.OpenRead(Fullname);
                    System.IO.BinaryReader br = new System.IO.BinaryReader(fs);

                    uint count = br.ReadUInt32();
                    uint i     = 0;

                    while (i < count)
                    {
                        uint index        = br.ReadUInt32();

                        uint      nameLen = br.ReadUInt32();
                        byte[]  nameBytes = br.ReadBytes((int)nameLen);
                        string       name = System.Text.Encoding.UTF8.GetString(nameBytes);

                        uint     valueLen = br.ReadUInt32();
                        byte[] valueBytes = br.ReadBytes((int)valueLen);
                        string      value = System.Text.Encoding.UTF8.GetString(valueBytes);

                        Property.Add(new Core.Platform.Configuration.Property(index, name, value));

                        i++;
                    }

                    br.Close();
                    fs.Close();
                }
                public override void Write()
                {
                    Check();
                    if (!Exists)
                        Create();

                    System.IO.FileStream   fs = System.IO.File.Open(Fullname, System.IO.FileMode.Create, System.IO.FileAccess.Write);
                    System.IO.BinaryWriter bw = new System.IO.BinaryWriter(fs);

                    bw.Write((uint)Property.Count);

                    for (int i = 0; i < Property.Count; i++)
                    {
                        Core.Platform.Configuration.Property prop = Property[i];

                        bw.Write(prop.Index);

                        string name       = (prop.Name != null) ? prop.Name : "";
                        byte[] nameBytes  = System.Text.Encoding.UTF8.GetBytes(name);

                        bw.Write((uint)nameBytes.Length);
                        bw.Write(nameBytes);

                        string value      = (System.Convert.ToString(prop.Value) != null) ? System.Convert.ToString(prop.Value) : "";
                        byte[] valueBytes = System.Text.Encoding.UTF8.GetBytes(value);

                        bw.Write((uint)valueBytes.Length);
                        bw.Write(valueBytes);
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
                        Update(-1, "Exception [!] Config file already exists");
                        return;
                    }

                    Construct(Fullname, true);

                    Check();
                }
                public override void Remove()
                {
                    Check();

                    if (!Exists)
                    {
                        Update(-1, "Exception [!] Config file does not exist");
                        return;
                    }

                    System.IO.File.Delete(Fullname);

                    Check();
                }
                public override string ToString()
                {
                    return $"<{base.ToString()}>";
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
            public class Directory : Core.Platform.FileSystem.Directory
            {
                public Directory(string fullname) : this(fullname, 2, false, null) { }
                public Directory(string fullname, uint mode) : this(fullname, mode, false, null) { }
                public Directory(string fullname, uint mode, bool recurse) : this(fullname, mode, recurse, null) { }
                public Directory(string fullname, uint mode, bool recurse, string filter) : base()
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
            
                    var raw = Manager.Scan(Fullname, Option.Recurse);
            
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
                public Format.ByteSize GetRecursiveBytes()
                {
                    try
                    {
                        var psi = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName               = "du",
                            Arguments              = $"-sb {Fullname}",
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
                protected FileSystem.Entry CreateEntry(uint index, Core.Platform.FileSystem.Raw raw)
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
                        Size       = new Format.ByteSize(raw.IsDirectory ? "Directory" : "File", raw.Size),
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
                public override string ToString()
                {
                    return Fullname;
                }
            }

            public class Manager : Core.Interop.FileSystem
            {
                private Func<string, object> Bridge { get; set; }
                [StructLayout(LayoutKind.Sequential)]
                private struct dirent
                {
                    public ulong     d_ino;
                    public long      d_off;
                    public ushort d_reclen;
                    public byte     d_type;

                    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
                    public byte[]   d_name;
                }
                [StructLayout(LayoutKind.Sequential)]
                public struct timespec
                {
                    public long tv_sec;
                    public long tv_nsec;
                }
                [StructLayout(LayoutKind.Sequential)]
                public struct FileStat
                {
                    public ulong st_dev;
                    public ulong st_ino;
                    public ulong st_nlink;
                    public uint st_mode;
                    public uint st_uid;
                    public uint st_gid;
                    public int __pad0;
                    public ulong st_rdev;
                    public long st_size;
                    public long st_blksize;
                    public long st_blocks;
                    public timespec st_atim;
                    public timespec st_mtim;
                    public timespec st_ctim;
                    public long __reserved0;
                    public long __reserved1;
                    public long __reserved2;
                }
                [DllImport("libc", SetLastError = true)]
                private static extern IntPtr opendir(string name);
                [DllImport("libc", SetLastError = true)]
                private static extern IntPtr readdir(IntPtr dir);
                [DllImport("libc", SetLastError = true)]
                private static extern int closedir(IntPtr dir);
                [DllImport("libc", SetLastError = true)]
                private static extern int stat(byte[] path, out FileStat buf);
                private const byte DT_DIR = 4;
                private const byte DT_LNK = 10;
                public Manager(Func<Core.Console.Controller> console, Func<string, object> bridge) : base(console)
                {
                    Bridge = bridge;
                }
                public Process.Manager             Process() =>       (Process.Manager)Bridge("Process");
                public Security.Manager           Security() =>      (Security.Manager)Bridge("Security");
                public Configuration.Manager Configuration() => (Configuration.Manager)Bridge("Configuration");
                public override void LoadDependencies()
                {
                    var process = Process();

                    // string source, string displayname, string name, string fullname
                    process.Add("FileSystem", "du",  "du",  process.Run("command", "-v du"));
                    process.Add("FileSystem", "chown", "chown", process.Run("command", "-v chown"));
                }
                public override void Initialize()
                {
                    // null for now
                }
                public void SetLocation(string fullname)
                {
                    Location = fullname;
                }
                public static List<Core.Platform.FileSystem.Raw> Scan(string fullname, bool recurse)
                {
                    List<Core.Platform.FileSystem.Raw> results = new();
                    Stack<string>                        stack = new();

                    stack.Push(fullname);

                    while (stack.Count > 0)
                    {
                        string    current = stack.Pop();
                        System.IntPtr dir = opendir(current);

                        if (dir == IntPtr.Zero)
                            continue;

                        try
                        {
                            IntPtr entry;
                            while ((entry = readdir(dir)) != IntPtr.Zero)
                            {
                                var             d = Marshal.PtrToStructure<dirent>(entry);
                                int           len = Array.IndexOf(d.d_name, (byte)0);

                                if (len < 0)
                                    len = d.d_name.Length;

                                string       name = System.Text.Encoding.UTF8.GetString(d.d_name, 0, len);

                                if (name == "." || name == "..")
                                    continue;

                                string pathstring = System.IO.Path.Combine(current, name);
                                
                                bool        isDir = d.d_type == DT_DIR;
                                bool    isReparse = d.d_type == DT_LNK;
                                DateTime  created = DateTime.MinValue;
                                DateTime modified = DateTime.MinValue;
                                ulong        size = 0;
                                byte[]       path = System.Text.Encoding.UTF8.GetBytes(pathstring + "\0");

                                if (stat(path, out var s) == 0)
                                {
                                    size     = (ulong)Math.Max(0, s.st_size);
                                    modified = DateTimeOffset.FromUnixTimeSeconds(s.st_mtim.tv_sec).UtcDateTime;
                                    created  = DateTimeOffset.FromUnixTimeSeconds(s.st_ctim.tv_sec).UtcDateTime;
                                }

                                string fullpath;
                                try
                                {
                                    fullpath = System.IO.Path.GetFullPath(pathstring);
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine($"GetFullPath FAILED current=[{current}] name=[{name}] " + $"pathstring=[{pathstring}]");
                                    throw;
                                }

                                results.Add(new Linux.FileSystem.Raw
                                {
                                    Name        = name,
                                    Fullname    = fullpath,
                                    Extension   = isDir ? "" : System.IO.Path.GetExtension(name),
                                    IsDirectory = isDir,
                                    IsReparse   = isReparse,
                                    Size        = size,
                                    Created     = created,
                                    Modified    = modified
                                });

                                // Recurse
                                if (isDir && recurse && !isReparse)
                                    stack.Push(pathstring);
                            }
                        }
                        finally
                        {
                            closedir(dir);
                        }
                    }

                    return results;
                }
                public override Core.Platform.FileSystem.Directory GetDirectory(string fullname) => GetDirectory(fullname, 2, false);
                public override Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode) => GetDirectory(fullname, mode, false);
                public override Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode, bool recurse)
                {
                    return new FileSystem.Directory(fullname, mode, recurse);
                }
                public override string ToString()
                {
                    return $"<{base.ToString()}>";
                }
            }
        }
    }
}
