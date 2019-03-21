/**
 * Dmd:        2.085.0
 * Date:       2019-Mar-21 15:13:22
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.base.strutil;

/// SHIFT-JIS の格納に。
alias jchar = ubyte;
/// ditto
alias immutable(jchar)[] jstring;
/// ditto
alias immutable(jchar)* jstringz;
/// ditto
alias immutable(wchar)* wstringz;

/// suger
jchar j(T:char)(T c){ return cast(jchar)c; }
/// ditto
jstring j(T)(T[] str){ return cast(jstring)str; }
/// ditto
jstringz jz(T)(T* strz){ return cast(jstringz)strz; }
/// ditto
string c(T)(T[] jstr){ return cast(string)jstr; }


///
T enstring(T)(T str, lazy string msg = "failure in enstring")
{
    if (0 < str.length) return str;
    else throw new Exception(msg);
}

///
wstring fromUTF16z(const(wchar)* str)
{
    import std.conv : to;
    size_t i;
    for (i = 0 ; str[i] != '\0' ; ++i){}
    return str[0 .. i].to!wstring;
}

///
struct TStringAppender(TCHAR)
{
    private Appender!(immutable(TCHAR)[][]) _payload;

    ///
    this(immutable(TCHAR)[] buf){ _payload.put(buf); }
    ///
    this(const(TCHAR)[] buf){ _payload.put(buf.idup); }

    ///
    ref TStringAppender opCall(const(TCHAR)[] buf)
    { _payload.put(buf.idup); return this; }
    /// ditto
    ref TStringAppender opCall(immutable(TCHAR)[] buf)
    { _payload.put(buf); return this; }

    ///
    immutable(TCHAR)[] dump()
    { auto str = _payload.data.join(); _payload.clear; return str; }

    ///
    ref TStringAppender ln(){ _payload.put("\n"); return this; }
    /// ditto
    ref TStringAppender ln(immutable(TCHAR)[] buf)
    { _payload.put("\n"); _payload.put(buf); return this; }
    /// ditto
    ref TStringAppender ln(const(TCHAR)[] buf)
    { _payload.put("\n"); _payload.put(buf.idup); return this; }
    /// ditto
    ref TStringAppender ln(uint t)
    { _payload.put("\n"); _payload.put(" ".repeat.take(t*4)); return this; }

    ///
    ref TStringAppender tab(uint t)
    { _payload.put(" ".repeat.take(t*4)); return this; }

}


///
string tabular(string[2][] data, string title1, string title2, int w = -1,
               string separator = "|")
{
    import std.range: repeat;
    import std.array: Appender, join;
    import std.conv: to;
    import std.format: format;
    import std.ascii: isAlpha;

    size_t wL = title1.length, wR = 0;
    foreach (one; data)
    {
        if (wL < one[0].length)
            wL = one[0].length;
    }

    if (0 < w && wL + 3 < w)
        wR = w - wL - 3;
    else
        wR = 10;

    Appender!(string[]) app;
    auto fmt = ["%", wL.to!string, "s " , separator, " %s"].join;

    app.put(fmt.format(title1, title2));
    app.put(['-'.repeat(wL+1).to!string, separator,
             '-'.repeat(wR+1).to!string].join);
    if (0 < w)
    {
        assert (0 < wR);

        foreach (one; data)
        {
            for (size_t i = 0; i < one[1].length;)
            {
                string line;
                size_t j;
                if      (one[1].length <= i + wR)
                {
                    j = one[1].length;
                    line = one[1][i .. j];
                }
                else if (one[1][i+wR-1] == ' ')
                {
                    j = i + wR;
                    line = one[1][i .. j];
                }
                else if (2 <= i + wR && one[1][i+wR-2] == ' ')
                {
                    j = i + wR - 1;
                    line = one[1][i .. j];
                }
                else if (one[1][i+wR] == ' ')
                {
                    j = i + wR + 1;
                    line = one[1][i .. j - 1];
                }
                else if (one[1][i+wR-1].isAlpha && one[1][i+wR].isAlpha)
                {
                    j = i + wR - 1;
                    line = one[1][i .. j] ~ "-";
                }
                else
                {
                    j = i + wR;
                    line = one[1][i .. j];
                }

                app.put(fmt.format(i == 0 ? one[0] : "", line));
                i = j;
            }
        }
    }
    else
    {
        foreach (one; data)
            app.put(fmt.format(one[0], one[1]));
    }

    return app.data.join("\n");
}

