/** dmd に依存関係を解決させる為の下準備.
 * Version:    0.173(dmd2.085.1)
 * Date:       2019-Apr-15 00:47:24
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.ready_data;

import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;
import sworks.base.mo;

void ready_data(alias PREDEF)(Macros data)
{
    import std.array : appender;
    import std.algorithm : splitter;
    import std.exception : enforce;
    import std.path : baseName, buildNormalizedPath, extension, relativePath,
        pathSeparator;
    import std.file : exists, SpanMode, isFile, dirEntries;
    import std.string : icmp;

    // ターゲット名の決定
    if (!data.have(PREDEF.target))
    {
        assert(data.have(PREDEF.root));
        string target_ext;
        if     (data.have(PREDEF.is_dll))
            target_ext = data[PREDEF.dll_ext];
        else if (data.have(PREDEF.is_lib))
            target_ext = data[PREDEF.lib_ext];
        else target_ext = data[PREDEF.exe_ext];

        data[PREDEF.target] =
            (data.get(PREDEF.root)[0])
            .baseName.setExt(target_ext);
    }
    logln("target name is " ~ data[PREDEF.target]);

    // def ファイルの決定
    if (data.have(PREDEF.is_dll) &&
        !data.have(PREDEF.def))
    {
        assert(data.have(PREDEF.root));
        // 一つ目のルートファイルの basename が .def のファイル名として使われる
        auto deffile = data.get(PREDEF.root)[0]
            .setExt(data[PREDEF.def]);
        deffile.exists.enforce(_(".def file for dll is not found."));
        data[PREDEF.def] = deffile;
    }

    // ディレクトリ型の探索
    foreach (one ; __traits(allMembers, PREDEF))
    {
        static if (one == "imp" || one == "lib" || one == "src" || one == "dd")
        {
            auto item = data.get(one);
            if (null is item || item.isEmpty) continue;
            auto isM = item.isMutable;
            item.isMutable = true;
            auto result = appender!(string[])();
            foreach (val ; item[])
            {
                foreach (o ; val.splitter(pathSeparator))
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
    auto src_dir = data.get(PREDEF.src);
    foreach (one ; data.get(PREDEF.imp)[]) src_dir ~= one;

    logln("source file directories are " ~ data[PREDEF.src]);

    // 外部ライブラリの決定
    foreach (one ; data.get(PREDEF.lib)[])
    {
        if (!one.exists || one.isFile) continue;

        foreach (string name ; one.dirEntries(SpanMode.depth))
        {
            if (0 == data[PREDEF.lib_ext].icmp(name.extension))
                data[PREDEF.libs] ~= name.relativePath;
        }
    }

    // dmd の '-I' オプションを準備
    if (data.have(PREDEF.src))
        data[PREDEF.compile_flag] ~=
            "-I" ~ data[PREDEF.src];

    // この時点で Makefile の名前は決定されていなければならない。
    data.have(PREDEF.m).enforce(_("please specify Makefile's name."));
}
