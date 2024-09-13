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
    import std.file : readText;
    import std.json;

    import esstool.arrayutil : len, contains;
    import esstool : CSVBuilder;

    string[] unlocalizations = createUnlocalizations();

    auto builder = new CSVBuilder();

    JSONValue[string][string] langRawMap;

    auto langs = findLangs();
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
    import esstool : LineReader, CSVBuilder;
    import esstool.arrayutil : contains, len;
    import std.string;

    string[string] readLangLines(string lang)
    {
        string[string] map;
        LineReader reader = new LineReader(langPath ~ "/" ~ lang ~ ".lang");

        while (reader.readly)
        {
            auto line = reader.read;
            if (contains(line, '#'))
            {
                line = line.split("#")[0];
            }
            if (!contains(line, '='))
            {
                continue;
            }

            string[] kv = line.split("=");
            map[kv[0]] = kv[1];
        }

        return map;
    }

    string[string][string] readLangFile()
    {
        string[string][string] langsMap;
        auto langs = findLangs("lang");
        foreach (lang; langs)
        {
            langsMap[lang] = readLangLines(lang);
        }

        return langsMap;
    }

    string[] unlocalizations = new string[0];

    string targetFile = langPath ~ "/" ~ target ~ ".lang";
    auto reader = new LineReader(targetFile);

    while (reader.readly)
    {
        string line = reader.read;
        line = contains(line, '#') ? line.split("#")[0] : line;
        if (!contains(line, '='))
        {
            unlocalizations ~= "";
            continue;
        }

        unlocalizations ~= line.split("=")[0];
    }

    auto langs = readLangFile;
    auto builder = new CSVBuilder();
    auto count = len(unlocalizations);

    for (int i = 0; i < count; i++)
    {
        auto key = unlocalizations[i];
        if (key == "")
        {
            continue;
        }

        builder.addAt("unlocalization", key, i);
        foreach (lang; langs.keys)
        {
            auto dat = langs[lang];
            if (!contains(dat.keys, key))
            {
                continue;
            }

            auto value = dat[key];
            builder.addAt(lang, value, i);
        }
    }

    builder.build(basePath ~ "/LangTable.csv");
}

void build(LangArgs args)
{
    import std.csv;
    import std.file : readText, exists, isFile;
    import esstool.arrayutil : contains;

    auto fileName = basePath ~ "/LangTable.csv";

    if (!exists(fileName) || !isFile(fileName))
    {
        LOGGER.warn("Cannot find LangTable.csv file!");
        return;
    }
    auto table = readText(fileName);

    string[][string] datas;
    foreach (pair; csvReader!(string[string])(table, null))
    {
        foreach (key; pair.keys)
        {
            datas[key] ~= pair[key];
        }
    }

    if (!contains(datas.keys, "unlocalization"))
    {
        LOGGER.error("The CSV file didnot had `unlocalization` type!");
        return;
    }

    string[] basic = datas["unlocalization"];
    foreach (key; datas.keys)
    {
        if (key == "unlocalization")
        {
            continue;
        }

        if (args.langType == "lang")
        {
            langBuild(basic, datas[key], key);
        }
        else
        {
            jsonBuild(basic, datas[key], key);
        }
    }

}

void jsonBuild(string[] basic, string[] creator, string lang)
{
    import esstool.arrayutil : len;
    import esstool : StringBuilder;

    import std.file : write;

    StringBuilder build = new StringBuilder();
    int count = len(basic);

    build.append("{").appendNewLine;
    for (int i = 0; i < count; i++)
    {
        auto key = basic[i];
        auto value = creator[i];

        if (key == "" && value == "")
        {
            build.appendNewLine;
            continue;
        }

        build.append("    \"")
            .append(key)
            .append("\"")
            .append(": \"")
            .append(value)
            .append("\",")
            .appendNewLine;
    }

    build.removeAt(build.size() - 3).append("}");

    write(langPath ~ "/" ~ lang ~ ".json", build.asString);
}

void langBuild(string[] basic, string[] creator, string lang)
{
    import esstool.arrayutil : len;
    import esstool : StringBuilder;

    import std.file : write;

    StringBuilder build = new StringBuilder();
    int count = len(basic);

    for (int i = 0; i < count; i++)
    {
        auto key = basic[i];
        auto value = creator[i];

        if (key == "" && value == "")
        {
            build.appendNewLine;
            continue;
        }

        build.append(key)
            .append("=")
            .append(value)
            .appendNewLine;
    }

    write(langPath ~ "/" ~ lang ~ ".lang", build.asString);
}

string[] findLangs(string type = "json")
{
    import std.string : split, replace, endsWith;
    import std.file : dirEntries, SpanMode;

    string[] langs = new string[0];

    foreach (entry; dirEntries(langPath, SpanMode.shallow))
    {
        if (!entry.isFile)
        {
            continue;
        }

        string fileName = entry.name.split("\\")[$ - 1].replace("\"", "");

        if (type == "lang" && fileName.endsWith(".lang"))
        {
            langs ~= fileName.replace(".lang", "");
        }
        else if (type == "json" && fileName.endsWith(".json"))
        {
            langs ~= fileName.replace(".json", "");
        }
    }

    return langs;
}
