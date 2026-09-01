// FightingEntropy.Linux
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using FightingEntropy.Core;
using FightingEntropy.Core.Interop;
using FightingEntropy.Core.Platform.Security;
using FightingEntropy.Core.Platform.Security.Certificate;
using System.ComponentModel;
using System.Security;


namespace FightingEntropy
{
    namespace Linux
    {
        namespace Interop
        {
            public sealed class Controller : FightingEntropy.Core.Interop.Controller
            {
                public override ISecurity           Security { get; }
                public override IConfiguration Configuration { get; }
                public override IFileSystem       FileSystem => throw new NotImplementedException();
                public override IProcess             Process => throw new NotImplementedException();
                public override IService             Service => throw new NotImplementedException();
                public override ICommand             Command => throw new NotImplementedException();
                public override INetwork             Network => throw new NotImplementedException();
                public override IHardware           Hardware => throw new NotImplementedException();
                public Controller()
                {
                    Security      = new Security.Manager();
                    Configuration = new Configuration.Manager();
                }
            }
        }

        namespace Security
        {
            using Core.Platform.Security;

            public class Identifier : Core.Platform.Security.Identifier
            {
                public Identifier() { }
                public Identifier(string sid) : base(sid) { }
                public Identifier(int uid, int gid) : base(uid, gid) { }
                public Identifier(string name, int uid, int gid, string sid) : base(name, uid, gid, sid) { }
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
                [DllImport("libc")]
                private static extern uint geteuid();
                public Identity() { }
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
                    DisplayName       = null;
                    Fullname          = split[4];
                    UserPrincipalName = null;
                    SamAccountName    = null;
                    Domain            = null;
                    Uid               = int.Parse(split[2]);
                    Gid               = int.Parse(split[3]);
                    Sid               = null;
                    Home              = split[5];
                    Shell             = split[6];
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

            public sealed class Manager : Core.Interop.Security
            {
                // public Platform.Security.Identifier?            Domain { get; }
                // public List<Platform.Security.Certificate.Store> Store { get; }
                // public Platform.Security.Context?              Context { get; }
                // public Platform.Security.Credential?        Credential { get; }
                // public List<Platform.Security.Reference>     Reference { get; }
                [DllImport("libc")]
                private static extern uint geteuid();

                public List<Account>                              Account { get; set; }
                public List<Role>                                    Role { get; set; }
                public List<Identity>                            Identity { get; set; }
                public List<Claim>                                  Claim { get; set; }
                private Dictionary<string, List<string>>         ClaimMap = new();

                // public abstract void Refresh();
                // public void SetCredential(Credential credential);
                // public void SetCredential(string username);

                // protected abstract void ResolveDomain();         [ ]
                // protected abstract void ResolveStoreList();      [ ]
                // protected abstract void ResolveReferenceList();  [ ]
				// protected abstract void ResolveAccountList();    [ ]
                // protected abstract void ResolveIdentityList();   [ ]
                // protected abstract void ResolveRoleList();       [ ]
                // protected abstract void ResolveClaimList();      [ ]
                // protected abstract void ResolveContext();        [ ]
				
				// public static ProtocolMode GetProtocolMode(uint mode)
                // public static AuthenticationType GetAuthType(string value)
                // public static AccountType GetAccountType(Identifier sid)

                public Manager() : base()
                {
                    Account  = new List<Account>();
                    Role     = new List<Role>();
                    Identity = new List<Identity>();
                    Claim    = new List<Claim>();
                }
                protected override void ResolveDomain()
                {
                    Domain = null;
                    try
                    {
                        // 1. Get domain list
                        string list = RunProcess("sssctl", "domain-list");
                        if (string.IsNullOrWhiteSpace(list))
                            return;

                        string domain = list.Split('\n').Select(l => l.Trim()).FirstOrDefault(l => l.Length > 0 );

                        if (string.IsNullOrWhiteSpace(domain))
                            return;

                        // 2. Query domain info
                        string info = RunProcess("sssctl", $"domain-info {domain}");
                        if (string.IsNullOrWhiteSpace(info))
                            return;

                        // 3. Extract SID
                        var sidLine = info.Split('\n').FirstOrDefault(l => l.Contains("SID:"));

                        if (sidLine == null)
                            return;

                        string sid = sidLine.Split(':')[1].Trim();

                        Domain = new Identifier(sid);
                    }
                    catch
                    {
                        return;
                    }
                }
                protected override void ResolveStoreList()
                {
                    Store.Clear();

                    Store.Add(CreateStore("System CA", "/etc/ssl/certs"));
                    Store.Add(CreateStore("Local CA", "/usr/local/share/ca-certificates"));
                    Store.Add(CreateStore("User NSSDB", $"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}/.pki/nssdb"));
                }
                protected override void ResolveReferenceList()
                {
                    Reference.Clear();
                    GetReference();

                    if (string.IsNullOrEmpty(Domain.AccountDomainSid))
                        return;

                    var pattern = @"(?i)(?<placeholder>21\s*domain|root\s*domain|domain)";

                    foreach (var r in Reference)
                    {
                        if (string.IsNullOrWhiteSpace(r.Value))
                            continue;

                        r.Value = Regex.Replace(r.Value, pattern, Domain.AccountDomainSid);
                    }
                }
                protected override void ResolveAccountList()
                {
                    Account.Clear();

                    foreach (string line in System.IO.File.ReadAllLines("/etc/passwd"))
                    {
                        var item = new Account((uint)Account.Count, line);
                        
                        if (item.Uid == 0)
                            item.AccountType = Core.Platform.Security.AccountType.LocalSystem;
                        else if (item.Uid < 1000)
                            item.AccountType = Core.Platform.Security.AccountType.LocalService;
                        else
                            item.AccountType = Core.Platform.Security.AccountType.User;

                        Account.Add(item);
                    }
                }
                protected override void ResolveIdentityList()
                {
                    Identity.Clear();

                    bool isAdmin = geteuid() == 0;

                    foreach (var account in Account)
                    {
                        var roles = GetRolesForUser(account.Username);
                        Identity.Add(CreateIdentity(account, roles, isAdmin));
                    }
                }
                protected override void ResolveRoleList()
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
                private Identity CreateIdentity(Account account, List<Role> roles, bool isAdmin)
                {
                    return new Identity
                    {
                        Name            = account.Username,
                        Domain          = "",
                        Id              = account.Uid.ToString(),
                        IsAdministrator = isAdmin,
                        IsAuthenticated = account != null,
                        Role            = roles.Cast<Core.Platform.Security.Role>().ToList()
                    };
                }
                private Principal CreatePrincipal(Account account, Identity identity, List<string> claims)
                {
                    int uid        = account.Uid.HasValue ? (int)account.Uid.Value : 0;
                    int gid        = account.Gid.HasValue ? (int)account.Gid.Value : 0;

                    return new Principal
                    {
                        Account    = account,
                        Identifier = new Identifier(identity.Name, uid, gid, account.Sid),
                        Role       = identity.Role,
                        Claim      = claims.Select(c => new Core.Platform.Security.Claim { Type  = "role", Value = c }).ToList()
                    };
                }
                protected override void ResolveClaimList()
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
                protected override void ResolveContext()
                {
                    int uid             = (int)geteuid();
                    var account         = Account.FirstOrDefault(a => a.Uid == uid);
                    if (account == null)
                        return;
                        
                    var identity        = Identity.FirstOrDefault(i => i.Id == uid.ToString());
                    if (identity == null)
                        return;

                    if (!ClaimMap.TryGetValue(identity.Id, out var claimNames))
                        claimNames      = new List<string>();

                    var roles           = Role.Where(r => r.Members.Contains(identity.Name)).ToList();
                    var principal       = CreatePrincipal(account, identity, claimNames);

                    Context             = new Context
                    {
                        Identity        = identity,
                        Principal       = principal,
                        Credential      = null,
                        Certificate     = new List<Core.Platform.Security.Certificate.Entry>(),

                        IsAdministrator = uid == 0,
                        IsAuthenticated = true,
                        Platform        = "Linux",

                        Domain          = null,
                        Username        = identity.Name,
                        UserId          = account.Uid?.ToString() ?? "0",
                        GroupId         = account.Gid?.ToString() ?? "0",
                    };
                }
                public override void Refresh()
                {
                    ResolveDomain();
                    ResolveStoreList();
                    ResolveReferenceList();
                    ResolveAccountList();
                    ResolveRoleList();
                    ResolveIdentityList();
                    ResolveClaimList();
                    ResolveContext();
                }
                public Account GetAccountByUid(int uid)
                {
                    return Account.FirstOrDefault(a => a.Uid == uid);
                }
                public List<Role> GetRolesForUser(string username)
                {
                    return Role.Where(r => r.Members.Contains(username)).ToList();
                }
                public string RunProcess(string name, string arguments)
                {
                    var psi                    = new ProcessStartInfo
                    {
                        FileName               = name,
                        Arguments              = arguments,
                        RedirectStandardError  = true,
                        RedirectStandardOutput = true,
                        UseShellExecute        = false
                    };

                    using var proc = Process.Start(psi);
                    string output  = proc.StandardOutput.ReadToEnd();

                    proc.WaitForExit();

                    return output;
                }
                public bool IsAdmin(string username)
                {
                    string output = RunProcess("sudo",$"-l -U {username}");

                    return Regex.IsMatch(output, @"\(ALL.*\)\s+(NOPASSWD:\s*)?ALL", RegexOptions.Multiline);
                }
                public string RunOpenSsl(string args)
                {
                    return RunProcess("openssl", args);
                }
                public void Populate(Entry entry)
                {
                    string raw = RunOpenSsl($"x509 -in \"{entry.Fullname}\" -text -noout");

                    if (string.IsNullOrWhiteSpace(raw))
                        return;

                    entry.Type        = EntryType.Certificate;
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
                public override void Initialize()
                {
                    string root = ConfigurationPath();

                    if (!System.IO.Directory.Exists(root))
                        System.IO.Directory.CreateDirectory(root);

                    string path = $"{root}/{DateTime.Now.ToString("yyyy.M.0")}";

                    if (!System.IO.Directory.Exists(path))
                        System.IO.Directory.CreateDirectory(path);

                    Clear();
                }
                public override void Initialize(string fullname)
                {
                    Fullname = fullname;

                    Name     = System.IO.Path.GetFileNameWithoutExtension(fullname);
                    Branch   = System.IO.Path.GetDirectoryName(fullname);
                    Root     = Branch;
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

                        uint      nameLen = br.ReadUInt32();
                        byte[]  nameBytes = br.ReadBytes((int)nameLen);
                        string       name = System.Text.Encoding.UTF8.GetString(nameBytes);

                        uint     valueLen = br.ReadUInt32();
                        byte[] valueBytes = br.ReadBytes((int)valueLen);
                        string      value = System.Text.Encoding.UTF8.GetString(valueBytes);

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

                    return $"/var/lib/{company}/{project}";
                }
                public override void Resolve()
                {
                    string root = ConfigurationPath();

                    if (!System.IO.Directory.Exists(root))
                        System.IO.Directory.CreateDirectory(root);

                    List<Version>      versions = new List<Version>();
                    System.IO.DirectoryInfo  di = new System.IO.DirectoryInfo(root);

                    foreach (System.IO.DirectoryInfo dir in di.GetDirectories().Where(x => Regex.IsMatch(x.Name, @"^\d{4}\.\d{1,}\.\d{1}$")))
                    {
                        versions.Add(Version.Parse(dir.Name));
                    }

                    Version latest = (versions.Count == 0) ? GenerateVersion() : versions.Max();

                    string xpath = $"{root}/{latest.ToString()}";

                    if (!System.IO.Directory.Exists(xpath))
                        System.IO.Directory.CreateDirectory(xpath);

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

        }


    }
}
