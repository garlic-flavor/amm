/** macros.d マクロの実装
 * Version:      0.160(dmd2.060)
 * Date:         2012-Oct-09 22:25:03
 * Authors:      KUMA
 * License:      CC0
 */
module sworks.compo.stylexml.macros;
private import std.string, std.exception;
public import sworks.compo.stylexml.macro_item;

/** マクロの実装
 * マクロのキーは全て小文字に変換されます。
 */
class Macros
{
	private MacroItem[string] _data;

	string opIndex( const(char)[] key)
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data ) return p_data.toString;
		else return "";
	}

	MacroItem opIndexAssign( string value, const(char)[] key)
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data )
		{
			(*p_data) = value;
			return *p_data;
		}
		else
		{
			auto new_item = new MacroItem(value);
			_data[key] = new_item;
			return new_item;
		}
	}

	MacroItem opIndexOpAssign(string OP : "~")( string value, const(char)[] key )
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data )
		{
			(*p_data) ~= value;
			return *p_data;
		}
		else
		{
			auto new_item = new MacroItem(value);
			_data[key] = new_item;
			return new_item;
		}
	}

	MacroItem forceConcat( const(char)[] key, string value )
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data )
		{
			p_data.isMutable = true;
			(*p_data) ~= value;
			return *p_data;
		}
		else
		{
			auto new_item = new MacroItem(value);
			_data[key] = new_item;
			return new_item;
		}
	}


	MacroItem opIndexAssign(MacroItem value, in const(char)[] key)
	{
		_data[key.toLower] = value;
		return value;
	}


	Macros remove( in const(char)[] key)
	{
		_data.remove(assumeUnique(key.toLower[]));
		return this;
	}

	MacroItem get( in const(char)[] key ) { return _data.get( assumeUnique(key.toLower[]), null ); }

	/**
	 * if the key is exists and its value is not null, return true.
	 * else return false.
	 */
	const bool have( in const(char)[] key)
	{
		auto p_data = key.toLower in _data;
		return (null is p_data) ? false : !(p_data.isEmpty);
	}

	/**
	 * make the value to be unrewritable.
	 * if the key is not exists, new key with an unrewritable null value is generated.
	 */
	void fix( const(char)[] key, string value="" )
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data )
		{
			(*p_data) = value;
			p_data.isMutable = false;
		}
		else _data[key] = new MacroItem(value, " ", false );
	}

	void rewrite( const(char)[] key, string value="" )
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( null !is p_data )
		{
			(*p_data).isMutable = true;
			(*p_data) = value;
			(*p_data).isMutable = false;
		}
		else _data[key] = new MacroItem(value, " ", false );
	}

	MacroItem fixAssign( const(char)[] key, string value="" )
	{
		key = key.toLower;
		auto p_data = key in _data;
		if( p_data !is null )
		{
			(*p_data) = value;
			(*p_data).isMutable = false;
			return *p_data;
		}
		else
		{
			auto new_item = new MacroItem(value, " ", false);
			_data[key] = new_item;
			return new_item;
		}
	}
}

debug(macros)
{
	import std.stdio;
	void main()
	{
	  Macros data = new Macros;
		data["hello"] = "world";
		data["good-bye"] = new MacroItem("heaven");

		writeln(data["hello"]);
		writeln(data["good-bye"]);
	}
}