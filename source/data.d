module data;

string WORK_SPCAE_MODID = "";
string BASE_DIR = "./.mcdt";
string FILE_DIR;

void checkWorkspace()
{
    import std.file: exists, isFile, isDir, read;
    import std.json;

    if (!exists("./.mctd" || !isDir("./.mctd")))
    {
        initWorkspace();
    }

    if (!exists("./.mctd/mod.json" || !isFile("./.mcdt/mod.json")))
    {
        initWorkspace();
    }

    auto jsonData = parseJSON(readText("./.mctd/mod.json"));
    WORK_SPCAE_MODID = jsonData["modid"];

    FILE_DIR = WORK_SPCAE_MODID == "" ? BASE_DIR : "./src/main/resources/assets" ~ WORK_SPCAE_MODID;
}

void initWorkspace()
{
    import std.file;

    mkdir("./.mctd");
    write("./.mctd/mod.json", "{\n    \"modid\": \"\"\n}");
}