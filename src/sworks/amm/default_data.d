/** マクロに初期値を設定します.
 * Version:      0.163(dmd2.060)
 * Date:         2012-Oct-26 23:56:49
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.amm.default_data;
import std.path, std.algorithm;
import sworks.compo.stylexml.macros;

/// マクロに初期値を設定します。
void set_default_data(alias MACROKEY, alias DEFAULT_VALUE)(Macros data)
{
	foreach( one ; __traits( allMembers, MACROKEY ) )
	{
		if     ( "BRACKET" == one ) data[ __traits( getMember, MACROKEY, one ) ] = new BracketItem();
		else if( 0 < one.endsWith( "_DIRECTORY" ) )
			data[ __traits( getMember, MACROKEY, one ) ] = new MacroItem( "", pathSeparator );
		else data[ __traits( getMember, MACROKEY, one ) ] = new MacroItem();
	}

	foreach( one ; __traits( allMembers, DEFAULT_VALUE ) )
	{
		data[ __traits( getMember, MACROKEY, one ) ] = __traits( getMember, DEFAULT_VALUE, one );
	}
}


