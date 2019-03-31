/** コマンドライン引数を解析します.
 * Version:    0.172(dmd2.085.0)
 * Date:       2019-Mar-29 00:44:09
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.args_data;
import sworks.base.mo;
import sworks.base.search;
import sworks.base.getopt;
import sworks.base.output;
import sworks.stylexml.macros;

//
auto set_args_data(alias ML)(Macros data, string[] args)
{
    import std.array: join;
    import std.file: exists;
    import std.exception: enforce;
    import std.path: buildNormalizedPath, extension, dirName;
    import std.string: toLower;
    import std.process: environment;

    //
    data.fix(ML.remake_command, args.toCommandString);

    alias L = MoUtil.ExpandMode.Lazily;

    auto result = Getopt(
        args,

        "lang", "-lang **", _("Specify the language. The default value is taken from an environment variable named 'LANG'.", L),
        (string key, string lang) { _.setlocale(lang); },

        "verbose", _("Set output policy as 'VERBOSE'.", L),
        (){ Output.mode = Output.MODE.VERBOSE; },

        "quiet|q", _("Set output policy as 'quiet'.", L),
        (){ Output.mode = Output.MODE.QUIET; },

        Getopt.Config.notInSummary,
        "L", (string val) { data[ML.link_flag] ~= val; },

        Getopt.Config.notInSummary,
        "I", (string key, string val) { data[ML.src] ~= val; },

        Getopt.Config.notInSummary,
        "of", (string key, string val) { data.fix(ML.target, val); },

        Getopt.Config.notInSummary,
        "m32mscoff|m32|m64",
        (string key)
        {
            data[ML.compile_flag] ~= "-" ~ key;
            data[ML.link_flag] ~= "-" ~ key;
            switch (key)
            {
            case "m32":
                break;
            case "m64":
                data[ML.lib] ~= "lib64";
                data[ML.is_vclinker] = "defined";
                break;
            case "m32mscoff":
                data[ML.is_vclinker] =  "defined";
                break;
            default:
                throw new Exception(_("Unknown option: %s", key));
            }
        },

        Getopt.Config.notInSummary,
        "deps",
        (string key, string val){ data.rewrite(ML.deps_file, val); },

        Getopt.Config.notInSummary,
        "Dd",
        (string key, string val){ data.rewrite(ML.ddoc, val); },

        Getopt.Config.regex,
        "^-.*$", "other options", _("are passed to dmd.", L),
        (string key) { data[ML.compile_flag] ~= key; },

        Getopt.Config.regex,
        ["^(?P<", Getopt.Key, ">[^-/].*)(?P<", Getopt.Equal, ">\\+=)(?P<",
         Getopt.Value, ">.*)$"].join,
        "name+=value", _("Append 'value' to the macro named 'name'.", L),
        (string key, string val){ data.forceConcat(key, val); },

        Getopt.Config.regex,
        ["^(?P<", Getopt.Key, ">[^-/][^=]*)(?P<", Getopt.Equal, ">=)(?P<",
         Getopt.Value, ">.*)$"].join,
        "name=value", _("Set 'value' to the macro named 'name'.", L),
        (string key, string val){ data.rewrite(key, val); },

        Getopt.Config.regex,
        "^[^-/=\\.][^=\\.]*$", "name",
        _("Set the macro named 'name' as 'defined'.", L),
        (string key){ data.rewrite(key, "defined"); },

        Getopt.Config.notInSummary,
        Getopt.Config.filePattern,
        "*.*",
        (string name, string ext)
        {
            auto nn = name.buildNormalizedPath;
            auto lext = ext.toLower;

            if      (data[ML.exe_ext] == lext)
                data.rewrite(ML.target, nn);
            else if (data[ML.mak_ext] == lext)
                data.rewrite(ML.m, nn);
            else
            {
                nn.exists.enforce(_("%s is not found.", name));

                if      (data[ML.lib_ext] == lext ||
                         data[ML.obj_ext] == lext)
                    data[ML.libs] ~= nn;
                else if (data[ML.src_ext] == lext)
                    data[ML.root] ~= nn;
                else if (data[ML.rc_ext] == lext)
                    data[ML.rc] ~= nn;
                else if (data[ML.def_ext] == lext)
                    data[ML.def] ~= nn;
                else if (data[ML.ddoc_ext] == lext)
                    data[ML.ddoc] ~= nn;
                else if (data[ML.xml_ext] == lext)
                    data.rewrite(ML.style, nn);
                else
                    throw new Exception(_("%s is an unknown file type.", name));
            }
        },

        );

    //
    if (result.helpWanted)
        return result;

    // この時点で root_file は指定されていなければならない。
    if (data.have(ML.root))
        logln("root file detected : ", data[ML.root]);
    else
    {
        _("please input root files of the project.\n").outln;
        result.helpWanted = true;
        return result;
    }

    // ターゲットが lib や、dll かどうか。
    if (data.have(ML.target))
    {
        auto target_ext = data[ML.target].extension.toLower;
        if      (target_ext == data[ML.dll_ext])
            data[ML.is_dll] = "defined";
        else if (target_ext == data[ML.lib_ext])
            data[ML.is_lib] = "defined";
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

    logln("file searching is ready : ", style_search.pathes);

    data.rewrite(ML.style,
                 style_search.abs(data[ML.style])
                 .enforce(data[ML.style] ~ " is not found"));

    logln("a style file is detected: " ~ data[ML.style]);

    // auto result = getopt (
    //     args,
    //     config.passThrough,
    //     "verbose", Lang("Set output policy as verbose.", "出力の冗長性を「冗長」に設定します。"),
    //     (string){ Output.mode = Output.MODE.VERBOSE; },

    //     "quiet|q", Lang("Set output policy as quiet.", "出力の冗長性を「最小」に設定します。"),
    //     (string){ Output.mode = Output.MODE.QUIET; },

    //     "L", Lang("Pass this to linker.", "リンカオプションを設定します。"),
    //     (string, string opt) {
    //         data[PREDEF.link_flag.stringof] ~= "-L" ~
    //             opt.startsWith("=") ? opt[1..$] : opt;
    //     },

    //     "I", Lang("Passed to dmd. This specify a directory of import.", "dmdに渡されます。インポートファイルが探されるディレクトリを設定します。"),
    //     (string, string opt) {
    //         data[PREDEF.src.stringof] ~=
    //             opt.startsWith("=") ? opt[1..$] : opt;
    //     },

    //     "o", Lang("Passed to dmd. This set the target of the project. -of=target.exe", "dmdに渡されます。プロジェクトのターゲットファイル名を指定します。 -of=target.exe"),
    //     (string, string opt) {
    //         switch (opt.startsWith("f=", "f"))
    //         {
    //         case 1:
    //             data.fix (PREDEF.target.stringof, opt[2..$]);
    //             break;
    //         case 2:
    //             data.fix (PREDEF.target.stringof, opt[1..$]);
    //             break;
    //         default:
    //             throw new Exception ("Unknown option: ", "-o" ~ opt);
    //         }
    //     },

    //     "m", Lang("Passed to dmd. This set linkage option. -m64 / -m32mscoff", "dmdに渡され、ターゲットのリンケージを設定します。-m64 / -m32mscoff"),
    //     (string, string opt) {
    //         data[PREDEF.compile_flag.stringof] ~= "-m" ~ opt;
    //         data[PREDEF.link_flag.stringof] ~= "-m" ~ opt;
    //         if      (opt == "32") {}
    //         else if (opt == "64")
    //         {
    //             data[PREDEF.lib.stringof] ~= "lib64";
    //             data[PREDEF.is_vclinker.stringof] = "defined";
    //         }
    //         else if (opt == "32mscoff")
    //         {
    //             data[PREDEF.is_vclinker.stringof] = "defined";
    //         }
    //         else
    //             throw Exception("Unknown option: ", "-m" ~ opt);
    //     },
        

    // string argsext;
    // for (sizediff_t i = 1, j ; i<args.length ; ++i)
    // {
    //     // dmd へのオプション
    //     if (args[i].startsWith("-"))
    //     {
    //         auto opt = args[i][1 .. $];
    //         if      (opt.startsWith("L"))
    //             data[PREDEF.link_flag.stringof] ~= args[i];
    //         else if (opt.startsWith("I"))
    //             data[PREDEF.src.stringof] ~= opt[1..$];
    //         else if (opt.startsWith("of"))
    //             data.rewrite(PREDEF.target.stringof, opt[2..$]);
    //         else if (opt.startsWith("deps="))
    //             data.rewrite(PREDEF.deps_file.stringof, opt[5 .. $]);
    //         else if (opt.startsWith("Dd"))
    //             data.rewrite(PREDEF.ddoc.stringof, opt[2 .. $]);
    //         else
    //         {
    //             auto a = args[i];
    //             data[PREDEF.compile_flag.stringof] ~= a;
    //             if      ("-m64" == a)
    //             {
    //                 data[PREDEF.link_flag.stringof] ~= a;
    //                 data[PREDEF.lib.stringof] ~= "lib64";
    //                 data[PREDEF.is_vclinker.stringof] = "defined";
    //             }
    //             else if ("-m32mscoff" == a)
    //             {
    //                 data[PREDEF.link_flag.stringof] ~= a;
    //                 data[PREDEF.is_vclinker.stringof] = "defined";
    //             }
    //         }
    //     }
    //     // マクロへの値つき代入
    //     else if (0 < (j = args[i].countUntil("+=")))
    //         data.forceConcat(args[i][0..j], args[i][j+2..$]);
    //     else if (0 < (j = args[i].countUntil('=')))
    //         data.rewrite(args[i][0..j], args[i][j+1..$]);
    //     // マクロへの値省略代入
    //     else if (0 == (argsext = args[i].extension).length)
    //         data.rewrite(args[i], "defined");
    //     // ターゲット
    //     else if (0 == argsext.icmp(data[PREDEF.exe_ext.stringof]) ||
    //              0 == argsext.icmp(data[PREDEF.dll_ext.stringof]))
    //         data.rewrite(PREDEF.target.stringof, args[i].buildNormalizedPath);
    //     else if (0 == argsext.icmp(data[PREDEF.mak_ext.stringof]))
    //         data.rewrite(PREDEF.m.stringof, args[i].buildNormalizedPath);
    //     // ファイル
    //     else
    //     {
    //         args[i].exists.enforce(args[i] ~ " is not found.");
    //         auto file = args[i].buildNormalizedPath;

    //         // ライブラリ
    //         if     (0 == argsext.icmp(data[PREDEF.lib_ext.stringof]) ||
    //                 0 == argsext.icmp(data[PREDEF.obj_ext.stringof]))
    //             data[PREDEF.libs.stringof] ~= file.buildNormalizedPath;
    //         else if (0 == argsext.icmp(data[PREDEF.src_ext.stringof]))
    //             data[PREDEF.root.stringof] ~= file.buildNormalizedPath;
    //         else if (0 == argsext.icmp(data[PREDEF.rc_ext.stringof]))
    //             data[PREDEF.rc.stringof] ~= file.buildNormalizedPath;
    //         else if (0 == argsext.icmp(data[PREDEF.def_ext.stringof]))
    //             data[PREDEF.def.stringof] ~= file.buildNormalizedPath;
    //         else if (0 == argsext.icmp(data[PREDEF.ddoc_ext.stringof]))
    //             data[PREDEF.ddoc.stringof] ~= file.buildNormalizedPath;
    //         else if (0 == argsext.icmp(data[PREDEF.xml_ext.stringof]))
    //             data.rewrite(PREDEF.style.stringof, file.buildNormalizedPath);
    //         else throw new Exception(args[i] ~ " is an unknown file type.");
    //     }
    // }

    // // この時点で root_file は指定されていなければならない。
    // data.have(PREDEF.root.stringof)
    //     .enforce(" please input root files of the project.");
    // debln("root file detected : ", data[PREDEF.root.stringof]);

    // // ターゲットが lib や、dll かどうか。
    // if (data.have(PREDEF.target.stringof))
    // {
    //     auto target_ext = data[PREDEF.target.stringof].extension;
    //     if      (0 == target_ext.icmp(data[PREDEF.dll_ext.stringof]))
    //         data[PREDEF.is_dll.stringof] = "defined";
    //     else if (0 == target_ext.icmp(data[PREDEF.lib_ext.stringof]))
    //         data[PREDEF.is_lib.stringof] = "defined";
    // }
    // -style.xml ファイルの探索
    // Search style_search = new Search;
    // style_search.install(".");
    // if      (auto path = environment.get("HOME"))
    //     style_search.install(path);
    // else if (auto path = environment.get("HOMEPATH"))
    //     style_search.install(path);

    // version      (Windows)
    //     style_search.install(args[0].dirName);
    // else version (linux)
    // {
    //     auto d = thisExePath.dirName;
    //     style_search.install(d);
    //     style_search.install(d.dirName.buildPath("etc/amm"));
    // }

    // debln("search is ready : ", style_search.pathes);

    // data.rewrite(PREDEF.style.stringof,
    //              style_search.abs(data[PREDEF.style.stringof])
    //              .enforce(data[PREDEF.style.stringof] ~ " is not found"));

    // logln(data[PREDEF.style.stringof] ~ " is detected.");

    return result;
}

//
string toCommandString(string[] args)
{
    import std.array: Appender;
    import std.algorithm: countUntil;
    import std.path: baseName;

    Appender!string buf;
    buf.put (args[0].baseName);
    foreach (one ; args[1..$])
    {
        buf.put(" ");
        if (0 <= one.countUntil(" ") || 0 <= one.countUntil("(") ||
            0 <= one.countUntil(")"))
        {
            buf.put("\""); buf.put(one); buf.put("\"");
        }
        else
            buf.put(one);
    }
    return buf.data;
}

