/** コマンドライン引数を解析します.
 * Version:      0.161(dmd2.060)
 * Date:         2012-Oct-11 16:37:46
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.amm.args_data;
import std.algorithm, std.array, std.process, std.exception, std.path, std.file, std.string;
import sworks.compo.util.search;
import sworks.compo.util.output;
import sworks.compo.stylexml.macros;

//
void set_args_data(alias MACROKEY)(Macros data, string[] args, Output output)
{
	auto remake = appender("amm");
	foreach( one ; args[ 1 .. $ ] )
	{
		remake.put(" ");
		if( 0 <= one.countUntil(" ") ) { remake.put( "\"" ); remake.put( one ); remake.put("\""); }
		else remake.put(one);
	}
	data.fix( MACROKEY.REMAKE_COMMAND, remake.data );

	string argsext;
	for(int i=1,j ; i<args.length ; i++)
	{
		// dmd へのオプション
		if( args[i].startsWith( "-" ) )
		{
			auto opt = args[i][ 1 .. $ ];
			if     ( opt.startsWith( "L" ) ) data[ MACROKEY.LINK_FLAG ] ~= args[i];
			else if( opt.startsWith( "I" ) ) data[ MACROKEY.SRC_DIRECTORY ] ~= opt[1..$];
			else if( opt.startsWith( "of" ) ) data.rewrite( MACROKEY.TARGET, opt[2..$] );
			else if( opt.startsWith( "deps=" ) ) data.rewrite( MACROKEY.DEPS_FILE, opt[ 5 .. $ ] );
			else if( opt.startsWith( "Dd" ) ) data.rewrite( MACROKEY.DDOC_DIRECTORY, opt[ 2 .. $ ] );
			else data[ MACROKEY.COMPILE_FLAG ] ~= args[i];
		}
		// マクロへの値つき代入
		else if( 0 < (j = args[i].countUntil("+=")) ) data.forceConcat( args[i][0..j], args[i][j+2..$] );
		else if( 0 < (j = args[i].countUntil('=')) ) data.rewrite( args[i][0..j], args[i][j+1..$] );
		// マクロへの値省略代入
		else if( 0 == (argsext = args[i].extension).length ) data.rewrite( args[i], "defined");
		// ターゲット
		else if( 0 == argsext.icmp( data[MACROKEY.EXE_EXT] ) || 0 == argsext.icmp( data[MACROKEY.DLL_EXT] ) )
			data.rewrite( MACROKEY.TARGET, args[i] );
		else if( 0 == argsext.icmp( data[MACROKEY.MAK_EXT] ) ) data.rewrite( MACROKEY.MAKEFILE, args[i] );
		else
		{
			enforce( args[i].exists, args[i] ~ " is not found." );
			auto file = args[i].buildNormalizedPath;

			// ライブラリ
			if     ( 0 == argsext.icmp( data[MACROKEY.LIB_EXT] ) || 0 == argsext.icmp( data[MACROKEY.OBJ_EXT] ) )
				data[ MACROKEY.LIB_FILE ] ~= file;

			else if( 0 == argsext.icmp( data[MACROKEY.SRC_EXT] ) ) data[ MACROKEY.ROOT_FILE ] ~= file;
			else if( 0 == argsext.icmp( data[MACROKEY.RC_EXT] ) ) data[ MACROKEY.RC_FILE ] ~= file;
			else if( 0 == argsext.icmp( data[MACROKEY.DEF_EXT] ) ) data[ MACROKEY.DEF_FILE ] ~= file;
			else if( 0 == argsext.icmp( data[MACROKEY.DDOC_EXT] ) ) data[ MACROKEY.DDOC_FILE ] ~= file;
			else if( 0 == argsext.icmp( data[MACROKEY.XML_EXT] ) ) data.rewrite( MACROKEY.STYLE_FILE, file );
			else throw new Exception( args[i] ~ " is an unknown file type." );
		}
	}

	// この時点で root_file は指定されていなければならない。
	enforce(data.have(MACROKEY.ROOT_FILE), " please input root files of the project.");
	output.debln("root file detected.");

	// ターゲットが lib や、dll かどうか。
	if( data.have( MACROKEY.TARGET ) )
	{
		auto target_ext = data[MACROKEY.TARGET].extension;
		if     ( 0 == target_ext.icmp( data[MACROKEY.DLL_EXT] ) ) data[MACROKEY.TARGET_IS_DLL] = "defined";
		else if( 0 == target_ext.icmp( data[MACROKEY.LIB_EXT] ) ) data[MACROKEY.TARGET_IS_LIB] = "defined";
	}

	// -style.xml ファイルの探索
	Search style_search = new Search;
	style_search.entry(".");
	style_search.entry(getenv("HOME"));
	style_search.entry(dirName(args[0]));
	output.debln("search is ready");

	data.rewrite(MACROKEY.STYLE_FILE, enforce(style_search.abs(data[MACROKEY.STYLE_FILE])
	                                ,data[MACROKEY.STYLE_FILE] ~ " is not found"));

	output.logln(data[MACROKEY.STYLE_FILE] ~ " is detected.");
}