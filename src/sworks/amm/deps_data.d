/** dmd を呼び出し、プロジェクトの依存関係を解決する.
 * Version:    0.172(dmd2.085.0)
 * Date:       2016-Jun-04 00:02:01
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.deps_data;

import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;
import sworks.stylexml.macro_item;
debug import std.stdio : writeln;

// dmd を呼び出し、 data の["dependencies"] に依存関係を記述する。
void set_deps_data(alias PREDEF)(Macros data)
{
    import std.exception : enforce;
    import std.path : absolutePath, buildNormalizedPath, setExtension;
    import std.algorithm : bringToFront, sort, find;
    import std.range : take;

    auto src_search = new Search;
    data.have(PREDEF.src).enforce("src directory is not detected.");
    foreach (one ; data.get(PREDEF.src).toArray)
        src_search.install(one);
    auto imp_search = new Search;
    if (data.have(PREDEF.imp))
        foreach (one ; data.get(PREDEF.imp).toArray)
            imp_search.install(one);
    logln("file filters are ready");

    DepsLink[string] depslink;
    string obj_ext = data[PREDEF.obj_ext];
    // dmd を呼び出した結果として生成されるファイル名
    string deps_file = data[PREDEF.deps_file];

    // それぞれのルートファイルに対し、依存関係を解決する。
    foreach (one ; data.get(PREDEF.root).toArray)
    {
        auto abs = one.absolutePath.buildNormalizedPath;
        set_deps_of!PREDEF(
            one, data, depslink,
            fn => fn == abs || src_search.contain(fn) &&
                  !imp_search.contain(fn),
            deps_file, obj_ext);
    }
    depslink.resolve_public_deps;
    logln("resolving public dependencies done.");

    // マクロの値をセットする。
    import std.array : Appender;
    import std.string : join;
    auto depslines = Appender!(string[])();
    depslines.reserve(depslink.length);
    auto keys = depslink.keys.sort;
    foreach (one; data.get(PREDEF.root).toArray)
        keys.bringToFront(keys.find(one).take(1));

    foreach (key ; keys)
    {
        auto one = depslink[key];
        if (!one.needsCompile) continue;
        auto obj_name = one.name.setExtension(obj_ext);
        if (0 < one.allDeps.length)
            depslines.put([obj_name, " : ", one.allDeps.join(" ")].join);

        data[PREDEF.to_compile] ~= one.name;
        data[PREDEF.to_link] ~= obj_name;
    }
    logln("all resolving of dependencies done.");

    // リソースファイルがある場合はそれも追加しておく。
    if (data.have(PREDEF.rc))
    {
        depslines.put(data[PREDEF.rc].setExtension("res") ~ " : " ~
                      data[PREDEF.rc]);
        logln("a resource file is detected: ", data[PREDEF.rc]);
    }

    data[PREDEF.dependencies] =
        depslines.data.join(data[PREDEF.bracket]);

    logln("dependencies macro is ready.");
}

private: //#####################################################################

/// 一つのファイルの依存関係を解決する。
void set_deps_of(alias PREDEF)(string root_file, Macros data,
                                   ref DepsLink[string] depslink,
                                   bool delegate(string) isMemberFile,
                                   string deps_file, string obj_ext)
{
    import std.conv : to;
    import std.file : exists, read, remove;
    import std.string : join;
    import std.process : executeShell;
    import std.exception : enforce;

    // 終了時に dmd に生成させたファイルを削除する。
    scope(exit) if (deps_file.exists) deps_file.remove;

    auto command = [data[PREDEF.gen_deps_command], " -deps=",
                    deps_file, " ", data[PREDEF.compile_flag], " ",
                    root_file].join;
    logln("generation command is>", command);
    // dmd を実行
    auto result = executeShell(command);
    enforce(0 == result.status && deps_file.exists,
            "\n" ~ result.output ~ "\nfail to generate " ~ deps_file);
    logln("command succeeded.");

    depslink[root_file] = depslink.get(root_file, new DepsLink(root_file));

    logln("read tempdeps");
    deps_file.read.to!string.parse_depsfile(depslink, isMemberFile);
}

/** depsfile をパースする。

↓こんなんを期待している。
"sworks.util.style_parser (src\\sworks\\amm\\style_parser.d) : public : sworks.util.output (src\\sworks\\util\\output.d)"
**/
class DepsLink
{
    string name;
    // 文字列インポートにより依存関係に上っているものは false になる。
    bool needsCompile;
    DepsLink[] deps;

    bool resolvedAboutThis;
    string[] allDeps;

    this(string n, bool nc = true) { this.name = n; needsCompile = nc; }
}

void parse_depsfile(string filecont, ref DepsLink[string] depslink,
                    bool delegate(string) isMemberFile)
{
    import std.regex : ctRegex, match;
    import std.array : replace;
    import std.path : absolutePath, buildNormalizedPath;

    log("start parsing tempdeps.");

    enum REG = ctRegex!(
        `^\S+\s+\(([^\)]+)\)\s+:\s+(\S+)\s+:\s+\S+\s+\(([^\)]+)\)`, "gm");
    auto m = filecont.match(REG);

    size_t counter;
    foreach (one; m)
    {
        auto c = one.captures;
        assert(4 == c.length);

        auto fn = c[1].replace("\\\\", "\\");
        if (!isMemberFile(fn.absolutePath.buildNormalizedPath)) continue;
        auto type = c[2];
        auto df = c[3].replace("\\\\", "\\");
        if (!isMemberFile(df.absolutePath.buildNormalizedPath)) continue;

        auto fl = depslink.get(fn, new DepsLink(fn));
        depslink[fn] = fl;

        auto dl = depslink.get(df, new DepsLink(df, type != "string"));
        depslink[df] = dl;

        fl.deps ~= dl;

        log(++counter, ".");
    }
    logln("done.");
}

/** public import を解決する。
**/
void resolve_public_deps(DepsLink[string] dls)
{
    logln("start resolving of public dependencies.");

    // 間接的依存関係を解決
    void fill_indirect_dependencies(DepsLink dl)
    {
        assert(dl);
        if (dl.resolvedAboutThis || 0 < dl.allDeps.length) return;
        dl.resolvedAboutThis = true;

        logln("start with: ", dl.name);
        Output.incIndent;
        bool[string] allDeps;
        allDeps[dl.name] = true;
        foreach (d; dl.deps)
        {
            if (d.name == dl.name) continue;

            assert(d);
            logln("about: ", d.name);

            allDeps[d.name] = true;
            if (auto pd = d.name in dls)
            {
                assert((*pd).name != dl.name);
                fill_indirect_dependencies(*pd);
                foreach (one; (*pd).allDeps)
                    allDeps[one] = true;
            }
        }
        dl.allDeps = allDeps.keys;
        Output.decIndent;
    }
    foreach (key, dl; dls)
    {
        logln("about :", key);
        Output.incIndent;
        fill_indirect_dependencies(dl);
        logln("done.");
        Output.decIndent;
    }
}

