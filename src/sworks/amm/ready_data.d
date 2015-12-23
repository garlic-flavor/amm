/** dmd に依存関係を解決させる為の下準備.
 * Version:    0.168(dmd2.069.2)
 * Date:       2015-Dec-23 19:01:54.2955255
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.ready_data;

import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;

void ready_data(alias MACROSTORE)(Macros data)
{
    import std.array : appender;
    import std.algorithm : splitter;
    import std.exception : enforce;
    import std.path : baseName, buildNormalizedPath, isFile, dirEntries,
        extension, relativePath;
    import std.file : exists, SpanMode;
    import std.string : icmp;

    // ターゲット名の決定
    if (!data.have(MACROSTORE.PREDEF.target))
    {
        assert(data.have(MACROSTORE.PREDEF.root));
        string target_ext;
        if     (data.have(MACROSTORE.PREDEF.is_dll))
            target_ext = data[MACROSTORE.PREDEF.dll_ext];
        else if (data.have(MACROSTORE.PREDEF.is_lib))
            target_ext = data[MACROSTORE.PREDEF.lib_ext];
        else target_ext = data[MACROSTORE.PREDEF.exe_ext];

        data[MACROSTORE.PREDEF.target] =
            (data.get(MACROSTORE.PREDEF.root).toArray[0])
            .baseName.setExt(target_ext);
    }
    logln("target name is " ~ data[MACROSTORE.PREDEF.target]);

    // def ファイルの決定
    if (data.have(MACROSTORE.PREDEF.is_dll) &&
        !data.have(MACROSTORE.PREDEF.def))
    {
        assert(data.have(MACROSTORE.PREDEF.root));
        // 一つ目のルートファイルの basename が .def のファイル名として使われる
        auto deffile = data.get(MACROSTORE.PREDEF.root).toArray[0]
            .setExt(data[MACROSTORE.PREDEF.def]);
        deffile.exists.enforce(".def file for dll is not found.");
        data[MACROSTORE.PREDEF.def] = deffile;
    }

    // ディレクトリ型の探索
    foreach (one ; __traits(allMembers, MACROSTORE))
    {
        static if (one == "imp" || one == "lib" || one == "src" || one == "dd")
        {
            auto item = data.get(one);
            if (null is item || item.isEmpty) continue;
            auto isM = item.isMutable;
            item.isMutable = true;
            auto result = appender!(string[])();
            foreach (val ; item.toArray)
            {
                foreach (o ; val.splitter(";"))
                {
                    if (!o.exists) continue;
                    result.put(o.buildNormalizedPath);
                }
            }
            item = result.data;
            item.isMutable = isM;
        }
    }

    // ソースファイルを含むディレクトリの決定
    auto src_dir = data.get(MACROSTORE.PREDEF.src);
    foreach (one ; data.get(MACROSTORE.PREDEF.imp).toArray) src_dir ~= one;

    logln("source file directories are " ~ data[MACROSTORE.PREDEF.src]);

    // 外部ライブラリの決定
    foreach (one ; data.get(MACROSTORE.PREDEF.lib).toArray)
    {
        if (!one.exists || one.isFile) continue;

        foreach (string name ; one.dirEntries(SpanMode.depth))
        {
            if (0 == data[MACROSTORE.PREDEF.lib_ext].icmp(name.extension))
                data[MACROSTORE.PREDEF.libs] ~= name.relativePath;
        }
    }

    // dmd の '-I' オプションを準備
    if (data.have(MACROSTORE.PREDEF.src))
        data[MACROSTORE.PREDEF.compile_flag] ~=
            "-I" ~ data[MACROSTORE.PREDEF.src];

    // この時点で Makefile の名前は決定されていなければならない。
    data.have(MACROSTORE.PREDEF.m).enforce("please specify Makefile's name.");
}




