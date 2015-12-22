/** dmd を呼び出し、プロジェクトの依存関係を解決する.
 * Version:    0.168(dmd2.069.2)
 * Date:       2015-Dec-20 20:43:41
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
void set_deps_data(alias MACROSTORE)(Macros data)
{
    import std.exception : enforce;
    import std.path : absolutePath, buildNormalizedPath, setExtension;

    auto src_search = new Search;
    data.have(MACROSTORE.PREDEF.src).enforce("src directory is not detected.");
    foreach (one ; data.get(MACROSTORE.PREDEF.src).toArray)
        src_search.install(one);
    auto imp_search = new Search;
    if (data.have(MACROSTORE.PREDEF.imp))
        foreach (one ; data.get(MACROSTORE.PREDEF.imp).toArray)
            imp_search.install(one);
    logln("file filters are ready");

    DepsLink[string] depslink;
    string obj_ext = data[MACROSTORE.PREDEF.obj_ext];
    // dmd を呼び出した結果として生成されるファイル名
    string deps_file = data[MACROSTORE.PREDEF.deps_file];

    // それぞれのルートファイルに対し、依存関係を解決する。
    foreach (one ; data.get(MACROSTORE.PREDEF.root).toArray)
    {
        auto abs = one.absolutePath.buildNormalizedPath;
        set_deps_of!MACROSTORE(
            one, data, depslink,
            fn => fn == abs || src_search.contain(fn) &&
                  !imp_search.contain(fn),
            deps_file, obj_ext);
    }
    depslink.resolve_public_deps;

    // マクロの値をセットする。
    import std.array : Appender;
    import std.string : join;
    auto depslines = Appender!(string[])();
    depslines.reserve(depslink.length);
    foreach (one ; depslink)
    {
        auto obj_name = one.name.setExtension(obj_ext);
        if (0 < one.allDeps.length)
            depslines.put([obj_name, " : ", one.allDeps.join(" ")].join);

        data[MACROSTORE.PREDEF.to_compile] ~= one.name;
        data[MACROSTORE.PREDEF.to_link] ~= obj_name;
    }

    // リソースファイルがある場合はそれも追加しておく。
    if (data.have(MACROSTORE.PREDEF.rc))
        depslines.put(data[MACROSTORE.PREDEF.rc].setExtension("res") ~ " : " ~
                      data[MACROSTORE.PREDEF.rc]);

    data[MACROSTORE.PREDEF.dependencies] =
        depslines.data.join(data[MACROSTORE.PREDEF.bracket]);
}

private: //#####################################################################

/// 一つのファイルの依存関係を解決する。
void set_deps_of(alias MACROSTORE)(string root_file, Macros data,
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

    auto command = [data[MACROSTORE.PREDEF.gen_deps_command], " -deps=",
                    deps_file, " ", data[MACROSTORE.PREDEF.compile_flag], " ",
                    root_file].join;
    logln("generation command is>", command);
    // dmd を実行
    auto result = executeShell(command);
    enforce(0 == result.status && deps_file.exists,
            "\n" ~ result.output ~ "\nfail to generate " ~ deps_file);

    depslink[root_file] = depslink.get(root_file, new DepsLink(root_file));

    deps_file.read.to!string.parse_depsfile(depslink, isMemberFile);
}

/** depsfile をパースする。

↓こんなんを期待している。
"sworks.util.style_parser (src\\sworks\\amm\\style_parser.d) : public : sworks.util.output (src\\sworks\\util\\output.d)"
**/
class DepsLink
{
    string name;
    DepsLink[] deps;
    string[] allDeps;

    this(string n) { this.name = n; }
}

void parse_depsfile(string filecont, ref DepsLink[string] depslink,
                    bool delegate(string) isMemberFile)
{
    import std.regex : ctRegex, match;
    import std.array : replace;
    import std.path : absolutePath, buildNormalizedPath;

    enum REG = ctRegex!(
        `^\S+\s+\(([^\)]+)\)\s+:\s+\S+\s+:\s+\S+\s+\(([^\)]+)\)`, "gm");
    auto m = filecont.match(REG);

    foreach (one; m)
    {
        auto c = one.captures;
        assert(3 == c.length);

        auto fn = c[1].replace("\\\\", "\\");
        if (!isMemberFile(fn.absolutePath.buildNormalizedPath)) continue;
        auto df = c[2].replace("\\\\", "\\");
        if (!isMemberFile(df.absolutePath.buildNormalizedPath)) continue;

        auto fl = depslink.get(fn, new DepsLink(fn));
        depslink[fn] = fl;

        auto dl = depslink.get(df, new DepsLink(df));
        depslink[df] = dl;

        fl.deps ~= dl;
    }
}

/** public import を解決する。
**/
void resolve_public_deps(DepsLink[string] dls)
{
    // 間接的依存関係を解決
    void fill_indirect_dependencies(DepsLink dl)
    {
        if (0 < dl.allDeps.length) return;

        bool[string] allDeps;
        allDeps[dl.name] = true;
        foreach (d; dl.deps)
        {
            allDeps[d.name] = true;
            if (auto pd = d.name in dls)
            {
                fill_indirect_dependencies(*pd);
                foreach (one; (*pd).allDeps)
                    allDeps[one] = true;
            }
        }
        dl.allDeps = allDeps.keys;
    }
    foreach (dl; dls) fill_indirect_dependencies(dl);
}

