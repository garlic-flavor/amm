/** コマンドライン引数を解析します.
 * Version:    0.168(dmd2.069.2)
 * Date:       2015-Dec-23 19:01:54.2735255
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.args_data;
import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;

//
void set_args_data(alias STORE)(Macros data, string[] args)
{
    import std.algorithm : countUntil, startsWith;
    import std.array : appender;
    import std.exception : enforce;
    import std.file : exists, thisExePath;
    import std.path : buildPath, buildNormalizedPath, extension,
        dirName;
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
    data.fix(STORE.PREDEF.remake_command, remake.data); // 

    string argsext;
    for (sizediff_t i = 1, j ; i<args.length ; ++i)
    {
        // dmd へのオプション
        if (args[i].startsWith("-"))
        {
            auto opt = args[i][1 .. $];
            if      (opt.startsWith("L"))
                data[STORE.PREDEF.link_flag] ~= args[i];
            else if (opt.startsWith("I"))
                data[STORE.PREDEF.src] ~= opt[1..$];
            else if (opt.startsWith("of"))
                data.rewrite(STORE.PREDEF.target, opt[2..$]);
            else if (opt.startsWith("deps="))
                data.rewrite(STORE.PREDEF.deps_file, opt[5 .. $]);
            else if (opt.startsWith("Dd"))
                data.rewrite(STORE.PREDEF.ddoc, opt[2 .. $]);
            else
            {
                auto a = args[i];
                data[STORE.PREDEF.compile_flag] ~= a;
                if ("-m64" == a)
                {
                    data[STORE.PREDEF.link_flag] ~= a;
                    data[STORE.PREDEF.lib] ~= "lib64";
                }
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
        else if (0 == argsext.icmp(data[STORE.PREDEF.exe_ext]) ||
                 0 == argsext.icmp(data[STORE.PREDEF.dll_ext]))
            data.rewrite(STORE.PREDEF.target, args[i]);
        else if (0 == argsext.icmp(data[STORE.PREDEF.mak_ext]))
            data.rewrite(STORE.PREDEF.m, args[i]);
        // ファイル
        else
        {
            args[i].exists.enforce(args[i] ~ " is not found.");
            auto file = args[i].buildNormalizedPath;

            // ライブラリ
            if     (0 == argsext.icmp(data[STORE.PREDEF.lib_ext]) ||
                    0 == argsext.icmp(data[STORE.PREDEF.obj_ext]))
                data[STORE.PREDEF.libs] ~= file;
            else if (0 == argsext.icmp(data[STORE.PREDEF.src_ext]))
                data[STORE.PREDEF.root] ~= file;
            else if (0 == argsext.icmp(data[STORE.PREDEF.rc_ext]))
                data[STORE.PREDEF.rc] ~= file;
            else if (0 == argsext.icmp(data[STORE.PREDEF.def_ext]))
                data[STORE.PREDEF.def] ~= file;
            else if (0 == argsext.icmp(data[STORE.PREDEF.ddoc_ext]))
                data[STORE.PREDEF.ddoc] ~= file;
            else if (0 == argsext.icmp(data[STORE.PREDEF.xml_ext]))
                data.rewrite(STORE.PREDEF.style, file);
            else throw new Exception(args[i] ~ " is an unknown file type.");
        }
    }

    // この時点で root_file は指定されていなければならない。
    data.have(STORE.PREDEF.root)
        .enforce(" please input root files of the project.");
    debln("root file detected : ", data[STORE.PREDEF.root]);

    // ターゲットが lib や、dll かどうか。
    if (data.have(STORE.PREDEF.target))
    {
        auto target_ext = data[STORE.PREDEF.target].extension;
        if      (0 == target_ext.icmp(data[STORE.PREDEF.dll_ext]))
            data[STORE.PREDEF.is_dll] = "defined";
        else if (0 == target_ext.icmp(data[STORE.PREDEF.lib_ext]))
            data[STORE.PREDEF.is_lib] = "defined";
    }
    // -style.xml ファイルの探索
    Search style_search = new Search;
    style_search.install(".");
    if      (auto path = environment.get("HOME"))
        style_search.install(path);
    else if (auto path = environment.get("HOMEPATH"))
        style_search.install(path);

    version      (Windows)
        style_search.install(args[0].dirName);
    else version (linux)
    {
        auto d = thisExePath.dirName;
        style_search.install(d);
        style_search.install(d.dirName.buildPath("etc"));
    }

    debln("search is ready : ", style_search.pathes);

    data.rewrite(STORE.PREDEF.style,
                 style_search.abs(data[STORE.PREDEF.style])
                 .enforce(data[STORE.PREDEF.style] ~ " is not found"));

    logln(data[STORE.PREDEF.style] ~ " is detected.");
}
