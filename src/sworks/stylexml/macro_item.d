/** 追記の可不可を変更できる文字列
 * Version:    0.167(dmd2.069.2)
 * Date:       2015-Dec-16 20:03:36
 * Authors:    KUMA
 * License:    cc0
 */
module sworks.stylexml.macro_item;

/// 複数の文字列を追加できる。上書き不可にもできる。
class MacroItem
{
    bool isMutable;
    string separator;

@trusted:

    this(string v = "", string separator=" ", bool isMutable = true)
    {
        if (0 < v.length) _value = [v];
        else _value = null;

        this.isMutable = isMutable;
        this.separator = separator;
    }

    override @property
    string toString()
    {
        import std.conv : to;
        import std.string : join;
        return _value.join(separator).to!string;
    }
    @property @nogc pure nothrow
    string[] toArray() { return _value[]; }
    @property @nogc pure nothrow
    bool isEmpty() const { return 0 == _value.length; }

    /// 追加
    MacroItem opOpAssign(string OP : "~")(string v)
    {
        if (isMutable && 0 < v.length) _value ~= v;
        return this;
    }

    /// 代入
    MacroItem opAssign(string v)
    {
        if (!isMutable) return this;
        if (0 == v.length) _value = null;
        else _value = [v];
        return this;
    }

    MacroItem opAssign(string[] v)
    {
        if (isMutable) _value = v;
        return this;
    }

    string opCast(TYPE : string)()
    { return to!string(joiner(_value, separator)); }

private:
    string[] _value;
}

/** 改行文字定義用
 * value    means
 * n        \n
 * r        \r
 * rn       \r\n
 */
class BracketItem : MacroItem
{
    this(string value = "n") { super(); opAssign(value); }

    @disable @property @nogc nothrow override
    string[] toArray() { return _value[]; }
    @disable @nogc nothrow override
    MacroItem opOpAssign(string OP : "~")(string){ return this; }

    override
    BracketItem opAssign(string v)
    {
        import std.exception : enforce;
        auto bracket = new char[v.length];
        foreach (i, one ; v)
        {
            if      (one == 'n') bracket[i] = '\n';
            else if (one == 'r') bracket[i] = '\r';
            else
                throw new Exception(one
                    ~ " is not available. 'r' or 'n' is available.");
        }
        enforce(0 < bracket.length,
                v ~ " is not an available as bracket descripter");
        _value = [bracket.idup];
        return this;
    }
}
