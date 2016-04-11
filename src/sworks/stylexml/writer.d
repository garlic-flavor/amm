/**
 * Dmd:        2.071.0
 * Date:       2016-Apr-11 20:53:05
 * Authors:    KUMA
 * License:    CC0
*/
module sworks.stylexml.writer;

import sworks.base.array;

//
class Writer
{
    string bracket;

    this(string bracket){ this.bracket = bracket; _newline = true; }

    void put(const(char)[] items ...)
    {
        import std.string : stripLeft;
        if (_newline) items = items.stripLeft;
        putall(items);
    }

    void putall(const(char)[] items ...)
    {
        import std.array : replace;
        if (0 == items.length) return;
        _arr.replace(_arr.length, _arr.length, items);
        _newline = false;
    }

    void putln()
    {
        import std.algorithm : countUntil;
        import std.array : replace;
        import std.range : retro;
        import std.uni : isWhite;
        if (!_newline)
        {
            auto c = _arr.data.retro.countUntil!(x=>!isWhite(x));
            _arr.replace(_arr.length - c, _arr.length, bracket);
        }
        else _arr.replace(_arr.length, _arr.length, bracket);
        _newline = true;
    }

    const(char)[] opSlice() { return _arr[]; }

private:
    Array!(char) _arr;
    bool _newline;
}
