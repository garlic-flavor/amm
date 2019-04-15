/** Automatic Makefile Maker.
Version:    0.173(dmd2.085.1)
Date:       2019-Apr-15 01:04:00
Authors:    KUMA
License:    CC0
*/

module sworks.amm.main;

///
enum _VERSION_ = "0.173(dmd2.085.1)";

///
enum header =
    "Automatic Makefile Maker v" ~ _VERSION_ ~ ". Written by KUMA under CC0.";

///
string description()
{
    return _("This is a program that makes a Makefile from source files wirtten in D programmming language.");
}

///
enum how_to_use =
    ">amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d";

///
mixin NamedEnum!(
    //--------------------------------------------------------------------
    // basic environment.
    "bracket",
    "gmake",

    //--------------------------------------------------------------------
    // about file extension.
    "src_ext",
    "obj_ext",
    "exe_ext",
    "lib_ext",
    "dll_ext",
    "mak_ext",
    "rc_ext",
    "def_ext",
    "ddoc_ext",
    "xml_ext",

    //--------------------------------------------------------------------
    // pseudos for cross environment.
    "windows",
    "linux",

    //--------------------------------------------------------------------
    // directories to collect files.
    "src",
    "imp",
    "lib",
    "dd",

    //--------------------------------------------------------------------
    // files specified by command line.
    "root",
    "libs",
    "target",
    "m",
    "rc",
    "style",
    "def",
    "ddoc",

    //--------------------------------------------------------------------
    // flags specified by command line.
    "compile_flag",
    "link_flag",

    //--------------------------------------------------------------------
    // miscellaneous settings.
    "deps_file",
    "gen_deps_command",
    "footer",
    "v",

    //--------------------------------------------------------------------
    // amm ready these.
    "remake_command",
    "dependencies",
    "to_compile",
    "to_link",
    "i",
    "is_dll",
    "is_lib",
    "is_vclinker",

    ) PredefinedMacrosList;

//==============================================================================
import sworks.base.output;
import sworks.stylexml;
import sworks.base.mo;
import sworks.base.getopt;
import sworks.amm.args_data;
import sworks.amm.ready_data;
import sworks.amm.deps_data;
debug import std.stdio : writeln;

void main(string[] args)
{
    import std.conv: to;
    import std.file: exists, write;
    import std.exception : enforce;
    import std.string : lastIndexOf;
    import std.process: environment;
    import std.file: read;

    alias ML = PredefinedMacrosList;

    _.projectName = "amm";
    _.setlocale(environment.get("LANG", "en"));

    StyleParser parser;
    // マクロに初期値を設定
    auto data = default_macros;

    // コマンドライン引数解析
    auto result = data.set_args_data!PredefinedMacrosList(args);

    // ヘルプメッセージの表示
    if (result.helpWanted)
    {
        show_help(result.helpAbout, result.options, data);
        return;
    }

    // -style.xml ファイルの読み込み。
    auto str = data[ML.style].read.to!string;
    logln("success to open ", data[ML.style]);
    parser = new StyleParser(str, data);
    logln("parser is ready");

    // -style.xml ファイルのヘッダだけは読み込んでおく。
    parser.parseHead;
    logln("<head> is parsed successfully");

    // マクロを準備する。
    ready_data!ML(data);
    logln("macros are ready");

    data.logout_macros;

    // 依存関係を解決
    set_deps_data!ML(data);
    logln("dependencies are whole resolved.");

    //########## 準備完了 ##########
    // -style.xml ファイルのボディを処理する。
    logln("parse start.");
    auto makefile_cont = parser.parseBody();
    logln("parse success.");

    enforce(0 < makefile_cont.length, "failed to generate Makefile by " ~
            data[ML.style]);

    // Makefile が既存で、footer が見つかった場合、それ以降は残す。
    auto footer = data[ML.footer];
    if (0 < footer.length && data[ML.m].exists)
    {
        logln("old makefile is detected.");
        auto old_makefile_cont = data[ML.m].read.to!string;
        auto i = old_makefile_cont.lastIndexOf(footer);
        if (0 < i)
        {
            string post_footer = old_makefile_cont[i+footer.length .. $];
            if (0 < post_footer.length)
            {
                logln("post-footers are detected.");
                makefile_cont ~= post_footer;
            }
        }
    }

    // Makefile を出力。
    data[ML.m].write(makefile_cont);
    logln("complete.");
}

////////////////////////////////////////////////////////////////////////////////
private:

// マクロに初期値を設定します。
auto default_macros()
{
    import std.path: pathSeparator, dirSeparator;
    import std.array: join;

    alias ML = PredefinedMacrosList;

    auto db = new Macros;

    static @safe @nogc pure nothrow
    auto OS(string win, string nix)
    { version (Windows) return win; else return nix; }

    MacroItem S(string v, MacroItem.LazyMsg h)
    { return new SimpleItem(v, h); }

    MacroItem M(MacroItem.LazyMsg h)
    { return new MultiItem(h); }

    MacroItem MH(string v, MacroItem.LazyMsg h)
    {
        return new MultiHookedItem (v=>v.join(pathSeparator), h, [v]);
    }

    //--------------------------------------------------------------------
    db[ML.bracket] = new SimpleHookedItem(
        (string v)
        {
            switch (v)
            {
            case "rn":
                return "\r\n";
            case "r":
                return "\r";
            case "n":
                return "\n";
            default:
                throw new Exception(_("%s is not available as bracket.", v));
            }
            assert (0);
        }, OS("rn", "n"), _._("consists of newline characters. `'rn'` means CR+LF. `'n'` means LF. `'r'` means CR."));
    db[ML.gmake] = new SwitchItem(_._("for gnu make."), 0 < OS("", "defined").length);

    //--------------------------------------------------------------------
    db[ML.src_ext] = S(".d", _._("consists of the extension of source file. When a file with this extension is in the arguments, the file will be regarded the root file of the project. and the file will be set to the value of the macro 'ROOT'. When the value of macro 'TARGET' is undefined, the value of the macro will be set as 'ROOT' + 'EXE_EXT'."));
    db[ML.obj_ext] = S(OS(".obj", ".o"), _._("consists of an extension of a object file name."));
    db[ML.exe_ext] = S(OS(".exe", ""), _._("consists of an extension of an executable file name."));
    db[ML.lib_ext] = S(OS(".lib", ".a"), _._("consists of an extension of a statically linked library file name."));
    db[ML.dll_ext] = S(OS(".dll", ".so"), _._("consists of the extension of a Dynamic Linked Library. when a file with this extension is in the arguments, the file will be regarded as TARGET, and the macro 'IS_DLL' is defined."));
    db[ML.mak_ext] = S(".mak", _._("consists of the extension of Makefile. when a file with this extension is in the arguments, the file will be regarded as Makefile."));
    db[ML.rc_ext] = S(".rc", _._("consists of the extension of a resource file. When a file with this extension is in the arguments, the file will be set to the value of the macro 'RC'. Windows only."));
    db[ML.def_ext] = S(".def", _._("consists of the extension of a module definition file of D. when a file with this extension is in the arguments, the file will be regarded as module definition file."));
    db[ML.ddoc_ext] = S(".ddoc", _._("consists of the extension of a file for ddoc. when a file with this extension is in the arguments, the file will be regarded as for ddoc."));
    db[ML.xml_ext] = S(".xml", _._("consists of the extension of STYLE_FILE. when a file with this extension is in the arguments, the file will be regarded STYLE_FILE."));

    //--------------------------------------------------------------------
    db[ML.windows] = new SwitchHookedItem((){
        }, _._("when this macro is defined, standard settings for windows are chosen."));
    db[ML.linux] = new SwitchHookedItem((){
        }, _._("when this macro is defined, standard settings for linux are chosen."));

    //--------------------------------------------------------------------
    db[ML.src] = MH("src", _._("command line arguments that starts with '-I' is set to this value. This value is used to decide that the root directory of source files to be compiled."));
    db[ML.imp] = MH("import", _._("consists of the directory that contains files to be imported by your project."));
    db[ML.lib] = MH("lib", _._("consists of the directory that contains the file to be linked by your project."));
    db[ML.dd] = S("doc", _._("consists of the target directory of DDOC."));

    //--------------------------------------------------------------------
    db[ML.root] = M(_._("consists of the file name of a root file of your project. When a file name having `'.d'` as its extension is passed as a command line argument, the file name will be set to this macro."));
    db[ML.libs] = M( _._("consists of libraries names to link. Amm will gather files form the directory specified by the macro named `'lib'`."));
    db[ML.target] = M(_._("consists of the target file name of your project. On Windows, when a file name having `'.exe'` or `'.dll'` as its extension is passed as a command line argument, the file name will be set to this macro."));
    db[ML.m] = S("Makefile", _._("consists of the name of the Makefile."));
    db[ML.rc] = M(_._("consists of resource files. Windows only."));
    db[ML.style] = S("make-style.xml", _._("STYLE_FILE controls output."));
    db[ML.def] = M(_._("On Windows, when a file that has `'.def'` as its extension is passed as a command line argument, the file name will be set to this macro."));
    db[ML.ddoc] = M(_._("when a file that has `'.ddoc'` as its extension is passed as a command line argument, the file name will be set to this macro."));

    //--------------------------------------------------------------------
    db[ML.compile_flag] = M(_._("consists of compile flags for dmd. When a command line argument starts with `'-'`, the argument will be set to this macro."));
    db[ML.link_flag] = M( _._("consists of link flags for dmd. When a command line argument for amm starts with `'-L'`, the argument will be set to this macro."));

    //--------------------------------------------------------------------
    db[ML.deps_file] = S("tempdeps", _._("consists of the file name of the target of `'gen_deps_command'`."));
    db[ML.gen_deps_command] = S("dmd -c -op -o- -debug", _._("consists of the command that invokes dmd to resolve your project's dependencies."));
    db[ML.footer] = S("## generated by amm.", _._("consists of the 'footer mark' of the Makefile. Amm will overwrite the Makefile but, contents after this mark will remain."));
    db[ML.v] = S("", _._("specify the description about your project."));

    //--------------------------------------------------------------------
    db[ML.remake_command] = S("", _._("consists of the command line arguments that invoked amm."));
    db[ML.dependencies] = new MultiHookedItem(v=>v.join(db[ML.bracket]), _._("Amm will set this value."));
    db[ML.to_compile] = M(_._("Amm will set this value."));
    db[ML.to_link] = M(_._("Amm will set this value."));
    db[ML.i] = M(_._("Amm will set this value. This is same as `-I` option for dmd."));
    db[ML.is_dll] = new SwitchItem(_._("mark whether the target of your project is dynamic link library."));
    db[ML.is_lib] = new SwitchItem(_._("mark whether the target of your project is static link library."));
    db[ML.is_vclinker] = new SwitchItem(_._("If 'defined', dmd will invoke the linker of Microsoft."));


    // db[ML.env] = S("", _._("This macro exists for backward compatibility."));

    // db[ML.rc_file] = M(_._("On Windows, when a file that has `'.rc'` as its extension is passed as a command line argument, the file name will be set to this macro."));
    // db[ML.style_file] = S("make-style.xml", _._("consists of the setting file name."));
    // db[ML.authors] = S("", _._("specify the description about your project."));
    // db[ML.license] = S("", _._("specify the description about your project."));
    // db[ML.date] = M("", _._("Amm will set this value as today."));

    debug
    {
        // 全部あるかチェック
        foreach (one; __traits(allMembers, ML))
            assert (db.exists(one),
                    _("%s is not found.", one));

        // いらんのないかチェック
    outer:
        foreach (one; db.keys)
        {
            foreach (o; __traits(allMembers, ML))
                if (one == o) continue outer;
            assert (0, _("%s is not used.", one));
        }

    }
    return db;
}

//
void logout_macros(Macros macros)
{
    import std.algorithm: sort;
    import sworks.base.strutil;
    import std.array: array;

    if (Output.MODE.VERBOSE <= Output.mode)
    {
        "---------- current macros".logln;
        auto keys = macros.keys.sort.array;
        auto tabs = new string[2][keys.length];
        foreach (size_t i, key; keys)
        {
            tabs[i][0] = key;
            tabs[i][1] = macros[key];
        }
        // tabs.tabular("name", "value", -1, "=").logln;

        // foreach (key; macros.keys.sort)
        //     key.logln(" = ", macros[key]);
        "----------".logln;
    }
}

//
void show_help(string about, Getopt.Option[] opts, Macros macros)
{
    import std.format: format;
    import std.string: toLower;
    import sworks.base.strutil: Tabular;
    import std.array: replace;
    import std.conv: to;

    alias T3 = Tabular!3;
    alias T3C = T3.Column;

    alias ML = PredefinedMacrosList;

    void macroOut(int w)
    {
        auto t = T3(w, T3C(_("name")), T3C(_("default value")),
                    T3C(_("description")));
        foreach (one; __traits(allMembers, ML))
        {
            auto m = macros.get(one);
            if      (one == "bracket")
            {
                t(one,
                  m.toString.replace("\n", "n").replace("\r", "r").to!string,
                  m.help);
            }
            else if (one == "remake_command")
                t(one, "amm.exe", m.help);
            else
                t(one, m.toString, m.help);
        }
        t.dump.outln;
    }


    switch (about.toLower)
    {
    case "macro":
    {
        _("Predefined macros are bellows.").outln;
        macroOut(cast(int)(Output.getTerminalWidth-1));
    }
        break;
    case "howtouse":
        how_to_use.outln;
        break;
    case "summary":
        Getopt.prettyDescriptor(opts, -1).outln;
        break;
    case "macro_md":
        macroOut(-1);
        break;
    default:
        header.outln;
        description.outln;
        outln;
        how_to_use.outln;
        outln;
        Getopt.prettyDescriptor(opts, 80).outln;
        outln;
        _("To show more details, invoke with --help TOPICS.").outln;
        _("Available TOPICS are bellows.").outln;
        ("--help macro").outln;
        break;
    }
}

template NamedEnum(ARGS...)
{
    static if (0 < ARGS.length)
    {
        mixin("enum " ~ ARGS[0] ~ " = \"" ~ ARGS[0] ~ "\";");
        mixin NamedEnum!(ARGS[1..$]);
    }
}
