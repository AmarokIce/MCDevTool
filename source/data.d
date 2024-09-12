module data;

string WORK_SPCAE_MODID = "";
string BASE_DIR = "./.mcdt";
string FILE_DIR;

void checkWorkspace()
{
    import std.file: exists, isFile, isDir, readText;
    import std.json;

    if (!exists("./.mcdt") || !isDir("./.mcdt"))
    {
        initWorkspace();
    }

    if (!exists("./.mcdt/mod.json") || !isFile("./.mcdt/mod.json"))
    {
        initWorkspace();
    }

    auto jsonData = parseJSON(readText("./.mcdt/mod.json")).object();
    WORK_SPCAE_MODID = jsonData["modid"].str();

    FILE_DIR = WORK_SPCAE_MODID == "" ? BASE_DIR : "./src/main/resources/assets" ~ WORK_SPCAE_MODID;
}

void initWorkspace()
{
    import std.file;

    mkdir("./.mcdt");
    write("./.mcdt/mod.json", "{\n    \"modid\": \"\"\n}");
}