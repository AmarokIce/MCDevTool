module langhandler;

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

    // TODO

}

void build(LangArgs args)
{

}