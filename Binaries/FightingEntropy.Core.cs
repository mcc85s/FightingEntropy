// FightingEntropy.Core
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.NetworkInformation;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Principal;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace FightingEntropy
{
    namespace Format
    {
        [Serializable]
        public readonly struct ModDateTime
        {
            public readonly DateTime Value { get; }
            public ModDateTime(DateTime dt)
            {
                Value = dt;
            }
            public ModDateTime(string date)
            {
                if (!DateTime.TryParse(date, out DateTime result))
                    throw new Exception("Exception [!] Invalid date format");

                Value = result;
            }
            public static implicit operator DateTime(ModDateTime fdt) => fdt.Value;
            public static implicit operator ModDateTime(DateTime dt)  => new ModDateTime(dt);
            public static ModDateTime   Now() => new ModDateTime(DateTime.Now);
            public string        DateString() => Value.ToString("MM/dd/yyyy HH:mm:ss");
            public string         DayString() => Value.ToString("MM/dd/yyyy");
            public string        TimeString() => Value.ToString("HH:mm:ss");
            public string        FileString() => Value.ToString("yyyy_MM_dd-HH_mm_ss");
            public string     ArchiveString() => Value.ToString("yyyy_MMdd-HHmmss");
            public override string ToString() => DateString();
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

        [Serializable]
        public readonly struct ByteSize
        {
            public readonly string Name { get; }
            public readonly ulong Bytes { get; }
            public readonly string Unit { get; }
            public readonly string Size { get; }
            public ByteSize(string name, ulong bytes)
            {
                Name  = name;
                Bytes = bytes;

                (Unit, ulong scale, string label) = bytes switch
                {
                    < Byte.KB_Max => ("Byte"     , Byte.B  , " B"),
                    < Byte.MB_Max => ("Kilobyte" , Byte.KB , "KB"),
                    < Byte.GB_Max => ("Megabyte" , Byte.MB , "MB"),
                    < Byte.TB_Max => ("Gigabyte" , Byte.GB , "GB"),
                    < Byte.PB_Max => ("Terabyte" , Byte.TB , "TB"),
                    < Byte.EB_Max => ("Petabyte" , Byte.PB , "PB"),
                    _             => ("Exabyte"  , Byte.EB , "EB"),
                };

                Size = $"{(double)Bytes / scale:N2} {label}";
            }
            public static ByteSize New(string name, ulong bytes) => new(name, bytes);
            public override string ToString() => Size;
        }

        [Serializable]
        public readonly struct Version
        {
            public int     Major { get; }
            public int     Minor { get; }
            public int     Build { get; }
            public int? Revision { get; }
            public Version() { }
            public Version(int major, int minor, int build)
            {
                Major    = major;
                Minor    = minor;
                Build    = build;
            }
            public Version(int major, int minor, int build, int revision)
            {
                Major    = major;
                Minor    = minor;
                Build    = build;
                Revision = revision;
            }
            public static implicit operator Version(System.Version v)
            {
                return (v != null) ? new Version(v.Major, v.Minor, v.Build, v.Revision) : new Version(0, 0, 0, -1);
            }
            public string             Label() => $"{Major}.{Minor}.{Build}";
            public override string ToString() => Revision < 0 ? Label() : $"{Label()}.{Revision}";
        }

        [Serializable]
        public class Content
        {
            public uint  Index { get; set; }
            public string Line { get; set; }
            public Content() { }
            public Content(uint index, string line)
            {
                Index = index;
                Line  = line;
            }
            public override string ToString() => Line;
        }

        namespace Progress
        {
            public enum OperationType
            {
                EventLog = 0,
                Transfer = 1,
            }

            public readonly struct Entry
            {
                public uint      Rank { get; }
                public uint   Current { get; }
                public uint     Total { get; }
                public string Percent { get; }
                public Entry(uint rank, uint current, uint total)
                {
                    Rank    = rank;
                    Current = current;
                    Total   = total;
                    Percent = total == 0 ? "100%" : (current / (double)total).ToString("P2");
                }
                public override string ToString() => $"{Percent} ({Current}/{Total})";
            }

            public readonly struct Tracker
            {
                public OperationType Operation { get; }
                public string      DisplayName { get; }
                public uint              Total { get; }
                public List<Entry>       Entry { get; }
                public Tracker(OperationType operation, string displayName, int total)
                {
                    Operation   = operation;
                    DisplayName = displayName;
                    Total       = (uint)total;
                    Entry       = new();

                    if (Total == 0)
                    {
                        Entry.Add(new(0,0,0));
                        return;
                    }

                    double step = (double)Total / 100.0;

                    for (uint i = 0; i <= 100; i++)
                    {
                        uint current = (uint)Math.Round(step * i);

                        if (current > Total) current = Total;

                        Entry.Add(new((uint)Entry.Count, current, Total));
                    }
                }
                public override string ToString() => $"{Operation}";
            }
        }
    }

    namespace Core
    {
        namespace Theme
        {
            namespace Input
            {
                public class Line
                {
                    public uint    Index { get; set; }
                    public uint     Rank { get; set; }
                    public uint    Bound { get; set; }
                    public string  Value { get; set; }
                    public uint   Length { get; set; }
                    public Line(uint index, uint rank, uint bound, string value)
                    {
                        Index  = index;
                        Rank   = rank;
                        Bound  = bound;
                        Value  = value;

                        SetLength();
                    }
                    public void SetLength()
                    {
                        Length = (uint)Value.Length;
                    }
                    public override string ToString() => Value != null ? Value.ToString() : "";
                }

                public class Container
                {
                    public uint      Index { get; set; }
                    public uint       Rank { get; set; }
                    public string     Type { get; set; }
                    public uint      Count { get; set; }
                    public List<Line> Line { get; set; } = new();
                    public Container(uint index, uint rank, string type, string[] lines)
                    {
                        Index = index;
                        Rank  = rank;
                        Type  = type;

                        Refresh(lines);
                    }
                    public void Clear()
                    {
                        Line.Clear();
                    }
                    public void Refresh(string[] lines)
                    {
                        Clear();

                        for (int x = 0; x < lines.Length; x++)
                        {
                            Line line = new Line(Index, Rank, (uint)x, lines[x]);

                            Line.Add(line);
                        }

                        Count = (uint)lines.Length;
                    }
                    public override string ToString() =>  $"[{Type}]({Count})";
                }

                public class Item
                {
                    public uint             Index { get; set; }
                    public string            Type { get; set; }
                    public List<Container> Output { get; set; } = new();
                    public Item(uint index, string type)
                    {
                        Index  = index;
                        Type   = type;
                        Output = new List<Container>();
                    }
                    public void Clear()
                    {
                        Output.Clear();
                    }
                    public override string ToString() => $"[{Type}]({Output.Count})";
                }

                public class Entry
                {
                    public Template.Mode Mode { get; set; }
                    public uint        Height { get; set; }
                    public List<Item>   Input { get; set; } = new();
                    public List<Line>  Output { get; set; } = new();
                    public Entry(object[] inputObject)
                    {
                        BuildInput(inputObject);
                        BuildOutput();
                    }
                    public Entry(Template.Mode mode, object[] inputObject)
                    {
                        Mode = mode;
                        BuildInput(inputObject);
                        BuildOutput();
                    }
                    public string[] ConvertHashtable(Hashtable table)
                    {
                        List<string> lines = new();

                        int buffer = table.Keys.Cast<object>().Select(x => $"{x}".Length).Max();

                        foreach (object key in table.Keys)
                            lines.Add($"{key.ToString().PadRight(buffer)} : {table[key]}");

                        return lines.ToArray();
                    }
                    public string[] ConvertObject(object obj)
                    {
                        List<string> lines = new();

                        var    pso = System.Management.Automation.PSObject.AsPSObject(obj);
                        int buffer = pso.Properties.Max(x => x.Name.Length);

                        foreach (var prop in pso.Properties)
                            lines.Add($"{prop.Name.PadRight(buffer)} : {prop.Value}");

                        return lines.ToArray();
                    }
                    public string[] ConvertString(string input)
                    {
                        int width = 86;

                        List<string> lines = new();
                        string        line;
                        string[]       raw;
                        string[]     words;
                        string        word;
                        string      buffer;

                        if (string.IsNullOrEmpty(input))
                        {
                            lines.Add("");
                            return lines.ToArray();
                        }

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

                                if (string.IsNullOrEmpty(line))
                                {
                                    lines.Add("");
                                    continue;
                                }

                                if (Regex.IsMatch(line, "[|_¯]"))
                                {
                                    lines.Add(line);
                                    continue;
                                }

                                words  = line.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                                buffer = "";

                                for (int w = 0; w < words.Length; w++)
                                {
                                    word = words[w];

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

                                if (buffer.Length > 0)
                                    lines.Add(buffer);
                            }

                            return lines.ToArray();
                        }
                    }
                    public string[] ConvertScript(string script)
                    {
                        List<string>   names = new();
                        List<string>  values = new();
                        List<string>   lines = new();

                        string       pattern = "([\"']?)([A-Za-z_][A-Za-z0-9_-]*)\\1\\s*=\\s*(?:([\"'])(.*?)\\3|([^;]+))";

                        string  scriptString = script.ToString().Replace("\r\n", "\n").Replace("\r", "\n");
                        string[] scriptLines = scriptString.Split('\n');

                        MatchCollection   mx = Regex.Matches(scriptLines[0], pattern);

                        if (mx.Count == 0)
                        {
                            for (int x = 0; x < scriptLines.Length; x++)
                            {
                                lines.Add(scriptLines[x]);
                            }

                            return lines.ToArray();
                        }

                        for (int i = 0; i < mx.Count; i++)
                        {
                            Match m = mx[i];

                            names.Add(m.Groups[2].Value);

                            if (m.Groups[4].Success)
                                values.Add(m.Groups[4].Value);
                            else
                                values.Add(m.Groups[5].Value.Trim());
                        }

                        int buffer = GetMaxLength(names);

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
                            case "String"      : { string s = (obj == null) ? "" : obj.ToString(); return ConvertString(s); }
                            case "Hashtable"   : { return ConvertHashtable((Hashtable)obj); }
                            case "ScriptBlock" : { string s = (obj == null) ? "" : obj.ToString(); return ConvertScript(s); }
                            case "PSObject"    : { return ConvertObject(obj); }
                            case "Int"         : { string s = (obj == null) ? "" : obj.ToString(); return ConvertString(s); }
                            case "Object[]"    : { return null; }
                            default            : { return null; }
                        }
                    }
                    public string DetermineType(object value)
                    {
                        if (value == null || value is string) return "String";
                        if (value is Hashtable) return "Hashtable";
                        if (value is System.Management.Automation.ScriptBlock) return "ScriptBlock";
                        if (value is System.Management.Automation.PSObject && value.GetType().Name != "Hashtable") return "PSObject";
                        if (value is int || value is double || value is decimal) return "Int";
                        if (value is IEnumerable) return "Object[]";
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
                        Input.Clear();

                        foreach (object obj in inputObject)
                        {
                            string type = DetermineType(obj);

                            if (type != "Object[]")
                            {
                                string[]     lines = ConvertByType(type, obj);
                                Item          item = new Item((uint)Input.Count, type);
                                Container     cont = new Container(item.Index, 0, type, lines);

                                item.Output.Add(cont);

                                Input.Add(item);
                            }
                            else
                            {
                                IEnumerable  enums = (IEnumerable)obj;
                                Item          item = new Item((uint)Input.Count, "Object[]");

                                foreach (object element in enums)
                                {
                                    string   etype = DetermineType(element);
                                    string[] lines = ConvertByType(etype, element);

                                    Container cont = new Container(item.Index, (uint)item.Output.Count, etype, lines);

                                    item.Output.Add(cont);
                                }

                                Input.Add(item);
                            }
                        }
                    }
                    public void BuildOutput()
                    {
                        Output.Clear();

                        bool modeFlag = Mode != Template.Mode.Banner && Mode != Template.Mode.Flag;

                        for (int i = 0; i < Input.Count; i++)
                        {
                            Item item = Input[i];

                            for (int c = 0; c < item.Output.Count; c++)
                            {
                                Container cont = item.Output[c];

                                for (int l = 0; l < cont.Line.Count; l++)
                                {
                                    Output.Add(cont.Line[l]);
                                }

                                if (modeFlag)
                                {
                                    if (c < item.Output.Count - 1)
                                    {
                                        Output.Add(new Line((uint)Output.Count, item.Index, (uint)c, ""));
                                    }
                                }
                            }

                            if (modeFlag)
                            {
                                if (i < Input.Count - 1)
                                {
                                    Output.Add(new Line((uint)Output.Count, item.Index, 0, ""));
                                }
                            }
                        }

                        Height = (uint)Output.Count;

                        if (modeFlag)
                        {
                            if (Height > 1)
                            {
                                Mode = Template.Mode.Section;
                            }
                            else
                            {
                                string line = Output.Count > 0 ? Output[0].ToString() : "";
                                Regex    rx = new Regex(@"^(\w+)\s(\[(\+|-|~|!)\])\s(.+)");
                                Match    mx = rx.Match(line);
                            
                                Mode = mx.Success ? Template.Mode.Action : Template.Mode.Function;
                            }
                            
                            for (int i = 0; i < Output.Count; i ++)
                            {
                                Output[i].Index = (uint)i;
                            }
                        }
                    }
                }
            }

            namespace Template
            {
                public enum Mode
                {
                    Function = 0,
                    Action   = 1,
                    Section  = 2,
                    Table    = 3,
                    Banner   = 4,
                    Flag     = 5,
                    General  = 6,
                }

                public enum TrackType
                {
                    Template = 0,
                    Single   = 1,
                    Title    = 2,
                    Body     = 3,
                    Prompt   = 4,
                }

                public class Slice
                {
                    public uint        Rank { get; set; }
                    public string      Text { get; set; }
                    public uint? Foreground { get; set; } = null;
                    public uint? Background { get; set; } = null;
                    public bool      Locked { get; set; } = false;
                    public Slice(uint rank, string text)
                    {
                        Rank       = rank;
                        Text       = text;
                    }
                    public Slice(uint rank, string text, uint foreground, uint background)
                    {
                        Rank       = rank;
                        Text       = text;
                        Foreground = foreground;
                        Background = background;
                    }
                    public override string ToString() => Text;
                }

                public class Palette
                {
                    public uint   Index { get; set; }
                    public uint[] Value { get; set; }
                    public Palette(uint index, uint[] value)
                    {
                        Index = index;
                        Value = value;
                    }
                    public override string ToString() => $"({Index}) {{{Value[0]},{Value[1]},{Value[2]},{Value[3]}}}";
                }

                public class Face
                {
                    public uint    Index { get; set; }
                    public string String { get; set; }
                    public char[]  Value { get; set; }
                    public uint[]  Bytes { get; set; }
                    public string    Hex { get; set; }
                    public Face(uint index, string hex)
                    {
                        Index = index;
                        Hex   = hex;
                        Bytes = new uint[4];
                        int b = 0;

                        for (int i = 0; i < 8; i += 2)
                        {
                            string pair = hex.Substring(i, 2);
                            Bytes[b]    = System.Convert.ToUInt32(pair, 16);
                            b++;
                        }

                        Value = new char[Bytes.Length];
                        for (int i = 0; i < Bytes.Length; i++)
                        {
                            Value[i] = (char)Bytes[i];
                        }

                        String = new string(Value);
                    }
                    public override string ToString() => $"({Index}) {{{String}}}";
                }

                public class Buffer
                {
                    public string       Type { get; set; }
                    public string     String { get; set; }
                    public List<uint>  Bytes { get; set; } = new();
                    public Buffer(string type, string inputString)
                    {
                        string     pattern = @"@\((?:\d+[;,]?)+\)\*\d+|\d+";
                        MatchCollection mx = Regex.Matches(inputString, pattern);

                        for (int i = 0; i < mx.Count; i ++)
                        {
                            string token = mx[i].Value;

                            if (Regex.IsMatch(token, @"^\d+$"))
                            {
                                Bytes.Add(Convert.ToUInt32(token));
                                continue;
                            }

                            if (Regex.IsMatch(token, @"^@\(\d+\)\*\d+$"))
                            {
                                string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                                string[] split = cleaned.Split('*');

                                uint    number = Convert.ToUInt32(split[0]);
                                uint    factor = Convert.ToUInt32(split[1]);

                                for (uint x = 0; x < factor; x++)
                                {
                                    Bytes.Add(number);
                                }

                                continue;
                            }

                            if (Regex.IsMatch(token, @"^@\(\d+[;,]\d+(?:[;,]\d+)*\)\*\d+$"))
                            {
                                string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                                string[] split = cleaned.Split('*');

                                string[] range = Regex.Split(split[0], "[;,]");
                                uint    factor = Convert.ToUInt32(split[1]);

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
                    public override string ToString() => $"<{base.ToString()}>";
                }

                public class Block
                {
                    public uint        Index { get; set; }
                    public uint        Track { get; set; }
                    public uint         Rank { get; set; }
                    public string       Text { get; set; }
                    public uint   Foreground { get; set; }
                    public uint   Background { get; set; }
                    public bool       Locked { get; set; } = false;
                    public Block(uint track, uint rank, string text, uint foreground, uint background)
                    {
                        Track      = track;
                        Rank       = rank;
                        Text       = text;
                        Foreground = foreground;
                        Background = background;
                    }
                    public void Update(Slice slice)
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
                    public void                Lock() => Locked = true;
                    public override string ToString() => Text;
                }

                public class Track
                {
                    public uint          Index { get; set; }
                    public uint           Rank { get; set; }
                    internal uint        Total { get; set; }
                    public TrackType      Type { get; set; }
                    internal Buffer       Mask { get; set; }
                    internal Buffer Foreground { get; set; }
                    internal Buffer Background { get; set; }
                    public List<Block>   Block { get; set; } = new();
                    public Track(uint index, uint rank, string mask, string foreground, string background)
                    {
                        Index      = index;
                        Rank       = rank;

                        SetType("Template");

                        Mask       = new Buffer("Mask",mask);
                        Foreground = new Buffer("Foreground",foreground);
                        Background = new Buffer("Background",background);

                        Clear();
                    }
                    public void Clear()
                    {
                        Block.Clear();
                    }
                    public void SetType(string type)
                    {
                        switch (type)
                        {
                            case "Template" : Type = TrackType.Template ; break;
                            case "Single"   : Type = TrackType.Single   ; break;
                            case "Title"    : Type = TrackType.Title    ; break;
                            case "Body"     : Type = TrackType.Body     ; break;
                            case "Prompt"   : Type = TrackType.Prompt   ; break;
                        }
                    }
                    public string Draft()
                    {
                        int     width = (int)Total.ToString().Length;
                        if (width < 2) width = 2;

                        string    rank = $" {Rank.ToString("D" + width)} ";
                        string[] track = new string[30];

                        for (int i = 0; i < 30; i++)
                            track[i] = Block[i].Text;

                        return $"|{rank}|{string.Join("|", track)}|";
                    }
                    public string Text()
                    {
                        string[] track = new string[30];

                        for (int i = 0; i < 30; i++)
                            track[i] = Block[i].Text;

                        return string.Join("", track);
                    }
                    public uint[] GetBytes(string type)
                    {
                        switch (type)
                        {
                            case "Mask"       : return       Mask.Bytes.ToArray();
                            case "Foreground" : return Foreground.Bytes.ToArray();
                            case "Background" : return Background.Bytes.ToArray(); 
                            default           : return                       null;
                        }
                    }
                    public uint[] GetForeground()
                    {
                        List<uint> list = new();

                        for (int i = 0; i < Block.Count; i++)
                            list.Add((uint)Block[i].Foreground);

                        return list.ToArray();
                    }
                    public uint[] GetBackground()
                    {
                        List<uint> list = new();

                        for (int i = 0; i < Block.Count; i++)
                            list.Add((uint)Block[i].Background);

                        return list.ToArray();
                    }
                    public void Lock(string line)
                    {
                        List<uint> list = new();
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
                                list.Add(UInt32.Parse(item));
                        }

                        for (int i = 0; i < list.Count; i++)
                            Block[(int)list[i]].Lock();
                    }
                    public override string ToString() => $"Track[{Index}]";
                }

                public class Draft
                {
                    public char[]      Face { get; set; }
                    public string RowHeader { get; set; }
                    public uint     Padding { get; set; }
                    public uint    MaxIndex { get; set; }
                    public int        Width { get; set; }
                    public Draft(List<Track> tracks)
                    {
                        Face    = new char[] { '_', '¯','=' };

                        Stage(tracks);
                    }
                    private void Stage(List<Track> tracks)
                    {
                        Width    = tracks.Max(x => x.Index).ToString().Length;

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
                            header = $"|{new string(Face[slot], RowHeader.Length - 2)}|";

                            for (int i = 0; i < 30; i++)
                                columns[i] = "====";
                        }

                        return $"{header}{string.Join("|", columns)}|";
                    }
                    public string Build(string name)
                    {
                        switch (name)
                        {
                            case "HeaderFrame" : return new string(Face[0], (int)Padding);
                            case "HeaderRuler" : return Ruler(0);
                            case "Partition"   : return Ruler(2);
                            case "FooterRuler" : return Ruler(1);
                            case "FooterFrame" : return new string(Face[1], (int)Padding);
                            default            : return null;
                        }
                    }
                }
            }

            public class Controller
            {
                public Template.Mode         Mode { get; set; }
                public Template.Palette   Palette { get; set; }
                public List<Template.Face>   Face { get; set; } = new();
                public Input.Entry             IO { get; set; }
                public Guid                  Guid { get; set; }
                public Format.ModDateTime    Time { get; set; }
                public string               Title { get; set; }
                public string              Prompt { get; set; }
                public List<Template.Track> Track { get; set; } = new();
                public Controller()
                {
                    Initialize();
                    Populate();
                }
                public static Controller Banner()
                {
                    Controller c = new Controller();

                    c.Refresh(Template.Mode.Banner, c.BannerText());
                    c.Write();

                    return c;
                }
                public static Controller Flag()
                {
                    Controller c = new Controller();

                    c.Refresh(Template.Mode.Flag, c.FlagText());
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
                public void Refresh(object inputObject)
                {
                    IO       = new Input.Entry(new object[]{ inputObject });
                    SetMode((uint)IO.Mode);
                    GenerateTemplate();
                    Reset();
                }
                public void Refresh(object[] inputObject)
                {
                    IO       = new Input.Entry(inputObject);
                    SetMode((uint)IO.Mode);
                    GenerateTemplate();
                    Reset();
                }
                public void Refresh(Template.Mode mode, object[] inputObject)
                {
                    IO       = new Input.Entry(mode, inputObject);
                    SetMode((uint)IO.Mode);

                    if      (Mode == Template.Mode.Banner) GenerateBanner();
                    else if (Mode == Template.Mode.Flag  ) GenerateFlag();
                    else                                   GenerateTemplate();
                    
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
                        throw new System.Exception($"Invalid palette [{index}]");

                    Palette = new Template.Palette(index, PaletteBytes((uint)index));
                }
                public void SetMode(uint mode)
                {
                    if (mode > 5)
                        throw new Exception($"Invalid type [{mode}]");

                    switch (mode)
                    {
                        case 0 : Mode = Template.Mode.Function ; break;
                        case 1 : Mode = Template.Mode.Action   ; break;
                        case 2 : Mode = Template.Mode.Section  ; break;
                        case 3 : Mode = Template.Mode.Table    ; break;
                        case 4 : Mode = Template.Mode.Banner   ; break;
                        case 5 : Mode = Template.Mode.Flag     ; break;
                        case 6 : Mode = Template.Mode.General  ; break;
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

                    Face.Clear();

                    for (uint x = 0; x < faceHex.Length; x++)
                    {
                        Template.Face item = new Template.Face(x,faceHex[x]);
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
                    string[] input = new string[12];

                    input[00] = "[==[ Dynamically Engineered Digital Security ]_/"; // 10
                    input[01] = "[_[ Application Development - Virtualization ]_/"; // 14
                    input[02] = "[=====[ Network & Hardware Magistration ]======/"; // 18
                    input[03] = "/ ____________________ \\";                        // 24
                    input[04] = "\\ [FightingEntropy(π)] /";                        // 25
                    input[05] = "/ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ \\";                        // 26
                    input[06] = "\\     ____________     /";                        // 27
                    input[07] = "/     [" + Time.DayString() + "]     \\";          // 28
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
                public Template.Track BuildTrack(uint index, uint rank, string mask, string foreground, string background)
                {
                    Template.Track track = new Template.Track(index, rank, mask, foreground, background);
                    
                    for (int x = 0; x < track.Mask.Bytes.Count; x++)
                    {
                        string text = Face[(int)track.Mask.Bytes[x]].String;
                        uint   fore = track.Foreground.Bytes[x];
                        uint   back = track.Background.Bytes[x];
                    
                        Template.Block block = new Template.Block(index, (uint)x, text, fore, back);
                    
                        track.Block.Add(block);
                    }

                    return track;
                }
                public void GenerateTemplate()
                {
                    Track.Clear();

                    string[] mask = TemplateMask();
                    string[] fore = TemplateForeground();
                    string[] back = TemplateBackground();

                    uint    index = 0;

                    switch (Mode)
                    {
                        case Template.Mode.Function:
                        {
                            uint[] rankOrder = {0, 1, 2, 3, 4};

                            for (uint i = 0; i < rankOrder.Length; i++)
                            {
                                int    ri = (int)rankOrder[i];
                                uint rank = rankOrder[i];

                                Template.Track track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                                if (index == 3) track.SetType("Single");

                                Track.Add(track);
                                index ++;
                            }
                            break;
                        }
                        case Template.Mode.Action:
                        {
                            uint[] rankOrder = {5, 6, 7, 8, 9};

                            for (uint i = 0; i < rankOrder.Length; i++)
                            {
                                int    ri = (int)rankOrder[i];
                                uint rank = rankOrder[i];

                                Template.Track track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                                if (index == 2) track.SetType("Single");

                                Track.Add(track);
                                index ++;
                            }
                            break;
                        }
                        case Template.Mode.Section:
                        {
                            uint[] rankOrder = {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};

                            for (uint i = 0; i < rankOrder.Length; i++)
                            {
                                int    ri = (int)rankOrder[i];
                                uint rank = rankOrder[i];

                                if (rank != 14)
                                {
                                    Template.Track track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                                    if      (rank == 11) track.SetType("Title");
                                    else if (rank ==  3) track.SetType("Prompt");

                                    Track.Add(track);
                                    index ++;
                                }    
                                else
                                {
                                    uint b = 0;
                                    while (b < IO.Output.Count)
                                    {
                                        Template.Track track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

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
                                        Template.Track track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);
                                    
                                        track.Block[0].Text  = "   /";
                                        track.Block[1].Text  = "/   ";
                                        track.Block[28].Text = "___/";
                                        track.Block[29].Text = "/   ";

                                        track.SetType("Body");

                                        Track.Add(track);
                                        index ++;
                                    }
                                    else
                                        Track[Track.Count - 1].Block[28].Text = "___/";
                                }
                            }
                            break;
                        }
                    }

                    SetTotal();
                }
                public void GenerateBanner()
                {
                    Track.Clear();

                    string[] mask = BannerMask();
                    string[] fore = BannerForeground();
                    string[] back = BannerBackground();

                    for (uint i = 0; i <= 24; i++)
                    {
                        Template.Track track = BuildTrack(i, i, mask[i], fore[i], back[i]);

                        if (i == 3)                 track.SetType("Title");
                        else if (i >= 9 && i <= 16) track.SetType("Body");
                        else if (i == 23)           track.SetType("Prompt");
                    
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

                    Track.Clear();

                    string[] mask = FlagMask();
                    string[] fore = FlagForeground();
                    string[] back = FlagBackground();

                    for (uint i = 0; i <= 38; i++)
                    {                
                        Template.Track track = BuildTrack(i, i, mask[i], fore[i], back[i]);
                    
                        if (i == 3)
                            track.SetType("Title");
                        else if (i == 10 || i == 14 || i == 18 || (i >= 24 && i <= 32))
                            track.SetType("Body");
                        else if (i == 37)
                            track.SetType("Prompt");
                        
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
                        Track[x].Total = (uint)Track.Count;
                }
                public Template.Track[] GetTrackByType(Template.TrackType type)
                {
                    List<Template.Track> list = new List<Template.Track>();

                    for (int i = 0; i < Track.Count; i++)
                    {
                        if (Track[i].Type == type)
                            list.Add(Track[i]);
                    }

                    return list.ToArray();
                }
                public string PrepareString(string text)
                {
                    if      (text.Length == 0) text = "  ";
                    else if (text.Length == 1) text = $" {text}";
                    else if (text.Length > 90) text = $"{text.Substring(0, 87)}...";

                    text = $" {text} ";

                    return text;
                }
                public List<Template.Slice> GenerateSlices(string text, uint startRank, uint foreground, uint background)
                {
                    List<Template.Slice> slices = new();

                    int remainder = text.Length % 4;
                    if (remainder > 0) text = text + new string(' ', 4 - remainder);

                    int sliceCount = text.Length / 4;
                    int x = 0;

                    while (x < sliceCount)
                    {
                        string part = text.Substring(x * 4, 4);

                        Template.Slice slice = new Template.Slice((uint)(startRank + x), part, foreground, background);

                        slices.Add(slice);
                        x ++;
                    }

                    return slices;
                }
                public List<Template.Slice> GenerateSlices(string text, uint startRank)
                {
                    List<Template.Slice> slices = new();

                    int remainder = text.Length % 4;
                    if (remainder > 0) text = text + new string(' ', 4 - remainder);

                    int sliceCount = text.Length / 4;
                    int x = 0;

                    while (x < sliceCount)
                    {
                        string part = text.Substring(x * 4, 4);

                        Template.Slice slice = new Template.Slice((uint)(startRank + x), part);

                        slices.Add(slice);
                        x ++;
                    }

                    return slices;
                }
                public void InsertLine(string type, string entry, int start, Template.Track track)
                {
                    string text;
                    List<Template.Slice> slices = new();

                    switch (type)
                    {
                        case "Function":
                        {
                            text = PrepareString(entry);
                            
                            slices = GenerateSlices(text, (uint)start, 2, 3);

                            for (int i = 0; i < slices.Count; i++)
                                track.Block[start + i].Update(slices[i]);

                            int index = start + slices.Count;

                            if (index == 25)
                                track.Block[26].Assign("]__/",1,3);
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
                            text = Mode != Template.Mode.Section ? PrepareString(entry) : entry;

                            slices = GenerateSlices(text, (uint)start, 2, 3);

                            for (int i = 0; i < slices.Count; i++)
                                track.Block[start + i].Update(slices[i]);

                            break;
                        }
                        case "Banner":
                        {
                            slices = GenerateSlices(entry, (uint)start);

                            for (int i = 0; i < slices.Count; i++)
                                track.Block[start + i].Update(slices[i]);

                            break;
                        }
                        case "Flag":
                        {
                            slices = GenerateSlices(entry, (uint)start);   

                            for (int i = 0; i < slices.Count; i++)
                                track.Block[start + i].Update(slices[i]);

                            break;
                        }
                    }
                }
                public void Reset()
                {
                    List<Template.Track> track = new();

                    if (Mode == Template.Mode.Function) // {0, 1, 2, 3, 4}
                    {
                        track.AddRange(GetTrackByType(Template.TrackType.Single));

                        InsertLine("Function", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();
                    }
                    else if (Mode == Template.Mode.Action) // {5, 6, 7, 8, 9}
                    {
                        track.AddRange(GetTrackByType(Template.TrackType.Single));

                        InsertLine("Action", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();
                    }
                    else if (Mode == Template.Mode.Section) // {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};
                    {
                        track.AddRange(GetTrackByType(Template.TrackType.Title));

                        InsertLine("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(Template.TrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                            InsertLine("Action", IO.Output[x].ToString(), 3, track[x]);

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(Template.TrackType.Prompt));

                        InsertLine("Function", Prompt, 3, track[0]);

                        track.Clear();
                    }
                    else if (Mode == Template.Mode.Banner)
                    {
                        track.AddRange(GetTrackByType(Template.TrackType.Title));

                        InsertLine("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(Template.TrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                            InsertLine("Banner", IO.Output[x].ToString(), 10, track[x]);

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(Template.TrackType.Prompt));

                        InsertLine("Function", Prompt, 3, track[0]);

                        track.Clear();
                    }
                    else if (Mode == Template.Mode.Flag)
                    {
                        track.AddRange(GetTrackByType(Template.TrackType.Title));

                        InsertLine("Function", Title, 3, track[0]);

                        track.Clear();

                        track.AddRange(GetTrackByType(Template.TrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            string line = IO.Output[x].ToString();
                            
                            InsertLine("Flag", line, line.Length == 48 ? 14 : 12, track[x]);
                        }

                        track.Clear();

                        track.AddRange(GetTrackByType(Template.TrackType.Prompt));

                        InsertLine("Function", Prompt, 3, track[0]);

                        track.Clear();
                    }
                }
                public string Draft()
                {
                    Template.Draft draft = new Template.Draft(Track);

                    System.Text.StringBuilder sb = new System.Text.StringBuilder();

                    // Header
                    sb.AppendLine(draft.Build("HeaderFrame"));
                    sb.AppendLine(draft.Build("HeaderRuler"));

                    // Tracks
                    for (int i = 0; i < Track.Count; i++)
                    {
                        Template.Track t = Track[i];

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
                        System.Console.OutputEncoding = System.Text.Encoding.UTF8;   
                }
                public void Write()
                {
                    for (int t = 0; t < Track.Count; t++)
                    {
                        Template.Track track = Track[t];

                        for (int b = 0; b < track.Block.Count; b++)
                        {
                            Template.Block block = track.Block[b];

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
                    Track[(int)index].Text();
                }
                public void DraftTrack(uint index)
                {
                    Template.Track track = Track[(int)index];

                    string head = $"| {track.Index:D2} | {track.Rank:D2} |";

                    System.Console.Write(head);

                    for (int i = 0; i < track.Block.Count; i++)
                    {
                        Template.Block block = track.Block[i];

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
                    Template.Draft draft = new Template.Draft(Track);

                    // Header
                    System.Console.WriteLine(draft.Build("HeaderFrame"));
                    System.Console.WriteLine(draft.Build("HeaderRuler"));

                    // Tracks
                    for (int i = 0; i < Track.Count; i++)
                    {
                        Template.Track t = Track[i];

                        string index = t.Index.ToString("D" + draft.Width);
                        string rank  = t.Rank.ToString("D" + 2);

                        // Write the left-hand header for the track
                        System.Console.Write($"| {index} | {rank} |");

                        // Now render each block with color
                        for (int b = 0; b < t.Block.Count; b++)
                        {
                            Template.Block block = t.Block[b];

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
                    Template.Draft draft = new Template.Draft(Track);

                    // Header
                    System.Console.WriteLine(draft.Build("HeaderFrame"));
                    System.Console.WriteLine(draft.Build("HeaderRuler"));

                    // Tracks
                    Template.Track track = Track[slot];

                    string index = track.Index.ToString("D" + draft.Width);
                    string rank  = track.Rank.ToString("D" + 2);

                    // Write the left-hand header for the track
                    System.Console.Write($"| {index} | {rank} |");
                    
                    // Now render each block with color
                    for (int b = 0; b < track.Block.Count; b++)
                    {
                        Template.Block block = track.Block[b];
                
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
                        System.Console.Write($" {mask[i],2} |");

                    System.Console.WriteLine();

                    // Foreground row
                    uint[] fore = track.GetForeground();
                    System.Console.Write("|  Fore:  |");

                    for (int i = 0; i < fore.Length; i++)
                        System.Console.Write($" {fore[i],2} |");

                    System.Console.WriteLine();

                    // Background row
                    uint[] back = track.GetBackground();
                    System.Console.Write("|  Back:  |");

                    for (int i = 0; i < back.Length; i++)
                        System.Console.Write($" {back[i],2} |");

                    System.Console.WriteLine();

                    // Footer
                    System.Console.WriteLine(draft.Build("FooterRuler"));
                    System.Console.WriteLine(draft.Build("FooterFrame"));
                }
                public string Text()
                {
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();

                    foreach (Template.Track track in Track)
                        sb.AppendLine(track.Text());

                    return sb.ToString();
                }
                public override string ToString() => $"<{base.ToString()}>";
            }
        }

        namespace Console
        {
            public enum Mode
            {
                Full   = 0,
                String = 1,
                Silent = 2,
                Debug  = 3,
                Trace  = 4,
            }

            public class Mark
            {
                public string              Name { get; set; }
                public Format.ModDateTime? Time { get; set; }
                public bool                 Set { get; set; }
                public Mark(string name)
                {
                    Name = name;
                    Time = null;
                    Set  = false;
                }
                public void Toggle()
                {
                    Time = DateTime.Now;
                    Set  = true;
                }
                public DateTime? AsDateTime
                { 
                    get { return Time.HasValue ? Time.Value.Value : DateTime.Now; }
                }
                public override string ToString() => Time.HasValue ? Time.Value.ToString() : "<unset>";
            }

            public class Entry
            {
                public uint     Index { get; set; }
                public string Elapsed { get; set; }
                public int      State { get; set; }
                public string  Status { get; set; }
                public Entry(uint index, string time, int state, string status)
                {
                    Index   = index;
                    Elapsed = time;
                    State   = state;
                    Status  = status;
                }
                public override string ToString() => $"[{Elapsed}] (State: {State}/Status: {Status})";
            }

            public class Controller
            {
                public Mode                          Mode { get; set; }
                public Mark                         Start { get; set; }
                public Mark                           End { get; set; }
                public string                        Span { get; set; }
                public Entry                       Status { get; set; }
                public ObservableCollection<Entry> Output { get; set; } = new();
                public Controller()
                {
                    Reset();
                }
                public string Elapsed()
                {
                    return ((End.Set ? End.AsDateTime : DateTime.Now) - Start.AsDateTime).ToString();
                }
                public void SetStatus()
                {
                    Status = new Entry((uint)Output.Count, Elapsed(), Status.State, Status.Status);
                }
                public void SetStatus(int state, string status)
                {
                    Status = new Entry((uint)Output.Count, Elapsed(), state, status);
                }
                public void SetMode(int mode)
                {
                    if (mode >= 0 && mode <= 4)
                        Mode = (Mode)mode;   
                }
                public void Initialize()
                {
                    if (Start.Set == true)
                    {
                        Update(-1, "Start [!] Error: Already initialized, try a different operation or reset.");
                        return;
                    }

                    Start.Toggle();
                    Update(0, $"Running [~] ({Start.ToString()})");
                }
                public void Complete()
                {
                    if (End.Set == true)
                    {
                        Update(-1, "End [!] Error: Already initialized, try a different operation or reset.");
                        return;
                    }

                    End.Toggle();
                    Span = Elapsed();
                    Update(100, $"Complete [+] ({End.ToString()}), Total: ({Span})");
                }
                public void Reset()
                {
                    Start  = new Mark("Start");
                    End    = new Mark("End");
                    Span   = null;
                    Status = null;
                    Output.Clear();
                }
                public void Update(int state, string status)
                {
                    SetStatus(state, status);
                    Output.Add(Status);

                    var entry = Last();
                    
                    if (Mode == Mode.Full)
                        System.Console.WriteLine(entry);
                    else if (Mode == Mode.String)
                        System.Console.WriteLine(entry.Status);
                    else if (Mode == Mode.Debug && entry.State <= -10)
                        System.Console.WriteLine(entry.Status);
                    else
                    { 
                        // Silent
                    }
                }
                public object Current()
                {
                    Update(Status.State, Status.Status);
                    return Last();
                }
                public Entry Last()
                {
                    return Output[Output.Count-1];
                }
                public object DumpConsole()
                {
                    string[] arr = new string[Output.Count];

                    for (int i = 0; i < Output.Count; i++)
                        arr[i] = Output[i].ToString();

                    return arr;
                }
                public override string ToString() => Span == null ? Elapsed() : Span;
            }
        }

        namespace Pattern
        {
            public static class Option
            {
                public const RegexOptions       Default = RegexOptions.Compiled;
                public const RegexOptions         ICase = RegexOptions.Compiled | RegexOptions.IgnoreCase;
                public const RegexOptions         Multi = RegexOptions.Compiled | RegexOptions.Multiline;
                public const RegexOptions    ICaseMulti = RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.Multiline;
                public const RegexOptions       Verbose = RegexOptions.Compiled | RegexOptions.IgnorePatternWhitespace;
                public const RegexOptions  ICaseVerbose = RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace;
                public const RegexOptions      Explicit = RegexOptions.Compiled | RegexOptions.ExplicitCapture;
                public const RegexOptions ICaseExplicit = RegexOptions.Compiled | RegexOptions.IgnoreCase | RegexOptions.ExplicitCapture;
            }

            public static class Filter
            {
                // Transfer/Filesystem
                public const string      Remote = @"^(?<scheme>https?|s?ftp|smb|tcp|udp):\/\/" +
                                                    @"(?<host>[^\/:\?]+)" +
                                                    @"(?::(?<port>\d+))?" +
                                                    @"(?<path>\/[^?]*)?" +
                                                    @"(?:\?(?<query>.*))?$";
                public const string         Unc = @"^\\\\(?<host>[^\\]+)\\(?<share>[^\\]+)(\\(?<path>.*))?$";
                public const string  FileSystem = @"^(?:[A-Za-z]:\\|/|\./|\.\./)";
                public const string     Windows = @"^(?<drive>[A-Za-z]):\\(?<path>.*)$";
                public const string       Linux = @"^(?<path>\/.*)$";
                public const string    Filename = @"^[^\\\/:*?""<>|]+$";
                public const string   Extension = @"^\.[A-Za-z0-9]+$";

                // Networking
                public const string        IPv4 = @"\b(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\b";
                public const string        IPv6 = @"(?i)\b(?:[0-9a-f]{1,4}:){1,7}[0-9a-f]{1,4}\b";
                public const string         Mac = @"\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b";
                public const string   IpAddress = @"(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}" +
                                                    @"(?:25[0-5]|2[0-4]\d|1?\d?\d)" +
                                                    @"|(?:[0-9A-Fa-f]{1,4}:){1,7}[0-9A-Fa-f]{1,4}";
                public const string    Hostname = @"^(?=.{1,253}$)(?!-)[A-Za-z0-9-]{1,63}(?<!-)$";
                public const string        Fqdn = @"^(?=.{1,253}$)(?:(?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,63}$";
                public const string         Uri = @"^(https?|ftp|sftp):\/\/[^\s\/$.?#].[^\s]*$";
                public const string        Port = @"^\d{1,5}$";
                public const string        Cidr = @"^(?<address>.+?)\/(?<prefix>\d{1,3})$";

                // Security
                public const string       Email = @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$";
                public const string         Upn = @"^[^@]+@[^@]+\.[^@]+$";
                public const string  DomainUser = @"^(?<domain>[^\\]+)\\(?<user>.+)$";
                public const string         Sid = @"^S-\d-\d+(?:-\d+)+$";
                public const string          DN = @"^(?:CN|OU|DC)=(?:[^,]+)(?:,(?:CN|OU|DC)=(?:[^,]+))*$";
                
                // Identifiers
                public const string        Guid = @"^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$";
                public const string         Hex = @"^(0x)?[0-9A-Fa-f]+$";
                public const string      Base64 = @"^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$";

                // Linux
                public const string      Device = @"^\/dev\/.+$";
                public const string  MountPoint = @"^\/(?:[^\/\0]+\/?)*$";
                public const string     Service = @"^[A-Za-z0-9._-]+(?:\.service)?$";
                public const string   Interface = @"^[A-Za-z0-9._:-]+$";

                // Process
                public const string         Pid = @"^\d+$";
                public const string CommandLine = @"^.+$";
                public const string  ProcMemory = @"VmSize:\s+(\d+)\s+kB[\s\S]*?VmRSS:\s+(\d+)\s+kB[\s\S]*?VmSwap:\s+(\d+)\s+kB";
            }

            public static class Expression
            {
                // Transfer/FileSystem
                public static readonly Regex      Remote = new(Filter.Remote      , Option.Default);
                public static readonly Regex         Unc = new(Filter.Unc         , Option.ICase);
                public static readonly Regex  FileSystem = new(Filter.FileSystem  , Option.Default);
                public static readonly Regex     Windows = new(Filter.Windows     , Option.Default);
                public static readonly Regex       Linux = new(Filter.Linux       , Option.Default);
                public static readonly Regex    Filename = new(Filter.Filename    , Option.Default);
                public static readonly Regex   Extension = new(Filter.Extension   , Option.Default);

                // Networking
                public static readonly Regex        IPv4 = new(Filter.IPv4        , Option.Default);
                public static readonly Regex        IPv6 = new(Filter.IPv6        , Option.ICase);
                public static readonly Regex   IpAddress = new(Filter.IpAddress   , Option.ICase);
                public static readonly Regex         Mac = new(Filter.Mac         , Option.Default);
                public static readonly Regex    Hostname = new(Filter.Hostname    , Option.Default);
                public static readonly Regex        Fqdn = new(Filter.Fqdn        , Option.Default);
                public static readonly Regex         Uri = new(Filter.Uri         , Option.ICase);
                public static readonly Regex        Port = new(Filter.Port        , Option.Default);
                public static readonly Regex        Cidr = new(Filter.Cidr        , Option.Default);

                // Security
                public static readonly Regex       Email = new(Filter.Email       , Option.ICase);
                public static readonly Regex         Upn = new(Filter.Upn         , Option.ICase);
                public static readonly Regex  DomainUser = new(Filter.DomainUser  , Option.Default);
                public static readonly Regex         Sid = new(Filter.Sid         , Option.Default);
                public static readonly Regex          DN = new(Filter.DN          , Option.Default);

                // Identifiers
                public static readonly Regex        Guid = new(Filter.Guid        , Option.Default);
                public static readonly Regex         Hex = new(Filter.Hex         , Option.Default);
                public static readonly Regex      Base64 = new(Filter.Base64      , Option.Default);

                // Linux
                public static readonly Regex      Device = new(Filter.Device      , Option.Default);
                public static readonly Regex  MountPoint = new(Filter.MountPoint  , Option.Default);
                public static readonly Regex     Service = new(Filter.Service     , Option.Default);
                public static readonly Regex   Interface = new(Filter.Interface   , Option.Default);

                // Process
                public static readonly Regex         Pid = new(Filter.Pid         , Option.Default);
                public static readonly Regex CommandLine = new(Filter.CommandLine , Option.Default);
                public static readonly Regex  ProcMemory = new(Filter.ProcMemory  , Option.Multi);
            }
        }

        namespace Platform
        {
            // Manages processes
            namespace Process
            {
                [Serializable]
                public enum Mode
                {
                    Template = 0,
                    Entry    = 1,
                }

                [Serializable]
                public enum State
                {
                    Unspecified = 0,
                    Running     = 1,
                    Stopped     = 2,
                    Faulted     = 3,
                    Completed   = 4,
                }

                [Serializable]
                public class Dependency
                {
                    public uint                Index { get; set; }
                    public string             Source { get; set; }
                    public string        DisplayName { get; set; }
                    public string               Name { get; set; }
                    public string           Fullname { get; set; }
                    public Guid                 Guid { get; set; }
                    public bool               Exists { get; set; }
                    public string           Argument { get; set; } = "";
                    public string   WorkingDirectory { get; set; } = "";
                    public bool      UseShellExecute { get; set; } = false;
                    public bool       RedirectStdOut { get; set; } = true;
                    public bool       RedirectStdErr { get; set; } = false;
                    public bool        RedirectStdIn { get; set; } = false;
                    public bool       CreateNoWindow { get; set; } = true;
                    public bool                Admin { get; set; } = false;
                    public int                    Id { get; set; }
                    public State               State { get; set; } = Core.Platform.Process.State.Unspecified;
                    public Format.ModDateTime? Start { get; set; }
                    public Format.ModDateTime?   End { get; set; }
                    public TimeSpan?            Span { get; set; }
                    public int?             ExitCode { get; set; }
                    public bool            Completed => End.HasValue;
                    public Dependency() { }
                    public Dependency(uint index, string source, string displayname, string name, string fullname)
                    {
                        Index       = index;
                        Source      = source;
                        DisplayName = displayname;
                        Name        = name;
                        Guid        = Guid.NewGuid();
                        
                        Assign(fullname);
                    }
                    public void Assign(string fullname)
                    {
                        Fullname = fullname;
                        Check();
                    }
                    public void SetTemplate(string arglist, string dir, bool shell, bool rout, bool rerr, bool rin, bool win, bool admin)
                    {
                        Argument         = arglist;
                        WorkingDirectory = dir;
                        UseShellExecute  = shell;
                        RedirectStdOut   = rout;
                        RedirectStdErr   = rerr;
                        RedirectStdIn    = rin;
                        CreateNoWindow   = win;
                        Admin            = admin;
                    }
                    public void SetArgument(string arglist)
                    {
                        Argument         = arglist;
                    }
                    public void SetDirectory(string directory)
                    {
                        WorkingDirectory = directory;
                    }
                    public void Reset()
                    {
                        Argument         = "";
                        WorkingDirectory = "";
                        UseShellExecute  = false;
                        RedirectStdOut   = true;
                        RedirectStdErr   = false;
                        RedirectStdIn    = false;
                        CreateNoWindow   = true;
                        Admin            = false;
                    }
                    public void Toggle(string property)
                    {
                        switch (property.ToLower())
                        {
                            case "shell"    : UseShellExecute = !UseShellExecute ; break;
                            case "out"      : RedirectStdOut  = !RedirectStdOut  ; break;
                            case "in"       : RedirectStdIn   = !RedirectStdIn   ; break;
                            case "error"    : RedirectStdErr  = !RedirectStdErr  ; break;
                            case "nowindow" : CreateNoWindow  = !CreateNoWindow  ; break;
                            default         : break;
                        }
                    }
                    public bool IsWdNull()
                    {
                        return string.IsNullOrWhiteSpace(WorkingDirectory);
                    }
                    public void SetState(State state)
                    {
                        State = state;
                    }
                    public void Check()
                    {
                        Exists = System.IO.File.Exists(Fullname) || System.IO.Directory.Exists(Fullname);
                    }
                    public void MarkStart(int pid)
                    {
                        Id       = pid;
                        Start    = Format.ModDateTime.Now();
                        End      = null;
                        Span     = null;
                        State    = State.Running;
                    }
                    public void MarkFaulted()
                    {
                        End      = Format.ModDateTime.Now();
                        Span     = End.Value.Value - Start.Value.Value;
                        State    = State.Faulted;
                    }
                    public void MarkEnd(int exitCode)
                    {
                        End      = Format.ModDateTime.Now();
                        Span     = End.Value.Value - Start.Value.Value;
                        ExitCode = exitCode;
                        State    = State.Completed;
                    }
                    public TimeSpan? CpuTime
                    {
                        get
                        {
                            if (Id <= 0) return null;

                            try
                            {
                                return System.Diagnostics.Process.GetProcessById(Id).TotalProcessorTime;
                            }
                            catch
                            {
                                return null;
                            }
                        }
                    }
                }

                [Serializable]
                public class Entry
                {
                    public int                         Id { get; set; }
                    public string                    Name { get; set; }
                    public string                    Path { get; set; }
                    public string                Argument { get; set; }
                    public Guid?                     Guid { get; set; }
                    public bool                 HasExited { get; set; }
                    public int                  SessionId { get; set; }
                    public Format.ByteSize     WorkingSet { get; set; }
                    public Format.ByteSize  VirtualMemory { get; set; }
                    public Format.ByteSize    PagedMemory { get; set; }
                    public Format.ByteSize NonpagedMemory { get; set; }
                    public TimeSpan               CpuTime { get; set; }
                    public IntPtr              MainWindow { get; set; }
                    public Entry() { }
                    public Entry(int id, string name, string path, string args, bool done, int ssid, ulong work, ulong vmem, ulong paged, ulong non, TimeSpan cpu, IntPtr win)
                    {
                        Id             = id;
                        Name           = name;
                        Path           = path;
                        Argument       = args;
                        HasExited      = done;
                        SessionId      = ssid;
                        WorkingSet     = new Format.ByteSize("Working", work);
                        VirtualMemory  = new Format.ByteSize("Virtual", vmem);
                        PagedMemory    = new Format.ByteSize("Paged", paged);
                        NonpagedMemory = new Format.ByteSize("Nonpaged", non);
                        CpuTime        = cpu;
                        MainWindow     = win;
                    }
                }

                [Serializable]
                public class Provider
                {
                    public List<Dependency> Dependency { get; set; } = new();
                    public List<Entry>           Entry { get; set; } = new();
                    public Provider() { }
                }
            }

            // Manages all defined security aspects, will definitely expand
            namespace Security
            {
                [Serializable]
                public enum ProtocolMode : uint
                {
                    None  = 0,
                    Ssl3  = 48,
                    Tls10 = 192,
                    Tls11 = 768,
                    Tls12 = 3072,
                    Tls13 = 12288
                }

                [Serializable]
                public enum AuthenticationType : uint
                {
                    None        = 0,
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
                    Local       = 12,
                    Unspecified = 13,
                }

                [Serializable]
                public enum AccountType : uint
                {
                    LocalSystem    = 0,
                    LocalService   = 1,
                    NetworkService = 2,
                    User           = 3,
                    BuiltinGroup   = 4,
                    Unspecified    = 5,
                }

                [Serializable]
                public enum ImpersonationLevel : uint
                {
                    None        = 0,
                    Anonymous   = 1,
                    Identify    = 2,
                    Impersonate = 3,
                    Delegate    = 4,
                    Unspecified = 5
                }
                
                [Serializable]
                public class Identifier
                {
                    public virtual string             Name { get; set; }
                    public virtual int?                Uid { get; set; }
                    public virtual int?                Gid { get; set; }
                    public virtual string              Sid { get; set; }
                    public virtual string AccountDomainSid { get; set; }
                    public virtual int?                Rid { get; set; }
                    public virtual int?       BinaryLength { get; set; }
                    public Identifier() { }
                    public Identifier(string name, string sid)
                    {
                        Name = name;
                        SetSid(sid);
                    }
                    public Identifier(string name, int? uid, int? gid, string sid)
                    {
                        Name = name;
                        Uid  = uid;
                        Gid  = gid;

                        SetSid(sid);
                    }
                    public void SetSid(string sidstring)
                    {
                        Sid              = sidstring;
                        Rid              = null;
                        AccountDomainSid = null;
                        BinaryLength     = null;

                        if (!Regex.IsMatch(sidstring, @"^S-\d+(-\d+){1,14}$"))
                            return;

                        string[] parts   = sidstring.Split('-');

                        if (int.TryParse(parts[^1], out int rid))
                            Rid          = rid;

                        AccountDomainSid = string.Join("-", parts.Take(parts.Length - 1));
                        BinaryLength     = parts.Length;
                    }
                }

                [Serializable]
                public class Reference
                {
                    public virtual uint             Index { get; set; }
                    public virtual bool        Referenced { get; set; }
                    public virtual string            Name { get; set; }
                    public virtual string           Value { get; set; }
                    public virtual Identifier  Identifier { get; set; }
                    public Reference() { }
                    public Reference(uint index, string name, string value)
                    {
                        Index = index;
                        Name  = name;
                        Value = value;
                    }
                    public void SetIdentifier(Identifier id)
                    {
                        Identifier = id;
                    }
                }

                [Serializable]
                public class Role
                {
                    public virtual string          Name { get; set; }
                    public virtual int?             Gid { get; set; }
                    public virtual int?             Rid { get; set; }
                    public virtual string           Sid { get; set; }
                    public virtual List<string> Members { get; set; } = new();
                    public Role() { }
                }

                [Serializable]
                public class Identity
                {
                    public virtual AuthenticationType AuthenticationType { get; set; }
                    public virtual ImpersonationLevel ImpersonationLevel { get; set; }
                    public virtual bool                  IsAuthenticated { get; set; }
                    public virtual bool                          IsGuest { get; set; }
                    public virtual bool                         IsSystem { get; set; }
                    public virtual bool                  IsAdministrator { get; set; }
                    public virtual string                           Name { get; set; }
                    public virtual Identifier                      Owner { get; set; }
                    public virtual Identifier                       User { get; set; }
                    public virtual List<Identifier>               Groups { get; set; } = new();
                    public virtual string                         Domain { get; set; }
                    public virtual string                             Id { get; set; }
                    public virtual List<Claim>                UserClaims { get; set; } = new();
                    public virtual List<Claim>              DeviceClaims { get; set; } = new();
                    public virtual List<Claim>                    Claims { get; set; } = new();
                    public virtual List<Role>                       Role { get; set; } = new();
                    public Identity() { }
                }

                [Serializable]
                public class Claim
                {
                    public virtual string                         Issuer { get; set; }
                    public virtual string                 OriginalIssuer { get; set; }
                    public virtual Dictionary<string, string> Properties { get; set; } = new();
                    public virtual string                           Type { get; set; }
                    public virtual string                          Value { get; set; }
                    public virtual string                      ValueType { get; set; }
                    public Claim() { }
                }

                [Serializable]
                public class Account
                {
                    public virtual uint               Index { get; set; }
                    public virtual AccountType  AccountType { get; set; }
                    public virtual string          Username { get; set; }
                    public virtual string       DisplayName { get; set; }
                    public virtual string DistinguishedName { get; set; }
                    public virtual string UserPrincipalName { get; set; }
                    public virtual string    SamAccountName { get; set; }
                    public virtual string            Domain { get; set; }
                    public virtual int?                 Uid { get; set; }
                    public virtual int?                 Gid { get; set; }
                    public virtual Identifier           Sid { get; set; }
                    public virtual string              Home { get; set; }
                    public virtual string             Shell { get; set; }
                    public Account() { }
                    public void SetAccountType(Core.Platform.Security.AccountType type)
                    {
                        AccountType       = type;
                    }
                }

                [Serializable]
                public class Principal
                {
                    public virtual Account       Account { get; set; }
                    public virtual Identifier Identifier { get; set; }
                    public virtual List<Role>       Role { get; set; } = new();
                    public virtual List<Claim>     Claim { get; set; } = new();
                    public Principal() { }
                }

                [Serializable]
                public class Principal2
                {
                    public virtual Identity         Identity { get; set; }
                    public virtual List<Claim>          User { get; set; } = new();
                    public virtual List<Claim>        Device { get; set; } = new();
                    public virtual List<Claim>        Claims { get; set; } = new();
                    public virtual List<Identity> Identities { get; set; } = new();
                    public Principal2() { }
                }

                [Serializable]
                public class Context
                {
                    public virtual Identity                   Identity { get; set; }
                    public virtual Principal                 Principal { get; set; }
                    public virtual Credential               Credential { get; set; }
                    public virtual List<Certificate.Entry> Certificate { get; set; } = new();
                    public virtual bool                IsAdministrator { get; set; }
                    public virtual bool                IsAuthenticated { get; set; }
                    public virtual string                     Platform { get; set; }
                    public virtual string                       Domain { get; set; }
                    public virtual string                     Username { get; set; }
                    public virtual string                       UserId { get; set; }
                    public virtual string                      GroupId { get; set; }
                    public Context() { }
                }

                namespace Certificate
                {
                    [Serializable]
                    public enum EntryType
                    {
                        Store       = 0,
                        Certificate = 1,
                    }

                    [Serializable]
                    public enum StoreLocation
                    {
                        System      = 0,
                        User        = 1,
                        App         = 2,
                        Unspecified = 3,
                    }

                    [Serializable]
                    public class Entry
                    {
                        public virtual uint                   Index { get; set; }
                        public virtual EntryType               Type { get; set; }
                        public virtual string                  Name { get; set; }
                        public virtual string              Fullname { get; set; }
                        public virtual string               Symlink { get; set; }
                        public virtual bool                  Exists { get; set; }
                        public virtual string             StoreName { get; set; }
                        public virtual X509Certificate2 Certificate { get; set; }
                        public virtual StoreLocation  StoreLocation { get; set; }
                        public virtual string            Thumbprint { get; set; }
                        public virtual string               Subject { get; set; }
                        public virtual string                Issuer { get; set; }
                        public virtual Format.ModDateTime NotBefore { get; set; }
                        public virtual Format.ModDateTime  NotAfter { get; set; }
                        public virtual bool           HasPrivateKey { get; set; }
                        public Entry() { }
                    }

                    [Serializable]
                    public class Store
                    {
                        public uint              Index { get; set; }
                        public string      DisplayName { get; set; }
                        public StoreLocation  Location { get; set; }
                        public string             Name { get; set; }
                        public string         Fullname { get; set; }
                        public bool             Exists { get; set; }
                        public List<Entry> Certificate { get; set; } = new();
                        public Store() { }
                    }
                }

                [Serializable]
                public class Credential
                {
                    public string                       Username { get; set; }
                    public System.Security.SecureString Password { get; set; }
                    public Credential() { }
                    public Credential(System.Management.Automation.PSCredential credential)
                    {
                        Username = credential.UserName;
                        Password = credential.Password;
                    }
                    public Credential(string username, System.Security.SecureString password)
                    {
                        Username = username;
                        Password = password;
                    }
                    public System.Management.Automation.PSCredential ToPsCredential()
                    {
                        return new System.Management.Automation.PSCredential(Username, Password);
                    }
                    public override string ToString() => $"Username: {Username}, Password: {Password}";
                }

                [Serializable]
                public class Provider
                {
                    public Identifier?                  Domain { get; set; }
                    public List<Certificate.Store>       Store { get; set; } = new();
                    public Context?                    Context { get; set; }
                    public Credential?              Credential { get; set; }
                    public List<Reference>           Reference { get; set; } = new();
                    public List<Account>               Account { get; set; } = new();
                    public Provider() { }
                }
            }

            // Registry/Binary configuration for reconstitution + persistence across platforms
            namespace Configuration
            {
                [Serializable]
                public enum Type
                {
                    Registry   = 0,
                    FileSystem = 1,    
                }

                // Individual property for the FEModule configuration
                [Serializable]
                public class Property
                {
                    public uint   Index { get; set; }
                    public string  Name { get; set; }
                    public object Value { get; set; }
                    public Property() { }
                    public Property(uint index, string name, string value)
                    {
                        Index = index;
                        Name  = name;
                        Value = value;
                    }
                }

                // Provider class meant to orchestrate specific Windows registry paths or Linux configuration path
                [Serializable]
                public class Provider
                {
                    public Type               Type { get; set; }
                    public string            Drive { get; set; }
                    public string             Name { get; set; }
                    public string         Fullname { get; set; }
                    public bool             Exists { get; set; } = false;
                    public string             Root { get; set; }
                    public string             Path { get; set; }
                    public string           Branch { get; set; }
                    public Format.ByteSize    Size { get; set; }
                    public List<Property> Property { get; set; } = new();
                    public Provider() { }
                }
            }

            // All custom filesystem primitive extensions
            namespace FileSystem
            {
                // Entry type
                [Serializable]
                public enum Type
                {
                    Directory = 0,
                    File      = 1,
                }

                // Directory.Options mode
                [Serializable]
                public enum Mode : uint
                {
                    Directory = 0,
                    File      = 1,
                    All       = 2,
                }

                // Used for raw file system enumeration via P/Invoke
                [Serializable]
                public class Raw
                {
                    public string       Name { get; set; }
                    public string   Fullname { get; set; }
                    public string  Extension { get; set; }
                    public bool  IsDirectory { get; set; }
                    public bool    IsReparse { get; set; }
                    public ulong        Size { get; set; }
                    public DateTime  Created { get; set; }
                    public DateTime Modified { get; set; }
                    public Raw() { }
                }

                // Handles subdirectories and files within a directory controller
                [Serializable]
                public class Entry
                {
                    public uint                   Index { get; set; }
                    public Type                    Type { get; set; }
                    public string                 Label { get; set; }
                    public Format.ModDateTime?  Created { get; set; }
                    public Format.ModDateTime? Modified { get; set; }
                    public string                  Name { get; set; }
                    public Format.ByteSize         Size { get; set; }
                    public string             Extension { get; set; }
                    public string           DisplayName { get; set; }
                    public string             Reference { get; set; }
                    public string              Fullname { get; set; }
                    public bool                  Exists { get; set; }
                    public byte[]                 Bytes { get; set; }
                    public Entry() { }
                    public void SetLabel(string label)
                    {
                        Label = label;
                    }
                }

                // Flags for the directory controller
                [Serializable]
                public class Option
                {
                    public Mode     Mode { get; set; }
                    public bool  Recurse { get; set; }
                    public string Filter { get; set; }
                    public Option() { }
                }

                // Controls all of the above classes, subdirectories do not use this
                [Serializable]
                public class Directory
                {
                    public uint                    Index { get; set; }
                    public Type                     Type { get; set; }
                    public string                  Label { get; set; }
                    public Format.ModDateTime?   Created { get; set; }
                    public Format.ModDateTime?  Modified { get; set; }
                    public string                   Name { get; set; }
                    public bool                   Exists { get; set; }
                    public Format.ByteSize          Size { get; set; }
                    public string               Fullname { get; set; }
                    public Option                 Option { get; set; } = new();
                    public List<Entry>             Entry { get; set; } = new();
                    public Directory() { }
                    public void SetLabel(string label) => Label = label;
                }

                [Serializable]
                public class Resource : Directory
                {
                    // Share + isShare
                    // Permissions (Accounts + SIDs)
                    // ACL (similar?)
                }

                // Manages all things related to file system
                public class Provider
                {
                    public string           Location { get; set; }
                    public List<Directory>  Resource { get; set; } = new();
                    public Provider() { }
                }
            }

            // Machine specific, but also logical classes
            namespace Logical
            {
                [Serializable]
                public enum Affiliation
                {
                    Workgroup = 0,
                    Domain    = 1,
                }

                // Information about the computer system
                [Serializable]
                public class Computer
                {
                    public string             Name { get; set; }
                    public string      DisplayName { get; set; }
                    public Affiliation Affiliation { get; set; }
                    public string          NetBios { get; set; }
                    public string           Domain { get; set; }
                    public string        Workgroup { get; set; }
                    public string    UserDnsDomain { get; set; }
                    public Computer() { }
                }

                // Information about the bios
                [Serializable]
                public class Bios
                {
                    public string            Name { get; set; }
                    public string    Manufacturer { get; set; }
                    public string    SerialNumber { get; set; }
                    public string         Version { get; set; }
                    public string     ReleaseDate { get; set; }
                    public bool     SmBiosPresent { get; set; }
                    public string   SmBiosVersion { get; set; }
                    public string     SmBiosMajor { get; set; }
                    public string     SmBiosMinor { get; set; }
                    public string SystemBiosMajor { get; set; }
                    public string SystemBiosMinor { get; set; }
                    public Bios() { }
                }

                // Information about the operating system
                [Serializable]
                public class OperatingSystem
                {
                    public string Caption  { get; set; }
                    public string Version  { get; set; }
                    public string   Build  { get; set; }
                    public string  Serial  { get; set; }
                    public uint  Language  { get; set; }
                    public uint   Product  { get; set; }
                    public uint      Type  { get; set; }
                    public OperatingSystem() { }
                }
    
                // Specific information about the computer's make/model/manufacturer/chassis/hardware types
                [Serializable]
                public class ComputerSystem
                {
                    public string    Manufacturer { get; set; }
                    public string           Model { get; set; }
                    public string         Product { get; set; }
                    public string          Serial { get; set; }
                    public Format.ByteSize Memory { get; set; }
                    public string    Architecture { get; set; }
                    public string            UUID { get; set; }
                    public string         Chassis { get; set; }
                    public string        BiosUefi { get; set; }
                    public string        AssetTag { get; set; }
                    public ComputerSystem() { }
                }

                // Represents a partition on any volume
                [Serializable]
                public class Partition
                {
                    public uint                       Index { get; set; }
                    public uint                        Disk { get; set; }
                    public Hardware.Disk.PartitionType Type { get; set; }
                    public string                      Name { get; set; }
                    public Format.ByteSize             Size { get; set; }
                    public bool                        Boot { get; set; }
                    public bool                     Primary { get; set; }
                    public Partition() { }
                }
        
                // Partitions contain volumes
                [Serializable]
                public class Volume
                {
                    public uint            Disk { get; set; }
                    public uint       Partition { get; set; }
                    public string         Label { get; set; }
                    public string       DriveID { get; set; }
                    public string   Description { get; set; }
                    public string    Filesystem { get; set; }
                    public string    VolumeName { get; set; }
                    public string  VolumeSerial { get; set; }
                    public Format.ByteSize Size { get; set; }
                    public Format.ByteSize Used { get; set; }
                    public Format.ByteSize Free { get; set; }
                    public Volume() { }
                }
            }

            // Hardware specific, may expand later
            namespace Hardware
            {
                [Serializable]
                public enum DeviceType
                {
                    Unspecified,
                    Processor,
                    Memory,
                    Storage,
                    Network,
                    Video,
                    Audio,
                    Input,
                    USB
                }

                [Serializable]
                public class Device
                {
                    public uint        Index { get; set; }
                    public DeviceType   Type { get; set; }
                    public string       Name { get; set; }
                    public string     Vendor { get; set; }
                    public string   DeviceId { get; set; }
                    public string HardwareId { get; set; }
                    public bool      Enabled { get; set; }
                    public Device() { }
                }

                [Serializable]
                public class Vendor
                {
                    public uint  Index { get; set; }
                    public string  Hex { get; set; }
                    public string Name { get; set; }
                    public Vendor() {}
                }

                // Represents a CPU/processor
                [Serializable]
                public class Processor
                {
                    public uint           Rank { get; set; }
                    public string Manufacturer { get; set; }
                    public string         Name { get; set; }
                    public string      Caption { get; set; }
                    public uint          Cores { get; set; }
                    public uint           Used { get; set; }
                    public uint        Logical { get; set; }
                    public uint        Threads { get; set; }
                    public string  ProcessorId { get; set; }
                    public string     DeviceId { get; set; }
                    public uint          Speed { get; set; }
                    public Processor() { }
                }

                namespace Disk
                {
                    [Serializable]
                    public enum PartitionStyle
                    {
                        Unspecified = 0,
                        GPT         = 1,
                        MBR         = 2,    
                    }

                    [Serializable]
                    public enum PartitionType
                    {
                        Unspecified = 0,
                        Primary     = 1,
                        Extended    = 2,
                        Logical     = 3,
                    }

                    [Serializable]
                    public enum OperationalStatus
                    {
                        Unspecified = 0,
                        Online      = 1,
                        ReadOnly    = 2,
                        Mounted     = 3,
                    }

                    // Represents a physical disk + partitions + volumes
                    [Serializable]
                    public class Entry
                    {
                        public uint                           Rank { get; set; }
                        public uint                          Index { get; set; }
                        public string                     DeviceId { get; set; }
                        public string                       Vendor { get; set; }
                        public string                        Model { get; set; }
                        public Format.ByteSize                Size { get; set; }
                        public string                       Serial { get; set; }
                        public string                     UniqueId { get; set; }
                        public string                     Location { get; set; }
                        public PartitionStyle       PartitionStyle { get; set; } = PartitionStyle.Unspecified;
                        public OperationalStatus OperationalStatus { get; set; } = OperationalStatus.Unspecified;
                        // public string          ProvisioningType { get; set; }
                        // public string              HealthStatus { get; set; }
                        public string                      BusType { get; set; }
                        public List<Logical.Partition>   Partition { get; set; } = new();
                        public List<Logical.Volume>         Volume { get; set; } = new();
                        public Entry() { }
                    }
                }

                [Serializable]
                public enum NetworkAdapterType
                {
                    Unspecified = 0,
                    Ethernet    = 1,
                    Wireless    = 2,
                    Bluetooth   = 3,
                    Loopback    = 4,
                    Tunnel      = 5,
                    Wan         = 6,
                    Virtual     = 7,
                    Bridge      = 8,
                }

                // Represents a physical network adapter and its' configuration
                [Serializable]
                public class NetworkAdapter
                {
                    public uint                           Rank { get; set; }
                    public string                         Name { get; set; }
                    public uint                 InterfaceIndex { get; set; }
                    public NetworkAdapterType      AdapterType { get; set; }
                    public string                 Manufacturer { get; set; }
                    public Network.MacAddress.Entry MacAddress { get; set; }
                    public string                  ServiceName { get; set; }
                    public string                     DeviceId { get; set; }
                    public string                  PnpDeviceId { get; set; }
                    public Format.ByteSize               Speed { get; set; }
                    public NetworkAdapter() { }
                }

                [Serializable]
                public class Provider
                {
                    public List<Vendor>          Vendor { get; set; } = new();
                    public List<Device>          Device { get; set; } = new();
                    public List<Processor>    Processor { get; set; } = new();
                    public List<Disk.Entry>        Disk { get; set; } = new();
                    public List<NetworkAdapter> Network { get; set; } = new();
                    public Provider() { }
                }
            }
            
            // Network specific, may expand later
            namespace Network
            {
                // todo: 1) (Nbtstat..?), 2) Arp, 3) Whois, 4) Port definitions

                // Network protocols will typically be IPv4 or IPv6
                public enum Protocol
                {
                    Unknown = 0,
                    IPv4    = 4,
                    IPv6    = 6,
                    IPX     = 7
                }

                namespace MacAddress
                {
                    [Serializable]
                    public enum Type
                    {
                        Plain       = 0,
                        Hypen       = 1,
                        Period      = 2,
                        Colon       = 3,
                        Unspecified = 4,
                    }

                    [Serializable]
                    public class Entry
                    {
                        public Type    Type { get; set; }
                        public string Value { get; set; }
                        public Entry() {}
                    }
                }

                namespace IpAddress
                {
                    [Serializable]
                    public enum Type
                    {
                        Unspecified = 0,
                        IPv4        = 1,
                        IPv6        = 2,
                        IPX         = 3,
                    }

                    [Serializable]
                    public enum IPv4Class
                    {
                        Unspecified = 0,
                        A           = 1,
                        B           = 2,
                        C           = 3,
                        Local       = 4,
                        APIPA       = 5,
                        Multicast   = 6,
                        Reserved    = 7,
                        Broadcast   = 8,
                    }

                    [Serializable]
                    public class Option
                    {
                        public IPv4Class? IPv4Class { get; set; }
                        public bool   IPv4Multicast { get; set; }
                        public bool   IPv4Broadcast { get; set; }
                        public long?    IPv6ScopeId { get; set; }
                        public bool   IPv6Multicast { get; set; }
                        public bool   IPv6LinkLocal { get; set; }
                        public bool   IPv6SiteLocal { get; set; }
                        public bool      IPv6Teredo { get; set; }
                        public Option() { }
                    }

                    [Serializable]
                    public class Entry
                    {
                        public Type     Type { get; set; }
                        public string  Value { get; set; }
                        public Option Option { get; set; } = new();
                        public Entry() { }
                    }
                }

                namespace Route
                {
                    [Serializable]
                    public enum Type
                    {
                        Unknown   = 0,
                        Local     = 1,
                        Connected = 2,
                        Static    = 3,
                        Dynamic   = 4,
                        Multicast = 5,
                        Broadcast = 6,
                    }

                    [Serializable]
                    public enum State
                    {
                        Unspecified = 0,
                        Alive       = 1,
                        Dormant     = 2,
                        Invalid     = 3,
                    }

                    [Serializable]
                    public class Entry
                    {
                        public uint              Index { get; set; }
                        public Protocol       Protocol { get; set; }
                        public Type               Type { get; set; }
                        public State             State { get; set; }
                        public uint     InterfaceIndex { get; set; }
                        public string   InterfaceAlias { get; set; }
                        public IpAddress.Entry  Target { get; set; }
                        public uint             Prefix { get; set; }
                        public IpAddress.Entry NextHop { get; set; }
                        public uint             Metric { get; set; }
                        public bool            Publish { get; set; }
                        public Entry() { }
                    }
                }

                namespace Firewall
                {
                    [Serializable]
                    public enum Direction
                    {
                        Unspecified = 0,
                        Inbound     = 1,
                        Outbound    = 2,
                    }

                    [Serializable]
                    public enum Action
                    {
                        Unspecified = 0,
                        Allow       = 1,
                        Block       = 2,
                    }

                    [Serializable]
                    public enum State
                    {
                        Unspecified = 0,
                        Disabled    = 1,
                        Enabled     = 2,
                    }

                    [Serializable]
                    public class Entry
                    {
                        public uint                    Index { get; set; }
                        public string                   Name { get; set; }
                        public string            DisplayName { get; set; }
                        public string                  Group { get; set; }
                        public Direction           Direction { get; set; }
                        public Action                 Action { get; set; }
                        public State                   State { get; set; }
                        public List<Protocol>       Protocol { get; set; }
                        public List<uint>               Port { get; set; }
                        public List<IpAddress.Entry> Address { get; set; }
                        public Entry() { }
                    }
                }

                namespace Netstat
                {
                    [Serializable]
                    public enum Type
                    {
                        Unspecified = 0,
                        Tcp         = 1,
                        Tcp6        = 2,
                        Udp         = 3,
                        Udp6        = 4,
                        Unknown     = 5,
                    }

                    [Serializable]
                    public enum State
                    {
                        Unspecified = 0,
                        Listen      = 1,
                        Established = 2,
                        SynSent     = 3,
                        SynReceived = 4,
                        FinWait1    = 5,
                        FinWait2    = 6,
                        CloseWait   = 7,
                        Closing     = 8,
                        Closed      = 9,
                        LastAck     = 10,
                        TimeWait    = 11,
                        Bound       = 12,
                        Connected   = 13,
                        Unconnected = 14,
                        Unknown     = 15,
                    }

                    [Serializable]
                    public class Host
                    {
                        public string Hostname { get; set; }
                        public string  Address { get; set; }
                        public string     Port { get; set; }
                        public bool       IPv4 { get; set; }
                        public bool       IPv6 { get; set; }
                        public Host() { }
                    }

                    [Serializable]
                    public class Entry
                    {
                        public Type  Protocol { get; set; }
                        public Host     Local { get; set; }
                        public Host    Remote { get; set; }
                        public State    State { get; set; }
                        public Entry() { }
                    }
                }

                [Serializable]
                public class Hierarchy
                {
                    public string  Domain { get; set; }
                    public string NetBios { get; set; }
                    public Hierarchy() {}
                }

                // This represents a Dynamic Host Control Protocol "seed", which bootstraps a particular Dhcp (server/client)
                [Serializable]
                public class Dhcp
                {
                    public string                     Name { get; set; }
                    public IpAddress.Entry      SubnetMask { get; set; }
                    public IpAddress.Entry         Network { get; set; }
                    public IpAddress.Entry      StartRange { get; set; }
                    public IpAddress.Entry        EndRange { get; set; }
                    public IpAddress.Entry       Broadcast { get; set; }
                    public List<IpAddress.Entry> Exclusion { get; set; }
                    public Dhcp() {}
                }
            
                [Serializable]
                public class Node
                {
                    public uint                Index { get; set; }
                    public string             Switch { get; set; }
                    public IpAddress.Entry IpAddress { get; set; }
                    public string             Domain { get; set; }
                    public string            NetBios { get; set; }
                    public IpAddress.Entry   Trusted { get; set; }
                    public uint               Prefix { get; set; }
                    public IpAddress.Entry   Netmask { get; set; }
                    public IpAddress.Entry   Gateway { get; set; }
                    public List<IpAddress.Entry> Dns { get; set; }
                    public Dhcp                 Dhcp { get; set; }
                    public uint             Transmit { get; set; }
                    public Node() {}
                }
            
                // Network adapters will have an interface, and that interface will hold configurations
                [Serializable]
                public class Interface
                {
                    public uint                        Index { get; set; }
                    public string                Description { get; set; }
                    public string                ServiceName { get; set; }
                    public MacAddress.Entry       MacAddress { get; set; }
                    public List<Configuration> Configuration { get; set; } = new();
                    public Interface() { }
                }
    
                // Network adapter interfaces with (a) valid configuration(s) will be represented here, supports multiple addresses
                [Serializable]
                public class Configuration
                {
                    public Protocol                Protocol { get; set; }
                    public IpAddress.Entry          Address { get; set; }
                    public IpAddress.Entry?      SubnetMask { get; set; }
                    public IpAddress.Entry          Gateway { get; set; }
                    public bool                 DhcpEnabled { get; set; }
                    public string                DhcpServer { get; set; }
                    public List<IpAddress.Entry> DnsServers { get; set; }
                    public Configuration() { }
                }

                // This represents both a local host, or a remote host, and can be used to perform a variety of tasks (mostly ping sweep)
                [Serializable]
                public class Host
                {
                    public string               Source { get; set; }
                    public string          Destination { get; set; }
                    public string             Hostname { get; set; }
                    public IpAddress.Entry IPv4Address { get; set; }
                    public IpAddress.Entry IPv6Address { get; set; }
                    public uint                  Bytes { get; set; }
                    public uint                   Time { get; set; }
                    public bool              Connected { get; set; }
                    public Host() { }
                }
                
                // This is a network template object, used for persistence in node configurations
                [Serializable]
                public class Template
                {
                    public uint       Index { get; set; }
                    public string    Switch { get; set; }
                    public string IpAddress { get; set; }
                    public string    Domain { get; set; }
                    public string   NetBios { get; set; }
                    public string   Trusted { get; set; }
                    public string    Prefix { get; set; }
                    public string   Netmask { get; set; }
                    public string   Gateway { get; set; }
                    public string[]     Dns { get; set; }
                    public object      Dhcp { get; set; }
                    public uint    Transmit { get; set; }
                    public Template() { }
                }

                [Serializable]
                public class Provider
                {
                    public Hierarchy?              Hierarchy { get; set; }
                    public Dhcp?                        Dhcp { get; set; }
                    public Node?                        Node { get; set; }
                    public List<Interface>         Interface { get; set; } = new();
                    public List<Route.Entry>           Route { get; set; } = new();
                    public List<Netstat.Entry>       Netstat { get; set; } = new();
                    // public Nbt      => Mostly for Windows/ADDS
                    // public Arp      => look at local networks for adjacent hosts
                    // public Whois    => resolve ip address to domain and location
                    // public Port     => port definitions
                    public List<Firewall.Entry>     Firewall { get; set; } = new();
                    public List<IpAddress.Entry>          Ip { get; set; } = new();
                    public Provider() { }
                }
            }

            // Manages threads and runspacing
            namespace Thread
            {
                [Serializable]
                public enum State : uint
                {
                    Created   = 0,
                    Started   = 1,
                    Running   = 2,
                    Completed = 3,
                    Faulted   = 4
                }   

                [Serializable]
                public enum IntensityLevel : uint
                {
                    Low    = 0,  // Minimal CPU usage, conservative thread count
                    Medium = 1,  // Balanced throughput
                    High   = 2   // Maximum throughput, highest CPU usage
                }

                [Serializable]
                public class IntensitySlot
                {
                    public uint           Index { get; set; }
                    public IntensityLevel Level { get; set; }
                    public string          Name { get; set; }
                    public string   Description { get; set; }
                    public bool        Selected { get; set; }
                    public IntensitySlot() { }
                }

                [Serializable]
                public class Status
                {
                    public string                      Key { get; set; }
                    public string                     Name { get; set; }
                    public int                     Current { get; set; }
                    public int                       Total { get; set; }
                    public string                  Message { get; set; }
                    public Format.ModDateTime?    StartUtc { get; set; }
                    public Format.ModDateTime? LastUpdated { get; set; }
                    public Format.ModDateTime? LastChanged { get; set; }
                    public bool                 IsComplete { get; set; }
                    public bool                  IsStalled { get; set; }
                    public Status() { }
                }

                [Serializable]
                public class Instance
                {
                    public int                       Index { get; set; }
                    public string                     Name { get; set; }
                    public int                          Id { get; set; }
                    public Format.ModDateTime      Started { get; set; }
                    public Format.ModDateTime   LastReport { get; set; }
                    public Format.ModDateTime   NextReport { get; set; }
                    public Format.ModDateTime?   Completed { get; set; }
                    public State                    Status { get; set; }
                    public bool                  IsStarted { get; set; }
                    public bool                  IsRunning { get; set; }
                    public bool                 IsComplete { get; set; }
                    public bool                HasDuration { get; set; }
                    public Instance() { }
                }

                namespace SessionState
                {
                    [Serializable]
                    public enum Source : uint
                    {
                        Assembly = 0,
                        Function = 1,
                        Variable = 2,
                        Script   = 3
                    }

                    [Serializable]
                    public enum Phase : uint
                    {
                        Assigned  = 0,
                        Initial   = 1,
                        Bootstrap = 2,
                        Worker    = 3
                    }

                    [Serializable]
                    public class Entry
                    {
                        public int           Index { get; set; }
                        public Source       Source { get; set; }
                        public Phase         Phase { get; set; }
                        public string         Name { get; set; }
                        public string  Description { get; set; }
                        public byte[]        Bytes { get; set; }
                        public bool         Locked { get; private set; }
                        public Entry() { }
                    }
                }

                [Serializable]
                public enum ProviderState : uint
                {
                    Idle      = 0,
                    Running   = 1,
                    Resetting = 2,
                    Faulted   = 3
                }

                public class Provider
                {
                    public ConcurrentQueue<string>               Queue { get; set; }
                    public ConcurrentBag<object>                   Bag { get; set; }
                    public ConcurrentQueue<string>            Messages { get; set; }
                    public ConcurrentDictionary<int, Instance> Threads { get; set; }
                    public RunspacePool                           Pool { get; set; }
                    public List<IntensitySlot>               Intensity { get; set; }
                    // private PerformanceCounter              cpuCounter { get; set; }
                    public List<IAsyncResult>                     Jobs { get; set; } = new();
                    public int                              MaxThreads { get; set; }
                    public DateTime                          StartTime { get; set; }
                    public DateTime                        LastBeatUtc { get; set; }
                    public int                              TotalItems { get; set; }
                    // public StatusBank                       StatusBank { get; set; }
                    public ProviderState                         State { get; set; }
                    public List<SessionState.Entry>       SessionState { get; private set; } = new();
                    public Provider() { }
                }
            }

            // PowerShell class extensions
            namespace PowerShell
            {
                namespace Drive
                {
                    [Serializable]
                    public enum Slot
                    {
                        PSDrive  = 0,
                        Template = 1
                    }
                    
                    [Serializable]
                    public enum Mode
                    {
                        FileSystem  = 0,
                        Registry    = 1,
                        Environment = 2,
                        Certificate = 3,
                        Variable    = 4,
                        Function    = 5,
                        Alias       = 6,
                        WSMan       = 7,
                        Custom      = 8,
                        Unspecified = 9
                    }

                    [Serializable]
                    public enum Scope
                    {
                        Global      = 0,
                        Local       = 1,
                        Script      = 2,
                        Private     = 3,
                        Unspecified = 4,
                    }

                    [Serializable]
                    public class Provider
                    {
                        public string        Name { get; set; }
                        public Mode          Mode { get; set; }
                        public string Description { get; set; }
                        public bool       Default { get; internal set; }
                        public bool       Virtual { get; set; }
                        public Provider() { }
                    }

                    [Serializable]
                    public class Entry
                    {
                        public uint                     Index { get; set; }
                        public Slot                      Slot { get; set; }
                        public Mode                      Mode { get; set; }
                        public Scope                    Scope { get; set; }
                        public string                    Name { get; set; }
                        public Provider              Provider { get; set; }
                        public string                    Root { get; set; }
                        public string             Description { get; set; }
                        public bool                    Exists { get; set; }
                        public Format.ByteSize           Used { get; set; }
                        public Format.ByteSize           Free { get; set; }
                        public bool                   Default { get; internal set; }
                        public bool                   Virtual { get; set; }
                        public bool               AutoMounted { get; set; }
                        public bool              NetworkDrive { get; set; }
                        public bool                       Unc { get; set; }
                        public bool                    Mapped { get; set; }
                        public Security.Credential Credential { get; set; }
                        public string             DisplayRoot { get; set; }
                        public string         CurrentLocation { get; set; }
                        public Entry() { }
                    }
                }
            }

            // Manages dependency entries as a list
            namespace Dependency
            {
                [Serializable]
                public class Entry : FileSystem.Entry
                {
                    public Entry() { }
                    public Entry(uint index, string name)
                    {
                        Index = index;
                        Name  = name;
                    }
                    public Entry(uint index, string name, string fullname) : this(index, name)
                    {
                        Assign(fullname);
                    }
                    public void Assign(string fullname)
                    {
                        Fullname = fullname;
                        Check();

                        if (Exists)
                        {
                            System.IO.FileInfo fi = new System.IO.FileInfo(Fullname);

                            Type      = Core.Platform.FileSystem.Type.File;
                            Created   = new Format.ModDateTime(fi.CreationTime);
                            Modified  = new Format.ModDateTime(fi.LastWriteTime);

                            Extension = System.IO.Path.GetExtension(Fullname).TrimStart('.');
                            Size      = new Format.ByteSize(Type.ToString(), (ulong)fi.Length);
                        }
                    }
                    public void Check()
                    {
                        Exists = System.IO.File.Exists(Fullname) || System.IO.Directory.Exists(Fullname);
                    }
                }

                [Serializable]
                public class List
                {
                    public string       Name { get; set; }
                    public List<Entry> Entry { get; set; } = new();
                    public List() { }
                    public List(string name)
                    {
                        Name  = name;
                    }
                    public void Clear()
                    {
                        Entry.Clear();
                    }
                    public void Add(string name)
                    {
                        Entry.Add(new Entry((uint)Entry.Count, name));
                    }
                    public void Add(string name, string fullname)
                    {
                        Entry.Add(new Entry((uint)Entry.Count, name, fullname));
                    }
                    public Entry Get(string name)
                    {
                        return Entry.FirstOrDefault(e => e.Name == name);
                    }
                }
            }

            // For transferring files from one location to another (to be extended)
            namespace Transfer
            {
                namespace Operation
                {
                    [Serializable]
                    public enum State
                    {
                        Unspecified,
                        Created,
                        Building,
                        Ready,
                        Running,
                        Paused,
                        Completed,
                        Failed,
                        Cancelled,
                    }

                    [Serializable]
                    public enum Mode
                    {
                        Unspecified = 0,
                        Fs_Fs       = 1,
                        Fs_Nw       = 2,
                        Nw_Fs       = 3,
                        Nw_Nw       = 4,
                    }

                    [Serializable]
                    public enum Protocol
                    {
                        Unspecified,
                        Local,
                        Http,
                        Https,
                        Ftp,
                        Sftp,
                        Tcp,
                        Udp,
                        Smb,
                    }
                }

                namespace Node
                {
                    [Serializable]
                    public enum Mode
                    {
                        Unspecified = 0,
                        FileSystem  = 1,
                        Remote      = 2,
                        Memory      = 3,
                    }

                    [Serializable]
                    public class Entry
                    {
                        public Mode            Mode { get; set; } = Mode.Unspecified;
                        public string      Resource { get; set; }
                        public string          Name { get; set; } = null;
                        public string      Fullname { get; set; } = null;
                        public bool          Exists { get; set; } = false;
                        public bool     IsDirectory { get; set; } = false;
                        public ulong         Length { get; set; } = 0;
                        public List<byte>     Bytes { get; set; } = new();
                        public Entry() { }
                        public Entry(Mode mode)
                        {
                            Mode = mode;
                        }
                    }

                    [Serializable]
                    public class FileSystem : Entry
                    {
                        public Format.ModDateTime?  Created { get; set; }
                        public Format.ModDateTime? Modified { get; set; }
                        public Format.ModDateTime? Accessed { get; set; }
                        public FileSystem() : base (Mode.FileSystem) { }
                    }

                    [Serializable]
                    public class Remote : Entry
                    {
                        public Operation.Protocol Protocol { get; set; }
                        public string?                Host { get; set; } = null;
                        public uint?                  Port { get; set; } = null;
                        public string?                Path { get; set; } = null;
                        public string?               Query { get; set; } = null;
                        public string?         ContentType { get; set; } = null;
                        public int?             StatusCode { get; set; } = null;
                        public Remote() : base (Mode.Remote) { }
                    }

                    [Serializable]
                    public class Memory : Entry
                    {
                        public string?    Format { get; set; } = null;
                        public bool   Compressed { get; set; } = false;
                        public bool   Serialized { get; set; } = false;
                        public string?  Checksum { get; set; } = null;
                        public Memory() : base (Mode.Memory) { }
                    }
                }

                namespace Endpoint
                {
                    [Serializable]
                    public class Entry : Node.Entry
                    {
                        public Entry() { }
                    }

                    [Serializable]
                    public class FileSystem : Node.FileSystem
                    {
                        public FileSystem() { }
                    }

                    [Serializable]
                    public class Remote : Node.Remote
                    {
                        public Remote() { }
                    }

                    [Serializable]
                    public class Memory : Node.Memory
                    {
                        public Memory() { }
                    }
                }

                namespace Harness
                {
                    [Serializable]
                    public enum Type
                    {
                        Unspecified = 0,
                        Source      = 1,
                        Target      = 2,    
                    }

                    [Serializable]
                    public class Entry : Node.Entry
                    {
                        public Type Type { get; set; } = Type.Unspecified;
                        public Entry() { }
                        public Entry(Type type)
                        {
                            Type = type;
                        }
                    }
                    
                    [Serializable]
                    public class FileSystem : Node.FileSystem
                    {
                        public Type Type { get; set; }
                        public FileSystem() { }
                        public FileSystem(Type type)
                        {
                            Type = type;
                        }
                    }

                    [Serializable]
                    public class Remote : Node.Remote
                    {
                        public Type Type { get; set; }
                        public Remote() { }
                        public Remote(Type type)
                        {
                            Type = type;
                        }
                    }

                    [Serializable]
                    public class Memory : Node.Memory
                    {
                        public Type Type { get; set; }
                        public Memory() { }
                        public Memory(Type type)
                        {
                            Type = type;
                        }
                    }
                }

                [Serializable]
                public class Entry
                {
                    public uint                      Index { get; set; }
                    public Endpoint.Entry?          Source { get; set; } = null;
                    public Endpoint.Entry?          Target { get; set; } = null;
                    public Format.Progress.Tracker? Status { get; set; } = null;
                    public Format.ByteSize?         Copied { get; set; } = null;
                    public bool                IsDirectory { get; set; } = false;
                    public ulong                    Length { get; set; } = 0;
                    public bool                   Complete { get; set; } = false;
                    public List<byte>               Buffer { get; set; } = new();
                    public Entry() { }
                }

                [Serializable]
                public class Provider
                {
                    public Operation.Mode             Mode { get; set; } = Operation.Mode.Unspecified;
                    public Operation.State           State { get; set; } = Operation.State.Unspecified;
                    public Operation.Protocol     Protocol { get; set; } = Operation.Protocol.Unspecified;
                    public Guid                         Id { get; set; }
                    public string              DisplayName { get; set; }
                    public string              Description { get; set; }
                    public Harness.Entry            Source { get; set; }
                    public Harness.Entry            Target { get; set; }
                    public List<Entry>               Entry { get; set; } = new();
                    public Format.Progress.Tracker? Status { get; set; }
                    public Format.ByteSize          Copied { get; set; }
                    public Format.ModDateTime?       Start { get; set; }
                    public Format.ModDateTime?         End { get; set; }
                    public TimeSpan?                  Span { get; set; }
                    public bool                   Complete { get; set; }
                    public Provider() { }
                }
            }

            // for transferring scripts to nodes
            namespace Script
            {
                [Serializable]
                public enum Phase
                {
                    Unspecified   = 0,
                    Installation  = 1,
                    Configuration = 2,
                    Validation    = 3,
                    Cleanup       = 4,
                    Complete      = 5,
                }

                [Serializable]
                public class Content : Format.Content
                {
                    public Content() { }
                }

                [Serializable]
                public class Block
                {
                    public uint            Index { get; set; }
                    public Phase           Phase { get; set; }
                    public string           Name { get; set; }
                    public string    DisplayName { get; set; }
                    public List<Content> Content { get; set; } = new();
                    public uint          Timeout { get; set; }
                    public bool         Complete { get; set; }
                    public Block() { }       
                }

                [Serializable]
                public class Controller
                {
                    public Phase        Phase { get; set; } = Phase.Unspecified;
                    public uint?     Selected { get; set; }
                    public List<Block>  Block { get; set; } = new();
                    public Controller() { }
                }
            }
        }

        namespace Transfer
        {
            namespace Endpoint
            {
                public class Entry : Platform.Transfer.Endpoint.Entry
                {
                    public Entry() { }
                    public Entry(Platform.Transfer.Node.Mode mode)
                    {
                        Mode = mode;
                    }
                    public virtual void Clear()
                    {
                        Bytes.Clear();
                    }
                    public override string ToString() => Fullname;
                }

                public sealed class FileSystem : Entry
                {
                    public FileSystem() : base(Platform.Transfer.Node.Mode.FileSystem)
                    {
                        
                    }
                }

                public sealed class Remote : Entry
                {
                    public Remote() : base(Platform.Transfer.Node.Mode.Remote)
                    {
                        
                    }
                }

                public sealed class Memory : Entry
                {
                    public Memory() : base(Platform.Transfer.Node.Mode.Memory)
                    {
                        
                    } 
                }
            }

            namespace Harness
            {
                public abstract class Entry : Platform.Transfer.Harness.Entry
                {
                    public Entry(Platform.Transfer.Harness.Type type, string resource)
                    {
                        Type     = type;
                        Resource = resource;
                    }
                    public abstract void Clear();
                    public abstract void Refresh();
                    public override string ToString() => Fullname;
                }

                public class FileSystem : Entry
                {
                    public Format.ModDateTime?  Created { get; set; }
                    public Format.ModDateTime? Modified { get; set; }
                    public Format.ModDateTime? Accessed { get; set; }
                    public FileSystem(Platform.Transfer.Harness.Type type, string resource) : base(type, resource)
                    {
                        Mode        = Platform.Transfer.Node.Mode.FileSystem;

                        Refresh();
                    }
                    public override void Clear()
                    {
                        Created  = null;
                        Modified = null;
                        Accessed = null;
                    }
                    public override void Refresh()
                    {
                        System.IO.FileSystemInfo info = null;

                        if (System.IO.File.Exists(Resource))
                            info = new System.IO.FileInfo(Resource);
                        else if (System.IO.Directory.Exists(Resource))
                            info = new System.IO.DirectoryInfo(Resource);

                        if (info == null)
                        {
                            Exists      = false;
                            Name        = System.IO.Path.GetFileName(Resource);
                            Fullname    = Resource;
                            IsDirectory = false;
                            Length      = 0;

                            return;
                        }

                        Name        = info.Name;
                        Fullname    = info.FullName;
                        Exists      = info.Exists;
                        IsDirectory = info is System.IO.DirectoryInfo;

                        if (info is System.IO.FileInfo file)
                        {
                            Length   = (ulong)file.Length;
                            Created  = new Format.ModDateTime(file.CreationTime);
                            Modified = new Format.ModDateTime(file.LastWriteTime);
                            Accessed = new Format.ModDateTime(file.LastAccessTime);
                        }

                        else if (info is System.IO.DirectoryInfo dir)
                        {
                            Created  = new Format.ModDateTime(dir.CreationTime);
                            Modified = new Format.ModDateTime(dir.LastWriteTime);
                            Accessed = new Format.ModDateTime(dir.LastAccessTime);
                        }
                    }
                    public override string ToString() => Fullname;
                }

                public class Remote : Entry
                {
                    public Platform.Transfer.Operation.Protocol Protocol { get; set; }
                    public string?                Host { get; set; } = null;
                    public uint?                  Port { get; set; } = null;
                    public string?                Path { get; set; } = null;
                    public string?               Query { get; set; } = null;
                    public string?         ContentType { get; set; } = null;
                    public int?             StatusCode { get; set; } = null;
                    public Remote(Platform.Transfer.Harness.Type type, string resource)  : base(type, resource)
                    {
                        Mode     = Platform.Transfer.Node.Mode.Remote;
                        Protocol = Platform.Transfer.Operation.Protocol.Unspecified;

                        Refresh();
                    }
                    public override void Clear()
                    {
                        Host        = null;
                        Port        = null;
                        Path        = null;
                        Query       = null;
                        ContentType = null;
                        StatusCode  = null;
                    }
                    public override void Refresh()
                    {
                        Clear();

                        Match match;

                        if (Pattern.Expression.Remote.IsMatch(Resource))
                        {
                            match = Pattern.Expression.Remote.Match(Resource);
                            string scheme = match.Groups["scheme"].Value.ToLower();

                            Protocol = scheme switch
                            {
                                "http"  => Platform.Transfer.Operation.Protocol.Http,
                                "https" => Platform.Transfer.Operation.Protocol.Https,
                                "ftp"   => Platform.Transfer.Operation.Protocol.Ftp,
                                "sftp"  => Platform.Transfer.Operation.Protocol.Sftp,
                                "tcp"   => Platform.Transfer.Operation.Protocol.Tcp,
                                "udp"   => Platform.Transfer.Operation.Protocol.Udp,
                                "smb"   => Platform.Transfer.Operation.Protocol.Smb,
                                _       => Platform.Transfer.Operation.Protocol.Unspecified
                            };

                            Host  = match.Groups["host"].Value;
                            Path  = match.Groups["path"].Value;
                            Query = match.Groups["query"].Value;

                            if (UInt32.TryParse(match.Groups["port"].Value, out uint port))
                                Port = port;

                            Name = System.IO.Path.GetFileName(Path);

                            Fullname = Resource;
                        }
                    }
                    public override string ToString() => Fullname;
                }

                public class Memory : Entry
                {
                    public string?    Format { get; set; } = null;
                    public bool   Compressed { get; set; } = false;
                    public bool   Serialized { get; set; } = false;
                    public string?  Checksum { get; set; } = null;
                    public Memory(Platform.Transfer.Harness.Type type, string resource)  : base(type, resource)
                    {
                        Mode = Platform.Transfer.Node.Mode.Memory;

                        Clear();
                    }
                    public override void Refresh() { }
                    public override void Clear()
                    {
                        Format     = null;
                        Compressed = false;
                        Serialized = false;
                        Checksum   = null;
                    }
                }
            }

            public class Entry : Platform.Transfer.Entry // this will be each entry in a list of (0,1,1+ entries)
            {
                // public uint                      Index { get; set; }
                // public Endpoint.Entry?          Source { get; set; } = null;
                // public Endpoint.Entry?          Target { get; set; } = null;
                // public Format.Progress.Tracker? Status { get; set; } = null;
                // public Format.ByteSize?         Copied { get; set; } = null;
                // public bool                IsDirectory { get; set; } = false;
                // public ulong                    Length { get; set; } = 0;
                // public bool                   Complete { get; set; } = false;
                // public List<byte>               Buffer { get; set; } = new();
                public Entry() { }
                public void Clear()
                {
                    Source      = null;
                    Target      = null;
                    Status      = null;
                    Copied      = null;
             
                    bool   isdir = false;
                    ulong length = 0;
             
                    Initialize(isdir, length);
                }
                public void Initialize(bool isdirectory, ulong length)
                {
                    IsDirectory  = isdirectory;
                    Length       = length;
                
                    Copied       = new Format.ByteSize("Copied", Length);
                    Complete     = false;
                    Buffer.Clear();

                    string name  = Source.Name != null ? Source.Name : "<null>";
                
                    // Format.Progress.Tracker(OperationType operation, string displayName, int total)
                    Status       = new Format.Progress.Tracker(Format.Progress.OperationType.Transfer, name, (int)Length);
                }
                // public Transfer.Endpoint.Entry CreateEntry(Platform.Transfer.Node.Mode mode, Transfer.Endpoint.Entry entry)
                // {
                //     if (mode == Platform.Transfer.Node.Mode.FileSystem)
                //         return new Transfer.Endpoint.FileSystem(entry);
                //     else if (mode == Platform.Transfer.Node.Mode.Remote)
                //         return new Transfer.Endpoint.Remote(entry);
                //     else
                //         return new Transfer.Endpoint.Memory(entry);
                // }
                // public void SetSource(Transfer.Endpoint.Entry entry)
                // {
                //     Source = CreateEntry(Platform.Transfer.Node.Mode.Source, entry);
                // }
                // public void SetTarget(Transfer.Endpoint.Entry entry)
                // {
                //     Target = CreateEntry(Platform.Transfer.Node.Mode.Target, entry);
                // }
                // public void SetNode(Platform.Transfer.Endpoint endpoint)
                // {
                //     string  dest = fullname;
                //     var     info = GetFileSystemInfo(dest);
                //     bool  exists = info?.Exists ?? false;
                //     ulong length = info is System.IO.FileInfo file ? (ulong)file.Length : 0;
                //  
                //     Target       = new Endpoint(EndpointMode.FileSystem, dest, exists, length);
                //     Status       = new Format.Progress.Tracker(Format.Progress.OperationMode.Transfer, Target.Name, (int)Target.Length);
                // }
                // public void Refresh()
                // {
                //     Refresh(Source);
                //  
                //     if (Target != null)
                //         Refresh(Target);
                // }
                // private void Refresh(Platform.Transfer.Endpoint.Entry endpoint)
                // {
                //     FileSystemInfo info; // Filesystem
                //     // Remote/Network
                //     // Memory/Archive
                //  
                //     if (System.IO.File.Exists(endpoint.Fullname))
                //         info = new System.IO.FileInfo(endpoint.Fullname);
                //     else if (System.IO.Directory.Exists(endpoint.Fullname))
                //         info = new System.IO.DirectoryInfo(endpoint.Fullname);
                //     else
                //         info = null; // need to implement (Remote/Network) and Memory, especially with compression and serialization
                //  
                //     endpoint.Exists = info?.Exists ?? false;
                //     endpoint.Length = info is System.IO.FileInfo file ? (ulong)file.Length : 0;
                // }
                public override string ToString() => $"{Source.Name}";
            }

            public class Provider : Platform.Transfer.Provider // this will be the manager
            {
                // public Operation.Mode             Mode { get; set; }
                // public Operation.State           State { get; set; } = OperationState.Unspecified;
                // public Operation.Protocol     Protocol { get; set; }
                // public Guid                         Id { get; set; }
                // public string              DisplayName { get; set; }
                // public string              Description { get; set; }
                // public Harness.Entry            Source { get; set; }
                // public Harness.Entry            Target { get; set; }
                // public List<Entry>               Entry { get; set; } = new();
                // public Format.Progress.Tracker? Status { get; set; }
                // public Format.ByteSize          Copied { get; set; }
                // public Format.ModDateTime?       Start { get; set; }
                // public Format.ModDateTime?         End { get; set; }
                // public TimeSpan?                  Span { get; set; }
                // public bool                   Complete { get; set; }
                public Provider() { }
                public Provider(string displayname, string description)
                {
                    // start making moves with the operation modes, they're not being used to decide all of this.
                    // Mode        = mode;
                    Id          = Guid.NewGuid();
                    DisplayName = displayname;
                    Description = description;

                    Clear();
                }
                public void Clear()
                {
                    // Clears the list, as well as the various properties so it can be reused if necessary
                    Entry.Clear();

                    Status  = null;
                    Copied  = new Format.ByteSize("Copied", 0);
                    Start   = null;
                    End     = null;
                    Span    = null;

                    MarkCreated();
                }
                public void DetermineMode()
                {
                    Mode = Platform.Transfer.Operation.Mode.Unspecified;

                    if (Source != null && Target != null)
                    {
                        if (Source.Mode == Platform.Transfer.Node.Mode.FileSystem)
                        {
                            if (Target.Mode == Platform.Transfer.Node.Mode.Remote)
                                Mode = Platform.Transfer.Operation.Mode.Fs_Nw;
                            else
                                Mode = Platform.Transfer.Operation.Mode.Fs_Fs;
                        }

                        else if (Source.Mode == Platform.Transfer.Node.Mode.Remote)
                        {
                            if (Target.Mode == Platform.Transfer.Node.Mode.Remote)
                                Mode = Platform.Transfer.Operation.Mode.Nw_Nw;
                            else
                                Mode = Platform.Transfer.Operation.Mode.Nw_Fs;
                        }
                    }
                }
                public void Refresh()
                {
                    // foreach (Transfer.Entry entry in Entry)
                    //     entry.Refresh();
                }
                public void Assign(string source, string target)
                {
                    AssignSource(source);
                    AssignTarget(target);
                }
                public void AssignSource(string source)
                {
                    Source = CreateNode(Platform.Transfer.Harness.Type.Source, source);
                }
                public void AssignTarget(string target)
                {
                    Target = CreateNode(Platform.Transfer.Harness.Type.Target, target);
                }
                public bool IsRemote(string resource)
                {
                    return Pattern.Expression.Remote.IsMatch(resource);
                }
                public bool IsFileSystem(string resource)
                {
                    return Pattern.Expression.FileSystem.IsMatch(resource);
                }
                public Harness.Entry CreateNode(Platform.Transfer.Harness.Type type, string resource)
                {
                    if  (IsFileSystem(resource)) return new Harness.FileSystem(type, resource);
                    else if (IsRemote(resource)) return new Harness.Remote(type, resource);
                    else                         return new Harness.Memory(type, resource);
                }
                public void Execute()
                {
                    MarkStart();

                    // does the operation require network?
                    if (Mode != Platform.Transfer.Operation.Mode.Fs_Fs)
                    {
                        // ensure (hardware + network) managers are working
                        // ensure network connectivity
                        // resolve (source/destination)
                        // some resources may need an API key, (and/or) credentials
                        // transfer (to/from) file system
                    }

                    // is target the filesystem?
                    if (Mode == Platform.Transfer.Operation.Mode.Fs_Fs || Mode == Platform.Transfer.Operation.Mode.Nw_Fs)
                    {
                        // checks if target directory is there and creates it if not
                        if (!System.IO.Directory.Exists(Target.Fullname))
                        {
                            System.Console.WriteLine($"[Create] {Target.Fullname}");

                            System.IO.Directory.CreateDirectory(Target.Fullname);
                        }
                    }

                    // now iterate through the loop
                    foreach (Entry entry in Entry)
                    {
                        // Transfer(entry);
                    }

                    MarkComplete();
                }
                // public void Transfer(Transfer.Entry entry)
                // {
                    // entry.Refresh();
                    // 
                    // if (entry.IsDirectory)
                    // {
                    //     if (!entry.Target.Exists)
                    //     {
                    //         System.Console.WriteLine($"[Create] {entry.Target.Fullname}");
                    // 
                    //         System.IO.Directory.CreateDirectory(entry.Target.Fullname);
                    // 
                    //         entry.Refresh();
                    //     }
                    // 
                    //     entry.Complete = true;
                    // 
                    //     return;
                    // }
                    // 
                    // using FileStream source = new FileStream(entry.Source.Fullname, FileMode.Open, FileAccess.Read);
                    // using FileStream target = new FileStream(entry.Target.Fullname, FileMode.Create, FileAccess.Write);
                    // 
                    // byte[] buffer = new byte[8192];
                    // int      read;
                    // uint progress = 0;
                    // ulong  copied = 0;
                    // 
                    // while ((read = source.Read(buffer, 0, buffer.Length)) > 0)
                    // {
                    //     target.Write(buffer, 0, read);
                    // 
                    //     copied += (ulong)read;
                    // 
                    //     while (progress < entry.Status.Entry.Count && copied >= entry.Status.Entry[(int)progress].Current)
                    //     {
                    //         entry.Copied = new Format.ByteSize("Copied", copied);
                    // 
                    //         System.Console.Write($"\r[{entry.Source.Name}] {entry.Status.Entry[(int)progress]}");
                    //         progress ++;
                    //     }
                    // }
                    // 
                    // entry.Copied = new Format.ByteSize("Copied", copied);
                    // 
                    // System.Console.WriteLine();
                    // 
                    // entry.Refresh();
                    // 
                    // entry.Complete = true;
                // }
                public FileSystemInfo GetFileSystemInfo(string path)
                {
                    if (System.IO.File.Exists(path))
                        return new System.IO.FileInfo(path);

                    if (System.IO.Directory.Exists(path))
                        return new System.IO.DirectoryInfo(path);

                    return null;
                }
                private Format.Progress.Tracker GetTracker(ulong total)
                {
                    var  type = Format.Progress.OperationType.Transfer;
                    int count = (int)Math.Min(total, int.MaxValue);

                    return new Format.Progress.Tracker(type, DisplayName, count);
                }
                public void Populate(Platform.FileSystem.Directory directory)
                {
                    // MarkBuilding();
                    // 
                    // Entry.Clear();
                    // 
                    // ulong total = 0;
                    // 
                    // foreach (var e in directory.Entry)
                    // {
                    //     var    entry   = new Transfer.Entry((uint)Entry.Count, e);
                    //     
                    //     // entry automatically creates an entry with a source assigned, set target will perform the other operation.
                    //     string  dest = e.Fullname.Replace(Source, Target);
                    //     var     info = GetFileSystemInfo(dest);
                    //     bool  exists = info?.Exists ?? false;
                    //     ulong length = info is System.IO.FileInfo file ? (ulong)file.Length : 0;
                    // 
                    //     entry.SetTarget(new Endpoint(EndpointType.FileSystem, dest, exists, length));
                    // 
                    //     if (!entry.IsDirectory) total += entry.Length;
                    // 
                    //     Entry.Add(entry);
                    // }
                    // 
                    // Status = GetTracker(total);
                    // 
                    // MarkReady();
                }
                public void Populate(object[] entry)
                {
                    // handles multiple entries
                }
                public void SetState(Platform.Transfer.Operation.State type)
                {
                    State  = type;
                }
                public void MarkUnspecified()
                {
                    Clear();
                    SetState(Platform.Transfer.Operation.State.Unspecified);
                }
                public void MarkCreated()
                {
                    Start = null;
                    End   = null;

                    SetState(Platform.Transfer.Operation.State.Created);
                }
                public void MarkReady()
                {
                    SetState(Platform.Transfer.Operation.State.Ready);
                }
                public void MarkBuilding()
                {
                    SetState(Platform.Transfer.Operation.State.Building);
                }
                public void MarkStart()
                {
                    Start = Format.ModDateTime.Now();

                    SetState(Platform.Transfer.Operation.State.Running);
                }
                public void MarkComplete()
                {
                    End   = Format.ModDateTime.Now();
                    Span  = End.Value.Value - Start.Value.Value;

                    SetState(Platform.Transfer.Operation.State.Completed);
                }
            }
        }

        namespace Script
        {
            public class Content : Platform.Script.Content
            {
                public Content() { }
                public Content(uint index, string line)
                {
                    Index = index;
                    Line  = line;
                }
                public override string ToString() => Line;
            }

            public class Block : Platform.Script.Block
            {
                public Block() { }
                public Block(uint index, Platform.Script.Phase phase, string name, string displayName, uint timeout, string[] content)
                {
                    Index       = index;
                    Phase       = phase;
                    Name        = name;
                    DisplayName = displayName;
                    Timeout     = timeout;
        
                    Load(content);
                }
                public void Clear()
                {
                    Content.Clear();
                }
                public void Load(string[] content)
                {
                    Clear();
                    Add($"# {DisplayName}");
        
                    foreach (string line in content)
                        Add(line);
        
                    Add("");
                }
                public void Add(string line)
                {
                    Content.Add(new Content((uint)Content.Count, line));
                }
                public override string ToString() => DisplayName;
            }

            public class Controller : Platform.Script.Controller
            {
                public Controller() { }
                public void SetPhase(Platform.Script.Phase phase)
                {
                    Phase = phase;
                }
                public void Clear()
                {
                    Block.Clear();                        
                }
                public void Reset()
                {
                    foreach (Block block in Block)
                        block.Complete = false;
        
                    Selected = 0;
                }
                public void Select(uint index)
                {
                    if (Block.FirstOrDefault(e => e.Index == index) != null) Selected = index;
                }
                public void Add(Platform.Script.Phase phase, string name, string displayName, uint timeout, string[] content)
                {
                    Block.Add(new Block((uint)Block.Count, phase, name, displayName, timeout, content));
                }
                public Platform.Script.Block Current()
                {
                    return Selected != null ? Block[(int)Selected] : null;
                }
                public Platform.Script.Block Get(uint index)
                {
                    return Block.FirstOrDefault(e => e.Index == index);
                }
                public Platform.Script.Block Get(string name)
                {
                    return Block.FirstOrDefault(e => e.Name == name);
                }
                public List<Platform.Script.Block> GetPhase(Platform.Script.Phase phase)
                {
                    return Block.Where(x => x.Phase == phase).ToList();
                }
                public void Run(uint index)
                {

                }
                public void Run(string name)
                {
                        
                }
                public override string ToString() => $"<{base.ToString()}>";
            }
        }

        namespace Logical
        {
            public class Partition : Platform.Logical.Partition
            {
                public Partition() { }
                public Partition(uint index, uint disk, string type, string name, ulong size, bool boot, bool primary)
                {
                    Index   = index;
                    Disk    = disk;
                    Type    = GetPartitionType(type);
                    Name    = name;
                    Size    = new Format.ByteSize("Partition", size);
                    Boot    = boot;
                    Primary = primary;
                }
                public Platform.Hardware.Disk.PartitionType GetPartitionType(string input)
                {
                    return input?.ToLower() switch
                    {
                        "primary"     => Platform.Hardware.Disk.PartitionType.Primary,
                        "extended"    => Platform.Hardware.Disk.PartitionType.Extended,
                        "logical"     => Platform.Hardware.Disk.PartitionType.Logical,
                        _             => Platform.Hardware.Disk.PartitionType.Unspecified,
                    };
                }
                public override string ToString() => Name;
            }

            public class Volume : Platform.Logical.Volume
            {
                public Volume() { }
                public Volume(uint disk, uint part, string label, string id, string desc, string fs, string volname, string volsn, ulong size, ulong used, ulong free)
                {
                    Disk           = disk;
                    Partition      = part;
                    Label          = label;
                    DriveID        = id;
                    Description    = desc;
                    Filesystem     = fs;
                    VolumeName     = volname;
                    VolumeSerial   = volsn;
                    Size           = new Format.ByteSize("Size", size);
                    Used           = new Format.ByteSize("Used", used);
                    Free           = new Format.ByteSize("Free", free);
                }
                public override string ToString() => Label;
            }
        }

        namespace Hardware
        {
            public class Vendor : Platform.Hardware.Vendor
            {
                public Vendor() { }
                public Vendor(uint index, string line)
                {
                    Index = index;
                    
                    string[] slice = line.Split("\t");

                    Hex   = slice[0];
                    Name  = slice[1];
                }
                public override string ToString() => Name;
            }

            public class Device : Platform.Hardware.Device
            {
                public Device() { }
                public Device(uint index, Platform.Hardware.DeviceType type, string name, string vendor, string dev, string hw, bool enabled)
                {
                    Index      = index;
                    Type       = type;
                    Name       = name;
                    Vendor     = vendor;
                    DeviceId   = dev;
                    HardwareId = hw;
                    Enabled    = enabled;
                }
                public override string ToString() => Name;
            }

            public class Disk : Platform.Hardware.Disk.Entry
            {
                public Disk() { }
                public Disk(uint rank, uint index, string dev, string ven, string mod, ulong size, string ser, string part, string ops, string bus, string uid, string loc)
                {
                    Rank              = rank;
                    Index             = index;
                    DeviceId          = dev;
                    Vendor            = ven;
                    Model             = mod;
                    Size              = new Format.ByteSize("Size", size);
                    Serial            = ser;
                    PartitionStyle    = GetPartitionStyle(part);
                    OperationalStatus = GetOperationalStatus(ops);
                    BusType           = bus;
                    UniqueId          = uid;
                    Location          = loc;
                }
                public void AddPartition(uint index, uint disk, string type, string name, ulong size, bool boot, bool primary)
                {
                    Partition.Add(new Logical.Partition(index, disk, type, name, size, boot, primary));
                }
                public void AddVolume(uint disk, uint part, string label, string id, string desc, string fs, string volname, string volsn, ulong size, ulong used, ulong free)
                {
                    Volume.Add(new Logical.Volume(disk, part, label, id, desc, fs, volname, volsn, size, used, free));
                }
                public Platform.Hardware.Disk.PartitionStyle GetPartitionStyle(string input)
                {
                    return input?.ToLower() switch
                    {
                        "gpt"   => Platform.Hardware.Disk.PartitionStyle.GPT,
                        "mbr"   => Platform.Hardware.Disk.PartitionStyle.MBR,
                        "msdos" => Platform.Hardware.Disk.PartitionStyle.MBR,
                        _       => Platform.Hardware.Disk.PartitionStyle.Unspecified,
                    };
                }
                public Platform.Hardware.Disk.PartitionType GetPartitionType(string style, string line)
                {
                    if (!style.Equals("GPT", StringComparison.OrdinalIgnoreCase))
                    {
                        // Future MBR logic goes here
                        return Platform.Hardware.Disk.PartitionType.Unspecified;
                    }

                    return Platform.Hardware.Disk.PartitionType.Primary;
                }
                public Platform.Hardware.Disk.OperationalStatus GetOperationalStatus(string input)
                {
                    return input?.ToLower() switch
                    {
                        "readonly" => Platform.Hardware.Disk.OperationalStatus.ReadOnly,
                        "mounted"  => Platform.Hardware.Disk.OperationalStatus.Mounted,
                        "online"   => Platform.Hardware.Disk.OperationalStatus.Online,
                        _          => Platform.Hardware.Disk.OperationalStatus.Unspecified,
                    };
                }
                public override string ToString() => $"[{Index}] {Model}";
            }

            public class Processor : Platform.Hardware.Processor
            {
                public Processor() { }
                public Processor(uint i, string mfr, string name, string cap, uint core, uint log, uint thr, string id, string dev, uint speed)
                {
                    Rank         = i;
                    Manufacturer = mfr;
                    Name         = name;
                    Caption      = cap;
                    Cores        = core;
                    Logical      = log;
                    Threads      = thr;
                    ProcessorId  = id;
                    DeviceId     = dev;
                    Speed        = speed;
                }
                public override string ToString() => Name;
            }

            public class NetworkAdapter : Platform.Hardware.NetworkAdapter
            {
                public NetworkAdapter() { }
                public NetworkAdapter(uint rank, string name, uint ifindex, string type, string manu, string mac, string service, string dev, string pnp, ulong speed)
                {
                    Rank           = rank;
                    Name           = name;
                    InterfaceIndex = ifindex;
                    
                    SetType(type);

                    Manufacturer   = manu;
                    MacAddress     = new Core.Network.MacAddress(mac);
                    ServiceName    = service;
                    DeviceId       = dev;
                    PnpDeviceId    = pnp;
                    Speed          = new Format.ByteSize("Speed", speed);
                }
                public void SetType(string type)
                {
                    if (Enum.TryParse<Platform.Hardware.NetworkAdapterType>(type, out var result))
                        AdapterType = result;
                }
                public override string ToString() => Name;
            }
        }

        namespace Network
        {
            // Old                         New                       Done
            // ---                         ---                       ----
            // VmNetworkMain               Network.Hierarchy         X
            // VmNetworkDhcp               Network.Dhcp              X
            // VmNetworkNode class         Network.Node              X
            // VmNodeScriptBlockController Script.Controller         X (may move elsewhere)
            // SocketTcpServer                                       - (definitely moving elsewhere, transfer)
            // VmNodeSmbShare                                        - (not sure)

            public class MacAddress : Platform.Network.MacAddress.Entry
            {
                public MacAddress() { }
                public MacAddress(string macaddress)
                {
                    Assign(macaddress.ToUpper());
                }
                public void Assign(string macaddress)
                {
                    if (Regex.IsMatch(macaddress, @"^(?:[\dA-F]{12}|(?:[\dA-F]{2}[:.-]?){5}[\dA-F]{2})$"))
                    {
                        Value = Regex.Replace(macaddress, @"[:.-]", "");

                             if (Regex.IsMatch(macaddress,   "-")) SetType(Platform.Network.MacAddress.Type.Hypen  , "-");
                        else if (Regex.IsMatch(macaddress, @"\.")) SetType(Platform.Network.MacAddress.Type.Period , ".");
                        else if (Regex.IsMatch(macaddress,   ":")) SetType(Platform.Network.MacAddress.Type.Colon  , ":");
                        else                                       SetType(Platform.Network.MacAddress.Type.Plain  , "");
                    }
                }
                public void SetType(Platform.Network.MacAddress.Type type, string str)
                {
                    Type  = type;
                    Value = string.Join(str, Slice());
                }
                public string[] Slice()
                {
                    List<string> slice = new();

                    for (int i = 0; i < 12; i += 2)
                        slice.Add(Value.Substring(i, 2));

                    return slice.ToArray();
                }
                public override string ToString() => Value;
            }

            public class IpAddress : Platform.Network.IpAddress.Entry
            {
                public IpAddress() { }
                public IpAddress(string address)
                {
                    Assign(address);
                }
                public void Assign(string address)
                {
                    if (!System.Net.IPAddress.TryParse(address, out var ip))
                        return;

                    Value = ip.ToString();

                    if (ip.AddressFamily is System.Net.Sockets.AddressFamily.InterNetwork)
                    {
                        Type         = Platform.Network.IpAddress.Type.IPv4;

                        byte[] octet = ip.GetAddressBytes();

                        Option.IPv4Class = (octet[0], octet[1]) switch
                        {
                            (   127,              _) => Platform.Network.IpAddress.IPv4Class.Local,
                            (   169,            254) => Platform.Network.IpAddress.IPv4Class.APIPA,
                            (<= 126,              _) => Platform.Network.IpAddress.IPv4Class.A,
                            (<= 191,              _) => Platform.Network.IpAddress.IPv4Class.B,
                            (<= 223,              _) => Platform.Network.IpAddress.IPv4Class.C,
                            (<= 239,              _) => Platform.Network.IpAddress.IPv4Class.Multicast,
                            (>= 240 and <= 254,   _) => Platform.Network.IpAddress.IPv4Class.Reserved,
                            (   255,            255) when octet[2] == 255 && octet[3] == 255 
                                                     => Platform.Network.IpAddress.IPv4Class.Broadcast,
                            _                        => Platform.Network.IpAddress.IPv4Class.Unspecified,
                        };

                        Option.IPv4Multicast = Option.IPv4Class == Platform.Network.IpAddress.IPv4Class.Multicast;
                        Option.IPv4Broadcast = Option.IPv4Class == Platform.Network.IpAddress.IPv4Class.Broadcast;
                    }

                    else if (ip.AddressFamily is System.Net.Sockets.AddressFamily.InterNetworkV6)
                    {
                        Type       = Platform.Network.IpAddress.Type.IPv6;

                        Option.IPv6ScopeId   = ip.ScopeId;
                        Option.IPv6Multicast = ip.IsIPv6Multicast;
                        Option.IPv6LinkLocal = ip.IsIPv6LinkLocal;
                        Option.IPv6SiteLocal = ip.IsIPv6SiteLocal;
                        Option.IPv6Teredo    = ip.IsIPv6Teredo;
                    }
                }
                public override string ToString() => Value;
            }

            public class Hierarchy : Platform.Network.Hierarchy
            {
                public Hierarchy() {}
                public Hierarchy(string domain, string netbios)
                {
                    Domain  = domain;
                    NetBios = netbios;
                }
                public override string ToString() => $"Domain: {Domain}, NetBios: {NetBios}";
            }
            
            public class Dhcp : Platform.Network.Dhcp
            {
                public Dhcp() {}
                public Dhcp(string name, string sm, string nw, string start, string end, string bc, string[] ex)
                {
                    Name       = name;
                    SubnetMask = new IpAddress(sm);
                    Network    = new IpAddress(nw);
                    StartRange = new IpAddress(start);
                    EndRange   = new IpAddress(end);
                    Broadcast  = new IpAddress(bc);
                    Exclusion  = ex.Select(x => (Platform.Network.IpAddress.Entry)new IpAddress(x)).ToList();
                }
                public override string ToString() => Name;
            }
            
            public class Node : Platform.Network.Node
            {
                public Node() {}
                public Node(uint index, string nw, string ip, string dom, string netbios, string trusted, uint prefix, string nm, string gw, string[] dns, Dhcp dhcp, uint trans)
                {
                    Index     = index;
                    Switch    = nw;
                    IpAddress = new IpAddress(ip);
                    Domain    = dom;
                    NetBios   = netbios;
                    Trusted   = new IpAddress(trusted);
                    Prefix    = prefix;
                    Netmask   = new IpAddress(nm);
                    Gateway   = new IpAddress(gw);
                    Dns       = dns.Select(x => (Platform.Network.IpAddress.Entry)new IpAddress(x)).ToList();
                    Dhcp      = dhcp;
                    Transmit  = trans;
                }
                public override string ToString() => $"{base.ToString()}>";
            }

            namespace Netstat
            {
                public class Host : Platform.Network.Netstat.Host
                {
                    public Host() {}
                    public Host(string endpoint)
                    {
                        int index = endpoint.LastIndexOf(':');

                        Address   = Regex.Replace(endpoint.Substring(0, index), @"(\[|\])", "");
                        Port      = endpoint.Substring(index + 1);

                        if (System.Net.IPAddress.TryParse(endpoint, out var ip))
                        {
                            IPv4 = ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork;
                            IPv6 = !IPv4;
                        }
                    }
                }

                public class Entry : Platform.Network.Netstat.Entry
                {
                    public Entry() { }
                    public Entry(Platform.Network.Netstat.Type pro, string local, string remote, Platform.Network.Netstat.State state)
                    {
                        Protocol = pro;
                        Local    = new Host(local);
                        Remote   = new Host(remote);
                        State    = state;
                    }
                    public override string ToString() => $"P: {Protocol}, L: {Local}, R: {Remote}, S: {State}";
                }
            }

            public class Interface : Platform.Network.Interface
            {
                public Interface() { }
                public Interface(uint index, string desc, string service, string mac)
                {
                    Index       = index;
                    Description = desc;
                    ServiceName = service;
                    MacAddress  = new MacAddress(mac);
                }
                public void AddConfig(Platform.Network.Protocol proto, string ip, string nm, string gw, bool dhcp, string srv, string[] dns)
                {
                    var config = new Configuration(proto, ip, nm, gw, dhcp, srv, dns);

                    Configuration.Add(config);
                }
                public override string ToString() => Description;
            }

            public class Configuration : Platform.Network.Configuration
            {
                public Configuration() { }
                public Configuration(Platform.Network.Protocol proto, string ip, string nm, string gw, bool dhcp, string dhcpsrv, string[] dns)
                {
                    Protocol    = proto;
                    Address     = new IpAddress(ip);
                    SubnetMask  = new IpAddress(nm);
                    Gateway     = new IpAddress(gw);
                    DhcpEnabled = dhcp;
                    DhcpServer  = dhcpsrv;
                    DnsServers  = dns.Select(x => (Platform.Network.IpAddress.Entry)new IpAddress(x)).ToList();
                }
                public override string ToString() => $"{Address}/{SubnetMask}";
            }

            public class Route : Platform.Network.Route.Entry
            {
                public Route() { }
                public Route(uint index, Platform.Network.Protocol proto, Platform.Network.Route.Type type, string ip, uint pf, string next, uint metric)
                {
                    Index    = index;
                    Protocol = proto;
                    Type     = type;
                    Target   = new IpAddress(ip);
                    Prefix   = pf;
                    NextHop  = new IpAddress(next);
                    Metric   = metric;
                }
                public override string ToString() => $"{Target}/{Prefix} -> {NextHop}";
            }

            public class Firewall : Platform.Network.Firewall.Entry
            {
                public Firewall() { }
                public override string ToString() => DisplayName ?? Name;
            }
        }

        namespace Interop
        {
            using Core.Platform;

            public interface INetwork
            {
                Platform.Network.Hierarchy?              Hierarchy { get; }
                Platform.Network.Dhcp?                        Dhcp { get; }
                Platform.Network.Node?                        Node { get; }
                List<Platform.Network.Interface>         Interface { get; }
                List<Platform.Network.Route.Entry>           Route { get; }
                List<Platform.Network.Netstat.Entry>       Netstat { get; }
                // public Nbt      => Mostly for Windows/ADDS
                // public Arp      => look at local networks for adjacent hosts
                // public Whois    => resolve ip address to domain and location
                // public Port     => port definitions
                List<Platform.Network.Firewall.Entry>     Firewall { get; }
                List<Platform.Network.IpAddress.Entry>          Ip { get; }
                void LoadDependencies();
                void Initialize();
                void Refresh();
                void RefreshInterfaces();
                void RefreshRoutes();
                void RefreshFirewall();
                void RefreshIp();
                void SetHierarchy(string domain, string netbios);
                void SetDhcp(string name, string sm, string nw, string start, string end, string bc, string[] ex);
                void GetNode();
                Platform.Network.Interface GetInterface(uint index);
                Platform.Network.Route.Entry GetRoute(uint index);
            }

            public abstract class Network : Platform.Network.Provider, INetwork
            {
                private readonly Func<Core.Console.Controller> _console;
                protected Network(Func<Core.Console.Controller> console)
                {
                    _console = console;
                }
                public void Update(int state, string status)
                {
                    _console().Update(state, status);
                }
                // public Hierarchy?              Hierarchy { get; set; }
                // public Dhcp?                        Dhcp { get; set; }
                // public Node?                        Node { get; set; }
                // public List<Interface>         Interface { get; set; }
                // public List<Route.Entry>           Route { get; set; }
                // public List<Netstat.Entry>       Netstat { get; set; }
                // public Hierarchy               Hierarchy { get; set; }
                // public Dhcp                         Dhcp { get; set; }
                // public Node                         Node { get; set; }
                // public Script.Controller          Script { get; set; } move?
                // public Connection.Controller  Connection { get; set; }
                // public List<Firewall.Entry>     Firewall { get; set; }
                // public List<IpAddress.Entry>          Ip { get; set; }
                // public Nbt      => Mostly for Windows/ADDS
                // public Arp      => look at local networks for adjacent hosts
                // public Whois    => resolve ip address to domain and location
                // public Port     => port definitions
                public Network()
                {
                    // Script = new Script.Controller();
                }
                public void SetHierarchy(string domain, string netbios)
                {
                    Hierarchy = new Core.Network.Hierarchy(domain, netbios);
                }
                public void SetDhcp(string name, string sm, string nw, string start, string end, string bc, string[] ex)
                {
                    Dhcp = new Core.Network.Dhcp(name, sm, nw, start, end, bc, ex);
                }
                public abstract void LoadDependencies();
                public abstract void Initialize();
                public abstract void Refresh();
                public abstract void RefreshInterfaces();
                public abstract void RefreshRoutes();
                public abstract void RefreshFirewall();
                public abstract void RefreshIp();
                public abstract void GetNode();
                public abstract Platform.Network.Interface GetInterface(uint index);
                public abstract Platform.Network.Route.Entry GetRoute(uint index);
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface IHardware
            {
                List<Platform.Hardware.Vendor>          Vendor { get; }
                List<Platform.Hardware.Device>          Device { get; }
                List<Platform.Hardware.Processor>    Processor { get; }
                List<Platform.Hardware.Disk.Entry>        Disk { get; }
                List<Platform.Hardware.NetworkAdapter> Network { get; }
                void LoadDependencies();
                void LoadVendors(string path);
                void Initialize();
                void Refresh();
                void RefreshDevices();
                void RefreshProcessors();
                void RefreshDisks();
                void RefreshNetworkAdapters();
                void Clear();
                void Rerank();
                Platform.Hardware.Device Get(uint index);
                Platform.Hardware.Device Get(string name);
                List<Platform.Hardware.Device> GetByType(Platform.Hardware.DeviceType type);
            }

            public abstract class Hardware : Platform.Hardware.Provider, IHardware
            {
                private readonly Func<Core.Console.Controller> _console;
                protected Hardware(Func<Core.Console.Controller> console)
                {
                    _console = console;
                }
                public void Update(int state, string status)
                {
                    _console().Update(state, status);
                }
                public abstract void LoadDependencies();
                public void LoadVendors(string path)
                {
                    if (!System.IO.File.Exists(path))
                    {
                        Update(-1, "Exception [!] Invalid vendor file");
                        return;
                    }

                    Vendor.Clear();

                    foreach (string line in System.IO.File.ReadAllLines(path))
                        Vendor.Add(new Core.Hardware.Vendor((uint)Vendor.Count, line));
                }
                public Platform.Hardware.Vendor GetVendor(string macaddress)
                {
                    return Vendor.FirstOrDefault(x => x.Hex == Regex.Replace(macaddress, "[:.-]", "").Substring(0,6));
                }
                public abstract void Initialize();
                public abstract void Refresh();
                public void Clear()
                {
                    Device.Clear();
                    Processor.Clear();
                    Disk.Clear();
                    Network.Clear();
                }
                public void Rerank()
                {
                    for (int i = 0; i < Device.Count; i++)
                    {
                        Device[i].Index = (uint)i;
                    }
                }
                public Platform.Hardware.Device Get(uint index)
                {
                    return Device.FirstOrDefault(x => x.Index == index);
                }
                public Platform.Hardware.Device Get(string name)
                {
                    return Device.FirstOrDefault(x => x.Name == name);
                }
                public List<Platform.Hardware.Device> GetByType(Platform.Hardware.DeviceType type)
                {
                    return Device.Where(x => x.Type == type).ToList();
                }
                public abstract void RefreshDevices();
                public abstract void RefreshProcessors();
                public abstract void RefreshDisks();
                public abstract void RefreshNetworkAdapters();
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface IProcess
            {
                List<Core.Platform.Process.Dependency> Dependency { get; }
                List<Core.Platform.Process.Entry>           Entry { get; }
                void Initialize();
                void LoadDependencies();
                void Clear(string name);
                void Add(string source, string displayname, string name, string fullname);
                string Start(Core.Platform.Process.Dependency dependency);
                void Start(string displayname);
                void Start(Guid guid);
                void Stop(Core.Platform.Process.Dependency dependency);
                void Stop(string displayname);
                void Stop(Guid guid);
                void Remove(string displayname);
                void Remove(Guid guid);
                void Refresh();
                void Rerank();
                bool Exists(int id);
                Core.Platform.Process.Dependency GetDependency(string source, string displayname);
                Core.Platform.Process.Dependency GetDependency(string displayname);
                Core.Platform.Process.Dependency GetDependency(Guid guid);
                Core.Platform.Process.Entry GetProcess(int id);
                Core.Platform.Process.Entry GetProcess(string name);
            }

            public abstract class Process : Core.Platform.Process.Provider, IProcess
            {
                private readonly Func<Core.Console.Controller> _console;
                public Process(Func<Core.Console.Controller> console) : base()
                {
                    _console = console;
                }
                public void Update(int state, string status)
                {
                    _console().Update(state, status);
                }
                public abstract void Initialize();
                public abstract void LoadDependencies();
                public void Clear(string name)
                {
                    if (name == "Entry")
                        Entry.Clear();
                    else if (name == "Dependency")
                        Dependency.Clear();
                }
                public void Add(string source, string displayname, string name, string fullname)
                {
                    var dependency = GetDependency(displayname);
                    if (dependency != null)
                    {
                        Update(0, $"Exception [!] Dependency: '{displayname}' exists");
                    }
                    else if (dependency == null)
                    {
                        Dependency.Add(new Core.Platform.Process.Dependency((uint)Dependency.Count, source, displayname, name, fullname));
                        Update(1, $"Added [+] Dependency: '{displayname}'");
                    }
                }
                public void Remove(Core.Platform.Process.Dependency dependency)
                {
                    Refresh();

                    if (Entry.FirstOrDefault(x => x.Id == dependency.Id) != null)
                    {
                        Update(-1, $"Exception [!] Stop process '{dependency.DisplayName}/{dependency.Guid}' before removal");
                        return;
                    }

                    if (dependency != null)
                        Dependency.Remove(dependency);

                    Rerank();
                }
                public void Remove(string displayname)
                {
                    var dependency = GetDependency(displayname);

                    if (dependency == null)
                        return;

                    Remove(dependency);
                }
                public void Remove(Guid guid)
                {
                    var dependency = GetDependency(guid);

                    if (dependency == null)
                        return;

                    Remove(dependency);
                }
                public abstract void Refresh();
                public abstract string Start(Core.Platform.Process.Dependency dependency);
                public void Start(string displayname)
                {
                    var dependency = GetDependency(displayname);
                    if (dependency == null)
                    {
                        Update(-1, $"Exception [!] Invalid DisplayName: {displayname}");
                        return;
                    }

                    Start(dependency);
                }
                public void Start(Guid guid)
                {
                    var dependency = GetDependency(guid);
                    if (dependency == null)
                    {
                        Update(-1, $"Exception [!] Invalid GUID: {guid}");
                        return;
                    }

                    Start(dependency);
                }
                public abstract void Stop(Core.Platform.Process.Dependency dependency);
                public void Stop(string displayname)
                {
                    var dependency = GetDependency(displayname);
                    if (dependency == null || !Entry.Any(x => x.Id == dependency.Id))
                    {
                        Update(-1, $"Exception [!] Invalid displayname: {displayname}");
                        return;
                    }

                    Stop(dependency);
                }
                public void Stop(Guid guid)
                {
                    var dependency = GetDependency(guid);
                    if (dependency == null || !Entry.Any(x => x.Id == dependency.Id))
                    {
                        Update(-1, $"Exception [!] Invalid GUID: {guid}");
                        return;
                    }

                    Stop(dependency);
                }
                public void Rerank()
                {
                    uint i = 0;

                    foreach (var d in Dependency)
                        d.Index = i++;
                }
                public bool Exists(int id)
                {
                    return Entry.Any(x => x.Id == id);
                }
                public Core.Platform.Process.Entry DefaultEntry(int id, string name, string file, string arglist, bool done)
                {
                    return new Core.Platform.Process.Entry(id, name, file, arglist, done, 0, 0, 0, 0, 0, TimeSpan.Zero, IntPtr.Zero);
                }
                public Core.Platform.Process.Dependency GetDependency(string source, string name)
                {
                    return Dependency.FirstOrDefault(x => x.Source == source && x.Name == name);
                }
                public Core.Platform.Process.Dependency GetDependency(string displayname)
                {
                    return Dependency.FirstOrDefault(x => x.DisplayName == displayname);
                }
                public Core.Platform.Process.Dependency GetDependency(Guid guid)
                {
                    return Dependency.FirstOrDefault(x => x.Guid == guid);
                }
                public Core.Platform.Process.Entry GetProcess(int id)
                {
                    return Entry.FirstOrDefault(x => x.Id == id);
                }
                public Core.Platform.Process.Entry GetProcess(string name)
                {
                    return Entry.FirstOrDefault(x => x.Name == name);
                }
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface ISecurity
            {
                Core.Platform.Security.Identifier             Domain { get; }
                List<Core.Platform.Security.Certificate.Store> Store { get; }
                Core.Platform.Security.Context               Context { get; }
                Core.Platform.Security.Credential         Credential { get; }
                List<Core.Platform.Security.Reference>     Reference { get; }
                List<Core.Platform.Security.Account>         Account { get; }
                void LoadDependencies();
                void RefreshAccounts(string type);
                Core.Platform.Security.Account GetAccount(string username);
                void Initialize();
                void Initialize(Core.Platform.Security.Credential credential);
                void Refresh();
                void SetCredential(Core.Platform.Security.Credential credential);
                void SetCredential(string username);
                void ValidateCredential();
                void ValidateCredential(string username);
                void ValidateCredential(string username, string password);
                void ValidateCredential(string username, SecureString securestring);
                void ValidateCredential(Core.Platform.Security.Credential credential);
            }

            public abstract class Security : Core.Platform.Security.Provider, ISecurity
            {
                private readonly Func<Core.Console.Controller> _console;
                public Security(Func<Core.Console.Controller> console) : base()
                {
                    _console = console;
                }
                public void Update(int state, string status)
                {
                    _console().Update(state, status);
                }
                public abstract void LoadDependencies();
                public abstract void RefreshAccounts(string type);
                public Core.Platform.Security.Account GetAccount(string username)
                {
                    return Account.FirstOrDefault(x => x.Username == username);
                }
                public abstract void Initialize();
                public abstract void Initialize(Core.Platform.Security.Credential credential);
                public abstract void Refresh();
                public void SetCredential(Core.Platform.Security.Credential credential)
                {
                    Credential = credential;
                }
                public void SetCredential(string username)
                {
                    System.Console.Write($"[{username}], enter password: ");

                    SecureString ss = new SecureString();

                    while (true)
                    {
                        var key = System.Console.ReadKey(intercept: true);

                        if (key.Key == ConsoleKey.C && key.Modifiers.HasFlag(ConsoleModifiers.Control))
                        {
                            System.Console.WriteLine();
                            Update(-1, "Exception [!] User aborted credential dialog");
                            Credential = null;
                            return;
                        }

                        if (key.Key == ConsoleKey.Enter)
                            break;

                        if (key.Key == ConsoleKey.Backspace)
                        {
                            if (ss.Length > 0)
                            {
                                ss.RemoveAt(ss.Length - 1);

                                System.Console.Write("\b \b");
                            }
                            continue;
                        }

                        ss.AppendChar(key.KeyChar);

                        System.Console.Write("*");
                    }

                    System.Console.WriteLine();
                    
                    ss.MakeReadOnly();

                    SetCredential(new Core.Platform.Security.Credential(username, ss));
                }
                public abstract void ValidateCredential();
                public abstract void ValidateCredential(string username);
                public abstract void ValidateCredential(string username, string password);
                public abstract void ValidateCredential(string username, SecureString securestring);
                public abstract void ValidateCredential(Core.Platform.Security.Credential credential);
                public abstract void ResolveDomain();
                public abstract void ResolveStoreList();
                public abstract void ResolveReferenceList();
                public void GetReference()
                {
                    Reference.Clear();

                    // Intentionally done this way to make changes more readily
                    string[] output = new string[95];

                    output[00] = "S-1-0                      , Null Authority";
                    output[01] = "S-1-0-0                    , Nobody";
                    output[02] = "S-1-1                      , World Authority";
                    output[03] = "S-1-1-0                    , Everyone";
                    output[04] = "S-1-2                      , Local Authority";
                    output[05] = "S-1-2-0                    , Local";
                    output[06] = "S-1-2-1                    , Console Logon";
                    output[07] = "S-1-3                      , Creator Authority";
                    output[08] = "S-1-3-0                    , Creator Owner";
                    output[09] = "S-1-3-1                    , Creator Group";
                    output[10] = "S-1-3-2                    , Creator Owner Server";
                    output[11] = "S-1-3-3                    , Creator Group Server";
                    output[12] = "S-1-3-4                    , Owner Rights";
                    output[13] = "S-1-5-80-0                 , All Services";
                    output[14] = "S-1-4                      , Non-unique Authority";
                    output[15] = "S-1-5                      , NT Authority";
                    output[16] = "S-1-5-1                    , Dialup";
                    output[17] = "S-1-5-2                    , Network";
                    output[18] = "S-1-5-3                    , Batch";
                    output[19] = "S-1-5-4                    , Interactive";
                    output[20] = "S-1-5-5-X-Y                , Logon Session";
                    output[21] = "S-1-5-6                    , Service";
                    output[22] = "S-1-5-7                    , Anonymous";
                    output[23] = "S-1-5-8                    , Proxy";
                    output[24] = "S-1-5-9                    , Enterprise Domain Controllers";
                    output[25] = "S-1-5-10                   , Principal Self";
                    output[26] = "S-1-5-11                   , Authenticated Users";
                    output[27] = "S-1-5-12                   , Restricted Code";
                    output[28] = "S-1-5-13                   , Terminal Server Users";
                    output[29] = "S-1-5-14                   , Remote Interactive Logon";
                    output[30] = "S-1-5-15                   , This Organization";
                    output[31] = "S-1-5-17                   , This Organization";
                    output[32] = "S-1-5-18                   , Local System";
                    output[33] = "S-1-5-19                   , NT Authority";
                    output[34] = "S-1-5-20                   , NT Authority";
                    output[35] = "S-1-5-21-domain-498        , Enterprise Read-only Domain Controllers";
                    output[36] = "S-1-5-21-domain-500        , Administrator";
                    output[37] = "S-1-5-21-domain-501        , Guest";
                    output[38] = "S-1-5-21-domain-502        , KRBTGT";
                    output[39] = "S-1-5-21-domain-512        , Domain Admins";
                    output[40] = "S-1-5-21-domain-513        , Domain Users";
                    output[41] = "S-1-5-21-domain-514        , Domain Guests";
                    output[42] = "S-1-5-21-domain-515        , Domain Computers";
                    output[43] = "S-1-5-21-domain-516        , Domain Controllers";
                    output[44] = "S-1-5-21-domain-517        , Cert Publishers";
                    output[45] = "S-1-5-21-domain-518        , Schema Admins";
                    output[46] = "S-1-5-21-domain-519        , Enterprise Admins";
                    output[47] = "S-1-5-21-domain-520        , Group Policy Creator Owners";
                    output[48] = "S-1-5-21-domain-521        , Read-only Domain Controllers";
                    output[49] = "S-1-5-21-domain-522        , Cloneable Domain Controllers";
                    output[50] = "S-1-5-21-domain-526        , Key Admins";
                    output[51] = "S-1-5-21-domain-527        , Enterprise Key Admins";
                    output[52] = "S-1-5-21-domain-553        , RAS and IAS Servers";
                    output[53] = "S-1-5-21-domain-571        , Allowed RODC Password Replication Group";
                    output[54] = "S-1-5-21-domain-572        , Denied RODC Password Replication Group";
                    output[55] = "S-1-5-32-544               , Administrators";
                    output[56] = "S-1-5-32-545               , Users";
                    output[57] = "S-1-5-32-546               , Guests";
                    output[58] = "S-1-5-32-547               , Power Users";
                    output[59] = "S-1-5-32-548               , Account Operators";
                    output[60] = "S-1-5-32-549               , Server Operators";
                    output[61] = "S-1-5-32-550               , Print Operators";
                    output[62] = "S-1-5-32-551               , Backup Operators";
                    output[63] = "S-1-5-32-552               , Replicators";
                    output[64] = "S-1-5-64-10                , NTLM Authentication";
                    output[65] = "S-1-5-64-14                , SChannel Authentication";
                    output[66] = "S-1-5-64-21                , Digest Authentication";
                    output[67] = "S-1-5-80                   , NT Service";
                    output[68] = "S-1-5-83-0                 , NT VIRTUAL MACHINE\\Virtual Machines";
                    output[69] = "S-1-16-0                   , Untrusted Mandatory Level";
                    output[70] = "S-1-16-4096                , Low Mandatory Level";
                    output[71] = "S-1-16-8192                , Medium Mandatory Level";
                    output[72] = "S-1-16-8448                , Medium Plus Mandatory Level";
                    output[73] = "S-1-16-12288               , High Mandatory Level";
                    output[74] = "S-1-16-16384               , System Mandatory Level";
                    output[75] = "S-1-16-20480               , Protected Process Mandatory Level";
                    output[76] = "S-1-16-28672               , Secure Process Mandatory Level";
                    output[77] = "S-1-5-32-554               , BUILTIN\\Pre-Windows 2000 Compatible Access";
                    output[78] = "S-1-5-32-555               , BUILTIN\\Remote Desktop Users";
                    output[79] = "S-1-5-32-556               , BUILTIN\\Network Configuration Operators";
                    output[80] = "S-1-5-32-557               , BUILTIN\\Incoming Forest Trust Builders";
                    output[81] = "S-1-5-32-558               , BUILTIN\\Performance Monitor Users";
                    output[82] = "S-1-5-32-559               , BUILTIN\\Performance Log Users";
                    output[83] = "S-1-5-32-560               , BUILTIN\\Windows Authorization Access Group";
                    output[84] = "S-1-5-32-561               , BUILTIN\\Terminal Server License Servers";
                    output[85] = "S-1-5-32-562               , BUILTIN\\Distributed COM Users";
                    output[86] = "S-1-5-32-569               , BUILTIN\\Cryptographic Operators";
                    output[87] = "S-1-5-32-573               , BUILTIN\\Event Log Readers";
                    output[88] = "S-1-5-32-574               , BUILTIN\\Certificate Service Dcom Access";
                    output[89] = "S-1-5-32-575               , BUILTIN\\RDS Remote Access Servers";
                    output[90] = "S-1-5-32-576               , BUILTIN\\RDS Endpoint Servers";
                    output[91] = "S-1-5-32-577               , BUILTIN\\RDS Management Servers";
                    output[92] = "S-1-5-32-578               , BUILTIN\\Hyper-V Administrators";
                    output[93] = "S-1-5-32-579               , BUILTIN\\Access Control Assistance Operators";
                    output[94] = "S-1-5-32-580               , BUILTIN\\Remote Management Users";

                    foreach (string line in output)
                    {
                        string[] split = line.Split(',');

                        Reference.Add(new Core.Platform.Security.Reference((uint)Reference.Count, split[1].Trim(), split[0].Trim()));
                    }
                }
                public abstract void ResolveIdentityList();
                public abstract void ResolveRoleList();
                public abstract void ResolveClaimList();
                public abstract void ResolveContext();
                public static Core.Platform.Security.ProtocolMode GetProtocolMode(uint mode)
                {
                    switch (mode)
                    {
                        case 48:    return Core.Platform.Security.ProtocolMode.Ssl3;
                        case 192:   return Core.Platform.Security.ProtocolMode.Tls10;
                        case 768:   return Core.Platform.Security.ProtocolMode.Tls11;
                        case 3072:  return Core.Platform.Security.ProtocolMode.Tls12;
                        case 12288: return Core.Platform.Security.ProtocolMode.Tls13;
                        default:    return Core.Platform.Security.ProtocolMode.None;
                    }
                }
                public static Core.Platform.Security.AuthenticationType GetAuthType(string value)
                {
                    if (string.IsNullOrEmpty(value))
                        return Core.Platform.Security.AuthenticationType.Unspecified;

                    switch (value.ToLower())
                    {
                        case "kerberos"  : return Core.Platform.Security.AuthenticationType.Kerberos;
                        case "ntlm"      : return Core.Platform.Security.AuthenticationType.NTLM;
                        case "negotiate" : return Core.Platform.Security.AuthenticationType.Negotiate;
                        case "basic"     : return Core.Platform.Security.AuthenticationType.Basic;
                        case "digest"    : return Core.Platform.Security.AuthenticationType.Digest;
                        case "x509"      : return Core.Platform.Security.AuthenticationType.Certificate;
                        case "oauth"     : return Core.Platform.Security.AuthenticationType.OAuth;
                        case "bearer"    : return Core.Platform.Security.AuthenticationType.OAuth;
                        case "federated" : return Core.Platform.Security.AuthenticationType.Federated;
                        case "anonymous" : return Core.Platform.Security.AuthenticationType.Anonymous;
                        case "cloudap"   : return Core.Platform.Security.AuthenticationType.CloudAP;
                        case "liveid"    : return Core.Platform.Security.AuthenticationType.LiveID;
                        default          : return Core.Platform.Security.AuthenticationType.Unspecified;
                    }
                }
                public static Core.Platform.Security.AccountType GetAccountType(Core.Platform.Security.Identifier sid)
                {
                    if (sid == null)
                        return Core.Platform.Security.AccountType.Unspecified;

                    if (sid.Sid.StartsWith("S-1-5-18")) return Core.Platform.Security.AccountType.LocalSystem;
                    if (sid.Sid.StartsWith("S-1-5-19")) return Core.Platform.Security.AccountType.LocalService;
                    if (sid.Sid.StartsWith("S-1-5-20")) return Core.Platform.Security.AccountType.NetworkService;
                    if (sid.Sid.StartsWith("S-1-5-21")) return Core.Platform.Security.AccountType.User;
                    if (sid.Sid.StartsWith("S-1-5-32")) return Core.Platform.Security.AccountType.BuiltinGroup;

                    return Core.Platform.Security.AccountType.Unspecified;
                }
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface IConfiguration
            {
                Core.Platform.Configuration.Type Type { get; }
                string    Drive { get; }
                string     Name { get; }
                string Fullname { get; }
                bool     Exists { get; }
                string     Root { get; }
                string     Path { get; }
                string   Branch { get; }
                List<Core.Platform.Configuration.Property> Property { get; }
                void LoadDependencies();
                void Clear();
                string Get(string name);
                void Initialize();
                List<Version> GetVersions();
                Version GetLatestVersion();
                Version GenerateVersion();
                string ConfigurationPath();
                void Install(Core.Module.Template template);
                void Refresh();
                void Check();
                void Read();
                void Write();
                void Create();
                void Remove();
            }

            public abstract class Configuration : Platform.Configuration.Provider, IConfiguration
            {
                private readonly Func<Core.Console.Controller> _console;
                public Configuration(Func<Core.Console.Controller> console) : base()
                {
                    _console = console;
                }
                public void Update(int state, string status)
                {
                    _console().Update(state, status);
                }
                public abstract void LoadDependencies();
                public void Clear()
                {
                    Property.Clear();
                }
                public void Add(string name, string value)
                {
                    if (!Property.Any(x => x.Name == name))
                        Property.Add(new Core.Platform.Configuration.Property((uint)Property.Count, name, value));
                }
                public string Get(string name)
                {
                    var prop = Property.FirstOrDefault(x => x.Name == name);

                    return prop.Value.ToString();
                }
                public abstract void Initialize();
                public abstract List<Version> GetVersions();
                public Version GetLatestVersion()
                {
                    List<Version> versions = GetVersions();

                    return versions.Count == 0 ? GenerateVersion() : versions.Max();
                }
                public Version GenerateVersion()
                {
                    return Version.Parse(DateTime.Now.ToString("yyyy.M.0"));
                }
                public abstract string ConfigurationPath();
                public string CompanyName() => "Secure Digits Plus LLC";
                public string ProjectName() => "FightingEntropy";
                public abstract void Install(Core.Module.Template template);
                public abstract void Refresh();
                public abstract void Check();
                public abstract void Read();
                public abstract void Write();
                public abstract void Create();
                public abstract void Remove();
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface IFileSystem
            {
                string                                    Location { get; set; }
                List<Core.Platform.FileSystem.Directory>  Resource { get; }
                void LoadDependencies();
                void Initialize();
                void SetLocation(string fullname);
                Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode, bool recurse, string filter);
                Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode, bool recurse);
                Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode);
                Core.Platform.FileSystem.Directory GetDirectory(string fullname);


                // Collection operations
                void Add(string label, string fullname, uint mode, bool recurse, string filter);
                void Add(string label, string fullname, uint mode, bool recurse);
                void Add(string label, string fullname, uint mode);
                void Add(string label, string fullname);
                void Refresh(string label);
                void Remove(string label);
                void Clear();
                void Rerank();

                // Directory operations
                void CreateDirectory(string fullname);
                void RemoveDirectory(string fullname, bool recurse = false);
                void RenameDirectory(string fullname, string newname);
                void MoveDirectory(string source, string target);
                void CopyDirectory(string source, string target, bool recurse = false);

                // File operations
                void CreateFile(string fullname);
                void RemoveFile(string fullname);
                void RenameFile(string fullname, string newname);
                void MoveFile(string source, string target);
                void CopyFile(string source, string target);

                // Security operations (needs some more thought)
                // void  CheckOwnership(string fullname);
                // void  TakeOwnership(string fullname);
                // List<Group> GetGroups(string fullname);
                // List<Acl> GetAcl(string fullname);
                // List<Permissions> GetPermissions(string fullname);

                // FileSystem Manager
                // ------------------
                // Files
                // Directories
                // Shares
                // Mounts
                // ACL application
                // Owner assignment
                // Permission application
            }

            public abstract class FileSystem : Core.Platform.FileSystem.Provider, IFileSystem
            {
                private readonly Func<Core.Console.Controller> _console;
                public FileSystem(Func<Core.Console.Controller> console) : base()
                {
                    _console = console;
                }
                public void Update(int state, string status) => _console().Update(state, status);
                public abstract void LoadDependencies();
                public abstract void Initialize();
                public void SetLocation(string fullname) => Location = fullname;
                public abstract Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode, bool recurse, string filter);
                public abstract Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode, bool recurse);
                public abstract Core.Platform.FileSystem.Directory GetDirectory(string fullname, uint mode);
                public abstract Core.Platform.FileSystem.Directory GetDirectory(string fullname);
                public Core.Platform.FileSystem.Directory GetResource(string label) => Resource.FirstOrDefault(x => x.Label == label);
                // Resource operations (Resource will = directories + isshares, permissions, ACL's, etc.)
                public void Add(string label, string fullname, uint mode = 2, bool recurse = false, string filter = null)
                {
                    if (string.IsNullOrWhiteSpace(label) || string.IsNullOrWhiteSpace(fullname))
                    {
                        Update(-1, $"Exception [!] Resource requires (label + path)");
                        return;
                    }

                    var res = GetResource(label);
                    if (res != null)
                        Update(-1, $"Exception [!] Resource label '{label}' exists under path '{res.Fullname}'");

                    else if (!CheckDirectory(fullname))
                        Update(-1, $"Exception [!] Resource path '{fullname}' does not exist");

                    else
                    {
                        var dir   = GetDirectory(fullname, mode, recurse, filter);
                        dir.SetLabel(label);
                        dir.Index = (uint)Resource.Count;

                        Resource.Add(dir);

                        Update(1, $"Added [+] Resource label '{label}' to path '{fullname}'");
                    }
                }
                public void Add(string label, string fullname, uint mode, bool recurse) => Add(label, fullname, mode, recurse, null);
                public void Add(string label, string fullname, uint mode) => Add(label, fullname, mode, false, null);
                public void Add(string label, string fullname) => Add(label, fullname, 2, false, null);
                public void Remove(string label)
                {
                    if (string.IsNullOrWhiteSpace(label))
                    {
                        Update(-1, "Exception [!] Resource label must be (specified + valid)");
                        return;
                    }

                    var dir = GetResource(label);
                    if (dir == null)
                    {
                        Update(-1, $"Exception [!] Resource label '{label}' (is invalid/does not exist)");
                        return;
                    }

                    else if (dir != null)
                    {
                        Resource.Remove(dir);
                        Rerank();

                        Update(1, $"Removed [!] Resource label '{dir.Label}' to path '{dir.Fullname}'");
                    }
                }
                public abstract void Refresh(string label);
                public void Clear() => Resource.Clear();
                public void Rerank()
                {
                    for (int i = 0; i < Resource.Count; i++) Resource[i].Index = (uint)i;
                }
                // filesystem operations
                public DirectoryInfo GetDirectoryInfo(string fullname) => new System.IO.DirectoryInfo(fullname);
                public bool            CheckDirectory(string fullname) => System.IO.Directory.Exists(fullname);
                public FileInfo           GetFileInfo(string fullname) => new System.IO.FileInfo(fullname);
                public byte[]            GetFileBytes(string fullname) => CheckFile(fullname) ? System.IO.File.ReadAllBytes(fullname) : null;
                public string[]          GetFileLines(string fullname) => CheckFile(fullname) ? System.IO.File.ReadAllLines(fullname) : null;
                public string             GetFileText(string fullname) => CheckFile(fullname) ? System.IO.File.ReadAllText(fullname) : null;
                public bool                 CheckFile(string fullname) => System.IO.File.Exists(fullname);
                public bool                 CheckPath(string fullname) => CheckFile(fullname) || CheckDirectory(fullname);
                // Directory operations
                public void CreateDirectory(string fullname)
                {
                    if (CheckPath(fullname))
                    {
                        Update(-1, $"Exception [!] (Directory/File) '{fullname}' exists");
                        return;
                    }

                    try
                    {
                        System.IO.Directory.CreateDirectory(fullname);
                        Update(1, $"Created [!] Directory '{fullname}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void RemoveDirectory(string fullname, bool recurse = false)
                {
                    if (!CheckDirectory(fullname))
                    {
                        Update(-1, $"Exception [!] Directory '{fullname}' does not exist");
                        return;
                    }
                    
                    try
                    {
                        System.IO.Directory.Delete(fullname, recurse);

                        Update(1, $"Removed [+] Directory '{fullname}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void RenameDirectory(string fullname, string newname)
                {
                    if (!CheckDirectory(fullname))
                    {
                        Update(-1, $"Exception [!] Directory '{fullname}' does not exist");
                        return;
                    }

                    string target = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(fullname), newname);

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] Path '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.Directory.Move(fullname, target);
                        Update(1, $"Renamed [+] Directory '{fullname}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    } 
                }
                public void MoveDirectory(string source, string target)
                {
                    if (!CheckDirectory(source))
                    {
                        Update(-1, $"Exception [!] Directory '{source}' does not exist");
                        return;
                    }

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] Path '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.Directory.Move(source, target);
                        Update(1, $"Moved [+] Directory '{source}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    } 
                }
                public virtual void CopyDirectory(string source, string target, bool recurse = false)
                {
                    if (!CheckDirectory(source))
                    {
                        Update(-1, $"Exception [!] Directory '{source}' does not exist");
                        return;
                    }

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] (Directory/File) '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.Directory.CreateDirectory(target);

                        foreach (var file in System.IO.Directory.GetFiles(source))
                        {
                            var name = System.IO.Path.GetFileName(file);
                            var dest = System.IO.Path.Combine(target, name);

                            System.IO.File.Copy(file, dest);
                        }

                        if (recurse)
                        {
                            foreach (var directory in System.IO.Directory.GetDirectories(source))
                            {
                                var name = System.IO.Path.GetFileName(directory);
                                var dest = System.IO.Path.Combine(target, name);

                                CopyDirectory(directory, dest, true);
                            }
                        }

                        Update(1, $"Copied [+] Directory '{source}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                // File operations
                public void CreateFile(string fullname)
                {
                    if (CheckPath(fullname))
                    {
                        Update(-1, $"Exception [!] (Directory/File) '{fullname}' exists");
                        return;
                    }

                    try
                    {
                        using (System.IO.File.Create(fullname)) { }

                        Update(1, $"Created [+] File '{fullname}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void RemoveFile(string fullname)
                {
                    if (!CheckFile(fullname))
                    {
                        Update(-1, $"Exception [!] File '{fullname}' does not exist");
                        return;
                    }

                    try
                    {
                        System.IO.File.Delete(fullname);
                        Update(1, $"Removed [+] File '{fullname}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void RenameFile(string fullname, string newname)
                {
                    if (!CheckFile(fullname))
                    {
                        Update(-1, $"Exception [!] File '{fullname}' does not exist");
                        return;
                    }

                    string target = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(fullname),newname);

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] Path '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.File.Move(fullname, target);

                        Update(1, $"Renamed [+] File '{fullname}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void MoveFile(string source, string target)
                {
                    if (!CheckFile(source))
                    {
                        Update(-1, $"Exception [!] File '{source}' does not exist");
                        return;
                    }

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] Path '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.File.Move(source, target);

                        Update(1, $"Moved [+] File '{source}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }
                public void CopyFile(string source, string target)
                {
                    if (!CheckFile(source))
                    {
                        Update(-1, $"Exception [!] File '{source}' does not exist");
                        return;
                    }

                    if (CheckPath(target))
                    {
                        Update(-1, $"Exception [!] Path '{target}' already exists");
                        return;
                    }

                    try
                    {
                        System.IO.File.Copy(source, target);

                        Update(1, $"Copied [+] File '{source}' to '{target}'");
                    }
                    catch (Exception ex)
                    {
                        Update(-1, $"Exception [!] {ex.Message}");
                    }
                }

                // Security operations
                // void CheckOwnership(string fullname);
                // void TakeOwnership(string fullname);
                public override string ToString() => $"<{base.ToString()}>";
            }

            public interface IService
            {
                bool Exists(string name);
                bool IsRunning(string name);
                void Start(string name);
                void Stop(string name);
                void Restart(string name);
            }

            public interface ICommand
            {
                int Execute(string command);
                int Execute(string command, params string[] arguments);
                string Capture(string command);
                string Capture(string command, params string[] arguments);
            }

            public abstract class Controller
            {
                protected Func<string, object>        Bridge { get; set; }
                protected Console.Controller         Console { get; private set; }
                public abstract IProcess             Process { get; }
                public abstract ISecurity           Security { get; }
                public abstract IConfiguration Configuration { get; }
                public abstract IFileSystem       FileSystem { get; }
                public abstract INetwork             Network { get; }
                public abstract IHardware           Hardware { get; }
                public abstract IService             Service { get; }
                public abstract ICommand             Command { get; }
                protected Controller() { }
                public abstract void LoadDependencies();
                public abstract void Initialize();
                public abstract void Initialize(Core.Platform.Security.Credential credential);
                public void AssignConsole(Core.Console.Controller console)
                {
                    Console = console;
                }
                protected Core.Console.Controller GetConsole() =>  Console;
                public override string ToString() => $"<{base.ToString()}>";
            }
        }

        namespace Module
        {
            public class Template
            {
                public string         Name { get; set; }
                public string      Company { get; set; }
                public string       Author { get; set; }
                public string       Source { get; set; }
                public string  Description { get; set; }
                public string    Copyright { get; set; }
                public string         Guid { get; set; }
                public string         Date { get; set; }
                public string      Version { get; set; }
                public string      Caption { get; set; }
                public string     Platform { get; set; }
                public string         Role { get; set; }
                public string Architecture { get; set; }
                public string     Resource { get; set; }
                public string       Module { get; set; }
                public string         File { get; set; }
                public string     Manifest { get; set; }
                public string     Shortcut { get; set; }
                public string       Config { get; set; }
                public Template() { }
            }

            namespace Host
            {
                public enum Role
                {
                    Client      = 0,
                    Server      = 1,
                    Unspecified = 2,     
                }

                public enum Platform
                {
                    Windows     = 0,
                    Unix        = 1,
                    OSX         = 2,
                    BSD         = 3,
                    Unspecified = 4,
                }

                public enum OS
                {
                    Win32_Client = 0,
                    Win32_Server = 1,
                    Unix         = 2,
                    OSX          = 3,
                    BSD          = 4, // Maybe at some point, who the hell knows. I rememeber some guy from BSD askin' about making PowerShell for it.
                    Unspecified  = 5, 
                }

                public enum State
                {
                    Initial     = 0,   // Only OS/Caption/Platform/PSVersion allowed
                    Operational = 1,   // Full PSDrive interaction allowed
                    Restricted  = 2,   // Future: limited operations
                    Elevated    = 3,   // Future: privileged operations
                    Unspecified = 4
                }

                public class Provider : Core.Platform.PowerShell.Drive.Provider
                {
                    public Provider() : base() { }
                    public Provider(System.Management.Automation.ProviderInfo info, bool isDefault, bool isVirtual)
                    {
                        Name        = info.Name;
                        Mode        = GetMode(Name);
                        Description = info.Description;
                        Default     = isDefault;
                        Virtual     = isVirtual;
                    }
                    public Provider(string name, string description, bool isVirtual)
                    {
                        Name        = name;
                        Mode        = GetMode(Name);
                        Description = description;
                        Default     = false;
                        Virtual     = isVirtual;
                    }
                    public string Auto(string name) => $"<Custom[{name}]>";
                    public Core.Platform.PowerShell.Drive.Mode GetMode(string name)
                    {
                        var mode = Core.Platform.PowerShell.Drive.Mode.Unspecified;

                        return Enum.TryParse<Core.Platform.PowerShell.Drive.Mode>(name, true, out var result) ? result : mode;
                    }
                    public override string ToString() => Name;
                }

                public class Drive : Core.Platform.PowerShell.Drive.Entry
                {
                    public Drive() : base() { }
                    public Drive(uint index, System.Management.Automation.PSDriveInfo drive, bool isDefault, bool isVirtual)
                    {
                        Index           = index;
                        Slot            = Core.Platform.PowerShell.Drive.Slot.PSDrive;
                        Name            = drive.Name;
                        Provider        = new Provider(drive.Provider, isDefault, isVirtual);
                        Root            = drive.Root;
                        Exists          = true;
                        Description     = drive.Description;

                        GetSize(drive);

                        Default         = isDefault;
                        Virtual         = isVirtual;

                        Assessment(drive);
                    }
                    public Drive(uint index, string name, string provider, string root, Core.Platform.PowerShell.Drive.Scope scope, string desc, bool isVirtual)
                    {
                        Index           = index;
                        Slot            = Core.Platform.PowerShell.Drive.Slot.Template;
                        Name            = name;
                        Provider        = new Provider(provider, "Custom", isVirtual);
                        Root            = root;
                        Exists          = false;
                        Description     = desc;

                        Used            = new Format.ByteSize("Used", 0);
                        Free            = new Format.ByteSize("Free", 0);

                        Default         = false;
                        Virtual         = isVirtual;

                        SetScope(scope);
                    }
                    public void Assessment(System.Management.Automation.PSDriveInfo drive)
                    {
                        GetSize(drive);

                        Slot            = Core.Platform.PowerShell.Drive.Slot.PSDrive;

                        DisplayRoot     = drive.DisplayRoot;
                        CurrentLocation = drive.CurrentLocation;
                        Scope           = GetScope(drive);
                        
                        Credential      = drive.Credential != null ? new Core.Platform.Security.Credential(drive.Credential) : null;

                        Unc             = Root != null && Regex.IsMatch(Root, @"^(\\\\|//)");
                        Mapped          = Name.Length == 1 && Unc;
                        NetworkDrive    = Provider.Mode == Core.Platform.PowerShell.Drive.Mode.FileSystem && Unc;
                        AutoMounted     = Provider.Mode != Core.Platform.PowerShell.Drive.Mode.FileSystem;
                    }
                    public Core.Platform.PowerShell.Drive.Scope GetScope(System.Management.Automation.PSDriveInfo drive)
                    {
                        var prop = GetProperty(drive, "Scope", "DriveScope");
                        if (prop != null)
                        {
                            object val = GetValue(drive, prop);

                            if (val != null)
                            {
                                Enum.TryParse<Core.Platform.PowerShell.Drive.Scope>(val.ToString(), true, out var result);
                                return result;
                            }
                        }

                        return Core.Platform.PowerShell.Drive.Scope.Unspecified;
                    }
                    public void SetScope(Core.Platform.PowerShell.Drive.Scope scope)
                    {
                        Scope = scope;
                    }
                    private PropertyInfo GetProperty(object obj, string name1, string name2)
                    {
                        var xtype = obj.GetType();
                        var prop  = xtype.GetProperty(name1);

                        return (prop != null) ? prop : xtype.GetProperty(name2);
                    }
                    private object GetValue(object obj, PropertyInfo prop)
                    {
                        return prop.GetValue(obj, null);
                    }
                    public void GetSize(System.Management.Automation.PSDriveInfo drive)
                    {
                        long         used = 0;
                        long         free = 0;
                        PropertyInfo prop = null;
                        object        val = null;
                        
                        // Used / UsedSpace
                        prop              = GetProperty(drive, "Used", "UsedSpace");
                        if (prop != null)
                        {
                            val           = GetValue(drive, prop);

                            if (val is long) 
                                used      = (long)val;
                        }

                        // Free / FreeSpace
                        prop              = GetProperty(drive, "Free", "FreeSpace");
                        if (prop != null)
                        {
                            val           = GetValue(drive, prop);

                            if (val is long)
                                free      = (long)val;
                        }

                        Used            = new Format.ByteSize("Used", (ulong)used);
                        Free            = new Format.ByteSize("Free", (ulong)free);
                    }
                    public void Clear()
                    {
                        Used            = new Format.ByteSize("Used", 0);
                        Free            = new Format.ByteSize("Free", 0);

                        DisplayRoot     = null;
                        CurrentLocation = null;
                        Scope           = Core.Platform.PowerShell.Drive.Scope.Unspecified;
                        
                        Credential      = null;

                        Unc             = false;
                        Mapped          = false;
                        NetworkDrive    = false;
                        AutoMounted     = false;
                    }
                }

                public class Option
                {
                    public State   State { get; private set; }
                    public string Status { get; private set; }
                    public Option()
                    {
                        SetInitial();
                    }
                    internal void SetStatus(string status) => Status = status;
                    internal void SetState(string mode)
                    {
                        switch (mode)
                        {
                            case "Initial"     : State = State.Initial     ; break;
                            case "Operational" : State = State.Operational ; break;
                            case "Restricted"  : State = State.Restricted  ; break;
                            case "Elevated"    : State = State.Elevated    ; break;
                            default            : State = State.Unspecified ; break;
                        }
                    }
                    internal void     SetInitial() => SetState("Initial");
                    internal void SetOperational() => SetState("Operational");
                    internal void  SetRestricted() => SetState("Restricted");
                    internal void    SetElevated() => SetState("Elevated");
                }

                public enum ArchitectureType : uint
                {
                    X86         = 0,
                    X64         = 1,
                    Arm         = 2,
                    Arm64       = 3,
                    Unspecified = 4,
                }

                public class Architecture
                {
                    public ArchitectureType Type { get; set; }
                    public string           Name { get; set; }
                    public string    DisplayName { get; set; }
                    public string          Label { get; set; }
                    public Architecture(ArchitectureType type, string name, string displayname, string label)
                    {
                        Type        = type;
                        Name        = name;
                        DisplayName = displayname;
                        Label       = label;
                    }
                    public override string ToString() => $"{Name}, {DisplayName}, {Label}";
                }

                public class Controller
                {
                    public string               Caption { get; set; }
                    public Architecture?   Architecture { get; set; }
                    public Platform            Platform { get; set; }
                    public Role                    Role { get; set; }
                    public OS                        OS { get; set; }
                    public string           DisplayName { get; set; }
                    public Version?           PSVersion { get; set; }
                    public Option                Option { get; set; } = new();
                    public List<Drive>            Drive { get; set; } = new();
                    public System.Management.Automation.EngineIntrinsics Context { get; set; }
                    public Controller(System.Management.Automation.EngineIntrinsics context)
                    {
                        Context = context;
                        Refresh();
                    }
                    public void Clear()
                    {
                        // Clears the drive array
                        Drive.Clear();

                        // Clears any associated properties
                        Caption      = null;
                        Architecture = null;
                        PSVersion    = null;
                        OS           = OS.Unspecified;
                        Platform     = Platform.Unspecified;
                    }
                    public void Initial()
                    {
                        Caption      = RuntimeInformation.OSDescription.ToString();
                        Architecture = GetArchitecture();
                        PSVersion    = GetPSVersion();

                        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                        {
                            bool serv   = Regex.IsMatch(Caption, "Server");

                            Platform    = Platform.Windows;
                            OS          = serv ? OS.Win32_Server : OS.Win32_Client;
                            Role        = serv ? Role.Server : Role.Client;
                        }
                        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                        {
                            Platform    = Platform.Unix;
                            OS          = OS.Unix;
                            Role        = Role.Client;
                        }
                        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                        {
                            Platform    = Platform.OSX;
                            OS          = OS.OSX;
                            Role        = Role.Client;
                        }
                        else
                        {
                            Platform    = Platform.Unspecified;
                            OS          = OS.Unspecified;
                            Role        = Role.Client;
                        }

                        DisplayName = $"{Platform.ToString()}-{Role.ToString()}";

                        Load();
                        Option.SetOperational();
                    }
                    public void Load()
                    {
                        foreach (PSDriveInfo drive in Context.SessionState.Drive.GetAll())
                            Add(drive, true, false);
                    }
                    public Drive Get(string driveName)
                    {
                        return Drive.FirstOrDefault(e => string.Equals(e.Name, driveName, StringComparison.OrdinalIgnoreCase));
                    }
                    public void Add(System.Management.Automation.PSDriveInfo info, bool isDefault, bool isVirtual)
                    {
                        Drive drive = Get(info.Name);

                        if (drive == null)
                            Drive.Add(new Drive((uint)Drive.Count, info, isDefault, isVirtual));
                    }
                    public void Add(string driveName, string provider, string root, Core.Platform.PowerShell.Drive.Scope scope, string description, bool isVirtual)
                    {
                        Drive drive = Get(driveName);

                        if (drive == null)
                            Drive.Add(new Drive((uint)Drive.Count, driveName, provider, root, Core.Platform.PowerShell.Drive.Scope.Script, description, isVirtual));
                    }
                    public void Check(string driveName)
                    {
                        Drive drive = Get(driveName);

                        if (drive.Mode == Core.Platform.PowerShell.Drive.Mode.Unspecified)
                        {
                            drive.Exists = false;
                            return;
                        }

                        try
                        {
                            string resolved = Context.SessionState.Path.GetUnresolvedProviderPathFromPSPath(drive.Root);
                            var results     = Context.InvokeCommand.InvokeScript("Test-Path -LiteralPath $args[0]", new object[]{ resolved });

                            if (results != null && results.Count > 0)
                            {
                                object obj = results[0].BaseObject;
                                drive.Exists = obj is bool && (bool)obj;
                            }
                            else
                                drive.Exists = false;
                        }
                        catch
                        {
                            drive.Exists    = false;
                        }
                    }
                    public void Create(string driveName)
                    {
                        Drive drive = Get(driveName);

                        if (drive.Slot == Core.Platform.PowerShell.Drive.Slot.PSDrive)
                            return;

                        System.Management.Automation.PSCredential     cred = drive.Credential != null ? drive.Credential.ToPsCredential() : null;
                        System.Management.Automation.ProviderInfo provider = Context.SessionState.Provider.Get(drive.Provider.Name).FirstOrDefault();
                        System.Management.Automation.PSDriveInfo      info = new System.Management.Automation.PSDriveInfo(drive.Name, provider, drive.Root, drive.Description, cred);

                        try
                        {
                            Context.SessionState.Drive.New(info, drive.Scope.ToString());

                            Update(drive.Name);
                        }
                        catch
                        {
                            
                        }
                    }
                    public void Remove(string driveName)
                    {
                        Drive drive = Get(driveName);

                        if (drive != null && !drive.Default)
                        {
                            try
                            {
                                Context.SessionState.Drive.Remove(drive.Name, true, drive.Scope.ToString());
                            }
                            catch
                            {
                                // swallow
                            }

                            Drive.Remove(drive);
                            Rerank();
                        }
                    }
                    public void Update(string driveName)
                    {
                        Drive drive = Get(driveName);

                        if (drive.Slot == Core.Platform.PowerShell.Drive.Slot.Template)
                        {
                            drive.Exists = false;
                            return;
                        }

                        System.Management.Automation.PSDriveInfo info = Context.SessionState.Drive.Get(drive.Name);

                        // If PSDrive no longer exists
                        if (info == null)
                        {
                            drive.Exists = false;
                            return;
                        }

                        // Update basic fields
                        drive.Exists      = true;
                        drive.Root        = info.Root;
                        drive.Description = info.Description;

                        // Update provider if changed
                        if (!string.Equals(drive.Provider.Name, info.Provider.Name, StringComparison.OrdinalIgnoreCase))
                        {
                            drive.Provider = new Provider(info.Provider, drive.Default, drive.Virtual);
                        }

                        // Re-run assessment logic
                        drive.Assessment(info);
                    }
                    public void Rerank()
                    {
                        for (int x = 0; x < Drive.Count; x++)
                            Drive[x].Index = (uint)x;
                    }
                    public void Refresh()
                    {
                        System.Console.WriteLine("Refreshing [~]");

                        switch (Option.State)
                        {
                            case State.Initial :
                                Clear();
                                Initial();
                                Load();
                                Option.SetOperational();
                                break;

                            case State.Operational :
                                foreach (Drive drive in Drive)
                                {
                                    if (drive.Default)
                                        Update(drive.Name);
                                }
                                break;

                            case State.Restricted :
                                foreach (Drive drive in Drive)
                                {
                                    if (drive.Default && !drive.Virtual)
                                        Update(drive.Name);
                                }
                                break;

                            case State.Elevated :
                                foreach (Drive drive in Drive)
                                {
                                    Update(drive.Name);
                                }
                                break;

                            case State.Unspecified :
                                break;
                        }
                    }
                    public Architecture GetArchitecture()
                    {
                        string           arch = RuntimeInformation.OSArchitecture.ToString();
                        ArchitectureType type;
                        string[]       values;

                        switch (arch)
                        {
                            case "X86"   : values = new string[]{    "i386",   "x86",   "(x86)" }; type = ArchitectureType.X86         ; break;
                            case "X64"   : values = new string[]{  "x86_64",   "x64",   "(x64)" }; type = ArchitectureType.X64         ; break;
                            case "Arm"   : values = new string[]{     "arm",   "ARM",   "(ARM)" }; type = ArchitectureType.Arm         ; break;
                            case "Arm64" : values = new string[]{ "aarch64", "ARM64", "(ARM64)" }; type = ArchitectureType.Arm64       ; break;
                            default      : values = new string[]{     "unk",   "Unk",   "(Unk)" }; type = ArchitectureType.Unspecified ; break;
                        }

                        return new Architecture(type, values[0], values[1], values[2]);
                    }
                    public Version GetPSVersion()
                    {
                        var table = Context.SessionState.PSVariable.GetValue("PSVersionTable") as IDictionary;
                        if (table == null || !table.Contains("PSVersion"))
                            return new Version(0,0);

                        object value = table["PSVersion"];

                        if (value is System.Management.Automation.SemanticVersion sem)
                        {
                            return new Version(sem.Major, sem.Minor, sem.Patch);
                        }

                        else if (value is Version ver)
                        {
                            return ver;
                        }

                        // Fallback
                        return new Version(0,0);
                    }
                    public string GetDefaultResourcePath()
                    {
                        if (OS == OS.Win32_Client || OS == OS.Win32_Server)
                            return $"{Environment.GetEnvironmentVariable("ProgramData")}\\Secure Digits Plus LLC\\FightingEntropy";
                        else if (OS == OS.Unix)
                            return "/opt/secure-digits-plus-llc/fightingentropy";
                        else if (OS == OS.OSX || OS == OS.BSD || OS == OS.Unspecified)
                            return null; // Gonna have to work on that when I have labs with those set up
                        else
                            return null;
                    }
                    public string GetDefaultModulePath()
                    {
                        string modpath = Environment.GetEnvironmentVariable("PSModulePath");

                        if (OS == OS.Win32_Client || OS == OS.Win32_Server)
                            return modpath.Split(";").FirstOrDefault(e => Regex.IsMatch(e, "Windows.+Modules"));
                        else if (OS == OS.Unix)
                            return modpath.Split(":").FirstOrDefault(e => Regex.IsMatch(e, "/usr.+powershell/Modules"));
                        else if (OS == OS.OSX || OS == OS.BSD || OS == OS.Unspecified)
                            return null; // Gonna have to work on that when I have labs with those set up
                        else
                            return null;
                    }
                    public string GetDefaultShortcutPath()
                    {
                        if (OS == OS.Win32_Client || OS == OS.Win32_Server)
                            return $"{Environment.GetEnvironmentVariable("Public")}\\Desktop\\FightingEntropy.lnk";
                        else if (OS == OS.Unix)
                            return "/usr/share/applications/FightingEntropy.desktop";
                        else if (OS == OS.OSX || OS == OS.BSD || OS == OS.Unspecified)
                            return null; // Gonna have to work on that when I have labs with those set up
                        else
                            return null;
                    }
                    public override string ToString() => $"<{Caption}, {Platform}/{OS}, PSVersion: {PSVersion}>";
                }
            }

            namespace Root
            {
                public enum Mode
                {
                    Directory = 0,
                    File      = 1,
                }

                public class Property
                {
                    public uint      Index { get; set; }
                    public Mode       Mode { get; set; }
                    public string     Name { get; set; }
                    public string Fullname { get; set; }
                    public bool     Exists { get; set; }
                    public Property(uint index, uint mode, string name, string fullname)
                    {
                        Index    = index;
                        Mode     = (Mode)mode;
                        Name     = name;
                        Fullname = fullname;

                        Check();
                    }
                    public void Check()
                    {
                        Exists = File.Exists(Fullname) || Directory.Exists(Fullname);   
                    }
                    public void Create()
                    {
                        Check();

                        if (!Exists)
                        {
                            if (Name == "Resource" || Name == "Module") System.IO.Directory.CreateDirectory(Fullname);
                            else if (Name == "File" || Name == "Manifest") System.IO.File.Create(Fullname).Dispose();

                            Check();
                        }
                    }
                    public void Remove()
                    {
                        Check();

                        if (Exists)
                        {
                            if (Name == "Resource" || Name == "Module")
                                System.IO.Directory.Delete(Fullname, true);
                            else if (Name == "File" || Name == "Manifest" || Name == "Shortcut")
                                System.IO.File.Delete(Fullname);

                            Check();
                        }
                    }
                    public override string ToString() => Fullname;
                }

                public class Controller
                {
                    public Property Resource { get; set; }
                    public Property   Module { get; set; }
                    public Property     File { get; set; }
                    public Property Manifest { get; set; }
                    public Property Shortcut { get; set; }
                    public Controller() { }
                    public void Assign(Core.Interop.Configuration config)
                    {
                        Resource = new Property(0, 0, "Resource" , config.Get("Resource"));
                        Module   = new Property(1, 0, "Module"   , config.Get("Module"));
                        File     = new Property(2, 1, "File"     , config.Get("File"));
                        Manifest = new Property(3, 1, "Manifest" , config.Get("Manifest"));
                        Shortcut = new Property(4, 1, "Shortcut" , config.Get("Shortcut"));
                    }
                    public Property[] List() => new Property[] { Resource, Module, File, Manifest, Shortcut };
                    public void Refresh()
                    {
                        foreach (Property prop in List())
                            prop.Check();
                    }
                    public override string ToString() => $"<{base.ToString()}>";
                }
            }

            namespace Manifest
            {
                public enum Mode
                {
                    Directory = 0,
                    File      = 1,
                }

                public enum Type
                {
                    Control  = 0,
                    Function = 1,
                    Graphic  = 2,
                }

                public enum Tag
                {
                    Control   = 0,
                    Functions = 1,
                    Graphics  = 2,
                }

                public class Content : Format.Content
                {
                    public Content(uint index, string line) : base(index, line) { }
                }

                public class Entry
                {
                    public uint               Index { get; set; }
                    public Mode                Mode { get; set; }
                    public Type                Type { get; set; }
                    private Tag                 Tag { get; set; }
                    public Format.ModDateTime? Date { get; set; } = null;
                    public string              Name { get; set; }
                    public string       DisplayName { get; set; }
                    public string          Fullname { get; set; }
                    public Format.ByteSize     Size { get; set; }
                    public bool              Exists { get; set; } = false;
                    public string            Source { get; set; }
                    public string              Hash { get; set; }
                    public bool               Match { get; set; }
                    public byte[]             Bytes { get; set; }
                    public Entry(uint index, uint type, string name)
                    {
                        Index       = index;
                        Mode        = Mode.Directory;
                        Type        = (Manifest.Type)type;
                        Tag         = (Manifest.Tag)type;
                        Name        = Path.GetFileName(name);
                        Hash        = string.Empty;
                    }
                    public Entry(uint index, uint type, string name, string hash) : this (index, type, name)
                    {
                        Mode        = Manifest.Mode.File;
                        Hash        = hash;
                    }
                    public void Assign(string resource, string source, Version version)
                    {
                        if (Mode == Manifest.Mode.Directory)
                        {
                            DisplayName = "\\" + Name;
                            Fullname    =  Path.Combine(resource, Name);
                            Source      = string.Format("{0}/blob/main/Version/{1}/{2}", source, version, Tag.ToString());
                        }
                        else
                        {
                            DisplayName = "\\" + Type.ToString() + "\\" + Name;
                            Fullname    = Path.Combine(resource, Tag.ToString(), Name);
                            Source      = string.Format("{0}/blob/main/Version/{1}/{2}/{3}?raw=true", source, version, Tag.ToString(), Name);
                        }
                    }
                    public void Clear() => Bytes = new byte[0];
                    public void Check()
                    {
                        if (Mode == Manifest.Mode.Directory)
                        {
                            DirectoryInfo info = new DirectoryInfo(Fullname);

                            Exists = info.Exists;
                            Size   = new Format.ByteSize("Directory", 0UL);

                            if (Exists)
                                Date   = Exists ? new Format.ModDateTime(info.LastWriteTime) : null;
                        }
                        else
                        {
                            FileInfo info = new FileInfo(Fullname);

                            Exists = info.Exists;
                            
                            if (Exists)
                            {
                                Size   = new Format.ByteSize("File", (ulong)info.Length);
                                Date   = Exists ? new Format.ModDateTime(info.LastWriteTime) : null;
                            }
                            else if (!Exists)
                                Size   = new Format.ByteSize("File", 0UL);
                        }
                    }
                    public void Create()
                    {
                        Check();

                        if (Mode == Manifest.Mode.Directory && Exists == false) System.IO.Directory.CreateDirectory(Fullname);
                        else if (Mode == Manifest.Mode.File && Exists == false) System.IO.File.Create(Fullname).Dispose();

                        Check();
                    }
                    public void Remove()
                    {
                        Check();

                        if (Mode == Manifest.Mode.Directory && Exists == true) System.IO.Directory.Delete(Fullname);
                        else if (Mode == Manifest.Mode.File && Exists == true) System.IO.File.Delete(Fullname);

                        Check();
                    }
                    public void Read()
                    {
                        if (Mode != Manifest.Mode.File)
                            throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                        Check();

                        if (Exists)
                        {
                            Clear();

                            Bytes = System.IO.File.ReadAllBytes(Fullname);

                            Check();
                        }
                    }
                    public void Write()
                    {
                        if (Mode != Manifest.Mode.File)
                            throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                        Check();

                        if (Exists == true) System.IO.File.WriteAllBytes(Fullname, Bytes);

                        Check();
                    }
                    public string[] Content()
                    {
                        if (Mode != Manifest.Mode.File)
                            throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                        if (Bytes.Length > 0)
                            return System.Text.Encoding.UTF8.GetString(Bytes).Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);
                        else
                            return Array.Empty<string>();
                    }
                    public Content[] Lines()
                    {
                        string[]    content = Content();
                        List<Content> lines = new List<Content>();

                        foreach (string line in content)
                            lines.Add(new Content((uint)lines.Count, line));

                        return lines.ToArray();
                    }
                    public void Download()
                    {
                        if (Mode != Manifest.Mode.File)
                            throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                        Check();

                        if (!Exists) Create();

                        int   attempts = 0;
                        string content = null;

                        while (content == null && attempts < 5)
                        {
                            try
                            {
                                using (var http = new System.Net.Http.HttpClient())
                                    content = http.GetStringAsync(Source).Result;
                            }
                            catch
                            {
                                
                            }

                            attempts ++;
                        }

                        if (content == null)
                            throw new Exception("Exception [!] File " + Name + " failed to download");

                        Bytes = System.Text.Encoding.UTF8.GetBytes(content);

                        Write();
                    }
                    public string Status()
                    {
                        string token = Exists ? "+" : "_";
                    
                        if (Mode == Manifest.Mode.Directory)
                            return $"[{token}] {Name.PadRight(8)} : {Fullname}";
                        else
                            return $"[{token}] {Name.PadRight(31)} | {Hash}";
                    }
                    public override string ToString() => Fullname;
                }

                public class Controller
                {
                    public Version    Version { get; set; }
                    public string      Source { get; set; }
                    public string    Resource { get; set; }
                    public List<Entry>  Entry { get; set; } = new();
                    public Controller() { }
                    public void Assign(Core.Interop.Configuration config)
                    {
                        Version  = new Version(config.Get("Version"));
                        Source   = config.Get("Source");
                        Resource = config.Get("Resource");
                    }
                    public void        Clear() => Entry.Clear();
                    public Entry        Last() => Entry[Entry.Count-1];
                    public string LastStatus() => Last().Status();
                    private void Add(Entry entry)
                    {
                        for (int x = 0; x < Entry.Count; x ++)
                        {
                            if (Entry[x].Fullname == entry.Fullname)
                                return;
                        }

                        entry.Check();

                        Entry.Add(entry);
                    }
                    public void AddFolder(uint type, string name)
                    {
                        Entry entry = new Entry((uint)Entry.Count, type, name);

                        AssignEntry(entry);
                    }
                    public void AddFile(uint type, string name, string hash)
                    {
                        Entry entry = new Entry((uint)Entry.Count, type, name, hash);

                        AssignEntry(entry);
                    }
                    private void AssignEntry(Entry entry)
                    {
                        entry.Assign(Resource, Source, Version);

                        Add(entry);
                    }
                    public void Refresh()
                    {
                        foreach (Entry entry in Entry)
                            entry.Check();
                    }
                    public override string ToString() => $"<{base.ToString()}>";
                }
            }

            public class Revision
            {
                public Format.Version       Version { get; set; }
                private Format.ModDateTime   Actual { get; set; }
                public string                  Date { get; set; }
                public string                  Time { get; set; }
                public Guid                    Guid { get; set; }
                public Revision(Version version, Format.ModDateTime datetime, Guid guid)
                {
                    // Supplied from registry/config
                    Version  = version;
                    Actual   = datetime;
                    Date     = Actual.DayString();
                    Time     = Actual.TimeString();
                    Guid     = guid;
                }
                public Revision(string line)
                {
                    // Supplied from repository
                    if (!Regex.IsMatch(line, Pattern("Version")) || !Regex.IsMatch(line, Pattern("Date")) || !Regex.IsMatch(line, Pattern("Guid")))
                        throw new Exception("Exception [!] Invalid input string");

                    string xversion = Filter("Version", line);
                    string xtime    = Filter("Date",    line);
                    string xguid    = Filter("Guid",    line);

                    if (xversion != null && xtime != null && xguid != null)
                    {   
                        Version  = new Version(xversion);
                        Actual   = new Format.ModDateTime(DateTime.Parse(xtime));
                        Date     = Actual.DateString();
                        Time     = Actual.TimeString();
                        Guid     = new Guid(xguid);
                    }
                }
                public Revision(bool createNew, int minor)
                {
                    // Automatic new
                    Actual      = Format.ModDateTime.Now();
                    Date        = Actual.DateString();
                    Time        = Actual.TimeString();
                    Version     = new Version(Actual.Value.ToString("yyyy.MM.") + minor);
                    Guid        = System.Guid.NewGuid();
                }
                public string Pattern(string name)
                {
                    switch (name)
                    {
                        case "Version" : return "\\d{4}\\.\\d{1,}\\.\\d{1,}";
                        case "Date"    : return "\\d{2}\\/\\d{2}\\/\\d{4} \\d{2}:\\d{2}:\\d{2}";
                        case "Guid"    : return "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";
                        default        : return null;
                    }
                }
                public string Filter(string type, string line)
                {
                    Match m = Regex.Match(line, Pattern(type));

                    if (!m.Success)
                        throw new Exception("Exception [!] Invalid string input");

                    return m.Value;
                }
                public override string ToString() => Version.ToString();
            }

            public class Controller
            {
                public string                             Name { get; set; }
                public string                          Company { get; set; }
                public string                           Author { get; set; }
                public string                           Source { get; set; }
                public string                      Description { get; set; }
                public string                        Copyright { get; set; }
                public Guid                               Guid { get; set; }
                public Format.ModDateTime                 Date { get; set; }
                public Revision                        Version { get; set; }
                public string                          Caption { get; set; }
                public string                         Platform { get; set; }
                public string                             Role { get; set; }
                public string                     Architecture { get; set; }
                public Host.Controller                    Host { get; set; }
                public Interop.Controller              Interop { get; set; }
                public Root.Controller                    Root { get; set; }
                public Manifest.Controller            Manifest { get; set; }
                public Console.Controller              Console { get; set; }
                public Theme.Controller                  Theme { get; set; }
                public Controller(System.Management.Automation.EngineIntrinsics context)
                {
                    Initialize(context);
                }
                public void Update(int state, string status) => Console.Update(state, status);
                public void Write(int state, string status)
                {
                    if (Console.Mode != Core.Console.Mode.Silent) Console.SetMode(2);

                    Theme.Refresh(new object[]{ status });
                    
                    foreach (Theme.Template.Track track in Theme.Track)
                        Update(state, track.Text());

                    Theme.Write();

                    if (Console.Mode != Core.Console.Mode.Full) Console.SetMode(0);
                }
                public void Write(uint palette, int state, string status)
                {
                    if (Console.Mode != Core.Console.Mode.Silent) Console.SetMode(2);

                    Theme.SetPalette(palette); 

                    Theme.Refresh(new object[]{ status });
                    
                    foreach (Theme.Template.Track track in Theme.Track)
                        Update(state, track.Text());

                    Theme.Write();

                    if (Console.Mode != Core.Console.Mode.Full) Console.SetMode(0);
                }
                public void Initialize(EngineIntrinsics context)
                {
                    LoadConsole();
                    LoadTheme();
                    LoadHost(context);
                    LoadInterop();
                    LoadRoot();
                    LoadManifest();
                    AssignConfig();
                }
                public Module.Template Defaults(string configuration)
                {
                    // Module Information
                    string version    = _CurrentVersion();
                    string modroot    = Host.GetDefaultModulePath();
                    string modpath    = System.IO.Path.Combine(Host.GetDefaultModulePath(), version);

                    return new Core.Module.Template
                    {
                        Name          = _DisplayName(),
                        Company       = _CompanyName(),
                        Author        = _AuthorName(),
                        Source        = _ProjectSource(),
                        Description   = _Description(),
                        Copyright     = _Copyright(),
                        Guid          = _Guid(),
                        Date          = _Date(),
                        Version       = version,
                        Caption       = Host.Caption.ToString(),
                        Platform      = Host.Platform.ToString(),
                        Role          = Host.Role.ToString(),
                        Architecture  = Host.Architecture.DisplayName,
                        Resource      = System.IO.Path.Combine(Host.GetDefaultResourcePath(), version),
                        Module        = modpath,
                        File          = System.IO.Path.Combine(modpath, "FightingEntropy.psm1"),
                        Manifest      = System.IO.Path.Combine(modpath, "FightingEntropy.psd1"),
                        Shortcut      = Host.GetDefaultShortcutPath(),
                        Config        = configuration
                    };
                }
                public string _DisplayName()    => $"[{_ProjectName()}(π)]";
                public string _ProjectName()    => "FightingEntropy";
                public string _ProjectSource()  => $"https://www.github.com/mcc85s/{_ProjectName()}";
                public string _CompanyName()    => "Secure Digits Plus LLC";
                public string _AuthorName()     => "Michael C. Cook Sr.";
                public string _CurrentVersion() => DateTime.Now.ToString("yyyy.M.0");
                public string _Description()    => "Beginning the fight against ID theft and cybercrime";
                public string _Copyright()      => "(c) 2026 (mcc85s/mcc85sx/sdp). All rights reserved.";
                public string _Guid()           => "7649d586-6a45-4dad-b24d-64eabde5f926";
                public string _Date()           => "04/06/2026 16:30:21";
                public string Now()             => Format.ModDateTime.Now().ToString();
                public void LoadConsole()
                {
                    if (Console == null)
                    {
                        try
                        {
                            Console = new Console.Controller();
                            Console.Initialize();
                        }
                        catch
                        {

                        }
                    }
                }
                public void LoadTheme()
                {
                    if (Theme == null)
                    {
                        try
                        {
                            string line = $"Loading [~] {_DisplayName()}[{_CurrentVersion()}]";
                            
                            Theme = new Theme.Controller(line);

                            Write(0, line);
                        }
                        catch
                        {
                            Update(-1, "Exception [!]  <Theme> not loaded");
                        }
                    }
                }
                public void LoadHost(System.Management.Automation.EngineIntrinsics context)
                {
                    if (Host == null)
                    {
                        try
                        {
                            Host    = new Host.Controller(context);

                            if (Host.OS == Module.Host.OS.BSD || Host.OS == Module.Host.OS.OSX || Host.OS == Module.Host.OS.Unspecified)
                            {
                                throw new Exception("Exception [!] BSD/OSX/Unspecified not yet supported");
                            }

                            Write(0, $"[+] <Host>: {Host}");
                        }
                        catch
                        {
                            Update(-1, "Exception [!]  <Host> not loaded");
                        }
                    }
                }
                public void LoadInterop()
                {
                    if (Interop == null)
                    {
                        try
                        {
                            string asmpath = System.IO.Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
                            string   label = null;

                            if (Host.OS == Module.Host.OS.Unix)
                                label = "FightingEntropy.Linux.dll";
                            else if (Host.OS == Module.Host.OS.Win32_Client || Host.OS == Module.Host.OS.Win32_Server)
                                label = "FightingEntropy.Windows.dll"; 

                            if (label == null)
                                throw new Exception("Exception [!] Unsupported OS");

                            string  provider = System.IO.Path.Combine(asmpath, label);

                            if (!System.IO.File.Exists(provider))
                                throw new Exception($"Exception [!] {label} not found");

                            byte[]     bytes = System.IO.File.ReadAllBytes(provider);
                            Assembly     asm = Assembly.Load(bytes);
                            System.Type ctrl = asm.GetTypes().First(t => typeof(Interop.Controller).IsAssignableFrom(t));

                            Interop = (Interop.Controller)Activator.CreateInstance(ctrl);

                            Interop.AssignConsole(Console);

                            Interop.LoadDependencies();

                            Interop.Initialize();

                            Write(0, $"[+] <Interop>: {Host.Platform}");
                        }
                        catch
                        {
                            Update(-1, $"Exception [!]  <Interop>: {Host.Platform} not loaded");
                        }
                    }
                }
                public void LoadRoot()
                {
                    if (Root == null)
                    {
                        try
                        {
                            Root = new Root.Controller();

                            Update(0, "[+] <Root>");
                        }
                        catch
                        {
                            Update(-1, "Exception [!] <Root> failed to load");
                            throw new Exception(Console.Last().Status);
                        }
                    }
                }
                public void LoadManifest()
                {
                    if (Manifest == null)
                    {
                        try
                        {
                            Manifest = new Manifest.Controller();

                            Update(0,"[+] <Manifest>");
                        }
                        catch
                        {
                            Update(-1, "Exception [!] <Manifest> failed to load");
                            throw new Exception(Console.Last().Status);
                        }
                    }                
                }
                public void AssignConfig()
                {
                    var  config = (Interop.Configuration)Interop.Configuration;
                    
                    if (config.Property.Count == 0)
                    {
                        config.Install(Defaults(config.ConfigurationPath()));
                    }
                    
                    // Assign the values from configuration to module
                    Name         = config.Get("Name");
                    Company      = config.Get("Company");
                    Author       = config.Get("Author");
                    Source       = config.Get("Source");
                    Description  = config.Get("Description");
                    Copyright    = config.Get("Copyright");
                    Guid         = new Guid(config.Get("Guid"));
                    Date         = new Format.ModDateTime(config.Get("Date"));
                    Version      = new Revision(new Version(config.Get("Version")), Date, Guid);
                    Caption      = config.Get("Caption");
                    Platform     = config.Get("Platform");
                    Role         = config.Get("Role");
                    Architecture = config.Get("Architecture");
                    
                    Root.Assign(config);
                    Manifest.Assign(config);
                }
                public Interop.Process       Process() =>       (Interop.Process)Interop.Process;
                public Interop.Security     Security() =>      (Interop.Security)Interop.Security;
                public Interop.Configuration  Config() => (Interop.Configuration)Interop.Configuration;
                public Interop.FileSystem FileSystem() =>    (Interop.FileSystem)Interop.FileSystem;
                public Interop.Network       Network() =>       (Interop.Network)Interop.Network;
                public Interop.Hardware     Hardware() =>      (Interop.Hardware)Interop.Hardware;
                public void     Banner() => Core.Theme.Controller.Banner();
                public void       Flag() => Core.Theme.Controller.Flag();
                public string ToString() => $"{_DisplayName()}://Core Module Controller";
            }
        }
    }
}
