module util;

import std.string;

string removeSpaceInHead(string key)
{
    while (key.startsWith(" "))
    {
        key = key[1 .. $];
    }

    return key;
}

string removeSpaceInBack(string key)
{
    while (key.endsWith(" "))
    {
        key = key[0 .. $ - 1];
    }

    return key;
}

string removeSpaceOutline(string key)
{
    return removeSpaceInHead(removeSpaceInBack(key));
}
