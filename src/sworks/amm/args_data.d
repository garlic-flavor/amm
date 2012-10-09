/** args_data.d コマンドライン引数を解析します.
 * Version:      0.160(dmd2.060)
 * Date:         2012-Oct-09 22:25:03
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.amm.args_data;
import std.process, std.exception, std.path, std.file, std.string;
import sworks.compo.util.search;
import sworks.compo.util.output;
import sworks.compo.stylexml.macros;

/**
 * sets datas along with commandline arguments.
 */
void set_args_data(alias MACROKEY)(Macros data, string[] args, Output output)
{
	string remake = "amm";
	foreach( one ; args[ 1 .. $ ] )
	{
		if( 0 <=  one.indexOf(" ") ) remake ~= " \"" ~ one ~ "\"";
		else remake ~= " " ~ one;
	}
	data.fix( MACROKEY.REMAKE_COMMAND, remake );

	for(int i=1,j ; i<args.length ; i++)
	{
		string argsext;

		// dmd へのオプション
		if     ( args[i].length > 0 && args[i][0]=='-' )
		{
			if( 1 < args[i].length )
			{
				if     ( args[i][1]=='L' ) data[MACROKEY.LINK_FLAG] ~= args[i];
				else if( args[i][1]=='I' ) data[MACROKEY.DMD_DIRECTORY] ~= args[i];
				else data[MACROKEY.COMPILE_FLAG] ~= args[i];
			}
		}
		// マクロへの値つき代入
		else if( 0 < (j = args[i].indexOf("+=")) ) data.forceConcat( args[i][0..j], args[i][j+2..$] );
		else if( 0 < (j = args[i].indexOf('=')) ) data.rewrite(args[i][0..j], args[i][j+1..$]);
		// マクロへの値省略代入
		else if( 0 == (argsext = args[i].extension).length ) data.rewrite( args[i], "defined");
		// ターゲット
		else if( data[MACROKEY.EXE_EXT] == argsext ) data.rewrite( MACROKEY.TARGET, args[i].buildNormalizedPath );
		else if( data[MACROKEY.LIB_EXT] == argsext )
		{
			data.rewrite( MACROKEY.TARGET, args[i].buildNormalizedPath );
			data[MACROKEY.TARGET_IS_LIB] = "defined";
		}
		else if( ".dll" == argsext )
		{
			data.rewrite( MACROKEY.TARGET, args[i].buildNormalizedPath );
			data[MACROKEY.TARGET_IS_DLL] = "defined";
		}
		// その他ソースファイル

		else
		{
			enforce( args[i].exists, args[i] ~ " is not found." );
			if     ( ".xml" == argsext ) data.fix( MACROKEY.STYLE_FILE, args[i].buildNormalizedPath );
			else if( ".d" == argsext ) data[MACROKEY.ROOT_FILE] ~= args[i].buildNormalizedPath;
			else if( ".rc" == argsext ) data[MACROKEY.RC_FILE] ~= args[i].buildNormalizedPath;
			else if( ".def" == argsext ) data.fix( MACROKEY.DEF_FILE, args[i].buildNormalizedPath );
			else if( ".ddoc" == argsext ) data[MACROKEY.DDOC_FILE] ~= args[i].buildNormalizedPath;
			else if( data[MACROKEY.OBJ_EXT] == argsext ) data[MACROKEY.TO_LINK] ~= args[i].buildNormalizedPath;
			else throw new Exception( args[i] ~ " is not a valid argument." );
		}
	}

	// この時点で root_file は指定されていなければならない。
	enforce(data.have(MACROKEY.ROOT_FILE), " please input root files of the project.");
	output.debln("root file detected.");

	// def ファイルの決定
	if( data.have( MACROKEY.TARGET_IS_DLL ) && !data.have(MACROKEY.DEF_FILE) )
	{
		// 一つ目のルートファイルの basename が .def のファイル名として使われる。
		auto deffile = setExtension( data.get(MACROKEY.ROOT_FILE).toArray[0],"def");
		enforce( deffile.exists, " def file for dll is not found." );
		data[MACROKEY.DEF_FILE] = deffile;
	}

	// -style.xml ファイルの探索
	Search style_search = new Search;
	style_search.entry(".");
	style_search.entry(getenv("HOME"));
	style_search.entry(dirName(args[0]));
	output.debln("search is ready");

	data.fix(MACROKEY.STYLE_FILE, enforce(style_search.abs(data[MACROKEY.STYLE_FILE])
	                     ,data[MACROKEY.STYLE_FILE] ~ " is not found"));

	output.logln(data[MACROKEY.STYLE_FILE] ~ " is detected.");
}