module langhandler;

import data;
import util;

struct LangArgs
{
    string commandType;
    string langType = "json";
    string targetLang = "en_us";
}

string basePath;
string langPath;

void langhandle(LangArgs args)
{
    basePath = data.BASE_DIR;
    langPath = data.FILE_DIR ~ "/lang";

    switch (args.commandType)
    {
    case "create":
        create(args);
        break;

    case "build":
        build(args);
        break;

    default:
        LOGGER.warn("Unknown command. Please send `./mcdt help` to get help.");
        break;
    }
}

void create(LangArgs args) => args.langType == "lang" ? langCreate(args.targetLang)
    : jsonCreate(args.targetLang);

void jsonCreate(string target)
{
    string[] createUnlocalizations()
    {
        import std.string : split, replace;
        import esstool.arrayutil : contains;
        import esstool : LineReader;

        string[] unlocalizations = new string[0];

        string targetFile = langPath ~ "/" ~ target ~ ".json";
        auto reader = new LineReader(targetFile);

        while (reader.readly())
        {
            string txt = reader.read();
            if (txt == "{" || txt == "}")
            {
                continue;
            }
            txt = contains(txt, ':') ? removeSpaceOutline(txt.split(":")[0].replace("\"", "")) : "";
            unlocalizations ~= txt;
        }

        return unlocalizations;
    }

    import std.string : split, replace;
    import std.file : dirEntries, readText, SpanMode;
    import std.json;

    import esstool.arrayutil : len, contains;
    import esstool : CSVBuilder;

    string[] langs = new string[0];

    foreach (entry; dirEntries(langPath, SpanMode.shallow))
    {
        if (!entry.isFile)
        {
            continue;
        }

        langs ~= entry.name.split("\\")[$ - 1].replace(".json", "").replace("\"", "");
    }

    string[] unlocalizations = createUnlocalizations();

    auto builder = new CSVBuilder();

    JSONValue[string][string] langRawMap;

    foreach (lang; langs)
    {
        JSONValue[string] raw = parseJSON(readText(langPath ~ "/" ~ lang ~ ".json")).object();
        langRawMap[lang] = raw;
    }

    for (int i = 0; i < len(unlocalizations); i++)
    {
        auto key = unlocalizations[i];

        if (key == "")
        {
            LOGGER.debugInfo("Pass");
            continue;
        }

        LOGGER.debugInfo("Data of : " ~ key);
        builder.addAt("unlocalization", key, i);

        foreach (lang; langRawMap.keys())
        {
            JSONValue[string] map = langRawMap[lang];

            builder.addAt(lang, contains(map.keys(), key) ? map[key].str() : "", i);
        }
    }

    builder.build(basePath ~ "/LangTable.csv");
}

void langCreate(string target)
{
    // TODO
}

void build(LangArgs args)
{
    import std.csv;
    import std.file : readText, exists, isFile;

    auto fileName = basePath ~ "/LangTable.csv";

    if (!exists(fileName) || !isFile(fileName))
    {
        LOGGER.warn("Cannot find LangTable.csv file!");
        return;
    }
    auto table = readText(fileName);

    foreach (pair; csvReader!(string[string])(table, null))
    {
        LOGGER.debugInfo("");
    }
}

void jsonBuild()
{

}
