/** コマンドライン引数を解析します.
 * Version:    0.169(dmd2.070.0)
 * Date:       2016-Feb-28 23:41:39
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.args_data;
import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;

//
void set_args_data(alias PREDEF)(Macros data, string[] args)
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
    data.fix(PREDEF.remake_command, remake.data); // 

    string argsext;
    for (sizediff_t i = 1, j ; i<args.length ; ++i)
    {
        // dmd へのオプション
        if (args[i].startsWith("-"))
        {
            auto opt = args[i][1 .. $];
            if      (opt.startsWith("L"))
                data[PREDEF.link_flag] ~= args[i];
            else if (opt.startsWith("I"))
                data[PREDEF.src] ~= opt[1..$];
            else if (opt.startsWith("of"))
                data.rewrite(PREDEF.target, opt[2..$]);
            else if (opt.startsWith("deps="))
                data.rewrite(PREDEF.deps_file, opt[5 .. $]);
            else if (opt.startsWith("Dd"))
                data.rewrite(PREDEF.ddoc, opt[2 .. $]);
            else
            {
                auto a = args[i];
                data[PREDEF.compile_flag] ~= a;
                if      ("-m64" == a)
                {
                    data[PREDEF.link_flag] ~= a;
                    data[PREDEF.lib] ~= "lib64";
                    data[PREDEF.is_vclinker] = "defined";
                }
                else if ("-m32mscoff" == a)
                {
                    data[PREDEF.is_vclinker] = "defined";
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
        else if (0 == argsext.icmp(data[PREDEF.exe_ext]) ||
                 0 == argsext.icmp(data[PREDEF.dll_ext]))
            data.rewrite(PREDEF.target, args[i].buildNormalizedPath);
        else if (0 == argsext.icmp(data[PREDEF.mak_ext]))
            data.rewrite(PREDEF.m, args[i].buildNormalizedPath);
        // ファイル
        else
        {
            args[i].exists.enforce(args[i] ~ " is not found.");
            auto file = args[i].buildNormalizedPath;

            // ライブラリ
            if     (0 == argsext.icmp(data[PREDEF.lib_ext]) ||
                    0 == argsext.icmp(data[PREDEF.obj_ext]))
                data[PREDEF.libs] ~= file.buildNormalizedPath;
            else if (0 == argsext.icmp(data[PREDEF.src_ext]))
                data[PREDEF.root] ~= file.buildNormalizedPath;
            else if (0 == argsext.icmp(data[PREDEF.rc_ext]))
                data[PREDEF.rc] ~= file.buildNormalizedPath;
            else if (0 == argsext.icmp(data[PREDEF.def_ext]))
                data[PREDEF.def] ~= file.buildNormalizedPath;
            else if (0 == argsext.icmp(data[PREDEF.ddoc_ext]))
                data[PREDEF.ddoc] ~= file.buildNormalizedPath;
            else if (0 == argsext.icmp(data[PREDEF.xml_ext]))
                data.rewrite(PREDEF.style, file.buildNormalizedPath);
            else throw new Exception(args[i] ~ " is an unknown file type.");
        }
    }

    // この時点で root_file は指定されていなければならない。
    data.have(PREDEF.root)
        .enforce(" please input root files of the project.");
    debln("root file detected : ", data[PREDEF.root]);

    // ターゲットが lib や、dll かどうか。
    if (data.have(PREDEF.target))
    {
        auto target_ext = data[PREDEF.target].extension;
        if      (0 == target_ext.icmp(data[PREDEF.dll_ext]))
            data[PREDEF.is_dll] = "defined";
        else if (0 == target_ext.icmp(data[PREDEF.lib_ext]))
            data[PREDEF.is_lib] = "defined";
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
        style_search.install(d.dirName.buildPath("etc/amm"));
    }

    debln("search is ready : ", style_search.pathes);

    data.rewrite(PREDEF.style,
                 style_search.abs(data[PREDEF.style])
                 .enforce(data[PREDEF.style] ~ " is not found"));

    logln(data[PREDEF.style] ~ " is detected.");
}
