
<#
    [Top 100 Billionaires]
    https://www.msn.com/en-us/money/personalfinance/
    meet-the-richest-person-in-the-world-plus-see-the-rest-of-the-top-100/ss-AA1l2voF
#>

Class BillionaireItem
{
    [UInt32] $Index
    [String] $Name
    [UInt32] $Age
    [Float]  $Worth
    [String] $Source
    [String] $Country
    BillionaireItem([UInt32]$Index,[String]$Name,[Float]$Worth,[String]$Source,[UInt32]$Age,[String]$Country)
    {
        $This.Index   = $Index
        $This.Name    = $Name
        $This.Age     = $Age
        $This.Worth   = $Worth
        $This.Source  = $Source
        $This.Country = $Country
    }
}

Class BillionaireList
{
    [Object] $Output
    BillionaireList()
    {
        $This.Output = @( )
    }
    [Object] BillionaireItem([UInt32]$Index,[String]$Name,[Float]$Worth,[String]$Source,[UInt32]$Age,[String]$Country)
    {
        Return [BillionaireItem]::New($Index,$Name,$Worth,$Source,$Age,$Country)
    }
    Add([String]$Name,[Float]$Worth,[String]$Source,[UInt32]$Age,[String]$Country)
    {
        $Item = $This.BillionaireItem($This.Output.Count,$Name,$Worth,$Source,$Age,$Country)
        $This.Output += $Item
    }
    AddLine([String]$Line)
    {
        $L = $Line -Split ";"

        $This.Add($L[0],$L[1],$L[2],$L[3],$L[4])
    }
    Reindex()
    {
        $This.Output = $This.Output | Sort-Object Worth -Descending
        $X           = 1
        ForEach ($Item in $This.Output)
        {
            $Item.Index = $X
            $X          ++
        }
    }
    [String] ToString()
    {
        Return "<Billionaire[List]>"
    }
}

$Ctrl = [BillionaireList]::New()
"Daniel Gilbert;15.5;Quicken Loans;60;United States",
"Peter Woo;15.7;real estate;76;Hong Kong",
"Eric Schmidt;15.8;Google;67;United States",
"Jerry Jones;15.9;Dallas Cowboys;80;United States",
"Robert Pera;16.1;wireless networking gear;44;United States",
"Emmanuel Besnier;16.2;cheese;52;France",
"Dilip Shanghvi;16.2;pharmaceuticals;67;India",
"Rupert Murdoch;16.3;newspapers, TV network;91;United States",
"John Menard Jr.;16.7;home improvement stores;82;United States",
"Theo Albrecht Jr.;17.1;Aldi, Trader Joes;71;Germany",
"Savitri Jindal;17.1;steel;72;India",
"Li Shufu;17.3;automobiles;59;China",
"Changpeng Zhao;17.4;cryptocurrency exchange;45;Canada",
"Donald Bren;17.4;real estate;90;United States",
"Steve Cohen;17.5;hedge funds;66;United States",
"Thomas Frist Jr.;17.8;hospitals;84;United States",
"Wang Wenyin;18.2;mining, copper products;54;China",
"Alexey Mordashov;18.4;steel, investments;57;Russia",
"David Tepper;18.5;hedge funds;65;United States",
"Qin Yinglin;18.5;pig breeding;57;China",
"Carl Icahn;18.6;investments;86;United States",
"Radhakishan Damani;18.6;retail, investments;67;India",
"Leonard Lauder;18.8;Estee Lauder;89;United States",
"Iris Fontbona;18.9;mining;79;Chile",
"Ray Dalio;19.1;hedge funds;73;United States",
"Wang Wei;19.6;package delivery, self made;52;China",
"He Xiangjian;19.6;home appliances, self made;80;China",
"Wang Chuanfu;19.8;batteries, automobiles, self made;56;China",
"William Lei Ding;20;online games, self made;51;China",
"Stefan Quandt;20.3;BMW;56;Germany",
"Jack Ma;20.7;e-commerce, self made;58;China",
"Gennady Timchenko;20.8;oil, gas, self made;70;Russia",
"Abigail Johnson;20.9;Fidelity;60;United States",
"Vagit Alekperov;21;oil, self made;72;Russia",
"Colin Zheng Huang;21.1;e-commerce, self made;42;China",
"Lukas Walton;21.4;Walmart;36;United States",
"Takemitsu Takizaki;21.4;sensors, self made;77;Japan",
"Michael Hartono;22.1;banking, tobacco;83;Indonesia",
"Cyrus Poonawalla;22.4;vaccines;81;India",
"Harold Hamm;22.4;oil and gas, self made;76;United States",
"R. Budi Hartono;23;banking, tobacco;81;Indonesia",
"Guillaume Pousaz;23;fintech, self made;41;Switzerland",
"Susanne Klatten;23;BMW, pharmaceuticals;60;Germany",
"Germán Larrea Mota Velasco;23.7;mining;69;Mexico",
"Leonid Mikhelson;24.4;gas, chemicals, self made;67;Russia",
"Shiv Nadar;24.4;software services, self made;77;India",
"Masayoshi Son;24.5;internet, telecom, self made;65;Japan",
"Thomas Peterffy;24.8;discount brokerage, self made;78;United States",
"Vladimir Lisin;25.4;steel, transport, self made;66;Russia",
"MacKenzie Scott;25.8;Amazon;52;United States",
"Vladimir Potanin;26.4;metals, self made;61;Russia",
"Klaus-Michael Kuehne;26.5;shipping;85;Germany",
"Ma Huateng;26.8;internet media, self made;51;China",
"Andrey Melnichenko;27;coal, fertilizers, self made;50;Russia",
"Gina Rinehart;27;mining;68;Australia",
"Dieter Schwarz;27.7;retail;83;Germany",
"Miriam Adelson;28;casinos;77;Israel, United States",
"Jim Simons;28.1;hedge funds, self made;84;United States",
"Lee Shau Kee;28.1;real estate, self made;94;Hong Kong",
"Tadashi Yanai;28.4;fashion retail, self made;73;Japan",
"Stephen Schwarzman;28.5;investments, self made;75;United States",
"Jeff Yass;30;trading, investments, self made;64;United States",
"Len Blavatnik;30;music, chemicals, self made;65;United States",
"Alain Wertheimer;30.2;Chanel;74;France",
"Gerard Wertheimer;30.2;Chanel;71;France",
"Robin Zeng;31.4;batteries, self made;53;Hong Kong",
"Ken Griffin;31.5;hedge funds, self made;54;United States",
"Li Ka-shing;32.5;diversified, self made;94;Hong Kong",
"Giovanni Ferrero;33.2;Nutella, chocolates;58;Italy",
"Beate Heister and Karl Albrecht Jr.;33.6;supermarkets;72;Germany",
"François Pinault;33.8;luxury goods, self made;86;France",
"Phil Knight;37.4;Nike, self made;84;United States",
"Mark Zuckerberg;37.7;Facebook, self made;38;United States",
"Jacqueline Mars;38;candy, pet food;83;United States",
"John Mars;38;candy, pet food;87;United States",
"Rodolphe Saadé;41.4;shipping;52;France",
"Zhang Yiming;49.5;TikTok, self made;38;China",
"David Thomson;50.1;media;65;Canada",
"Michael Dell;50.2;Dell Technologies, self made;57;United States",
"Alice Walton;58.2;Walmart;73;United States",
"Charles Koch;58.2;Koch Industries;87;United States",
"Julia Koch;58.2;Koch Industries;60;United States",
"Rob Walton;59.2;Walmart;78;United States",
"Amancio Ortega;59.6;Zara, self made;86;Spain",
"Jim Walton;60.4;Walmart;74;United States",
"Zhong Shanshan;64.2;beverages, pharmaceuticals, self made;67;China",
"Françoise Bettencourt Meyers;66.7;L Oréal;69;France",
"Sergey Brin;74.5;Google, self made;49;United States",
"Steve Ballmer;75.2;Microsoft, self made;66;United States",
"Michael Bloomberg;76.8;Bloomberg LP, self made;80;United States",
"Larry Page;77.5;Google, self made;49;United States",
"Carlos Slim Helú;86.9;telecom, self made;82;Mexico",
"Mukesh Ambani;92.5;diversified;65;India",
"Larry Ellison;98.8;software, self made;78;United States",
"Warren Buffett;101.6;Berkshire Hathaway, self made;92;United States",
"Bill Gates;101.6;Microsoft, self made;67;United States",
"Jeff Bezos;110.3;Amazon, self made;58;United States",
"Gautam Adani;144.7;infrastructure, commodities, self made;60;India",
"Bernard Arnault;160.5;LVMH;73;France",
"Elon Musk;192;Tesla, SpaceX, self made;51;United States" | % { 

    $Ctrl.AddLine($_)
}

$Ctrl.Reindex()
$Ctrl.Output | Out-GridView -Title "Top 100 Billionaires"
