module langhandler;

import std.csv;
import std.file;
import std.string : split, replace, endsWith;

import esstool : LineReader;

import log : log;
import data;
import util;

struct LangArgs
{
    string commandType;
    string langType = "json";
    string targetLang = "en_us";
}

struct LangOptions
{
    string key;
    string value;
}

void langhandle(LangArgs args)
{
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
    auto basePath = data.BASE_DIR;
    auto langPath = data.FILE_DIR ~ "/lang";

    auto type = args.langType == "json" ? ".json" : ".lang";

    auto files = new string[0];

    import esstool.arrayutil : contains;

    foreach (DirEntry file; dirEntries(langPath))
    {
        if (!file.isFile())
        {
            continue;
        }

        auto name = file.name().split("/")[$ - 1];
        if (name.endsWith(type))
        {
            files ~= name.replace(type, "");
        }
    }

    if (!contains(files, args.targetLang))
    {
        return;
    }

    auto reader = new LineReader(langPath ~ args.targetLang ~ type);

}

LangOptions[] jsonHandler(LineReader reader)
{
    auto options = new LangOptions[0];

    while (reader.readly())
    {
        auto text = reader.read();
        if (text == "{" || text == "}")
        {
            continue;
        }

        text.replace("\"", "");
        auto kv = text.split(":");
        string key = removeSpaceInHead(kv[0]);
        string value = removeSpaceInHead(kv[1]);

        if (value.endsWith(","))
        {
            value = value[0 .. $ - 1];
        }

        options ~= new LangOptions(key, value);
    }

    return options;
}

void build(LangArgs args)
{

}
