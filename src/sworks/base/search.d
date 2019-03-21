/** 入力されたディレクトリの順にファイルを検索します。
 * Dmd:        2.085.0
 * Date:       2016-Jun-04 00:02:01
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.base.search;
/// support only UTF-8

/// 拡張子のつけかえ。ext=="" の時は拡張子を取る。
@trusted pure nothrow
string setExt(string path, string ext)
{
    import std.path : setExtension, stripExtension;
    if (0 < ext.length) return path.setExtension(ext);
    else return path.stripExtension;
}

/** path が base フォルダに含まれるか?
Returns:
  含まれる場合 true
**/
@trusted pure
bool isChildOf(string path, string base)
{
    import std.path : absolutePath, buildNormalizedPath, isDirSeparator;
    if (0 == path.length || 0 == base.length) return false;
    auto apath = path.absolutePath.buildNormalizedPath;
    auto abase = base.absolutePath.buildNormalizedPath;

    if (abase.length <= apath.length && abase == apath[0 .. abase.length]
        && (abase.length == apath.length || abase[$-1].isDirSeparator
            || apath[abase.length].isDirSeparator)) return true;
    else return false;
}


/** エントリ内でファイルが見つかった場合、その絶対/相対パスを返す。

Notice:
  Windowsのみ
  検索の順序は install() を呼び出した順
  最初のヒットで検索は終了します。
**/
class Search
{
@trusted:

    @property @nogc pure nothrow
    auto pathes() inout { return _path[]; }
    @property @nogc pure nothrow
    size_t length() const { return _path.length; }

    /** サーチパスに加える。
     Params:
       path = カレントディレクトリから見えているパスでなければならない。
     */
    bool install(string path)
    {
        import std.path : absolutePath, buildNormalizedPath;
        import std.file : exists, isDir;

        if (0 == path.length) return false;
        auto p = path.absolutePath.buildNormalizedPath;
        if (p.exists && p.isDir)
        {
            _path ~= p;
            return true;
        }
        else return false;
    }

    /** 絶対パスを探す。
     Params:
       p = 検索するパス
     Returns:
       パスが見付かった場合は、その絶対パス。見つからなかった場合は null。
     */
    nothrow
    string abs(string p)
    {
        import std.path : buildPath, buildNormalizedPath, isAbsolute;
        import std.file : exists;
        if      (0 == p.length){}
        else if (p.isAbsolute)
        {
            if (p.exists) return p.buildNormalizedPath;
        }
        else
        {
            foreach (one ; _path)
            {
                string result = one.buildPath(p);
                if (result.exists) return result.buildNormalizedPath;
            }
        }
        return null;
    }

    /// ditto
    string rel(string p)
    {
        import std.path : relativePath;
        string abspath = abs(p);
        if (0 == abspath.length) return null;
        else return abspath.relativePath;
    }

    /// install の子孫ディレクトリかどうか
    pure
    bool contain(string p)
    {
        import std.path : absolutePath, buildNormalizedPath;
        if (0 == p.length) return false;
        p = p.absolutePath.buildNormalizedPath;
        foreach (one ; _path)
        {
            if (p.isChildOf(one)) return true;
        }
        return false;
    }


    @property pure nothrow
    override string toString()
    {
        import std.path : dirSeparator;
        import std.conv : to;
        import std.string : join;
        return _path.join(dirSeparator).to!string;
    }

private:
    // _path は絶対パス(ドライブ名をふくむ。)
    string[] _path;
}

//##############################################################################
debug(search):

import std.stdio;

void main()
{
    import std.path : absolutePath;
    Search search = new Search;
    search.install("..");

    writeln(search);

    string abs_path = search.abs("vwrite/../vwrite/src/sworks/base/search.d");
    writeln(abs_path);
    string rel_path = search.rel(abs_path);
    writeln(rel_path);
    string abs2 = "README.md".absolutePath;
    if (abs2.isChildOf("..")) writeln(abs2~" is a child");
    else writeln(abs2~" is not a child");
}

