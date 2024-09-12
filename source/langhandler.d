module langhandler;

import log : log;
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
        log("Unknown command. Please send `./mcdt help` to get help.");
        break;
    }
}

void create(LangArgs args)
{

    // TODO

}

void jsonCreate(string target)
{
    string createUnlocalizations()
    {
        import std.string : split;
        import esstool.arrayutil : contains;
        import esstool : LineReader;

        string[] unlocalizations = new string[0];

        string targetFile = langPath ~ "/" ~ target ~ ".json";
        auto reader = new LineReader(targetFile);

        while (reader.readly())
        {
            string txt = reader.read();
            txt = contains(txt, ":") ? removeSpaceOutline(txt.split(":")) : "";
            unlocalization ~= txt;
        }

        return unlocalizations;
    }

    import std.string : split, replace;
    import std.file : dirEntries, readText;
    import std.json;

    import esstool.arrayutil : len;
    import esstool : CSVBuilder;

    string[] langs = new string[0];

    foreach (entry; dirEntries(langPath))
    {
        if (!entry.isFile)
        {
            continue;
        }

        langs ~= entry.name.split("/")[$ - 1].replace(".json");
    }

    string[] unlocalizations = createUnlocalizations();

    auto builder = new CSVBuilder();

    JSONValue[string][string] langRawMap;

    foreach (lang; langs)
    {
        auto raw = parseJSON(readText(langPath ~ "/" ~ lang ~ ".json")).object();
        langRawMap[lang] = raw;
    }

    for (int i = 0; i < len(unlocalizations); i++)
    {
        auto key = unlocalizations[i];

        if (key == "")
        {
            continue;
        }

        foreach (lang; langRawMap.keys())
        {
            auto map = langRawMap[lang];
            if (len(map) <= i)
            {
                continue;
            }

            builder.add(lang, map[key].str());
        }
    }

    builder.build(basePath ~ "/LangTable.csv");
}

void build(LangArgs args)
{

}

void jsonBuild()
{

}
