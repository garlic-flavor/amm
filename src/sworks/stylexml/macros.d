/** macros.d マクロの実装
 * Dmd:        2.085.1
 * Date:       2019-Apr-14 23:45:01
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.stylexml.macros;
public import sworks.stylexml.macro_item;

/** マクロの実装
マクロのキーは全て小文字に変換されます。
 */
class Macros
{
    import std.string : toLower;

    string opIndex(const(char)[] key)
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data) return p_data.toString;
        else return null;
    }

    MacroItem opIndexAssign(string value, const(char)[] key)
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            (*p_data) = value;
            return *p_data;
        }
        else
        {
            auto new_item = new SimpleItem(value);
            _data[key] = new_item;
            return new_item;
        }
    }

    MacroItem opIndexAssign (string[] value, const(char)[] key)
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            (*p_data) = value;
            return *p_data;
        }
        else
        {
            auto new_item = new MultiItem(null, value);
            _data[key] = new_item;
            return new_item;
        }
    }

    MacroItem opIndexOpAssign(string OP : "~")(string value, const(char)[] key)
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            (*p_data) ~= value;
            return *p_data;
        }
        else
        {
            auto new_item = new SimpleItem(value);
            _data[key] = new_item;
            return new_item;
        }
    }

    MacroItem forceConcat(const(char)[] key, string value)
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            p_data.isMutable = true;
            (*p_data) ~= value;
            return *p_data;
        }
        else
        {
            auto new_item = new SimpleItem(value);
            _data[key] = new_item;
            return new_item;
        }
    }


    MacroItem opIndexAssign(MacroItem value, in const(char)[] key)
    {
        _data[key.toLower] = value;
        return value;
    }


    Macros remove(in const(char)[] key)
    {
        import std.exception : assumeUnique;
        _data.remove(assumeUnique(key.toLower[]));
        return this;
    }

    MacroItem get(in const(char)[] key)
    {
        import std.exception : assumeUnique;
        return _data.get(assumeUnique(key.toLower[]), null);
    }

    /**
     if the key exists and its value is not null, return true.
     else return false.
    **/
    const bool have(in const(char)[] key)
    {
        auto p_data = key.toLower in _data;
        return (null is p_data) ? false : !(p_data.isEmpty);
    }

    const bool exists(in const(char)[] key)
    {
        return (key.toLower in _data) !is null;
    }

    /**
    make the value to be unrewritable.
    if the key does not exists, new key with an unrewritable null value is
    generated.
    **/
    void fix(const(char)[] key, string value="")
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            (*p_data) = value;
            p_data.isMutable = false;
        }
        else _data[key] = new SimpleItem(value, null, false);
    }

    void fixAll()
    {
        foreach (val ; _data)
            val.isMutable = false;
    }


    void rewrite(const(char)[] key, string value="")
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (null !is p_data)
        {
            (*p_data).isMutable = true;
            (*p_data) = value;
            (*p_data).isMutable = false;
        }
        else _data[key] = new SimpleItem(value, null, false);
    }

    MacroItem fixAssign(const(char)[] key, string value="")
    {
        key = key.toLower;
        auto p_data = key in _data;
        if (p_data !is null)
        {
            (*p_data) = value;
            (*p_data).isMutable = false;
            return *p_data;
        }
        else
        {
            auto new_item = new SimpleItem(value, null, false);
            _data[key] = new_item;
            return new_item;
        }
    }

    int opApply(scope int delegate(string, string) prog)
    {
        int result = 0;
        foreach (key, val ; _data)
        {
            result = prog(key, val.toString);
            if (result)
                break;
        }
        return result;
    }


    @property
    string[] keys() const
    {
        return _data.keys;
    }

private:
    MacroItem[string] _data;
}



//##############################################################################
debug(macros):

import std.stdio;
void main()
{
    Macros data = new Macros;
    data["hello"] = "world";
    data["good-bye"] = new MacroItem("heaven");

    writeln(data["hello"]);
    writeln(data["good-bye"]);
}
