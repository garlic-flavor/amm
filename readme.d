/** readme
Date:       2019-Apr-01 01:41:20
Authors:    KUMA
License:    CC0
*/

module readme;

import sworks.base.readmegen;

///
enum _VERSION_ = "0.172(dmd2.085.0)";

void proc(string locale = "")
{
    import std.process: execute;

    if (0 < locale.length && !_.setlocale(locale))
        return;

    //
    h1("Automatic Makefile Maker");
    putln;
    b("Version:")(_VERSION_).ln;
    b("Date:")(" 2019-Apr-1").ln;
    b("Authors:")(" KUMA").ln;
    b("License:")(" CC0").ln;

    //
    h2._("Description");
    _("This is a program that makes a Makefile from source codes written in D programming language, automatically.").ln;

    //
    h2._("Acknowledgements");
    _("AMM is written with D.").ln;
    _("Digital Mars D Programming Language").link("http://dlang.org/").ln;
    putln;
    _("AMM depends on Mofile as a submodule.").ln;
    _("Mofile").link("https://github.com/FreeSlave/mofile.git").ln;

    //
    h2._("BUGS");
    list._("An error will occur when any Japanese are in a delimited string. (on windows)");

    //
    h2._("How to build");
    h3._("on Windows");
    _("Please build with the make tool distributed with dmd.").ln;

    h4("32bit");
    ">make -f win.mak release".pre;

    h4("64bit");
    ">make -f win.mak release FLAG=-m64".pre;

    h3._("on linux");
    ">make -f linux64.mak release".pre;

    //
    h2._("How to use");
    exec("amm.exe", "-help", "HowToUse", "-lang", locale).pre;
    exec("amm.exe", "-help", "Summary", "-lang", locale).putln;

    //
    h3._("How files in command line arguments are treated as,");
    list._("`.d` is treated as a root file of the project.");
    list._("`.exe` is treated as a target file name of the project. (on Windows)");
    list._("`.dll` is treated as a target file name of the project, and the project is assumed that its target is a dynamic link library.");
    list._("`.lib` is treated as a static link library to be linked with your project. (on Windows)");
    list._("`.def` is treated as a module definition file for DLL. (on Windows)");
    list._("`.rc` is treated as a resource file. (on Windows)");
    list._("`.xml` is treated as a setting file for amm, described below.");
    list._("`.mak` is treated as a file name of the target Makefile.");

    //
    h2._("Previous Notice");
    list._("amm will invoke dmd. Ensure that dmd is ready.");
    list._("Put make-style.xml where amm can find. The searching priority is,");
    1.elist._("Current directory.");
    1.elist._("The directory of environment variable 'HOME'.");
    1.elist._("The directory where amm is.");
    1.elist._("On Linux, `../etc/amm` (relative path from where amm is).");

    //
    h2._("Example");
    ">amm root_file.d".pre;
    _("With the above command, a Makefile will be generated in the current directory.").ln;
    _("I assumed that 'root_file.d' is a root file of the project, and that has `main()`function.").ln;
    _("If you want to make the target file name 'hoge.exe', do like this.").ln;
    ">amm root_file.d hoge.exe".pre;

    _("When the argument starts with '-', it will be passed to dmd.").ln;
    ">amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe".pre;

    _("You can set a macro for amm like this.").ln;

    ">amm v=1.0 gui root_file.d".pre;

    _("Now, the macro named `'v'` is set as `'1.0'`, and the macro named `'gui'` is set as `'defined'`.").ln;
    _("To Delete a macro command, do").ln;

    ">amm gui= root_file.d".pre;

    _("By the default setting, directories that consist your project are assumed like below.").ln;

    putln;
    "    -- project --+                             <-".put;
    _("where amm.exe will be invoked in.").ln;
    "                 |".putln;
    "                 |- target.exe                 <-".put;
    _("where the target file will be generated to.").ln;
    "                 |- Makefile                   <-".putln;
    "                 |".putln;
    "                 |-- src    --+".putln;
    "                 |            |- source files  <-".put;
    _("files that will be compiled.").ln;
    "                 |            |- ...".putln;
    "                 |".putln;
    "                 |-- import --+".putln;
    "                 |            |- import files  <-".put;
    _("files that will be imported.").ln;
    "                 |            |- ...".putln;
    "                 |".putln;
    "                 |-- lib    --+".putln;
    "                 |            |- libraries     <-".put;
    _("file that will be linked.").ln;
    "                 |            |- ...".putln;
    "                 |".putln;
    "                 |-- lib64  --+".putln;
    "                 |            |- libraries     <-".put;
    _("file that will be linked.").ln;
    "                 |            |- ...".putln;

    //
    h2._("About make-style.xml");
    _("`make-style.xml` controls the generation of Makefile. In this file, you can").ln;
    list._("output strings.");
    list._("set / add a string to a macro.");
    list._("retrieve a value from a macro, and do a simple replacement.");
    list._("use ifdef / ifndef conditioning.");
    putln;
    _("`make-style.xml` looks like below.").ln;

    "```xml
<style>
    <head>
        <ifdef id='gui'>
            <add id='compile_flag'>-version=Unicode</add>
                <add id='string_literal'>link_flag>-L/exet:nt/su:windows:4.0</add>
        </ifdef>
    </head>
    <environment compiler='dmd' id='make'>
        <body>
            TARGET = <get id='target' /><br />
            TO_COMPILE = <get id='to_compile' />< br />
            TO_LINK = <get id='to_link' /><br />
            COMPILE_FLAG = <get id='compile_flag' /><br />
            LINK_FLAG = <get id='link_flag' /><br />

            $(TARGET) : $(TO_LINK)<br />
            <tab />dmd  -of$@ $**<br />

            .d.obj :<br />
            <tab />dmd -c -op $(COMPILE_FLAG) $&lt;<br />

            <get id='dependencies' /><br />
            <get id='footer' />
        </body>
    </environment>
</style>

```".putln;

    _("With above make-style.xml, and with the command below,").ln;
    ">amm gui test.d".pre;
    _("the Makefile that is going to be generated will be like below.").ln;
    "```
TARGET = hogehoge.exe
TO_COMPILE = ./test.d
TO_LINK = ./test.obj
COMPILE_FLAG = -version=Unicode
LINK_FLAG = -L/exet:nt/su:windows:4.0

$(TARGET) : $(TO_LINK)
    dmd $(LINK_FLAG) -of$@ $**

.d.obj :
    dmd -c -op $(COMPILE_FLAG) $<

test.obj : test.d
## generated by amm.

```".putln;

    //
    h3._("Valid elements in make-style.xml");
    list._("`<style>` is a root element. `<body>` is an essential element in this.");
    list._("`<head>` is an element for preparation. Nothing is output. You can use `<set>`, `<add>` and, `<ifdef>`, `<ifndef>`. `<head>` will be followed by a `<body>` element.");
    list._("`<ifdef>` or `<ifndef>` has an `'id'` attribute. `'id'` specify its condition. `'id'` is an essential attribute.");
    list._("`<set>`'s contents are set to the macro specified by the `'id'` attribute. When the macro already exists, the value will be over written. You can use `<ws>`, `<br>`, `<tab>` and `<get>` in this element. `'id'` is an essential attribute.");
    list._("`<add>` adds its contents to the macro. `'id'` is an essential attribute.");
    list._("`<body>` is an element for output. Strings are simply outputted. Starting/Trailing spaces of each line are removed. You can use `<ws>`, `<tab>`, `<br>`, `<get>`, `<ifdef>` and `<ifndef>`. any Character Entity References are resolved by std.xml.");
    list._("`<ws>` outputs `' '`(space) to the Makefile. With `'length'` attribute, you can output sequential spaces.");
    list._("`<tab>` outputs `'\\t'(tab)` to the Makefile.");
    list._("`<br>` outputs `'\\r\\n'(on Windows)`/`'\\n'(on linux)`. The Macro named `'bracket'` controls this behavior.");
    list(1)._("`bracket=rn` is `'\\r\\n'`");
    list(1)._("`bracket=n` is `'\\n'`");
    list(1)._("`bracket=r` is `'\\r'`");
    list._("`<get>` expands the macro specified by `'id'` attribute. With `'from'` and `'to'` attributes, a replacement will occur when expanding. `<get>` is evaluated lazily. `'id'` is an essential attribute.");

    //
    h2._("Predefined macros");
    _("The values specified by command line have highest priority. The name of macro is case IN-sensitive.").ln;
    putln;
    exec("amm", "-help", "macro_md", "-lang", locale).putln;

    //
    h2._("Licensed under");
    _("Creative Commons Zero License").link("http://creativecommons.org/publicdomain/zero/1.0/").ln;

    //
    h2._("Development environment");
    list(0)("Windows Vista(x64) x dmd 2.084.0 x make (of Digital Mars)");
    list(0)("Ubuntu 15.10(x64) x gcc 5.2.1 x dmd 2.084.0 x GNU Make");

    //////////////////////////////////////////////////////////////////////
    //
    h2._("History");

    history("2018/04/01 ver. 0.172(dmd2.085.0)")
        ._("Implement japanese l10n.");

    history("2018/03/21 ver. 0.171(dmd2.085.0)")
        ._("Implement i18n.")
        ._("add mofile(https://github.com/FreeSlave/mofile.git) as submodule.")
        ._("add sworks.base.mo")
        ._("add sworks.base.getopt")
        ._("add sworks.base.readmegen")
        ._("add readme.d");

    history("2016/04/11 ver. 0.170(dmd2.071.0)")
        ._("bug fix about string import.");

    history("2016/02/28 ver. 0.169(dmd2.070.0)")
        ._("README.md is generated by ddoc.")
        ._("Pre-defined macros and its default values are generated by ddoc.");
    history("2015/12/22 ver. 0.168(dmd2.069.2)")
        ._("English README.md is added.")
        ._("some bug fix on linux.");

    history("2015/12/06 ver. 0.167(dmd2.069.2)")
        ._("fix deprecated about std.process.")
        ._("replace a tab with 4-spaces.");

    history("2014/06/28 ver. 0.166(dmd2.065)")
        ._("some bug fix.");

    history("2013/03/02 ver. 0.165(dmd2.064)")
        ._("fix a bug that amm can't find a make-style.xml on linux.");


    history("2012/10/28 ver. 0.164(dmd2.060)")
        ._("refine the style of output.");

    history("2012/10/25 ver. 0.163(dmd2.060)")
        ._("Now, amm can build on linux.");

    history("2012/10/11 ver. 0.162(dmd2.060)")
        ._("fix a bug about directory evaluation.")
        ._("rewrite make-style.xml.");

    history("2012/10/11 ver. 0.161(dmd2.060)")
        ._("Add japanese help messages.")
        ._("`help macro` command line option shows the list of macros.")
        ._("A `.lib` file is treated as a library to be linked with the project.")
        ._("`project` macro removed.")
        ._("`install_directory` macro removed.")
        ._("A `.mak` file is treated as a name of Makefile.")
        ._("Some macros are renamed.");

    history("2012/10/10 ver. 0.160(dmd2.060)")
        ._("Amm is on github.")
        ._("Doxygen were purged.")
        ._("`compo.lib` was expanded.");

    history("2012/10/09 ver. 0.159(dmd2.060)")
        ._("fix a bug when the target is a dll.");

    history("2012/06/07 ver. 0.158(dmd2.059)")
        ._("fix a bug about `public import`");

    history("2012/04/15 ver. 0.157(dmd2.059)")
        ._("fix some bugs about compo.lib")
        ._("more latter arguments have higher priority.")
        ._("A `.lib` file is treated as the target name of the project. To add libraries to be linked, use `to_link+=hoge.lib`.");

    history("2012/04/11 ver. 0.156(dmd2.058)")
        ._("whole brushing up.")
        ._("some modules were integrated as `compo.lib`.")
        ._("Now, amm depends on Doxygen http://www.doxygen.jp.");

    history("2010/08/20 ver. 0.155 dmd2.048")
        ._("fix a bug halting when `<!-- -->` is inside style-xml file.")
        ._("fix a bug when some modules depend on `.di`.");

    history("2010/05/27 ver. 0.154 dmd2.046")
        ._("Standardize style-xml.");

    history("2010/05/18 ver. 0.153 dmd2.045")
        ._("Standardize style-xml.")
        ._("`<make>` element was renamed to `<style>`.")
        ._("`<style>` element was renamed to `<environment>`.")
        ._("`style` macro was renamed to `env`.");

    history("2010/05/11 ver. 0.152 dmd2.045")
        ._("Amm is licensed under CC0(http://creativecommons.org/choose/zero).");

    history("2010/05/06 ver. 0.151 dmd2.045")
        ._("Some macros name were renamed.");

    history("2010/05/01 ver. 0.150 dmd2.043")
        ._("Amm can treat two or more `.d` files.")
        ._("Add `<add>` element.");

    history("2010/04/21 ver. 0.149 dmd2.043")
        ._("`<get>` element can be in a `<set>` element. `<get>` element is evaluated lazily.");

    history("2010/04/09 ver. 0.148 dmd2.042")
        ._("Add an implementation about building a dll.")
        ._("`<br>`, `<tab>` and `<ws>` element can be in a `<set>` element.");

    history("2010/04/07 ver. 0.147 dmd2.042")
        ._("fix a bug halting with absence of `import` declaration.");

    history("2010/03/15 ver. 0.146")
        ._("for dmd2.041.");

    history("2009/10/20 ver. 0.145")
        ._("for dmd2.035.")
        ._("In make-style.xml, starting and trailing spaces are removed.");

    history("2009/09/19 ver. 0.144")
        ._("Add `<footer>` macro.");

    history("2009/09/17 ver. 0.143")
        ._("`make` attribute of `<style>` element was renamed to `id`.")
        ._("`<ifndef>` element was added.")
        ._("make-style.xml were brushed up.");

    history("2009/09/15 ver. 0.14")
        ._("the way of specifying options was changed.")
        ._("`<switch>` element was removed.")
        ._("`<ifdef>` element was added.");

    history("2009/09/14 ver. 0.132")
        ._("fix a bug of my knowledge about Makefile.")
        ._("`<add>` element was remove.");

    history("2009/09/12 ver. 0.131")
        ._("now, `id` attribute of macro is case insensitive.")
        ._("fix some tiny bugs.");

    history("2009/09/04 ver. 0.13")
        ._("for dmd2.032")
        ._("`altstd.xml` was removed.")
        ._("amm doesn't depend on std.getopt.")
        ._("fix a bug about make-style.xml");

    history("2009/09/01 ver. 0.12")
        ._("vwrite was introduced.");

    history("2009/08/31 ver. 0.11")
        ._("now, end of line characters can be selected.")
        ._("use std.contracts.");

    history("2009/08/29 ver. 0.1")
        ._("first release.");
}


void main(string[] args)
{
    if (1 < args.length)
        _.openFile(args[$-1]);
    _.projectName = "readme";

    proc;

    putln;
    putln;
    hl;
    proc("ja");
}
