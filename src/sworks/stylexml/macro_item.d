/** 追記の可不可を変更できる文字列
 * Dmd:        2.085.1
 * Date:       2019-Apr-15 00:50:41
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.stylexml.macro_item;

import sworks.base.mo;

/// 複数の文字列を追加できる。上書き不可にもできる。
class MacroItem
{
    alias LazyMsg = string delegate();
    bool isMutable;

    @property
    string help()
    {
        return _helpMsg !is null ? _helpMsg() : _("no help message");
    }

    /// 追加
    MacroItem opOpAssign(string OP : "~")(string v)
    {
        if (isMutable && 0 < v.length)
            concat(v);
        return this;
    }

    /// 代入
    MacroItem opAssign(string v)
    {
        if (isMutable)
            assign (v);
        return this;
    }

    MacroItem opAssign(string[] v)
    {
        if (isMutable)
            assign(v);
        return this;
    }

    override @property abstract
    string toString();

    @property @nogc pure nothrow abstract
    bool isEmpty() const;

    abstract
    string[] opSlice();

    abstract
    string opIndex(size_t i);

protected:
    this(LazyMsg helpMsg, bool isMutable)
    {
        this.isMutable = isMutable;
        this._helpMsg = helpMsg;
    }

    abstract
    void concat(string);

    abstract
    void assign(string);

    abstract
    void assign(string[]);

private:
    LazyMsg _helpMsg;
}

//------------------------------------------------------------------------------
///
class SwitchItem : MacroItem
{
    this (LazyMsg helpMsg = null, bool flag = false, bool isMutable = true)
    {
        super (helpMsg, isMutable);
        this._value = flag;
    }

    override
    string toString()
    {
        return _value ? "defined" : "";
    }

    @property @nogc pure nothrow override
    bool isEmpty() const
    {
        return !_value;
    }

    override
    string[] opSlice()
    {
        return _value ? ["defined"] : null;
    }

    override
    string opIndex(size_t)
    {
        return _value ? "defined" : null;
    }

protected:
    override
    void concat (string v)
    {
        assign (v);
    }

    override
    void assign (string v)
    {
        _value = 0 < v.length;
    }

    override
    void assign (string[] v)
    {
        assign (0 < v.length ? v[$-1] : "");
    }

private:
    bool _value;
}

//------------------------------------------------------------------------------
///
class SwitchHookedItem : SwitchItem
{
    alias Hook = void delegate();

    this(Hook h, LazyMsg helpMsg = null, bool v = false, bool isMutable = true)
    {
        super(helpMsg, v, isMutable);
        assert (h !is null);
        _hook = h;
    }

protected:
    override
    void assign (string v)
    {
        auto prev = toString;
        super.assign(v);
        if (0 < v.length && 0 == prev.length)
            _hook();
    }

private:
    Hook _hook;
}


//------------------------------------------------------------------------------
///
class SimpleItem : MacroItem
{
    this(string v = "", LazyMsg helpMsg = null, bool isMutable = true)
    {
        super (helpMsg, isMutable);
        _value = v;
    }

    override @property
    string toString()
    {
        return _value;
    }

    @property @nogc pure nothrow override
    bool isEmpty() const { return 0 == _value.length; }

    pure nothrow override
    string[] opSlice()
    {
        return [_value];
    }

    @nogc pure override
    string opIndex(size_t i)
    {
        return _value;
    }

protected:

    override
    void concat(string v)
    {
        _value = v;
    }

    override
    void assign(string v)
    {
        _value = v;
    }

    override
    void assign (string[] v)
    {
        assign (0 < v.length ? v[$-1] : "");
    }

private:
    string _value;
}

//------------------------------------------------------------------------------
///
class SimpleHookedItem : SimpleItem
{
    alias Translator = string delegate(string);

    this(Translator t, string v = "",
         LazyMsg helpMsg = null, bool isMutable = true)
    {
        super (v, helpMsg, isMutable);
        assert (t !is null);
        _translator = t;
    }

    override
    string toString()
    {
        return _translator(super.toString);
    }

private:
    Translator _translator;
}

//------------------------------------------------------------------------------
///
class MultiItem : MacroItem
{
    this(LazyMsg helpMsg = null, string[] v = null, bool isMutable = true)
    {
        super (helpMsg, isMutable);
        _value = v;
    }

    override @property
    string toString()
    {
        import std.array: join;
        return _value.join(" ");
    }

    @property @nogc pure nothrow override
    bool isEmpty() const { return 0 == _value.length; }

    @nogc pure nothrow override
    string[] opSlice()
    {
        return _value;
    }

    @nogc pure override
    string opIndex(size_t i)
    {
        if      (0 == _value.length)
            return "";
        else if (i < _value.length)
            return _value[i];
        else
            return _value[$-1];
    }

protected:

    /// 追加
    override
    void concat(string v)
    {
        _value ~= v;
    }

    /// 代入
    override
    void assign(string v)
    {
        if (0 < v.length)
            _value = [v];
        else
            _value = null;
    }

    override
    void assign(string[] v)
    {
        _value = v;
    }

private:
    string[] _value;
}

//------------------------------------------------------------------------------
///
class MultiHookedItem : MultiItem
{
    alias Translator = string delegate(string[]);

    this(Translator t, LazyMsg helpMsg = null,
         string[] v = null, bool isMutable = true)
    {
        super (helpMsg, v, isMutable);
        assert (t !is null);
        _translator = t;
    }

    override @property
    string toString()
    {
        return _translator(_value);
    }

private:
    Translator _translator;
}

// /** 改行文字定義用
//  * value    means
//  * n        \n
//  * r        \r
//  * rn       \r\n
//  */
// class BracketItem : MacroItem
// {
//     this(string value = "n", LazyMsg h = null)
//     {
//         super("", h);
//         opAssign(value);
//     }

//     @nogc nothrow override
//     MacroItem opOpAssign(string OP : "~")(string) { assert(0); return this; }

//     override
//     BracketItem opAssign(string v)
//     {
//         import std.exception : enforce;
//         auto bracket = new char[v.length];
//         foreach (i, one ; v)
//         {
//             if      (one == 'n') bracket[i] = '\n';
//             else if (one == 'r') bracket[i] = '\r';
//             else
//                 throw new Exception(one
//                     ~ " is not available. 'r' or 'n' is available.");
//         }
//         enforce(0 < bracket.length,
//                 v ~ " is not an available as bracket descripter");
//         _value = [bracket.idup];
//         return this;
//     }
// }

