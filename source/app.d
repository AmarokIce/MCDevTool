import esstool.arrayutil : len;
import data;

const string getHelp = "Unknow command. please send `./mcdt help` to get help.";
const string TAB = "  ";
string[] helps;

void main(string[] args)
{
    // init args.
    args = args[1 .. $];

    // main start.
    init();
    data.checkWorkspace();

    string command = args.length < 1 ? "" : args[0];
    switch (command)
    {
    case "help":
        printHelp();
        break;

    case "lang":
        if (args.length < 2)
        {
            LOGGER.info(getHelp);
            break;
        }

        import langhandler;

        LangArgs langArgs = *(new LangArgs(
                args[1],
                args.length > 2 ? args[2] : "json",
                args.length > 3 ? args[3] : "en_us"
        ));

        langhandle(langArgs);
        break;

    case "model":
        LOGGER.info("TODO");
        break;

    default:
        LOGGER.warn(getHelp);
        break;
    }
}

void init()
{
    string create(string commandName, string commandComment, int subCommand = 0)
    {
        string commandHelp = TAB;

        for (int i = 1; i < subCommand; i++)
        {
            commandHelp ~= TAB;
        }

        if (subCommand >= 1)
        {
            commandHelp ~= "|- ";
        }

        commandHelp ~= commandName;

        const int count = len(commandHelp);
        for (int i = 0; i < 25 - count; i++)
        {
            commandHelp ~= " ";
        }

        return commandHelp ~ "- " ~ commandComment;
    }

    helps ~= "Command List: ";

    helps ~= "";
    helps ~= create("lang", "create the language table to `./.mctd/LangTable.cvs");
    helps ~= create("create | build", "Create or build the language table to Json/Lang.", 1);
    helps ~= create("json | lang", "Scan/Build to Json/Lang file. Def: Json", 2);
    helps ~= create("[lang name]", "lang for reference. Def: en_us", 3);

    helps ~= "";
    helps ~= create("model", "create item/block models by lang.");
    helps ~= create("item | block | all", "model target. Def: all", 1);
    helps ~= create("[lang name]", "the reference lang file. Def: en_us.", 2);

    helps ~= "";
}

void printHelp()
{
    foreach (text; helps)
    {
        LOGGER.info(text);
    }
}
