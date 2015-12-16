/** dmd を呼び出し、プロジェクトの依存関係を解決する.
 * Version:    0.167(dmd2.069.2)
 * Date:       2015-Dec-16 19:25:53
 * Authors:    KUMA
 * License:    cc0
 */
module sworks.amm.deps_data;
import std.algorithm, std.process, std.exception, std.file, std.path,
      std.string, std.array, std.conv, std.regex;
import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;
import sworks.stylexml.macro_item;
alias std.string.join join;

// dmd を呼び出し、 data の["dependencies"] に依存関係を記述する。
void set_deps_data(alias MACROKEY)(Macros data)
{
    auto src_search = new Search;
    enforce(data.have(MACROKEY.SRC_DIRECTORY),
            "src directory is not detected.");
    foreach (one ; data.get(MACROKEY.SRC_DIRECTORY).toArray)
        src_search.entry(one);
    auto imp_search = new Search;
    if (data.have(MACROKEY.IMPORT_DIRECTORY))
        foreach (one ; data.get(MACROKEY.IMPORT_DIRECTORY).toArray)
            imp_search.entry(one);
    Output.logln("file filters are ready");

    DepsLink[string] depslink;
    string obj_ext = data[MACROKEY.OBJ_EXT];
    // dmd を呼び出した結果として生成されるファイル名
    string deps_file = data[MACROKEY.DEPS_FILE];

    // それぞれのルートファイルに対し、依存関係を解決する。
    foreach (one ; data.get(MACROKEY.ROOT_FILE).toArray)
    {
        auto abs = one.absolutePath.buildNormalizedPath;
        set_deps_of!MACROKEY(one, data, depslink,
                             fn=> fn == abs || src_search.contain(fn)
                                             && !imp_search.contain(fn),
                             deps_file, obj_ext);
    }
    auto dependencies = depslink.resolve_public_deps;

    // マクロの値をセットする。
    string[] depslines;
    foreach (key, one ; dependencies)
    {
        auto obj_name = key.setExtension(obj_ext);
        if (0 < one.length)
            depslines ~= obj_name ~ " : " ~ one.keys.join(" ");

        data[MACROKEY.TO_COMPILE] ~= key;
        data[MACROKEY.TO_LINK] ~= obj_name;
    }


    // リソースファイルがある場合はそれも追加しておく。
    if (data.have(MACROKEY.RC_FILE))
        depslines ~= data[MACROKEY.RC_FILE].setExtension("res") ~ " : "
                   ~ data[MACROKEY.RC_FILE];

    data[MACROKEY.DEPENDENCE] = depslines.join(data[MACROKEY.BRACKET]);
}


/** depsfile をパースする。

↓こんなんを期待している。
"sworks.util.style_parser (src\\sworks\\amm\\style_parser.d) : public : sworks.util.output (src\\sworks\\util\\output.d)"
**/
class DepsLink
{
    string name;
    DepsLink[] pub;
    DepsLink[] prv;

    this(string n) { this.name = n; }
}

void parse_depsfile(string filecont, ref DepsLink[string] depslink,
                    bool delegate(string) isMemberFile)
{
    auto m = match(filecont, regex(`^\S+\s+\(([^\)]+)\)\s+:\s+(\S+)\s+:\s+\S+\s+\(([^\)]+)\)`, "gm"));

    foreach (one ; m)
    {
        auto c = one.captures;
        enforce(4 == c.length);

        auto fn = c[1].replace("\\\\", "\\");
        if (!isMemberFile(fn.absolutePath.buildNormalizedPath)) continue;
        auto df = c[3].replace("\\\\", "\\");
        if (!isMemberFile(df.absolutePath.buildNormalizedPath)) continue;

        auto fl = depslink.get(fn, new DepsLink(fn));
        depslink[fn] = fl;

        auto dl = depslink.get(df, new DepsLink(df));
        depslink[df] = dl;

        if (0 == "public".icmp(c[2])) fl.pub ~= dl;
        else fl.prv ~= dl;
    }
}

/** public import を解決する。

Returns:
  ダミーの bool 値の -> 被依存ファイル名をキーとする連想配列
   -> 依存元ファイル名をキーとする連想配列。
**/
bool[string][string] resolve_public_deps(DepsLink[string] dls)
{
    bool[string][string] result;

    string[] get_pub_links(DepsLink dl)
    {
        bool[string] r;
        foreach (one ; dl.pub)
        {
            r[one.name] = true;
            if (one.name !in r)
            {
                auto t = get_pub_links(one);
                foreach (o ; t) r[o] = true;
            }
        }
        return r.keys;
    }

    foreach (key, dl ; dls)
    {
        bool[string] deps;
        deps[key] = true;
        foreach (one ; dl.prv) deps[one.name] = true;
        foreach (one ; get_pub_links(dl)) deps[one] = true;
        result[key] = deps;
    }

    return result;
}

/// 一つのファイルの依存関係を解決する。
void set_deps_of(alias MACROKEY)(string root_file, Macros data,
                                 ref DepsLink[string] depslink,
                                 bool delegate(string) isMemberFile,
                                 string deps_file, string obj_ext)
{
    // 終了時に dmd に生成させたファイルを削除する。
    scope(exit) if (deps_file.exists) deps_file.remove;

    auto command = data[MACROKEY.GENERATE_DEPS] ~ " -deps=" ~ deps_file ~ " "
        ~ data[MACROKEY.COMPILE_FLAG] ~ " " ~ root_file;
    Output.logln("generation command is>", command);
    // dmd を実行
    auto result = executeShell(command);
    enforce(0 == result.status && std.file.exists(deps_file),
            "\n" ~ result.output ~ "\nfail to generate " ~ deps_file);

    auto rootl = depslink.get(root_file, new DepsLink(root_file));
    depslink[root_file] = rootl;

    deps_file.read.to!string.parse_depsfile(depslink, isMemberFile);
}
