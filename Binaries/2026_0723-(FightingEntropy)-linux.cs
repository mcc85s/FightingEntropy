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
using System.Reflection.Emit;

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

        [Serializable]
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
            public string Label()
            {
                return string.Format("{0}.{1}.{2}", Major, Minor, Build);
            }
            public override string ToString()
            {
                string label = Label();

                return Revision < 0 ? label : label + "." + Revision;
            }
        }

        public class Content
        {
            public uint  Index;
            public string Line;
            public Content(uint index, string line)
            {
                Index = index;
                Line  = line;
            }
            public override string ToString()
            {
                return Line;
            }
        }

        namespace Progress
        {
            public enum Operation
            {
                EventLog = 0,
                Transfer = 1,
            }

            public sealed class Index
            {
                public uint      Rank { get; private set; }
                public uint   Current { get; private set; }
                public uint     Total { get; private set; }
                public string Percent { get; private set; }
                public Index(uint rank, uint current, uint total)
                {
                    Rank    = rank;
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

            public sealed class Tracker
            {
                public Operation Operation { get; private set; }
                public string  DisplayName { get; private set; }
                public uint          Total { get; private set; }
                public List<Index>  Output { get; private set; }
                public Tracker(Operation operation, string displayName, int count)
                {
                    Operation   = operation;
                    Total       = GetRandom(0, count);
                    DisplayName = displayName;
                    Initialize();
                }
                public Tracker(Operation operation, string displayName, int min, int max)
                {
                    Operation   = operation;
                    Total       = GetRandom(min, max);
                    DisplayName = displayName;
                    Initialize();
                }
                public void Clear()
                {
                    if (Output == null)
                        Output = new List<Index>();
                    else
                        Output.Clear();
                }
                private void Initialize()
                {
                    Clear();

                    // need to expand this into additional operations
                    if (Operation != Operation.EventLog)
                        return;

                    int segments = (Total <= 1000) ? 1 : (Total <= 2000) ? 2 : (Total < 10000) ? 5 : 10;
                    double step  = (double)Total / (double)segments;

                    for (int i = 0; i < segments; i++)
                    {
                        uint current = (uint)Math.Round(step * i);

                        if (current > Total) current = Total;

                        Output.Add(new Index((uint)Output.Count, current, Total));
                    }
                }
                public uint GetRandom(int min, int max)
                {
                    System.Random r = new System.Random();
                    return (uint)r.Next(min, max);
                }
            }
        }
        
        // FightingEntropy.Format
    }

    namespace Core
    {
        namespace Theme
        {
            namespace Input
            {
                public class Line
                {
                    public uint    Index;
                    public uint     Rank;
                    public uint    Bound;
                    public string  Value;
                    public uint   Length;
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
                    public override string ToString()
                    {
                        return (Value != null) ? Value.ToString() : "";
                    }
                }

                public class Container
                {
                    public uint      Index;
                    public uint       Rank;
                    public string     Type;
                    public uint      Count;
                    public List<Line> Line;
                    public Container(uint index, uint rank, string type, string[] lines)
                    {
                        Index = index;
                        Rank  = rank;
                        Type  = type;

                        Refresh(lines);
                    }
                    public void Clear()
                    {
                        if (Line == null)
                            Line = new List<Line>();
                        else
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
                    public override string ToString()
                    {
                        return string.Format("[{0}]({1})", Type, Count);
                    }
                }

                public class Item
                {
                    public uint             Index;
                    public string            Type;
                    public List<Container> Output;
                    public Item(uint index, string type)
                    {
                        Index  = index;
                        Type   = type;
                        Output = new List<Container>();
                    }
                    public void Clear()
                    {
                        if (Output == null)
                            Output = new List<Container>();
                        else
                            Output.Clear();
                    }
                    public override string ToString()
                    {
                        return string.Format("[{0}]({1})", Type, Output.Count);
                    }
                }

                public class Entry
                {
                    public Template.Mode Mode;
                    public uint        Height;
                    public List<Item>   Input;
                    public List<Line>  Output;
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
                        List<string> lines = new List<string>();
                        List<string>  keys = new List<string>();

                        foreach (object key in table.Keys)
                            keys.Add(key.ToString());

                        int buffer = GetMaxLength(keys);

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

                        var pso = System.Management.Automation.PSObject.AsPSObject(obj);

                        int buffer = 0;

                        foreach (var prop in pso.Properties)
                        {
                            if (prop.Name.Length > buffer)
                                buffer = prop.Name.Length;
                        }

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
                        List<string>   names = new List<string>();
                        List<string>  values = new List<string>();
                        List<string>   lines = new List<string>();

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
                        Input = new List<Item>();

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
                        Output        = new List<Line>();

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
                                string line = (Output.Count > 0) ? Output[0].ToString() : "";
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
                    public uint        Rank;
                    public string      Text;
                    public uint? Foreground = null;
                    public uint? Background = null;
                    public bool      Locked = false;
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
                }

                public class Palette
                {
                    public uint   Index;
                    public uint[] Value;
                    public Palette(uint index, uint[] value)
                    {
                        Index = index;
                        Value = value;
                    }
                    public override string ToString()
                    {
                        return string.Format("({0}) {{{1},{2},{3},{4}}}", Index, Value[0], Value[1], Value[2], Value[3]);
                    }
                }

                public class Face
                {
                    public uint    Index;
                    public string String;
                    public char[]  Value;
                    public uint[]  Bytes;
                    public string    Hex;
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
                    public override string ToString()
                    {
                        return string.Format("({0}) {{{1}}}", Index, String);
                    }
                }

                public class Buffer
                {
                    public string       Type;
                    public string     String;
                    public List<uint>  Bytes;
                    public Buffer(string type, string inputString)
                    {
                        Bytes              = new List<uint>();

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
                    public override string ToString()
                    {
                        return "<FightingEntropy.Core.Module.Theme.Template.Bytes>";
                    }
                }

                public class Block
                {
                    public uint        Index;
                    public uint        Track;
                    public uint         Rank;
                    public string       Text;
                    public uint   Foreground;
                    public uint   Background;
                    public bool       Locked = false;
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
                    public void Lock()
                    {
                        if (Locked) Locked = true;
                    }
                    public override string ToString()
                    {
                        return Text;
                    }
                }

                public class Track
                {
                    public uint          Index;
                    public uint           Rank;
                    internal uint        Total;
                    public TrackType      Type;
                    internal Buffer       Mask;
                    internal Buffer Foreground;
                    internal Buffer Background;
                    public List<Block>   Block;
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
                        if (Block == null)
                            Block = new List<Block>();
                        else
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
                            case "Mask"       : return       Mask.Bytes.ToArray();
                            case "Foreground" : return Foreground.Bytes.ToArray();
                            case "Background" : return Background.Bytes.ToArray(); 
                            default           : return                       null;
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
                                list.Add(UInt32.Parse(item));
                            }
                        }

                        for (int i = 0; i < list.Count; i++)
                        {
                            Block[(int)list[i]].Lock();
                        }
                    }
                }

                public class Draft
                {
                    public char[]      Face;
                    public string RowHeader;
                    public uint     Padding;
                    public uint    MaxIndex;
                    public int        Width;
                    public Draft(List<Track> tracks)
                    {
                        Face    = new char[] { '_', '¯','=' };

                        Stage(tracks);
                    }
                    private void Stage(List<Track> tracks)
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
                public Template.Mode         Mode;
                public Template.Palette   Palette;
                public List<Template.Face>   Face;
                public Input.Entry             IO;
                public Guid                  Guid;
                public Format.ModDateTime    Time;
                public string               Title;
                public string              Prompt;
                public List<Template.Track> Track;
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

                    if (Mode != Template.Mode.Banner || Mode != Template.Mode.Flag)
                    {
                        GenerateTemplate();   
                    }
                    else if (Mode == Template.Mode.Banner)
                    {
                        GenerateBanner();
                    }
                    else if (Mode == Template.Mode.Flag)
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

                    Palette = new Template.Palette(index, PaletteBytes((uint)index));
                }
                public void SetMode(uint mode)
                {
                    if (mode > 5)
                    {
                        throw new Exception("Invalid type [" + mode + "]");
                    }

                    switch (mode)
                    {
                        case 0 : Mode = Template.Mode.Function ; break;
                        case 1 : Mode = Template.Mode.Action   ; break;
                        case 2 : Mode = Template.Mode.Section  ; break;
                        case 3 : Mode = Template.Mode.Table    ; break;
                        case 4 : Mode = Template.Mode.Banner   ; break;
                        case 5 : Mode = Template.Mode.Flag     ; break;
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

                    Face = new List<Template.Face>();

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
                    Track         = new List<Template.Track>();

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

                                if (index == 3)
                                {
                                    track.SetType("Single");
                                }

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

                                if (index == 2)
                                {
                                    track.SetType("Single");
                                }

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
                    Track         = new List<Template.Track>();

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

                    Track         = new List<Template.Track>();

                    string[] mask = FlagMask();
                    string[] fore = FlagForeground();
                    string[] back = FlagBackground();

                    for (uint i = 0; i <= 38; i++)
                    {                
                        Template.Track track = BuildTrack(i, i, mask[i], fore[i], back[i]);
                    
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
                public Template.Track[] GetTrackByType(Template.TrackType type)
                {
                    List<Template.Track> list = new List<Template.Track>();

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

                    text = " " + text + " ";

                    return text;
                }
                public List<Template.Slice> GenerateSlices(string text, uint startRank, uint foreground, uint background)
                {
                    List<Template.Slice> slices = new List<Template.Slice>();

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

                        Template.Slice slice = new Template.Slice((uint)(startRank + x), part, foreground, background);

                        slices.Add(slice);
                        x ++;
                    }

                    return slices;
                }
                public List<Template.Slice> GenerateSlices(string text, uint startRank)
                {
                    List<Template.Slice> slices = new List<Template.Slice>();

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

                        Template.Slice slice = new Template.Slice((uint)(startRank + x), part);

                        slices.Add(slice);
                        x ++;
                    }

                    return slices;
                }
                public void InsertLine(string type, string inputText, int startColumn, Template.Track track)
                {
                    switch (type)
                    {
                        case "Function":
                        {
                            string text    = PrepareString(inputText);
                            
                            List<Template.Slice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

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

                            if (Mode != Template.Mode.Section)
                            {
                                text   = PrepareString(inputText);        
                            }
                            else
                            {
                                text   = inputText;
                            }

                            List<Template.Slice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

                            for (int i = 0; i < slices.Count; i++)
                            {
                                track.Block[startColumn + i].Update(slices[i]);
                            }
                            break;
                        }
                        case "Banner":
                        {
                            List<Template.Slice> slices = GenerateSlices(inputText, (uint)startColumn);

                            for (int i = 0; i < slices.Count; i++)
                            {
                                track.Block[startColumn + i].Update(slices[i]);
                            }
                            break;
                        }
                        case "Flag":
                        {
                            List<Template.Slice> slices = GenerateSlices(inputText, (uint)startColumn);   

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
                    List<Template.Track> track = new List<Template.Track>();

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
                        {
                            InsertLine("Action", IO.Output[x].ToString(), 3, track[x]);
                        }

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
                        {
                            InsertLine("Banner", IO.Output[x].ToString(), 10, track[x]);
                        }

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
                            if (line.Length == 48)
                                InsertLine("Flag", line, 14, track[x]);
                            else
                                InsertLine("Flag", line, 12, track[x]);
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
                    {
                        System.Console.OutputEncoding = System.Text.Encoding.UTF8;   
                    }
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

                    string head = string.Format("| {0:D2} | {1:D2} |", track.Index, track.Rank);
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
                        System.Console.Write(string.Format("| {0} | {1} |", index, rank));

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
                    System.Console.Write(string.Format("| {0} | {1} |", index, rank));
                    
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

                    foreach (Template.Track track in Track)
                    {
                        sb.AppendLine(track.Text());
                    }

                    return sb.ToString();
                }
                public override string ToString()
                {
                    return "<" + base.ToString() + ">";
                }
            }
        }

        namespace Console
        {
            public enum Mode
            {
                Full   = 0,
                String = 1,
                Silent = 2,
            }

            public class Mark
            {
                public string              Name;
                public Format.ModDateTime? Time;
                public bool                 Set;
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
                public override string ToString()
                {
                    return Time.HasValue ? Time.Value.ToString() : "<unset>";
                }
            }

            public class Entry
            {
                public uint     Index;
                public string Elapsed;
                public int      State;
                public string  Status;
                public Entry(uint index, string time, int state, string status)
                {
                    Index   = index;
                    Elapsed = time;
                    State   = state;
                    Status  = status;
                }
                public override string ToString()
                {
                    return string.Format("[{0}] (State: {1}/Status: {2})", Elapsed, State, Status);
                }
            }

            public class Controller
            {
                public Mode                          Mode { get; set; }
                public Mark                         Start { get; set; }
                public Mark                           End { get; set; }
                public string                        Span { get; set; }
                public Entry                       Status { get; set; }
                public ObservableCollection<Entry> Output { get; set; }
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
                    if (mode >= 0 && mode <= 2)
                    {
                        Mode = (Mode)mode;   
                    }
                }
                public void Initialize()
                {
                    if (Start.Set == true)
                    {
                        Update(-1, "Start [!] Error: Already initialized, try a different operation or reset.");
                        return;
                    }

                    Start.Toggle();
                    Update(0, "Running [~] (" + Start.ToString() + ")");
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
                    Update(100, "Complete [+] (" + End.ToString() + "), Total: (" + Span + ")");
                }
                public void Reset()
                {
                    Start  = new Mark("Start");
                    End    = new Mark("End");
                    Span   = null;
                    Status = null;
                    Output = new ObservableCollection<Entry>();
                }
                public void Update(int state, string status)
                {
                    SetStatus(state, status);
                    Output.Add(Status);
                    
                    if (Mode == Mode.Full)
                        System.Console.WriteLine(Last());
                    else if (Mode == Mode.String)
                        System.Console.WriteLine(Last().Status);
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
                    {
                        arr[i] = Output[i].ToString();
                    }

                    return arr;
                }
                public override string ToString()
                {
                    return string.Format("<{0}>", Span == null ? Elapsed() : Span);
                }
            }
        }

        namespace Network
        {
            public class Hierarchy
            {
                public string  Domain;
                public string NetBios;
                public Hierarchy(string domain, string netbios)
                {
                    Domain  = domain;
                    NetBios = netbios;
                }
            }
            
            public class Dhcp
            {
                public string        Name;
                public string  SubnetMask;
                public string     Network;
                public string  StartRange;
                public string    EndRange;
                public string   Broadcast;
                public string[] Exclusion;
                public Dhcp(string name, string sm, string nw, string start, string end, string bc, string[] ex)
                {
                    Name       = name;
                    SubnetMask = sm;
                    Network    = nw;
                    StartRange = start;
                    EndRange   = end;
                    Broadcast  = bc;
                    Exclusion  = ex;
                }
            }
            
            public class Node
            {
                public uint       Index;
                public string    Switch;
                public string IpAddress;
                public string    Domain;
                public string   NetBios;
                public string   Trusted;
                public string    Prefix;
                public string   Netmask;
                public string   Gateway;
                public string[]     Dns;
                public object      Dhcp;
                public uint    Transmit;
                public Node(uint index, string nw, string ip, string dom, string netbios, string trusted, string prefix, string nm, string gw, string[] dns, Dhcp dhcp, uint trans)
                {
                    Index     = index;
                    Switch    = nw;
                    IpAddress = ip;
                    Domain    = dom;
                    NetBios   = netbios;
                    Trusted   = trusted;
                    Prefix    = prefix;
                    Netmask   = nm;
                    Gateway   = gw;
                    Dns       = dns;
                    Dhcp      = dhcp;
                    Transmit  = trans;
                }
            }
            
            namespace Script
            {
                public class Content : Format.Content
                {
                    public Content(uint index, string line) : base(index, line) { }
                }

                public class Block
                {
                    public uint            Index;
                    public uint            Phase;
                    public string           Name;
                    public string    DisplayName;
                    public List<Content> Content;
                    public uint          Timeout;
                    public bool         Complete;
                    public Block(uint index, uint phase, string name, string displayName, uint timeout, string[] content)
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
                        if (Content == null)
                            Content = new List<Content>();
                        else
                            Content.Clear();
                    }
                    public void Load(string[] content)
                    {
                        Clear();
                        Add("# " + DisplayName);
            
                        foreach (string line in content)
                            Add(line);
            
                        Add("");
                    }
                    public void Add(string line)
                    {
                        Content.Add(new Content((uint)Content.Count, line));
                    }
                    public override string ToString()
                    {
                        return DisplayName;
                    }
                }
            
                public class Controller
                {
                    private uint     Selected;
                    public List<Block>  Block;
                    public Controller()
                    {
                        Clear();
                    }
                    public void Clear()
                    {
                        if (Block == null)
                            Block = new List<Block>();
                        else
                            Block.Clear();                        
                    }
                    public void Reset()
                    {
                        foreach (Block block in Block)
                        {
                            block.Complete = false;
                        }
            
                        Selected = 0;
                    }
                    public void Select(uint index)
                    {
                        if (Block.FirstOrDefault(e => e.Index == index) != null)
                            Selected = index;
                    }
                    public void Add(uint phase, string name, string displayName, uint timeout, string[] content)
                    {
                        Block.Add(new Block((uint)Block.Count, phase, name, displayName, timeout, content));
                    }
                    public Block Current()
                    {
                        return Selected != null ? Block[(int)Selected] : null;
                    }
                    public Block Get(string name)
                    {
                        return Block.Where(e => e.Name == name).FirstOrDefault();
                    }
                    public Block Get(uint index)
                    {
                        return Block.Where(e => e.Index == index).FirstOrDefault();
                    }
                    public void Run(uint index)
                    {

                    }
                    public void Run(string name)
                    {
                            
                    }
                    public override string ToString()
                    {
                        return base.ToString();
                    }
                }
            }

            
            // Old                         New                       Done
            // ---                         ---                       ----
            // VmNetworkMain               Network.Hierarchy         X
            // VmNetworkDhcp               Network.Dhcp              X
            // VmNetworkNode class         Network.Node              X
            // VmNodeScriptBlockController Network.Script.Controller X
            // SocketTcpServer                                       -
            // VmNodeSmbShare                                        -

            public class Controller
            {
                public Hierarchy              Hierarchy { get; set; }
                public Dhcp                        Dhcp { get; set; }
                public Node                        Node { get; set; }
                public Script.Controller         Script { get; set; }
                // public Connection.Controller Connection { get; set; }
                public Controller()
                {
                    
                }
            }
        }

        namespace Platform
        {
            // Machine specific, but also logical classes
            namespace Logical
            {
                // Domain and Netbios info
                [Serializable]
                public class Hierarchy
                {
                    public string  Domain { get; set; }
                    public string NetBios { get; set; }
                    public Hierarchy() { }
                }

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
                    public string          Type { get; set; }
                    public string          Name { get; set; }
                    public Format.ByteSize Size { get; set; }
                    public uint            Boot { get; set; }
                    public uint         Primary { get; set; }
                    public uint            Disk { get; set; }
                    public uint           Index { get; set; }
                    public Partition() { }
			    }
    
                // Represents a list of partitions which apply to FIXED disks (can apply to non-fixed, but not a priority ATM)
			    [Serializable]
			    public class Partitions
                {
                    public uint             Count { get; set; }
                    public List<Partition> Output { get; set; }
                    public Partitions() { }
			    }
    
                // Partitions contain volumes
			    [Serializable]
			    public class Volume
                {
                    public string       DriveID { get; set; }
                    public string   Description { get; set; }
                    public string    Filesystem { get; set; }
                    public Partition  Partition { get; set; }
                    public string    VolumeName { get; set; }
                    public string  VolumeSerial { get; set; }
                    public uint            Disk { get; set; }
                    public uint  PartitionIndex { get; set; }
                    public Format.ByteSize Free { get; set; }
                    public Format.ByteSize Used { get; set; }
                    public Format.ByteSize Size { get; set; }
                    public Volume() { }
			    }
    
                // Volumes contain the filesystem, operating system, and everything else
			    [Serializable]
			    public class Volumes
                {
                    public uint          Count { get; set; }
                    public List<Volume> Output { get; set; }
                    public Volumes() { }
			    }
            }

            // Hardware specific, may expand later
            namespace Hardware
            {
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
    
                // Represents a list of CPU's/processors (multiple threads/cores/processors)
                [Serializable]
                public class Processors
                {
                    public string            Name { get; set; }
                    public int              Count { get; set; }
                    public List<Processor> Output { get; set; }
                    public Processors() { }
			    }
    
                // Represents a physical disk + partitions + volumes
			    [Serializable]
                public class Disk
                {
                    public uint                          Rank { get; set; }
                    public uint                         Index { get; set; }
                    public string                    DeviceId { get; set; }
                    public string                       Model { get; set; }
                    public string                      Serial { get; set; }
                    public string              PartitionStyle { get; set; }
                    public string            ProvisioningType { get; set; }
                    public string           OperationalStatus { get; set; }
                    public string                HealthStatus { get; set; }
                    public string                     BusType { get; set; }
                    public string                    UniqueId { get; set; }
                    public string                    Location { get; set; }
                    public List<Logical.Partition> Partitions { get; set; }
                    public List<Logical.Volume>       Volumes { get; set; }
                    public Disk() { }
			    }
    
                // Represents a list of fixed disks (can apply to non-fixed, but not a priority ATM)
			    [Serializable]
                public class Disks
                {
                    public string       Name { get; set; }
                    public int         Count { get; set; }
                    public List<Disk> Output { get; set; }
                    public Disks() { }
			    }
    
                // Represents a physical network adapter and its' configuration
			    [Serializable]
                public class NetworkAdapter
                {
                    public uint                          Rank { get; set; }
                    public string                        Name { get; set; }
                    public string                 AdapterType { get; set; }
                    public string                Manufacturer { get; set; }
                    public string                  MacAddress { get; set; }
                    public string                 ServiceName { get; set; }
                    public string                    DeviceId { get; set; }
                    public string                 PnpDeviceId { get; set; }
                    public ulong                        Speed { get; set; }
                    public List<Network.Interface> Interfaces { get; set; }
                    public NetworkAdapter() { }
			    }
    
                // Represents a list of network adapters and their configurations
			    [Serializable]
                public class NetworkAdapters
                {
                    public string                 Name { get; set; }
                    public uint                  Count { get; set; }
                    public List<NetworkAdapter> Output { get; set; }
                    public NetworkAdapters() { }
			    }
            }
			
            // Network specific, may expand later
			namespace Network
            {
                // Network protocols will typically be IPv4 or IPv6, however other protocols exist, and need implementation here
			    public enum Protocol
                {
                    Unknown = 0,
                    IPv4    = 4,
                    IPv6    = 6,
                    IPX     = 7
                }
    
                // Network adapters will have an interface, and that interface will hold configurations
			    [Serializable]
                public class Interface
                {
                    public uint                         Index { get; set; }
                    public string                 Description { get; set; }
                    public string                 ServiceName { get; set; }
                    public uint                   DhcpEnabled { get; set; }
                    public string                  MacAddress { get; set; }
                    public List<Configuration> Configurations { get; set; }
                    public Interface() { }
			    }
    
                // Network adapter interfaces with (a) valid configuration(s) will be represented here, supports multiple addresses
			    [Serializable]
                public class Configuration
                {
                    public Protocol Protocol { get; set; }
                    public string    Address { get; set; }
                    public string SubnetMask { get; set; }
                    public string    Gateway { get; set; }
                    public string DnsServers { get; set; }
                    public string DhcpServer { get; set; }
                    public Configuration() { }
			    }

                // This represents both a local host, or a remote host, and can be used to perform a variety of tasks
                [Serializable]
                public class Host
                {
                    public string         Source { get; set; }
                    public string    Destination { get; set; }
                    public string       Hostname { get; set; }
                    public IPAddress IPv4Address { get; set; }
                    public IPAddress IPv6Address { get; set; }
                    public uint            Bytes { get; set; }
                    public uint             Time { get; set; }
                    public bool        Connected { get; set; }
                    public Host() { }
                }

                // This represents a Dynamic Host Control Protocol "seed", which bootstraps a particular Dhcp (server/client)
                [Serializable]
                public class Dhcp
                {
                    public string        Name { get; set; }
                    public string  SubnetMask { get; set; }
                    public string     Network { get; set; }
                    public string  StartRange { get; set; }
                    public string    EndRange { get; set; }
                    public string   Broadcast { get; set; }
                    public string[] Exclusion { get; set; }
                    public Dhcp()
                    {

                    }
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
            }

            // Registry/Binary configuration for reconstitution + persistence across platforms
            namespace Configuration
            {
                public enum Type
                {
                    Registry = 0,
                    FileSystem = 1,    
                }

                // Individual property for the FEModule configuration
                public class Property
                {
                    public uint   Index { get; set; }
                    public string  Name { get; set; }
                    public object Value { get; set; }
                    public bool  Exists { get; set; }
                    public Property() { }
                }

                // Provider class meant to orchestrate specific Windows registry paths or Linux configuration path
                public class Provider
                {
                    public Type       Type { get; set; }
                    public string    Drive { get; set; }
                    public string     Name { get; set; }
                    public string Fullname { get; set; }
                    public bool     Exists { get; set; }
                    private string    Root { get; set; }
                    private string    Path { get; set; }
                    private string  Branch { get; set; }
                    public List<Property> Property { get; set; }
                    public Provider() { }
                }
            }

            // All custom filesystem primitive extensions
            namespace FileSystem
            {
                // Entry type
                public enum Type
                {
                    Directory = 0,
                    File      = 1,
                }

                // Directory.Options mode
                public enum Mode : uint
                {
                    Directory = 0,
                    File      = 1,
                    All       = 2,
                }

                // Used for raw file system enumeration via P/Invoke
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
                }

                // For transferring files from one location to another (to be extended)
                public class Transfer
                {
                    FileStream      Source { get; set; }
                    FileStream Destination { get; set; }
                    byte[]          Buffer { get; set; }
                    public Transfer() { }
                }

                // Flags for the directory controller
                public class Option
                {
                    public Mode     Mode { get; set; }
                    public bool  Recurse { get; set; }
                    public string Filter { get; set; }
                    public Option() { }
                }

                // Controls all of the above classes, subdirectories do not use this
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
                    public Option                 Option { get; set; }
                    public virtual List<Entry>     Entry { get; set; }
                    public Directory() { }
                }
            }

            namespace Security
            {
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
                    public override string ToString()
                    {
                        return string.Format("Username: {0}, Password: {1}", Username, Password);
                    }
                }
            }

            // PowerShell class extensions
            namespace PowerShell
            {
                namespace Drive
                {
                    public enum Slot
                    {
                        PSDrive  = 0,
                        Template = 1
                    }

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
        }

        namespace Module
        {
            public struct Template
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

            namespace Host
            {
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

                public class Provider : Platform.PowerShell.Drive.Provider
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
                    public string Auto(string name)
                    {
                        return string.Format("<Custom[{0}]>", name);
                    }
                    public Platform.PowerShell.Drive.Mode GetMode(string name)
                    {
                        var mode = Platform.PowerShell.Drive.Mode.Unspecified;

                        return Enum.TryParse<Platform.PowerShell.Drive.Mode>(name, true, out var result) ? result : mode;
                    }
                    public override string ToString()
                    {
                        return Name;
                    }
                }

                public class Drive : Platform.PowerShell.Drive.Entry
                {
                    public Drive() : base() { }
                    public Drive(uint index, System.Management.Automation.PSDriveInfo drive, bool isDefault, bool isVirtual)
                    {
                        Index           = index;
                        Slot            = Platform.PowerShell.Drive.Slot.PSDrive;
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
                    public Drive(uint index, string name, string provider, string root, Platform.PowerShell.Drive.Scope scope, string desc, bool isVirtual)
                    {
                        Index           = index;
                        Slot            = Platform.PowerShell.Drive.Slot.Template;
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

                        Slot            = Platform.PowerShell.Drive.Slot.PSDrive;

                        DisplayRoot     = drive.DisplayRoot;
                        CurrentLocation = drive.CurrentLocation;
                        Scope           = GetScope(drive);
                        
                        Credential      = drive.Credential != null ? new Platform.Security.Credential(drive.Credential) : null;

                        Unc             = Root != null && Regex.IsMatch(Root, @"^(\\\\|//)");
                        Mapped          = Name.Length == 1 && Unc;
                        NetworkDrive    = Provider.Mode == Platform.PowerShell.Drive.Mode.FileSystem && Unc;
                        AutoMounted     = Provider.Mode != Platform.PowerShell.Drive.Mode.FileSystem;
                    }
                    public Platform.PowerShell.Drive.Scope GetScope(System.Management.Automation.PSDriveInfo drive)
                    {
                        var prop = GetProperty(drive, "Scope", "DriveScope");
                        if (prop != null)
                        {
                            object val = GetValue(drive, prop);

                            if (val != null)
                            {
                                Enum.TryParse<Platform.PowerShell.Drive.Scope>(val.ToString(), true, out var result);
                                return result;
                            }
                        }

                        return Platform.PowerShell.Drive.Scope.Unspecified;
                    }
                    public void SetScope(Platform.PowerShell.Drive.Scope scope)
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
                        Scope           = Platform.PowerShell.Drive.Scope.Unspecified;
                        
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
                    internal void SetStatus(string status)
                    {
                        Status = status;
                    }
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
                    internal void SetInitial()     => SetState("Initial");
                    internal void SetOperational() => SetState("Operational");
                    internal void SetRestricted()  => SetState("Restricted");
                    internal void SetElevated()    => SetState("Elevated");
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
                    public override string ToString()
                    {
                        return string.Format("{0}, {1}, {2}", Name, DisplayName, Label);
                    }
                }

                public class Controller
                {
                    public string               Caption { get; set; }
                    public Architecture?   Architecture { get; set; }
                    public OS                        OS { get; set; }
                    public string              Platform { get; set; }
                    public Version?           PSVersion { get; set; }
                    public Option                Option { get; set; }
                    public List<Drive>            Drive { get; set; }
                    public System.Management.Automation.EngineIntrinsics Context { get; set; }
                    public Controller(System.Management.Automation.EngineIntrinsics context)
                    {
                        Context = context;
                        Drive   = new List<Drive>();
                        Option  = new Option();

                        Option.SetInitial();
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
                        Platform     = null;
                    }
                    public void Initial()
                    {
                        Caption      = RuntimeInformation.OSDescription.ToString();
                        Architecture = GetArchitecture();
                        PSVersion    = GetPSVersion();

                        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                        {
                            OS          = Regex.IsMatch(Caption, "Server") ? OS.Win32_Server : OS.Win32_Client;
                            Platform    = OS == OS.Win32_Server ? "Windows.Server" : "Windows.Client";
                        }
                        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                        {
                            OS          = OS.Unix;
                            Platform    = "Unix";
                        }
                        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                        {
                            OS          = OS.OSX;
                            Platform    = "OSX";   
                        }
                        else
                        {
                            OS          = OS.Unspecified;
                            Platform    = "Unspecified";
                        }

                        Load();
                        Option.SetOperational();
                    }
                    public void Load()
                    {
                        foreach (PSDriveInfo drive in Context.SessionState.Drive.GetAll())
                        {
                            Add(drive, true, false);
                        }
                    }
                    public Drive Get(string name)
                    {
                        return Drive.FirstOrDefault(e => string.Equals(e.Name, name, StringComparison.OrdinalIgnoreCase));
                    }
                    public void Add(System.Management.Automation.PSDriveInfo info, bool isDefault, bool isVirtual)
                    {
                        Drive drive = Get(info.Name);

                        if (drive == null)
                        {
                            Drive.Add(new Drive((uint)Drive.Count, info, isDefault, isVirtual));
                        }
                    }
                    public void Add(string driveName, string provider, string root, Core.Platform.PowerShell.Drive.Scope scope, string description, bool isVirtual)
                    {
                        Drive drive = Get(driveName);

                        if (drive == null)
                        {
                            Drive.Add(new Drive((uint)Drive.Count, driveName, provider, root, Core.Platform.PowerShell.Drive.Scope.Script, description, isVirtual));
                        }
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
                            {
                                drive.Exists = false;
                            }
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
                        {
                            Drive[x].Index = (uint)x;
                        }
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

                        // PowerShell 7+ (SemanticVersion)
                        if (value is System.Management.Automation.SemanticVersion sem)
                        {
                            return new Version(sem.Major, sem.Minor, sem.Patch);
                        }

                        // Windows PowerShell 5.1 (System.Version)
                        if (value is Version ver)
                        {
                            return ver;
                        }

                        // Fallback
                        return new Version(0,0);
                    }
                    public override string ToString()
                    {
                        return string.Format("<{0}, {1}/{2}, PSVersion: {3}>", Caption, Platform, OS.ToString(), PSVersion);
                    }
                }
            }

            namespace Interop
            {
                public abstract class Controller
                {
                    public abstract string Name { get; }
                    public abstract void LoadRegistry();
                    public abstract void LoadSecurity();
                    public abstract void LoadToast();
                    public abstract void LoadHardware();
                    public abstract void LoadNetwork();
                    public abstract void LoadProcess();
                    public abstract void LoadThread();
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
                    public uint      Index;
                    public Mode       Mode;
                    public string     Name;
                    public string Fullname;
                    public bool     Exists;
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
                        if (Name == "Registry")
                        {
                            // Exists = RegistryKeyController.PathExists(Fullname);
                        }
                        else
                        {
                            Exists = File.Exists(Fullname) || Directory.Exists(Fullname);   
                        }
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

                public class Controller
                {
                    public Property Registry;
                    public Property Resource;
                    public Property   Module;
                    public Property     File;
                    public Property Manifest;
                    public Property Shortcut;
                    public Controller()
                    {

                    }
                    public void Assign(Module.Template template)
                    {
                        Registry = new Property(0, 0, "Registry" , template.Registry);
                        Resource = new Property(1, 0, "Resource" , template.Resource);
                        Module   = new Property(2, 0, "Module"   , template.Module);
                        File     = new Property(3, 1, "File"     , template.File);
                        Manifest = new Property(4, 1, "Manifest" , template.Manifest);
                        Shortcut = new Property(5, 1, "Shortcut" , template.Shortcut);
                    }
                    public Property[] List()
                    {
                        return new Property[] { Registry, Resource, Module, File, Manifest, Shortcut };
                    }
                    public void Refresh()
                    {
                        foreach (Property prop in List())
                        {
                            prop.Check();
                        }
                    }
                    public override string ToString()
                    {
                        return string.Format("<{0}>", base.ToString());
                    }
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
                    public uint               Index;
                    public Mode                Mode;
                    public Type                Type;
                    private Tag                 Tag;
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
                    public void Clear()
                    {
                        Bytes       = new byte[0];
                    }
                    public void Check()
                    {
                        if (Mode == Manifest.Mode.Directory)
                        {
                            DirectoryInfo info = new DirectoryInfo(Fullname);

                            Exists = info.Exists;
                            Size   = new Format.ByteSize("Directory", 0UL);

                            if (Exists)
                            {
                                Date   = Exists ? new Format.ModDateTime(info.LastWriteTime) : null;
                            }
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
                            {
                                Size   = new Format.ByteSize("File", 0UL);
                            }
                        }
                    }
                    public void Create()
                    {
                        Check();

                        if (Mode == Manifest.Mode.Directory && Exists == false)
                        {
                            Directory.CreateDirectory(Fullname);
                        }
                        else if (Mode == Manifest.Mode.File && Exists == false)
                        {
                            File.Create(Fullname).Dispose();
                        }

                        Check();
                    }
                    public void Remove()
                    {
                        Check();

                        if (Mode == Manifest.Mode.Directory && Exists == true)
                        {
                            Directory.Delete(Fullname);
                        }
                        else if (Mode == Manifest.Mode.File && Exists == true)
                        {
                            File.Delete(Fullname);
                        }

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

                            Bytes = File.ReadAllBytes(Fullname);

                            Check();
                        }
                    }
                    public void Write()
                    {
                        if (Mode != Manifest.Mode.File)
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
                        if (Mode != Manifest.Mode.File)
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
                    public Content[] Lines()
                    {
                        string[] content = Content();

                        List<Content> lines = new List<Content>();

                        foreach (string line in content)
                        {
                            lines.Add(new Content((uint)lines.Count, line));
                        }

                        return lines.ToArray();
                    }
                    public void Download()
                    {
                        if (Mode != Manifest.Mode.File)
                            throw new InvalidOperationException("Exception [!] Item is a directory, not a file");

                        Check();

                        if (!Exists)
                            Create();

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

                        Bytes = Encoding.UTF8.GetBytes(content);

                        Write();
                    }
                    public string Status()
                    {
                        string token = Exists ? "+" : "_";
                    
                        if (Mode == Manifest.Mode.Directory)
                            return string.Format("[{0}] {1} : {2}", token, Name.PadRight(8), Fullname);
                        else
                            return string.Format("[{0}] {1} | {2}", token, Name.PadRight(31), Hash);
                    }
                    public override string ToString()
                    {
                        return Fullname;
                    }
                }

                public class Controller
                {
                    public Version    Version;
                    public string      Source;
                    public string    Resource;
                    public List<Entry>  Entry;
                    public Controller()
                    {
                        Clear();
                    }
                    public void Assign(Module.Template template)
                    {
                        Version  = new Version(template.Version);
                        Source   = template.Source;
                        Resource = template.Resource;
                    }
                    public void Clear()
                    {
                        Entry    = new List<Entry>();
                    }
                    public Entry Last()
                    {
                        return Entry[Entry.Count-1];
                    }
                    public string LastStatus()
                    {
                        return Last().Status();
                    }
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
                        {
                            entry.Check();
                        }
                    }
                    public override string ToString()
                    {
                        return string.Format("<{0}>", base.ToString());
                    }
                }
            }

            public class Revision
            {
                public Format.Version  Version { get; set; }
                public Format.ModDateTime Time { get; set; }
                public string             Date { get; set; }
                public Guid               Guid { get; set; }
                public Revision(Version version, Format.ModDateTime time, Guid guid)
                {
                    // Supplied from registry/config
                    Version = version;
                    Time    = time;
                    Date    = Time.DateString();
                    Guid    = guid;
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
                        Time     = new Format.ModDateTime(DateTime.Parse(xtime));
                        Date     = Time.DateString();
                        Guid     = new Guid(xguid);
                    }
                }
                public Revision(bool createNew, int minor)
                {
                    // Automatic new
                    Time    = new Format.ModDateTime(DateTime.Now);
                    Date    = Time.DateString();
                    Version = new Version(Time.Value.ToString("yyyy.MM.") + minor);
                    Guid    = System.Guid.NewGuid();
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
                public override string ToString()
                {
                    return Version.ToString();
                }
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
                public void Update(int state, string status)
                {
                    // Updates the console, writes a message if in correct mode
                    Console.Update(state, status);
                }
                public void Write(int state, string status)
                {
                    if (Console.Mode != Core.Console.Mode.Silent)
                    {
                        // Silent mode
                        Console.SetMode(2);
                    }

                    // insert logic so that it adds every track it produces, AS it is produced
                    Theme.Refresh(new object[]{ status });
                    
                    // WriteTrack(index)
                    foreach (Theme.Template.Track track in Theme.Track)
                    {
                        Update(state, track.Text());
                    }

                    Theme.Write();

                    if (Console.Mode != Core.Console.Mode.Full)
                    {
                        // Full mode
                        Console.SetMode(0);
                    }
                }
                public void Write(uint palette, int state, string status)
                {
                    if (Console.Mode != Core.Console.Mode.Silent)
                    {
                        // Silent mode
                        Console.SetMode(2);
                    }

                    // Set color scheme
                    Theme.SetPalette(palette); 

                    // insert logic so that it adds every track it produces, AS it is produced
                    Theme.Refresh(new object[]{ status });
                    
                    // WriteTrack(index)
                    foreach (Theme.Template.Track track in Theme.Track)
                    {
                        Update(state, track.Text());
                    }

                    Theme.Write();

                    if (Console.Mode != Core.Console.Mode.Full)
                    {
                        // Full mode
                        Console.SetMode(0); 
                    }
                }
                private void Initialize(EngineIntrinsics context)
                {
                    LoadConsole();
                    LoadTheme();
                    LoadHost(context);
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
                    return "2026.8.0";
                }
                public string Now()
                {
                    return Format.ModDateTime.Now().ToString();
                }
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
                            string line = string.Format("Loading [~] {0}[{1}]", DisplayName(), CurrentVersion());
                            
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

                            Write(0, "[+] <Host>: {0}" + Host);
                        }
                        catch
                        {
                            Update(-1, "Exception [!]  <Host> not loaded");
                        }
                    }
                }
                public void GetRoot()
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
                public void GetManifest()
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
            }
        }

    }

    namespace Linux
    {
        namespace FileSystem
        {
            public class Raw : Core.Platform.FileSystem.Raw { }
            public class Entry : Core.Platform.FileSystem.Entry
            {
                public Entry(uint index, Raw raw) : base()
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
                        IntPtr dir = opendir(current);

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

                                string fullname = Path.Combine(current, name);
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
                                    Fullname    = Path.GetFullPath(fullname),
                                    Extension   = isDir ? "" : Path.GetExtension(name),
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
                    Name     = Path.GetFileName(fullname);
            
                    SetMode(mode);
                    SetRecurse(recurse);
                    SetFilter(filter);
            
                    Refresh();
                }
                public void SetType(string type)      => Label = type;
                public void SetLabel(string label)    => Label = label;
                public void SetMode(uint mode)        => Option.Mode    = (Core.Platform.FileSystem.Mode)mode;
                public void SetRecurse(bool recurse)  => Option.Recurse = recurse;
                public void SetFilter(string pattern) => Option.Filter  = pattern;
                public void Check()
                {
                    DirectoryInfo di = new DirectoryInfo(Fullname);
            
                    Exists = di.Exists;
                    if (Exists)
                    {
                        Created  = new Format.ModDateTime(di.CreationTime);
                        Modified = new Format.ModDateTime(di.LastWriteTime);
                    }
                    else
                    {
                        Created  = null;
                        Modified = null;
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
            
                    // LINUX RAW ENUMERATION
                    List<Raw> raw = new DirectoryScan().Scan(Fullname, Option.Recurse);
            
                    raw.Sort((a, b) => string.Compare(a.Fullname, b.Fullname, StringComparison.OrdinalIgnoreCase));
            
                    foreach (var r in raw)
                    {
                        if (r.IsDirectory && includeDirs)
                        {
                            if (!r.IsReparse)
                            {
                                var e          = new Core.Platform.FileSystem.Entry
                                {
                                    Index      = (uint)Entry.Count,
                                    Type       = Core.Platform.FileSystem.Type.Directory,
                                    Name       = r.Name,
                                    Fullname   = r.Fullname,
                                    Extension  = "",
                                    Created    = new Format.ModDateTime(r.Created),
                                    Modified   = new Format.ModDateTime(r.Modified),
                                    Size       = new Format.ByteSize("Directory", r.Size),
                                    Exists     = true
                                };
            
                                if (rx == null || rx.IsMatch(e.Name))
                                    Entry.Add(e);
                            }
                        }
                        else if (!r.IsDirectory && includeFiles)
                        {
                            var e          = new Core.Platform.FileSystem.Entry
                            {
                                Index      = (uint)Entry.Count,
                                Type       = Core.Platform.FileSystem.Type.File,
                                Name       = r.Name,
                                Fullname   = r.Fullname,
                                Extension  = Path.GetExtension(r.Name).TrimStart('.'),
                                Created    = new Format.ModDateTime(r.Created),
                                Modified   = new Format.ModDateTime(r.Modified),
                                Size       = new Format.ByteSize("File", r.Size),
                                Exists     = true
                            };
            
                            if (rx == null || rx.IsMatch(e.Name))
                                Entry.Add(e);
                        }
                    }
            
                    Size = Option.Recurse ? GetRecursiveBytes() : GetListBytes();
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

        // end namespace [Linux]
    }

    // end namespace [FightingEntropy]
}
