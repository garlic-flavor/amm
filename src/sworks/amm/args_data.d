/** コマンドライン引数を解析します.
 * Version:    0.173(dmd2.085.1)
 * Date:       2019-Apr-15 00:15:59
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

    auto result = Getopt(
        args,

        "lang", "-lang **", _._("Specify the language. The default value is taken from an environment variable named 'LANG'."),
        (string key, string lang) { _.setlocale(lang); },

        "verbose", _._("Set output policy as 'VERBOSE'."),
        (){ Output.mode = Output.MODE.VERBOSE; },

        "quiet|q", _._("Set output policy as 'quiet'."),
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
        "^-.*$", "other options", _._("are passed to dmd."),
        (string key) { data[ML.compile_flag] ~= key; },

        Getopt.Config.regex,
        ["^(?P<", Getopt.Key, ">[^-/].*)(?P<", Getopt.Equal, ">\\+=)(?P<",
         Getopt.Value, ">.*)$"].join,
        "name+=value", _._("Append 'value' to the macro named 'name'."),
        (string key, string val){ data.forceConcat(key, val); },

        Getopt.Config.regex,
        ["^(?P<", Getopt.Key, ">[^-/][^=]*)(?P<", Getopt.Equal, ">=)(?P<",
         Getopt.Value, ">.*)$"].join,
        "name=value", _._("Set 'value' to the macro named 'name'."),
        (string key, string val){ data.rewrite(key, val); },

        Getopt.Config.regex,
        "^[^-/=\\.][^=\\.]*$", "name",
        _._("Set the macro named 'name' as 'defined'."),
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
        import std.file: thisExePath;
        import std.path: buildPath;

        auto d = thisExePath.dirName;
        style_search.install(d);
        style_search.install(d.dirName.buildPath("etc/amm"));
    }

    logln("file searching is ready : ", style_search.pathes);

    data.rewrite(ML.style,
                 style_search.abs(data[ML.style])
                 .enforce(data[ML.style] ~ " is not found"));

    logln("a style file is detected: " ~ data[ML.style]);

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

