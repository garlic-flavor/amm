/** マクロに初期値を設定します.
 * Version:    0.167(dmd2.069.2)
 * Date:       2015-Dec-16 23:46:03.8967215
 * Authors:    KUMA
 * License:    CC0
 */
module sworks.amm.default_data;
import std.path, std.algorithm;
import sworks.stylexml.macros;

/// マクロに初期値を設定します。
void set_default_data(alias MACROKEY, alias DEFAULT_VALUE)(Macros data)
{
    foreach (one ; __traits(allMembers, MACROKEY))
    {
        if      ("BRACKET" == one)
            data[__traits(getMember, MACROKEY, one)] = new BracketItem();
        else if (0 < one.endsWith("_DIRECTORY"))
            data[__traits(getMember, MACROKEY, one)] =
                new MacroItem("", pathSeparator);
        else
            data[__traits(getMember, MACROKEY, one)] = new MacroItem();
    }

    foreach (one ; __traits(allMembers, DEFAULT_VALUE))
    {
        data[__traits(getMember, MACROKEY, one)] =
            __traits(getMember, DEFAULT_VALUE, one);
    }
}


