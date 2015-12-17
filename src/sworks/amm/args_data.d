/** コマンドライン引数を解析します.
 * Version:    0.167(dmd2.069.2)
 * Date:       2015-Dec-17 18:53:46.0477485
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.args_data;
import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;

//
void set_args_data(alias MACROKEY)(Macros data, string[] args)
{
    import std.algorithm : countUntil, startsWith;
    import std.array : appender;
    import std.exception : enforce;
    import std.file : exists;
    import std.path : buildNormalizedPath, extension, dirName;
    import std.process : environment, executeShell;
    import std.string : icmp;

    auto remake = "amm".appender;
    foreach (one ; args[1..$])
    {
        remake.put(" ");
        if (0 <= one.countUntil(" ") || 0 <= one.countUntil("(") ||
            0 <= one.countUntil(")"))
        {
            remake.put("\"");
            remake.put(one);
            remake.put("\"");
        }
        else remake.put(one);
    }
    data.fix(MACROKEY.REMAKE_COMMAND, remake.data);

    string argsext;
    for (sizediff_t i = 1, j ; i<args.length ; ++i)
    {
        // dmd へのオプション
        if (args[i].startsWith("-"))
        {
            auto opt = args[i][1 .. $];
            if      (opt.startsWith("L"))
                data[MACROKEY.LINK_FLAG] ~= args[i];
            else if (opt.startsWith("I"))
                data[MACROKEY.SRC_DIRECTORY] ~= opt[1..$];
            else if (opt.startsWith("of"))
                data.rewrite(MACROKEY.TARGET, opt[2..$]);
            else if (opt.startsWith("deps="))
                data.rewrite(MACROKEY.DEPS_FILE, opt[5 .. $]);
            else if (opt.startsWith("Dd"))
                data.rewrite(MACROKEY.DDOC_DIRECTORY, opt[2 .. $]);
            else
            {
                auto a = args[i];
                data[MACROKEY.COMPILE_FLAG] ~= a;
                if ("-m64" == a) data[MACROKEY.LINK_FLAG] ~= a;
            }
        }
        // マクロへの値つき代入
        else if (0 < (j = args[i].countUntil("+=")))
            data.forceConcat(args[i][0..j], args[i][j+2..$]);
        else if (0 < (j = args[i].countUntil('=')))
            data.rewrite(args[i][0..j], args[i][j+1..$]);
        // マクロへの値省略代入
        else if (0 == (argsext = args[i].extension).length)
            data.rewrite(args[i], "defined");
        // ターゲット
        else if (0 == argsext.icmp(data[MACROKEY.EXE_EXT]) ||
                 0 == argsext.icmp(data[MACROKEY.DLL_EXT]))
            data.rewrite(MACROKEY.TARGET, args[i]);
        else if (0 == argsext.icmp(data[MACROKEY.MAK_EXT]))
            data.rewrite(MACROKEY.MAKEFILE, args[i]);
        else
        {
            enforce(args[i].exists, args[i] ~ " is not found.");
            auto file = args[i].buildNormalizedPath;

            // ライブラリ
            if     (0 == argsext.icmp(data[MACROKEY.LIB_EXT]) ||
                    0 == argsext.icmp(data[MACROKEY.OBJ_EXT]))
                data[MACROKEY.LIB_FILE] ~= file;
            else if (0 == argsext.icmp(data[MACROKEY.SRC_EXT]))
                data[MACROKEY.ROOT_FILE] ~= file;
            else if (0 == argsext.icmp(data[MACROKEY.RC_EXT]))
                data[MACROKEY.RC_FILE] ~= file;
            else if (0 == argsext.icmp(data[MACROKEY.DEF_EXT]))
                data[MACROKEY.DEF_FILE] ~= file;
            else if (0 == argsext.icmp(data[MACROKEY.DDOC_EXT]))
                data[MACROKEY.DDOC_FILE] ~= file;
            else if (0 == argsext.icmp(data[MACROKEY.XML_EXT]))
                data.rewrite(MACROKEY.STYLE_FILE, file);
            else throw new Exception(args[i] ~ " is an unknown file type.");
        }
    }

    // この時点で root_file は指定されていなければならない。
    data.have(MACROKEY.ROOT_FILE)
        .enforce(" please input root files of the project.");
    debln("root file detected.");

    // ターゲットが lib や、dll かどうか。
    if (data.have(MACROKEY.TARGET))
    {
        auto target_ext = data[MACROKEY.TARGET].extension;
        if      (0 == target_ext.icmp(data[MACROKEY.DLL_EXT]))
            data[MACROKEY.TARGET_IS_DLL] = "defined";
        else if (0 == target_ext.icmp(data[MACROKEY.LIB_EXT]))
            data[MACROKEY.TARGET_IS_LIB] = "defined";
    }
    // -style.xml ファイルの探索
    Search style_search = new Search;
    style_search.entry(".");
    if      (auto path = environment.get("HOME"))
        style_search.entry(path);
    else if (auto path = environment.get("HOMEPATH"))
        style_search.entry(path);

    version      (Windows)
        style_search.entry(args[0].dirName);
    else version (linux)
        style_search.entry("where amm".executeShell.output.dirName);

    debln("search is ready");

    data.rewrite(MACROKEY.STYLE_FILE,
                 style_search.abs(data[MACROKEY.STYLE_FILE])
                 .enforce(data[MACROKEY.STYLE_FILE] ~ " is not found"));

    logln(data[MACROKEY.STYLE_FILE] ~ " is detected.");
}
