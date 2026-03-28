using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using System.Text.RegularExpressions;

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
    }

    namespace Theme
    {
        public class InputLine
        {
            public uint    Index;
            public uint     Rank;
            public uint     Line;
            public string  Value;
            public uint   Length;
            public InputLine(uint index, uint rank, uint line, string value)
            {
                Index  = index;
                Rank   = rank;
                Line   = line;
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

        public class InputContainer
        {
            public uint             Index;
            public uint              Rank;
            public string            Type;
            public uint             Count;
            public List<InputLine>   Line;
            public InputContainer(uint index, uint rank, string type, string[] lines)
            {
                Index = index;
                Rank  = rank;
                Type  = type;

                Refresh(lines);
            }
            public void Refresh(string[] lines)
            {
                Line  = new List<InputLine>();

                for (int x = 0; x < lines.Length; x++)
                {
                    InputLine line = new InputLine(Index, Rank, (uint)x, lines[x]);

                    Line.Add(line);
                }

                Count = (uint)lines.Length;
            }
            public override string ToString()
            {
                return string.Format("[{0}]({1})", Type, Count);
            }
        }

        public class InputItem
        {
            public uint                  Index;
            public string                 Type;
            public List<InputContainer> Output;
            public InputItem(uint index, string type)
            {
                Index  = index;
                Type   = type;
                Output = new List<InputContainer>();
            }
            public override string ToString()
            {
                return string.Format("[{0}]({1})", Type, Output.Count);
            }
        }

        public class InputObject
        {
            public TemplateType      Type;
            public uint            Height;
            public List<InputItem>  Input;
            public List<InputLine> Output;
            public InputObject(object[] inputObject)
            {
                BuildInput(inputObject);
                BuildOutput();
            }
            public InputObject(TemplateType type, object[] inputObject)
            {
                Type = type;
                BuildInput(inputObject);
                BuildOutput();
            }
            public string[] ConvertHashtable(Hashtable table)
            {
                List<string> lines = new List<string>();

                // Extract keys
                List<string> keys = new List<string>();
                foreach (object key in table.Keys)
                    keys.Add(key.ToString());

                // Compute longest key
                int buffer = GetMaxLength(keys);

                // Build aligned output
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

                // Extract properties
                var pso = System.Management.Automation.PSObject.AsPSObject(obj);

                // Compute longest property name
                int buffer = 0;

                foreach (var prop in pso.Properties)
                {
                    if (prop.Name.Length > buffer)
                        buffer = prop.Name.Length;
                }

                // Build aligned output
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

                // Normalize line endings
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

                        if (System.Text.RegularExpressions.Regex.IsMatch(line, "[|_¯]"))
                        {
                            lines.Add(line);
                            continue;
                        }

                        words  = line.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        buffer = "";

                        for (int w = 0; w < words.Length; w++)
                        {
                            word = words[w];

                            // If the word alone exceeds width, force it as its own line
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

                            // If adding this word would overflow, push current buffer
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

                        // Add final buffer for this line
                        if (buffer.Length > 0)
                            lines.Add(buffer);
                    }

                    return lines.ToArray();
                }
            }
            public string[] ConvertScript(string script)
            {
                List<string> lines = new List<string>();

                string pattern = "([\"']?)([A-Za-z_][A-Za-z0-9_-]*)\\1\\s*=\\s*(?:([\"'])(.*?)\\3|([^;]+))";

                string  scriptString = script.ToString().Replace("\r\n", "\n").Replace("\r", "\n");
                string[] scriptLines = scriptString.Split('\n');

                MatchCollection matches = Regex.Matches(scriptLines[0], pattern);

                if (matches.Count == 0)
                {
                    for (int x = 0; x < scriptLines.Length; x++)
                    {
                        lines.Add(scriptLines[x]);
                    }

                    return lines.ToArray();
                }

                // Collect keys and values
                List<string> names  = new List<string>();
                List<string> values = new List<string>();

                for (int i = 0; i < matches.Count; i++)
                {
                    Match m = matches[i];

                    names.Add(m.Groups[2].Value);

                    if (m.Groups[4].Success)
                        values.Add(m.Groups[4].Value);
                    else
                        values.Add(m.Groups[5].Value.Trim());
                }

                // Compute longest key
                int buffer = GetMaxLength(names);

                // Build aligned output
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
                    case "String"      :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertString(s);
                    }
                    case "Hashtable"   :
                    {
                        return ConvertHashtable((Hashtable)obj);
                    }
                    case "ScriptBlock" :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertScript(s);
                    }
	                case "PSObject"    :
                    {
                        return ConvertObject(obj);
                    }
	                case "Int"         :
                    {
                        string s = (obj == null) ? "" : obj.ToString();
                        return ConvertString(s);
                    }
	                case "Object[]"    :
                    {
                        return null;
                    }
                    default            :
                    {
                        return null;
                    }
                }
            }
            public string DetermineType(object value)
            {
                // String
                if (value == null || value is string)
                    return "String";

                // Hashtable
                if (value is Hashtable)
                    return "Hashtable";

                // ScriptBlock
                if (value is System.Management.Automation.ScriptBlock)
                    return "ScriptBlock";

                // PSObject (but not Hashtable)
                if (value is System.Management.Automation.PSObject && value.GetType().Name != "Hashtable")
                    return "PSObject";

                // Numeric primitives
                if (value is int || value is double || value is decimal)
                    return "Int";

                // Array
                if (value is IEnumerable)
                    return "Object[]";

                // Fallback: CLR type name
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
                Input = new List<InputItem>();

                foreach (object obj in inputObject)
                {
                    string    type = DetermineType(obj);

                    if (type != "Object[]")
                    {
                        string[] lines = ConvertByType(type, obj);

                        InputItem item = new InputItem((uint)Input.Count, type);

                        InputContainer container = new InputContainer(item.Index, 0, type, lines);

                        item.Output.Add(container);

                        Input.Add(item);
                    }
                    else
                    {
                        IEnumerable enumerable = (IEnumerable)obj;

                        InputItem item = new InputItem((uint)Input.Count, "Object[]");

                        foreach (object element in enumerable)
                        {
                            string etype = DetermineType(element);
                            string[] lines = ConvertByType(etype, element);

                            InputContainer container = new InputContainer(item.Index, (uint)item.Output.Count, etype, lines);

                            item.Output.Add(container);
                        }

                        Input.Add(item);
                    }
                }
            }
            public void BuildOutput()
            {
                Output = new List<InputLine>();

                for (int i = 0; i < Input.Count; i++)
                {
                    InputItem item = Input[i];

                    for (int c = 0; c < item.Output.Count; c++)
                    {
                        InputContainer container = item.Output[c];

                        // Emit all lines in this container
                        for (int l = 0; l < container.Line.Count; l++)
                        {
                            Output.Add(container.Line[l]);
                        }

                        // Padding between containers (Rule 3)
                        if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                        {
                            if (c < item.Output.Count - 1)
                            {
                                Output.Add(new InputLine((uint)Output.Count, item.Index, (uint)c, ""));
                            }
                        }
                    }

                    // Padding between items (Rule 4)
                    if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                    {
                        if (i < Input.Count - 1)
                        {
                            Output.Add(new InputLine((uint)Output.Count, item.Index, 0, ""));
                        }
                    }
                }

                Height = (uint)Output.Count;

                if (Type != TemplateType.Banner && Type != TemplateType.Flag)
                {
                    if (Height > 1)
                    {
                        Type = TemplateType.Section;
                    }
                    else
                    {
                        string line = (Output.Count > 0) ? Output[0].ToString() : "";
                        Regex    rx = new Regex(@"^(\w+)\s(\[(\+|-|~|!)\])\s(.+)");
                        Match    mx = rx.Match(line);
                    
                        if (mx.Success)
                        {
                            Type = TemplateType.Action;
                        }
                        else
                        {
                            Type = TemplateType.Function;
                        }
                    }
                    
                    for (int i = 0; i < Output.Count; i ++)
                    {
                        Output[i].Index = (uint)i;
                    }
                }
            }
        }

        public class TemplateSlice
        {
            public uint       Rank;
            public string     Text;
            public uint? Foreground = null;
            public uint? Background = null;
            public bool      Locked = false;
            public TemplateSlice(uint rank, string text)
            {
                Rank       = rank;
                Text       = text;
            }
            public TemplateSlice(uint rank, string text, uint foreground, uint background)
            {
                Rank       = rank;
                Text       = text;
                Foreground = foreground;
                Background = background;
            }
        }

        public enum TemplateType
        {
            Function = 0,
            Action   = 1,
            Section  = 2,
            Table    = 3,
            Banner   = 4,
            Flag     = 5,
            General  = 6,
        }

        public enum TemplateTrackType
        {
            Template = 0,
            Single   = 1,
            Title    = 2,
            Body     = 3,
            Prompt   = 4,
        }
        
        public class TemplatePalette
        {
            public uint   Index;
            public uint[] Value;
            public TemplatePalette(uint index, uint[] value)
            {
                Index = index;
                Value = value;
            }
            public override string ToString()
            {
                return string.Format("({0}) {{{1},{2},{3},{4}}}", Index, Value[0], Value[1], Value[2], Value[3]);
            }
        }

        public class TemplateFace
        {
            public uint    Index;
            public string String;
            public char[]  Value;
            public uint[]  Bytes;
            public string    Hex;
            public TemplateFace(uint index, string hex)
            {
                Index = index;
                Hex   = hex;

                // Convert hex pairs into uint bytes
                Bytes = new uint[4];
                int b = 0;

                for (int i = 0; i < 8; i += 2)
                {
                    string pair = hex.Substring(i, 2);
                    Bytes[b]    = System.Convert.ToUInt32(pair, 16);
                    b++;
                }

                // Convert bytes to chars
                Value = new char[Bytes.Length];
                for (int i = 0; i < Bytes.Length; i++)
                {
                    Value[i] = (char)Bytes[i];
                }

                // Build string from chars
                String = new string(Value);
            }
            public override string ToString()
            {
                return string.Format("({0}) {{{1}}}", Index, String);
            }
        }

        public class TemplateBytes
        {
            public string       Type;
            public string     String;
            public List<uint>  Bytes;
            public TemplateBytes(string type, string inputString)
            {
                Bytes = new List<uint>();

                // Tokenizer pattern (same as your PowerShell)
                string pattern = @"@\((?:\d+[;,]?)+\)\*\d+|\d+";
                MatchCollection mx = Regex.Matches(inputString, pattern);

                for (int i = 0; i < mx.Count; i ++)
                {
                    string token = mx[i].Value;

                    // CASE 1 — plain number
                    if (Regex.IsMatch(token, @"^\d+$"))
                    {
                        Bytes.Add(Convert.ToUInt32(token));
                        continue;
                    }

                    // CASE 2 — single-value repetition @(5)*2
                    if (Regex.IsMatch(token, @"^@\(\d+\)\*\d+$"))
                    {
                        // Remove @( and ) then split on *
                        string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                        string[] split = cleaned.Split('*');

                        uint number = Convert.ToUInt32(split[0]);
                        uint factor = Convert.ToUInt32(split[1]);

                        for (uint x = 0; x < factor; x++)
                        {
                            Bytes.Add(number);
                        }

                        continue;
                    }

                    // CASE 3 — multi-value repetition @(8;9)*5
                    if (Regex.IsMatch(token, @"^@\(\d+[;,]\d+(?:[;,]\d+)*\)\*\d+$"))
                    {
                        string cleaned = Regex.Replace(token, @"(@\(|\))", "");
                        string[] split = cleaned.Split('*');

                        // Split inner values on ; or ,
                        string[] range = Regex.Split(split[0], "[;,]");
                        uint factor = Convert.ToUInt32(split[1]);

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
                return "<FightingEntropy.Theme.TemplateBytes>";
            }
        }

        public class TemplateBlock
        {
            public uint        Index;
            public uint        Track;
            public uint         Rank;
            public string       Text;
            public uint   Foreground;
            public uint   Background;
            public bool       Locked = false;
            public TemplateBlock(uint track, uint rank, string text, uint foreground, uint background)
            {
                Track      = track;
                Rank       = rank;
                Text       = text;
                Foreground = foreground;
                Background = background;
            }
            public void Update(TemplateSlice slice)
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
                if (Locked != true)
                {
                    Locked = true;
                }
            }
            public override string ToString()
            {
                return Text;
            }
        }

        public class TemplateTrack
        {
            public uint                  Index;
            public uint                   Rank;
            internal uint                Total;
            public TemplateTrackType      Type;
            internal TemplateBytes        Mask;
            internal TemplateBytes  Foreground;
            internal TemplateBytes  Background;
            public List<TemplateBlock>   Block;
            public TemplateTrack(uint index, uint rank, string mask, string foreground, string background)
            {
                Index      = index;
                Rank       = rank;

                SetType("Template");

                Mask       = new TemplateBytes("Mask",mask);
                Foreground = new TemplateBytes("Foreground",foreground);
                Background = new TemplateBytes("Background",background);

                Clear();
            }
            public void SetType(string type)
            {
                switch (type)
                {
                    case "Template" : Type = TemplateTrackType.Template ; break;
                    case "Single"   : Type = TemplateTrackType.Single   ; break;
                    case "Title"    : Type = TemplateTrackType.Title    ; break;
                    case "Body"     : Type = TemplateTrackType.Body     ; break;
                    case "Prompt"   : Type = TemplateTrackType.Prompt   ; break;
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
                    case "Mask"       : return Mask.Bytes.ToArray();
                    case "Foreground" : return Foreground.Bytes.ToArray();
                    case "Background" : return Background.Bytes.ToArray(); 
                    default           : return null;
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
                        // Single number: "14"
                        list.Add(UInt32.Parse(item));
                    }
                }

                for (int i = 0; i < list.Count; i++)
                {
                    Block[(int)list[i]].Lock();
                }
            }
            public void Clear()
            {
                Block = new List<TemplateBlock>();
            }
        }

        public class TemplateDraft
		{
			public char[]      Face;
			public string RowHeader;
			public uint     Padding;
			public uint    MaxIndex;
			public int        Width;
            public TemplateDraft(List<TemplateTrack> tracks)
            {
                Face    = new char[] { '_', '¯','=' };

                Stage(tracks);
            }
            private void Stage(List<TemplateTrack> tracks)
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
                    case "HeaderFrame":
                    {
                        return new string(Face[0], (int)Padding);
                    }
                    case "HeaderRuler":
                    {
                        return Ruler(0);
                    }
                    case "Partition"  :
                    {
                        return Ruler(2);
                    }
                    case "FooterRuler":
                    {
                        return Ruler(1);
                    }
                    case "FooterFrame":
                    {
                        return new string(Face[1], (int)Padding);
                    }
                    default :
                    {
                        return null;
                    }
                }
            }
		}

        public class Controller
        {
            public TemplateType         Type;
            public TemplatePalette   Palette;
            public List<TemplateFace>   Face;
            public InputObject            IO;
            public Guid                 Guid;
            public Format.ModDateTime   Time;
            public string              Title;
            public string             Prompt;
            public List<TemplateTrack> Track;
            public Controller()
            {
                Initialize();
                Populate();
            }
            public static Controller Banner()
            {
                // static instance [Banner], starts w/ Initialize() and Populate()
                Controller c = new Controller();

                c.Refresh(TemplateType.Banner, c.BannerText());
                c.Write();

                return c;
            }
            public static Controller Flag()
            {
                // static instance [Flag], starts w/ Initialize() and Populate()
                Controller c = new Controller();

                c.Refresh(TemplateType.Flag, c.FlagText());
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
            public Controller(object inputObject, uint palette)
            {
                Initialize(palette);
                Populate();
                Refresh(new object[]{ inputObject });
            }
            public Controller(object inputObject, string title, uint palette)
            {
                Initialize(palette);
                Populate(title);
                Refresh(new object[]{ inputObject });
            }
            public Controller(object inputObject, string title, string prompt, uint palette)
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
            public Controller(object[] inputObject, uint palette)
            {
                Initialize(palette);
                Populate();
                Refresh(inputObject);
            }
            public Controller(object[] inputObject, string title, uint palette)
            {
                Initialize(palette);
                Populate(title);
                Refresh(inputObject);
            }
            public Controller(object[] inputObject, string title, string prompt, uint palette)
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
                IO       = new InputObject(inputObject);
                SetType((uint)IO.Type);
                GenerateTemplate();
                Reset();
            }
            public void Refresh(TemplateType type, object[] inputObject)
            {
                IO       = new InputObject(type, inputObject);
                SetType((uint)IO.Type);

                if (Type == TemplateType.Function || Type == TemplateType.Action || Type == TemplateType.Section)
                {
                    GenerateTemplate();   
                }
                else if (Type == TemplateType.Banner)
                {
                    GenerateBanner();
                }
                else if (Type == TemplateType.Flag)
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

                Palette = new TemplatePalette(index, PaletteBytes((uint)index));
            }
            public void SetType(uint type)
            {
                if (type > 5)
                {
                    throw new Exception("Invalid type [" + type + "]");
                }

                switch (type)
                {
                    case 0 : Type = TemplateType.Function ; break;
                    case 1 : Type = TemplateType.Action   ; break;
                    case 2 : Type = TemplateType.Section  ; break;
                    case 3 : Type = TemplateType.Table    ; break;
                    case 4 : Type = TemplateType.Banner   ; break;
                    case 5 : Type = TemplateType.Flag     ; break;
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

                Face = new List<TemplateFace>();

                for (uint x = 0; x < faceHex.Length; x++)
                {
                    TemplateFace item = new TemplateFace(x,faceHex[x]);
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
            public TemplateTrack BuildTrack(uint index, uint rank, string mask, string foreground, string background)
            {
                TemplateTrack track = new TemplateTrack(index, rank, mask, foreground, background);
                
                for (int x = 0; x < track.Mask.Bytes.Count; x++)
                {
                    string text = Face[(int)track.Mask.Bytes[x]].String;
                    uint   fore = track.Foreground.Bytes[x];
                    uint   back = track.Background.Bytes[x];
                
                    TemplateBlock block = new TemplateBlock(index, (uint)x, text, fore, back);
                
                    track.Block.Add(block);
                }

                return track;
            }
            public void GenerateTemplate()
            {
                Track         = new List<TemplateTrack>();

                string[] mask = TemplateMask();
                string[] fore = TemplateForeground();
                string[] back = TemplateBackground();

                uint    index = 0;

                switch (Type)
                {
                    case TemplateType.Function:
                    {
                        uint[] rankOrder = {0, 1, 2, 3, 4};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                            if (index == 3)
                            {
                                track.SetType("Single");
                            }

                            Track.Add(track);
                            index ++;
                        }
                        break;
                    }
                    case TemplateType.Action:
                    {
                        uint[] rankOrder = {5, 6, 7, 8, 9};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

                            if (index == 2)
                            {
                                track.SetType("Single");
                            }

                            Track.Add(track);
                            index ++;
                        }
                        break;
                    }
                    case TemplateType.Section:
                    {
                        uint[] rankOrder = {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};

                        for (uint i = 0; i < rankOrder.Length; i++)
                        {
                            int    ri = (int)rankOrder[i];
                            uint rank = rankOrder[i];

                            if (rank != 14)
                            {
                                TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

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
                                    TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);

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
                                    TemplateTrack track = BuildTrack(index, rank, mask[ri], fore[ri], back[ri]);
                                
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
                Track         = new List<TemplateTrack>();

                string[] mask = BannerMask();
                string[] fore = BannerForeground();
                string[] back = BannerBackground();

                for (uint i = 0; i <= 24; i++)
                {
                    TemplateTrack track = BuildTrack(i, i, mask[i], fore[i], back[i]);

                    if (i == 3)
                    {
                        track.SetType("Title");
                    }
                    else if (i >= 9 && i <= 16)
                    {
                        track.SetType("Body");
                    }
                    else if (i == 23)
                    {
                        track.SetType("Prompt");
                    }
                
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

                Track         = new List<TemplateTrack>();

                string[] mask = FlagMask();
                string[] fore = FlagForeground();
                string[] back = FlagBackground();

                for (uint i = 0; i <= 38; i++)
                {                
                    TemplateTrack track = BuildTrack(i, i, mask[i], fore[i], back[i]);
                
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
            public TemplateTrack[] GetTrackByType(TemplateTrackType type)
            {
                List<TemplateTrack> list = new List<TemplateTrack>();

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

                // Pad the string on both sides with a space
                text = " " + text + " ";

                return text;
            }
            public List<TemplateSlice> GenerateSlices(string text, uint startRank, uint foreground, uint background)
            {
                List<TemplateSlice> slices = new List<TemplateSlice>();

                // Pad text to 4-char boundary
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

                    TemplateSlice slice = new TemplateSlice((uint)(startRank + x), part, foreground, background);

                    slices.Add(slice);
                    x ++;
                }

                return slices;
            }
            public List<TemplateSlice> GenerateSlices(string text, uint startRank)
            {
                List<TemplateSlice> slices = new List<TemplateSlice>();

                // Pad text to 4-char boundary
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

                    TemplateSlice slice = new TemplateSlice((uint)(startRank + x), part);

                    slices.Add(slice);
                    x ++;
                }

                return slices;
            }
            public void LineInsertion(string type, string inputText, int startColumn, TemplateTrack track)
            {
                switch (type)
                {
                    case "Function":
                    {
                        // Prepare input string
                        string text    = PrepareString(inputText);
                        
                        List<TemplateSlice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

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

                        if (Type != TemplateType.Section)
                        {
                            text   = PrepareString(inputText);        
                        }
                        else
                        {
                            text   = inputText;
                        }

                        List<TemplateSlice> slices = GenerateSlices(text, (uint)startColumn, 2, 3);

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }
                        break;
                    }
                    case "Banner":
                    {
                        List<TemplateSlice> slices = GenerateSlices(inputText, (uint)startColumn);

                        for (int i = 0; i < slices.Count; i++)
                        {
                            track.Block[startColumn + i].Update(slices[i]);
                        }
                        break;
                    }
                    case "Flag":
                    {
                        List<TemplateSlice> slices = GenerateSlices(inputText, (uint)startColumn);   

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
                List<TemplateTrack> track = new List<TemplateTrack>();

                switch (Type)
                {
                    case TemplateType.Function: // {0, 1, 2, 3, 4}
                    {
                        // Set single
                        track.AddRange(GetTrackByType(TemplateTrackType.Single));

                        LineInsertion("Function", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Action: // {5, 6, 7, 8, 9}
                    {
                        // Set single
                        track.AddRange(GetTrackByType(TemplateTrackType.Single));

                        LineInsertion("Action", IO.Output[0].ToString(), 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Section: // {0, 1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4};
                    {
                        // Set title
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            LineInsertion("Action", IO.Output[x].ToString(), 3, track[x]);
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Banner:
                    {
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            LineInsertion("Banner", IO.Output[x].ToString(), 10, track[x]);
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                    case TemplateType.Flag:
                    {
                        track.AddRange(GetTrackByType(TemplateTrackType.Title));

                        LineInsertion("Function", Title, 3, track[0]);

                        track.Clear();

                        // Set body
                        track.AddRange(GetTrackByType(TemplateTrackType.Body));

                        for (int x = 0; x < IO.Output.Count; x ++)
                        {
                            string line = IO.Output[x].ToString();
                            if (line.Length == 48)
                            {
                                LineInsertion("Flag", line, 14, track[x]);
                            }
                            else
                            {
                                LineInsertion("Flag", line, 12, track[x]);
                            }
                        }

                        track.Clear();

                        // Set prompt
                        track.AddRange(GetTrackByType(TemplateTrackType.Prompt));

                        LineInsertion("Function", Prompt, 3, track[0]);

                        track.Clear();

                        break;
                    }
                }
            }
            public string Draft()
            {
                TemplateDraft draft = new TemplateDraft(Track);

                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                // Header
                sb.AppendLine(draft.Build("HeaderFrame"));
                sb.AppendLine(draft.Build("HeaderRuler"));

                // Tracks
                for (int i = 0; i < Track.Count; i++)
                {
                    TemplateTrack t = Track[i];

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
                    TemplateTrack track = Track[t];

                    for (int b = 0; b < track.Block.Count; b++)
                    {
                        TemplateBlock block = track.Block[b];

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
                TemplateTrack track = Track[(int)index];

                string head = string.Format("| {0:D2} | {1:D2} |", track.Index, track.Rank);
                System.Console.Write(head);

                for (int i = 0; i < track.Block.Count; i++)
                {
                    TemplateBlock block = track.Block[i];

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
                TemplateDraft draft = new TemplateDraft(Track);

                // Header
                System.Console.WriteLine(draft.Build("HeaderFrame"));
                System.Console.WriteLine(draft.Build("HeaderRuler"));

                // Tracks
                for (int i = 0; i < Track.Count; i++)
                {
                    TemplateTrack t = Track[i];

                    string index = t.Index.ToString("D" + draft.Width);
                    string rank  = t.Rank.ToString("D" + 2);

                    // Write the left-hand header for the track
                    System.Console.Write(string.Format("| {0} | {1} |", index, rank));

                    // Now render each block with color
                    for (int b = 0; b < t.Block.Count; b++)
                    {
                        TemplateBlock block = t.Block[b];

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
                TemplateDraft draft = new TemplateDraft(Track);

                // Header
                System.Console.WriteLine(draft.Build("HeaderFrame"));
                System.Console.WriteLine(draft.Build("HeaderRuler"));

                // Tracks
                TemplateTrack track = Track[slot];

                string index = track.Index.ToString("D" + draft.Width);
                string rank  = track.Rank.ToString("D" + 2);

                // Write the left-hand header for the track
                System.Console.Write(string.Format("| {0} | {1} |", index, rank));
                
                // Now render each block with color
                for (int b = 0; b < track.Block.Count; b++)
                {
                    TemplateBlock block = track.Block[b];
            
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

                foreach (TemplateTrack track in Track)
                {
                    sb.AppendLine(track.Text());
                }

                return sb.ToString();
            }
        }
    }
}
