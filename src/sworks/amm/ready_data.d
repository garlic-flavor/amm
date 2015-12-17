/** dmd に依存関係を解決させる為の下準備.
 * Version:    0.167(dmd2.069.2)
 * Date:       2015-Dec-16 23:46:03.9097215
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.ready_data;
import std.array : appender;
import std.algorithm, std.exception, std.path, std.file, std.string;
import sworks.base.search;
import sworks.base.output;
import sworks.stylexml.macros;

void ready_data(alias MACROKEY)(Macros data)
{
    // ターゲット名の決定
    if (!data.have(MACROKEY.TARGET))
    {
        assert(data.have(MACROKEY.ROOT_FILE));
        string target_ext;
        if     (data.have(MACROKEY.TARGET_IS_DLL)) target_ext = data[MACROKEY.DLL_EXT];
        else if (data.have(MACROKEY.TARGET_IS_LIB)) target_ext = data[MACROKEY.LIB_EXT];
        else target_ext = data[MACROKEY.EXE_EXT];

        data[MACROKEY.TARGET] = (data.get(MACROKEY.ROOT_FILE).toArray[0]).baseName.setExt(target_ext);
    }
    Output.logln("target name is " ~ data[MACROKEY.TARGET]);

    // def ファイルの決定
    if (data.have(MACROKEY.TARGET_IS_DLL) && !data.have(MACROKEY.DEF_FILE))
    {
        assert(data.have(MACROKEY.ROOT_FILE));
        // 一つ目のルートファイルの basename が .def のファイル名として使われる。
        auto deffile = data.get(MACROKEY.ROOT_FILE).toArray[0].setExt(data[MACROKEY.DEF_FILE]);
        enforce(deffile.exists, " def file for dll is not found.");
        data[MACROKEY.DEF_FILE] = deffile;
    }

    // ディレクトリ型の探索
    foreach (one ; __traits(allMembers, MACROKEY))
    {
        if (!one.endsWith("_DIRECTORY")) continue;
        auto macro_name = __traits(getMember, MACROKEY, one);
        auto item = data.get(macro_name);
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

    // ソースファイルを含むディレクトリの決定
    auto src_dir = data.get(MACROKEY.SRC_DIRECTORY);
    foreach (one ; data.get(MACROKEY.IMPORT_DIRECTORY).toArray) src_dir ~= one;

    Output.logln("source file directories are " ~ data[MACROKEY.SRC_DIRECTORY]);

    // 外部ライブラリの決定
    foreach (one ; data.get(MACROKEY.EXT_LIB_DIRECTORY).toArray)
    {
        if (!one.exists || one.isFile) continue;

        foreach (string name ; one.dirEntries(std.file.SpanMode.depth))
        {
            if (0 == data[MACROKEY.LIB_EXT].icmp(name.extension)) data[MACROKEY.LIB_FILE] ~= name.relativePath;
        }
    }

    // dmd の '-I' オプションを準備
    if (data.have(MACROKEY.SRC_DIRECTORY)) data[MACROKEY.COMPILE_FLAG] ~= "-I" ~ data[MACROKEY.SRC_DIRECTORY];

    // この時点で Makefile の名前は決定されていなければならない。
    enforce(data.have(MACROKEY.MAKEFILE),"please specify Makefile's name.");
}




