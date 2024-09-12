module lang.lang;

import std.file;
import std.string : split;

import esstool.errors;
import esstool.arrayutil : contains;
import esstool : LineReader;

import util;

struct LangValue
{
    string key;
    string value;
}

LangValue[] praseLang(string file)
{
    if (!exists(file) || !isFile(file))
    {
        throw new FileException("Cannot find file!");
    }

    LangValue[] texts = new LangValue[0];
    auto reader = new LineReader(file);
    while (reader.readly())
    {
        string text = reader.read();
        if (contains(text, "#"))
        {
            text = text.split("#")[0];
        }

        if (!contains(text, "="))
        {
            texts ~= new LangValue("", "");
            continue;
        }

        auto kv = text.split("=");
        string key = removeSpaceOutline(kv[0]);
        string value = removeSpaceOutline(kv[1]);

        texts ~= new LangValue(key, value);
    }
}
