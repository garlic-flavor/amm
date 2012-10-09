/** dmd に依存関係を解決させる為の下準備.
 * Version:      0.160(dmd2.060)
 * Date:         2012-Oct-09 22:25:03
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.amm.ready_data;
import std.exception, std.path, std.file, std.string;
import sworks.compo.util.search;
import sworks.compo.util.output;
import sworks.compo.stylexml.macros;

void ready_data(alias MACROKEY)(Macros data, Output output)
{
	// ターゲット名の決定
	if( !data.have(MACROKEY.TARGET) )
	{
		if( data.have(MACROKEY.PROJECT_DIRECTORY) )
			data[MACROKEY.TARGET] = setExt( data[MACROKEY.PROJECT_DIRECTORY].absolutePath.buildNormalizedPath.baseName
			                              , data[MACROKEY.EXE_EXT] );
		else
			data[MACROKEY.TARGET] = setExt( (data.get(MACROKEY.ROOT_FILE).toArray[0]).baseName
			                              , data[MACROKEY.EXE_EXT] );
	}
	output.logln( "target name is " ~ data[MACROKEY.TARGET] );

	// ソースファイルを含むディレクトリの決定
	auto src_dir = data.get(MACROKEY.SRC_DIRECTORY).toArray;
	data[MACROKEY.SRC_DIRECTORY] = "";
	foreach( one ; src_dir ) // 存在するものだけを残す。
	{
		if( one.exists ) data[MACROKEY.SRC_DIRECTORY] ~= one;
	}
	if( !data.have(MACROKEY.SRC_DIRECTORY) ) data[MACROKEY.SRC_DIRECTORY] = ".";
	else data[MACROKEY.DMD_DIRECTORY] ~= data[MACROKEY.SRC_DIRECTORY];
	output.logln( "source file directories are " ~ data[MACROKEY.SRC_DIRECTORY] );

	// インポートファイルを含むディレクトリの決定
	auto imp_dir = data.get(MACROKEY.IMPORT_DIRECTORY).toArray;
	data[MACROKEY.IMPORT_DIRECTORY] = "";
	foreach( one ; imp_dir ) // 存在するものだけを残す。
	{
		if( one.exists ) data[MACROKEY.IMPORT_DIRECTORY] ~= one;
	}
	if( data.have(MACROKEY.IMPORT_DIRECTORY) ) data[MACROKEY.DMD_DIRECTORY] ~= data[MACROKEY.IMPORT_DIRECTORY];
	output.logln( "import file directories are " ~ data[MACROKEY.IMPORT_DIRECTORY] );

	// 外部ライブラリの決定
	foreach( one ; data.get(MACROKEY.EXT_LIB_DIRECTORY).toArray )
	{
		if( !one.exists || one.isFile ) continue;

		foreach( string name ; one.dirEntries( std.file.SpanMode.depth ) )
		{
			if( 0 == data[MACROKEY.LIB_EXT].icmp( name.extension ) ) data[MACROKEY.EXT_LIB] ~= name.relativePath;
		}
	}
	output.logln( "external libraries are " ~ data[MACROKEY.EXT_LIB] );

	// リソースファイルの決定
	if( data.have(MACROKEY.RC_FILE) )
	{
		data[MACROKEY.RES_FILE] = setExtension(data[MACROKEY.RC_FILE],"res");
		data[MACROKEY.TO_LINK] ~= data[MACROKEY.RES_FILE];
	}

	// dmd の '-I' オプションを準備
	if( data.have(MACROKEY.DMD_DIRECTORY) ) data[MACROKEY.COMPILE_FLAG] ~= "-I" ~ data[MACROKEY.DMD_DIRECTORY];

	// インストールディレクトリの決定
	data[MACROKEY.TARGET] = buildPath( data[MACROKEY.INSTALL_DIRECTORY].relativePath.buildNormalizedPath
	                                  , data[MACROKEY.TARGET]);

	// この時点で Makefile の名前は決定されていなければならない。
	enforce( data.have(MACROKEY.MAKEFILE),"please specify Makefile's name." );
}
