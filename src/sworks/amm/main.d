/** Automatic Makefile Maker.
Version:    0.169(dmd2.070.0)
Date:       2016-Feb-28 23:36:59
Authors:    KUMA
License:    CC0

Macros:
  DMD_VERSION = 2.070.0

Description:
This is a program that makes a Makefile from the source code wirtten in
D programmming language, automatically.


Acknowledgements:
amm is written by D.
$(LINK2 http://dlang.org/, Digital Mars D Programming Language)

Bugs:
$(UL
$(LI An error will occur when any Japanese are in a delimited string.
  (on windows))
)

How_to_build:
$(H3 on Windows,
Please build with make tool that is distributed with dmd.)

$(H4 32bit,
$(PROMPT make -f win.mak release))

$(H4 64bit,
$(PROMPT make -f win.mak release FLAG=-m64))

$(H3 on linux,
$(PROMPT make -f linux64.mak release))

How_to_use:
$(PROMPT amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d)
$(TABLE
$(TR $(TH options)             $(SEP) $(TH description))
$(COL20)$(SEP)$(COL20)
$(TR $(TD h help ?)            $(SEP) $(TD show this message.))
$(TR $(TD macro_name)          $(SEP) $(TD define the macro named macro_name.))
$(TR $(TD macro_name=value)    $(SEP) $(TD define the macro named macro_name as value.))
$(TR $(TD m=Makefile)          $(SEP) $(TD set outputting Makefile's name.))
$(TR $(TD )                    $(SEP) $(TD passing a file of '.mak' extension as argument is same.))
$(TR $(TD root=path)           $(SEP) $(TD set the root file of this project.))
$(TR $(TD )                    $(SEP) $(TD passing a file of '.d' extension as argument is same.))
$(TR $(TD v=0.001)             $(SEP) $(TD set version description.))
$(TR $(TD )                    $(SEP) $(TD for my vwrite.))
$(TR $(TD help macro)          $(SEP) $(TD show pre-defined macros.))
)

Previous_Notice:
$(UL
$(LI amm will invoke dmd, ensure that dmd is ready.)
$(LI Put make-style.xml to where amm can find.
    The searching priority is,
$(OL
    $(OLI Current directory.)
    $(OLI The directory of the environment variable 'HOME'.)
    $(OLI The directory where the amm is.)
    $(OLI On Linux, `../etc/amm` (related with where the amm is).)
))
)

Example:
$(PROMPT amm root_file.d)

With the above command, a Makefile will be generated in the current directory.
I assume that 'root_file.d' is a root file of the project, and that has `main()`
function.
If you want to make the target file name 'hoge.exe', do like this.
$(PROMPT amm root_file.d hoge.exe)
When the argument starts with '-', it will be passed through to dmd.
$(PROMPT amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe)
You can use macro for amm like this.
$(PROMPT amm v=1.0 gui root_file.d)
The macro named `'v'` is set as `'1.0'`, and the macro named `'gui'` is set as
`'defined'`.

Delete macro command is
$(PROMPT amm gui= root_file.d)

In the default situation, directories that consist your project are assumed like
below.

$(PRE
    -- project --+                             <- where amm.exe will be invoked in.
                 |
                 |- target.exe                 <- where the target file will be generated to.
                 |- Makefile                   <-
                 |
                 |-- src    --+
                 |            |- source files  <- files that will be compiled.
                 |            |- ...
                 |
                 |-- import --+
                 |            |- import files  <- files that will be imported.
                 |            |- ...
                 |
                 |-- lib    --+
                 |            |- libraries     <- file that will be linked.
                 |            |- ...
                 |
                 |-- lib64  --+
                 |            |- libraries     <- file that will be linked.
                 |            |- ...

)

COMMAND_LINE_ARGUMENTS:
$(UL
$(LI '/?' '-h' '-help'
  show help messages.)
$(LI 'help macro'
  show pre-defined macros.)
$(LI starts with '-L'.
  is treated as link option.)
$(LI starts with '-'.
  is treated as comple option.)
$(LI has any extensions.
  is treated as some kind of file.
$(UL
    $(LI '.d'
      is treated as a root file of the project.)
    $(LI '.exe'
      is treated as a target file name of the project. (on Windows))
    $(LI '.dll'
      is treated as a target file name of the project, and the project is
      assumed that its target is dynamic link library.)
    $(LI '.lib'
      is treated as a static link library to be linked with your project.
      (on Windows))
    $(LI '.def'
      is treated as a module definition file for DLL. (on Windows))
    $(LI '.rc'
      is treated as a resource file. (on Windows))
    $(LI '.xml'
      is treated as a setting file for amm, described below.)
    $(LI '.mak'
      is treated as a file name of the target Makefile.)
))
$(LI other
  is treated as a definition of a macro.
$(UL
    $(LI `'macro_name=hogehoge'` sets the macro named `'macro_name'` as
      `'hogehoge'`.)
    $(LI `'macro_name+=hogehoge'` adds `'hogehoge'` to the macro named
      `'maco_name'`.)
    $(LI `'macro_name'` sets the macro named `'macro_name'` as `'defined'`.)
    $(LI `'macro_name='` removes the macro named `'macro_name'`.)
))
)

about_make-style.xml:
`make-style.xml` controls the generation of the Makefile.
In this file, you can
$(UL
$(LI output the string.)
$(LI set / add the string to the macro.)
$(LI retrieve the value from the macro, and do replacement.)
$(LI use ifdef / ifndef conditioning.)
)

`make-style.xml` looks like below.

---
    <style>
        <head>
            <ifdef id="gui">
                <add id="compile_flag">-version=Unicode</add>
                    <add id="link_flag">-L/exet:nt/su:windows:4.0</add>
            </ifdef>
        </head>
        <environment compiler="dmd" id="make">
            <body>
                TARGET = <get id="target" /><br />
                TO_COMPILE = <get id="to_compile" />< br />
                TO_LINK = <get id="to_link" /><br />
                COMPILE_FLAG = <get id="compile_flag" /><br />
                LINK_FLAG = <get id="link_flag" /><br />
                
                $(DOLLAR)(TARGET) : $(DOLLAR)(TO_LINK)<br />
                <tab />dmd $(LINK_FLAG) -of$@ $**<br />
                
                .d.obj :<br />
                <tab />dmd -c -op $(DOLLAR)(COMPILE_FLAG) $&lt;<br />
                
                <get id="dependencies" /><br />
                <get id="footer" />
            </body>
        </environment>
    </style>
---

With above make-style.xml, and with the command below,
$(PROMPT amm gui test.d)
the Makefile that is going to be generated will be like below.
---
    TARGET = hogehoge.exe
    TO_COMPILE = ./test.d
    TO_LINK = ./test.obj
    COMPILE_FLAG = -version=Unicode
    LINK_FLAG = -L/exet:nt/su:windows:4.0
    
    $(DOLLAR)(TARGET) : $(DOLLAR)(TO_LINK)
        dmd $(DOLLAR)(LINK_FLAG) -of$(DOLLAR)@ $(DOLLAR)**
    
    .d.obj :
        dmd -c -op $(DOLLAR)(COMPILE_FLAG) $(DOLLAR)<
    
    test.obj : test.d
    ## generated by amm.
---

Valid_elements_in_make-style.xml:
$(UL
$(LI `<style>`
    root element.
    `<environemnt>` is an essential element.)
$(LI `<head>`
    No outputting occur in this element.
    You can use `<set>`, `<and>` and, `<ifdef>`, `<ifndef>`.
    `<head>` will be followed by an `<environment>` or a `<body>` element.)
$(LI `<ifdef>` `<ifndef>`
    An `'id'` attribute of this element specify the condition.
    `'id'` is an essential attribute.)
$(LI `<set>`
    Its contents will be set to the macro named what is specified in the `'id'`
    attrubute.
    When the macro already exists, the value will be over written.
    You can use `<ws>`, `<br>`, `<tab>` and `<get>` in this element.
    `<get>` is evaluated lazily.
    `'id'` is an essential attribute.)
$(LI `<add>`
    The value will be added to the macro.
    `'id'` is an essential attribute.)
$(LI `<environment>`
    This element exists for backward compatibility.)
$(LI `<body>`
    Outputting may occur.
    Strings are outputted to the Makefile as usual.
    Starting/Trailing spaces are removed.
    You can use `<ws>`, `<tab>`, `<br>`, `<get>`, `<ifdef>` and `<ifndef>`.
    Character Entity References are resolved by std.xml.)
$(LI `<ws>`
    Output `' '`(space) to the Makefile. with `'length'` attrubute, you can
    output sequential spaces.)
$(LI `<tab>`
    Output `'\t'(tab)` to the Makefile.)
$(LI `<br>`
    Output `'\r\n'(on Windows)`/`'\n'(on linux)`.
    The Macro named `'bracket'` controls this behavior.
$(UL
    $(LI `bracket=rn`, then outputting is `'\r\n'`)
    $(LI `bracket=n`, then outputting is `'\n'`)
    $(LI `bracket=r`, then outputting is `'\r'`)
))
$(LI `<get>`
    Expand the macro specified by `'id'` attribute.
    With `'from'` and `'to'` attributes, a replacement will occur when the
    expansion.
    `'id'` is a essential attribute.)
)

Predefined_macros:
$(MACRODESC The values specified by command line have highest priority.
The name of macro is case IN-sensitive.)

$(MACRODEFS
$(MACRODEF4 bracket, rn, n,
  specify newline characters.
$(UL
    $(LI `'rn'` => CR+LF.)
    $(LI `'n'` => LF.)
    $(LI `'r'` => CR.)
))
$(MACRODEF env,
  This macro exists for backward compatibility.)
$(MACRODEF4 exe_ext, .exe, ,
  specify a extension of an executable file name.)
$(MACRODEF4 obj_ext, .obj, .o,
  specify a extension of a object file name.)
$(MACRODEF4 lib_ext, .lib, .a,
  specify a extension of a statically linked library file name.)
$(MACRODEF3 gen_deps_command, dmd -c -op -o- -debug,
  specify the command that invokes dmd to resolve your project's dependencies.)
$(MACRODEF3 deps_file, tempdeps,
  specify the file name of the target of `'gen_deps_command'`.)
$(MACRODEF3 m, Makefile,
  specify the name of the Makefile.)
$(MACRODEF root,
  specify the file name of root file of your project.
  When a file that has `'.d'` as its extension is passed as a command line
  argument, the file name will be set to this macro.)
$(MACRODEF compile_flag,
  specify compile flags for dmd.
  When a command line argument for amm starts with `'-'`, the argument will be
  set to this macro.)
$(MACRODEF link_flag,
  specify link flags for dmd
  When a command line argument for amm starts with `'-L'`, the argument will
  be set to this macro.)
$(MACRODEF target,
  specify the target file name of your project.
  On Windows, when a file that has `'.exe'` or `'.dll'` as its extension is
  passed as a command line argument for amm, the file name will be set to this
  macro.)
$(MACRODEF dependencies,
  Amm will set this value.)
$(MACRODEF to_compile,
  Amm will set this value.)
$(MACRODEF to_link,
  Amm will set this value.)
$(MACRODEF rc_file,
  On Windows, when a file that has `'.rc'` as its extension is passed as a
  command line argument for amm, the file name will be set to this macro.)
$(MACRODEF def,
  On Windows, when a file that has `'.def'` as its extension is passed as a
  command line argument for amm, the file name will be set to this macro.)
$(MACRODEF ddoc,
  On Windows, when a file that has `'.ddoc'` as its extension is passed as a
  command line argument for amm, the file name will be set to this macro.)
$(MACRODEF dd,
  specify the target directory of $(LINK2 http://dlang.org/spec/ddoc.html, DDOC).)
$(MACRODEF libs,
  specify libraries names to link.
  Amm will gather names form the directory specified by the macro named
  `'lib'`.)
$(MACRODEF imp,
  specify the directory that contains the files to be imported by your project.
  The default value is `'import'`.)
$(MACRODEF lib,
  specify the directory that contains the file to be linked by your project.
  The default value is `'lib'`.)
$(MACRODEF i,
  Amm will set this value.
  this is same as `-I` option for dmd.)
$(MACRODEF is_dll,
  specify whether the target of your project is dynamic link library.)
$(MACRODEF is_lib,
  specify whether the target of your project is static link library.)
$(MACRODEF verbose)
$(MACRODEF q,
  controls the verboseness of amm.)
$(MACRODEF3 footer, ## generated by amm.,
  specify the 'footer mark' of the Makefile.
  Amm will overwrite the Makefile. but, the contents after this mark will
  remain.)
$(MACRODEF style_file,
  specify the setting file name.
  The default value is `'make-style.xml'`.)
$(MACRODEF v)
$(MACRODEF authors)
$(MACRODEF license,
  specify the description about your project.)
$(MACRODEF date,
  Amm will set this value as today.)
$(MACRODEF remake_command,
  The command line arguments that invoked amm is set to the value.)
$(MACRODEF3 src, src,
  Amm set command line argument that starts with '-I' to this value.
  This value is used to decide that the root directory of source files
  to be compiled.)
$(MACRODEF is_vclinker,
  If true, dmd will invoke the linker of Microsoft.)
$(MACRODEF4 dll_ext, .dll, .so,
  the extension of a Dynamic Linked Library.
  when a file with this extension is in the arguments, the file will be
  regarded as TARGET, and the macro 'IS_DLL' is defined.)
$(MACRODEF3 mak_ext, .mak,
  the extension of Makefile.
  when a file with this extension is in the arguments, the file will be
  regarded as Makefile.)
$(MACRODEF3 src_ext, .d,
  The extension of a source file.
  When a file with this extension is in the arguments, the file will be
  regarded the root file of the project. and the file will be set to the value
  of the macro 'ROOT'.
  When the value of macro 'TARGET' is undefined, the value of the macro will
  be set as 'ROOT' + 'EXE_EXT'.)
$(MACRODEF3 rc_ext, .rc,
  The extension of a resource file.
  When a file with this extension is in the arguments, the file will be set to
  the value of the macro 'RC'.
  Windows only.)
$(MACRODEF rc,
  Resource files are set to this value.
  Windows only.)
$(MACRODEF3 def_ext, .def,
  the extension of a module definition file of D.
  when a file with this extension is in the arguments, the file will be
  regarded as module definition file.)
$(MACRODEF3 ddoc_ext, .ddoc,
  The extension of a file for ddoc.
  when a file with this extension is in the arguments, the file will be
  regarded as for ddoc.)
$(MACRODEF3 xml_ext, .xml,
  the extension of STYLE_FILE.
  when a file with this extension is in the arguments, the file will be
  regarded STYLE_FILE.)
$(MACRODEF3 style, make-style.xml,
  STYLE_FILE controls the output.
  when a file with '.xml' extension is in the arguments, the file will be
  regarded as STYLE_FILE.)


)

Licensed_under:
$(LINK2 http://creativecommons.org/publicdomain/zero/1.0/, Creative Commons Zero License)

Development_environment:
$(UL
$(LI Windows Vista(x64) x dmd $(DMD_VERSION) x make (of Digital Mars))
$(LI Ubuntu 15.10(x64) x gcc 5.2.1 x dmd $(DMD_VERSION) x GNU Make)
)

History:
$(UL
$(LI 2016/02/28 ver. 0.169(dmd2.070.0)
$(UL
    $(LI README.md is generated by ddoc.)
    $(LI Pre-defined macros and its default values are generated by ddoc.)
))
$(LI 2015/12/22 ver. 0.168(dmd2.069.2)
$(UL
    $(LI add English README.md.)
    $(LI some bug fix on linux.)
))
)

$(HL)

$(H1 はじめにお読み下さい。 - AMM -)
これはD言語で書かれたソースコードから Makefile を自動生成するプログラムです。

謝辞:
amm は D言語で書かれています。
$(LINK2 http://dlang.org/, Digital Mars D Programming Language)

Bugs:
$(UL
$(LI $(DEL '-inline' オプションで amm をコンパイルすると dmd が無限ループ(?) ( win32 及び linux32 で確認 )</del>(2013/03/02 dmd2.062)))
$(LI ヒアドキュメント、q"DELIMITER hoge-hoge...  DELIMITER" である(不明)パターンになると、"Error: Outside Unicode code space")
)

ビルド方法:
$(H3 Windows,
DMDに付属のmakeを使用して下さい。)

$(H4 32bit版,
$(PROMPT make -f win.mak release FLAG=-version=InJapanese))

$(H4 64bit版,
$(PROMPT make -f win.mak release FLAG="-version=InJapanese -m64"))

$(H3 Linux,
$(PROMPT make -f linux64.mak release FLAG=-version=InJapanese))

使い方:
$(PROMPT amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d)

$(TABLE
$(TR $(TH options)             $(SEP) $(TH description))
$(COL20)$(SEP)$(COL20)
$(TR $(TD h help ?)            $(SEP) $(TD ヘルプを表示します。))
$(TR $(TD macro_name)          $(SEP) $(TD マクロを定義済みとします。))
$(TR $(TD macro_name=value)    $(SEP) $(TD マクロに値を設定します。))
$(TR $(TD m=Makefile)          $(SEP) $(TD 出力される Makefile のファイル名を指定します。))
$(TR $(TD )                    $(SEP) $(TD 拡張子、'.mak' のファイルを渡しても可))
$(TR $(TD root=path)           $(SEP) $(TD ルートとなるソースファイルを指定します。))
$(TR $(TD )                    $(SEP) $(TD 拡張子、'.d' のファイルを渡しても可))
$(TR $(TD v=0.001)             $(SEP) $(TD ヴァージョン文字列を指定します。数字以外も指定できます。))
$(TR $(TD )                    $(SEP) $(TD 拙著の vwrite.exe 向けです。))
$(TR $(TD help macro)          $(SEP) $(TD 定義済みマクロを一覧表示します。))
)

事前に:
$(UL
$(LI dmd へパスを通し、使える状態にしておいて下さい。)
$(LI amm.exe へのパスを通して下さい。)
$(LI 同梱の make-style.xml を amm.exe が探せる位置において下さい。
  make-style.xml は以下の順に探されます。
$(OL
    $(OLI amm.exe を実行するフォルダ)
    $(OLI 環境変数 HOME のフォルダ)
    $(OLI amm.exe と同じフォルダ)
    $(OLI linux上では amm のあるフォルダから見て `../etc/amm`。)
))
)

簡単な使い方:
$(PROMPT amm root_file.d)

でカレントフォルダに Makefile ができます。

ここで、`root_file.d` としているのは、プロジェクトのルートとなるファイル
(実行形式のファイルがターゲットとなる場合は、一般的に `main()` 関数を含むファイル) です。

初期状態では色々と変なことになると思うので、`make-style.xml` をいじって自分の環境に合わせてみて下さい。

実行ファイル名を hoge.exe とするには、
$(PROMPT amm root_file.d hoge.exe)

とします。
$(PROMPT amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe)

'-'(ハイフン)で初まる引数は、dmd へそのまま引き渡されます。

以降で説明する、make-style.xml 内で使用されるマクロを設定するには、
$(PROMPT amm v=1.0 gui root_file.d)

これで、マクロ名 `"v"` に、文字列 `"1.0"` が、マクロ名 `"gui"` に、文字列 `"defined"` が設定されます。

既存のマクロを削除するには、
$(PROMPT amm gui= root_file.d)

とします。

初期状態では、フォルダの構成が以下のような環境が想定されています。

$(PRE
    -- project --+                             <- amm.exe はこのフォルダで実行される。
                 |
                 |- target.exe                 <- ここに実行ファイルができる。
                 |- Makefile                   <- Makefile はここに生成される。
                 |
                 |-- src    --+
                 |            |- source files  <- コンパイルされる。
                 |            |- ...
                 |
                 |-- import --+
                 |            |- import files  <- コンパイルされない。
                 |            |- ...
                 |
                 |-- lib    --+
                 |            |- libraries     <- リンクされる。
                 |            |- ...
                 |
                 |-- lib64  --+
                 |            |- libraries
                 |            |- ...

)

コマンドライン引数:
$(UL
$(LI '-h' '-help' '/?'
  ヘルプメッセージを出力します。)
$(LI 'help macro'
  定義済みマクロ一覧を表示します。)
$(LI '-L' で始まるもの
  リンカへのオプションとみなされ、リンク時に dmd へと引き渡されます。)
$(LI それ以外で、'-'(ハイフン)で始まるもの
  コンパイル時に dmd へと引き渡されます。)
$(LI 拡張子があるもの。(std.path.extension にヒットするもの)
  ファイル名として解釈されます。)
$(UL
    $(LI '.d'
      ソースコードのルートとなるファイルとして扱われます。
      複数のファイルを渡すこともできます。)
    $(LI '.exe'
      ターゲットのファイル名として扱われます。)
    $(LI '.dll'
      ターゲットのファイル名として扱われます。)
    $(LI '.lib'
      ターゲットのファイル名として扱われます。
      *リンクするライブラリとしては扱われない* ので注意が必要です。

      リンクするライブラリを指定する場合は、
      `to_link+=hoge.lib`
      とします。)
    $(LI '.def'
      dll を作る際に参照されます。)
    $(LI '.rc'
      Windows 用のリソースファイルとして認識されます。)
    $(LI '.xml'
      後述する設定ファイルとして読み込まれます。)
    $(LI '.mak'
      Makefile のファイル名)
)
$(LI それ以外
  後述の make-style.xml 内で参照されるマクロとして扱われます。
$(UL
    $(LI `'macro_name=hogehoge'` でマクロに値を設定できます。)
    $(LI `'macro_name+=hogehoge'` 複数設定可能なマクロには値を追加することができ
         ます。)
    $(LI `'macro_name'` 値を指定しなかった場合は `'defined'` が格納されます。)
    $(LI `'macro_name='` とすると、マクロを削除できます。)
)))

設定ファイル_make-style.xml:
設定ファイルは xml で記述されています。
Makefile の出力を制御します。

設定ファイル内では、
$(UL
$(LI 文字列をそのまま Makefile へ出力)
$(LI マクロへ文字を設定、追加)
$(LI マクロの文字を展開、置換して展開、して Makefile へ出力)
$(LI マクロの存在による分岐)
)

が可能です。

ファイルはおよそ以下のような構造になっています。
---
    <style>
        <head>
            <ifdef id="gui">
                <add id="compile_flag">-version=Unicode</add>
                    <add id="link_flag">-L/exet:nt/su:windows:4.0</add>
            </ifdef>
        </head>
        <environment compiler="dmd" id="make">
            <body>
                TARGET = <get id="target" /><br />
                TO_COMPILE = <get id="to_compile" />< br />
                TO_LINK = <get id="to_link" /><br />
                COMPILE_FLAG = <get id="compile_flag" /><br />
                LINK_FLAG = <get id="link_flag" /><br />
                
                $(DOLLAR)(TARGET) : $(DOLLAR)(TO_LINK)<br />
                <tab />dmd $(LINK_FLAG) -of$@ $**<br />
                
                .d.obj :<br />
                <tab />dmd -c -op $(DOLLAR)(COMPILE_FLAG) $&lt;<br />
                
                <get id="dependencies" /><br />
                <get id="footer" />
            </body>
        </environment>
    </style>
---
この設定ファイルと、次のコマンドで amm.exe を実行した場合、
$(PROMPT amm gui test.d)
出力される Makefile は、
---
    TARGET = hogehoge.exe
    TO_COMPILE = ./test.d
    TO_LINK = ./test.obj
    COMPILE_FLAG = -version=Unicode
    LINK_FLAG = -L/exet:nt/su:windows:4.0
    
    $(DOLLAR)(TARGET) : $(DOLLAR)(TO_LINK)
        dmd $(DOLLAR)(LINK_FLAG) -of$@ $(DOLLAR)**
    
    .d.obj :
        dmd -c -op $(DOLLAR)(COMPILE_FLAG) $(DOLLAR)<
    
    test.obj : test.d
    ## generated by amm.
---
というようになります。

コマンドライン引数 `'gui'` を設定したことによって、コンパイルオプション、リンクオプションが追加されています。

最後の行の `## generated by amm.` はフッタとしてマクロに登録されたものです。
例えばインストールコマンド等、フッタ以降に手動で記入したものは、amm.exe を再度実行し、
Makefile を作り直しても残ります。

行頭、行末の空白文字は省かれます。
それ以外の空白文字はそのまま出力されます。

行頭にタブを出力する場合は、`<tab />` を使用して下さい。


設定ファイルで利用可能なタグ:
$(UL
$(LI `<style>`
  ルートタグ。
  `<environment>` が必須要素)
$(LI `<head>`
  マクロへの値の設定は、この中で行います。
  `<set>` タグ、`<add>` タグ及び、`<ifdef>`、`<ifndef>` タグが使用可能です。
  `<head>` タグは、`<style>` 要素の中で、`<environment>` 要素の前か、
  `<environment>` 要素の中で、 `<body>` 要素の前に置くことができます。)
$(LI `<ifdef>`
  `'id'` 属性で指定した名前のマクロが登録されていた場合、要素の内容が反映されま
  す。
  `'id'` 属性が必須属性です。)
$(LI `<ifndef>`
  `<ifdef>` の反対。)
$(LI `<set>`
  内容が `'id'` 属性で指定した名前で、マクロへ登録されます。
  マクロが既に存在する場合は、それを上書きします。
  この要素の内容には、`<ws>` タグ、`<br>` タグ、`<tab>` タグ及び、`<get>` タグを
  含めることができます。
  `<get>` タグは、現在のマクロが展開されるときに評価されます。
  `'id'` 属性が必須属性です。)
$(LI `<add>`
  `<set>` とはちがい、値を追加します。)
$(LI `<environment>`
  `<environment>` タグは複数書くことができます。
  事前に、`'env'` という名前でマクロが登録されていると、
  `<environment>` タグの `'id'` 属性の値とマッチしたものが評価されます。
  `'env'` マクロが存在しない場合は、最初の `<environment>` が評価されます。
  `'id'` 属性が必須属性です。
  `<body>` 要素が必須要素です。)
$(LI `<body>`
  この要素内の、タグ以外のテキストはそのまま Makefile へ出力されます。
  行頭、行末の空白文字は消去されます。それ以外の空白はそのまま残されます。
  この要素の内容には、`<ws>` タグ、`<tab>` タグ、`<br>` タグ、`<get>` タグ及び、
  `<ifdef>`、`<ifndef>`
  タグを含めることが出来ます。
  文字実体参照は std.xml によって変換されます。)
$(LI `<ws>`
  Makefileに ' '(スペース)を出力します。`'length'` 属性を指定すれば、連続した
  空白を出力できます。)
$(LI `<tab>`
  タブ文字を出力します。)
$(LI `<br>`
  改行を出力します。
  初期状態では、CR+LF を出力しますが、これは事前に、`'bracket'` という名前で
  マクロを登録しておくことで
  変更できます。
  `bracket=rn` で CR+LFに、
  `bracket=n` で LF に、
  `bracket=r` で CR に設定されます。)
$(LI `<get>`
  `'id'` 属性の名前で登録されているマクロの値を展開します。
  未登録のマクロを指定した場合はなにも出力されません。
  `'from'` 属性と `'to'` 属性を指定すると、std.array.replace による置換を適用
  できます。
  `'id'` 属性が必須属性です。)
)

定義済みマクロ:
$(MACRODESC マクロの値は、コマンドラインによる指定が最優先されます。
大文字と小文字は区別されません。)

$(MACRODEFS
$(MACRODEF4 bracket, rn, n,
  改行コードを指定する。
$(UL
    $(LI `'rn'` で CR+LFに、)
    $(LI `'n'` で LF に、)
    $(LI `'r'` で CR に、設定されます。)
))
$(MACRODEF env,
  現在は使用していません。)
$(MACRODEF4 exe_ext, .exe, ,
  実行形式ファイルの拡張子。拡張子には '.'(ドット) を含める。)
$(MACRODEF4 obj_ext, .obj, .o,
  オブジェクトファイルの拡張子)
$(MACRODEF4 lib_ext, .lib, .a,
  ライブラリファイルの拡張子)
$(MACRODEF3 gen_deps_command, dmd -c -op -o- -debug,
  dmd にファイルの依存関係を解決させる為のコマンド。
  `'gen_deps_command' ~ 'compile_flag' ~ 'root_file'`
  で実行される。
  このコマンドの `'tempdeps'` の部分は、次項のマクロ `'deps_file'` の値と一致
  している必要がある。)
$(MACRODEF3 deps_file, tempdeps,
  `'gen_deps_command'` により生成されるファイル名。
  amm.exe 終了時にこのファイルを消去する。)
$(MACRODEF3 m, Makefile,
  生成される Makefile の名前)
$(MACRODEF root,
  プロジェクトのルートになるファイル名。
  ターゲットがライブラリの場合など、互いに疎なソースファイルを扱えるように、複数
  のファイルを登録できる。
  コマンドラインから、拡張子が `'.d'` のファイルを指定すると、このマクロに追加
  される。)
$(MACRODEF compile_flag,
  dmd に渡されるコンパイルオプション。
  コマンドライン引数のうち、'-'(ハイフン) で始まる引数がここに登録される。)
$(MACRODEF link_flag,
  dmd に渡されるリンクオプション。
  コマンドライン引数のうち、'-L' で始まる引数がここに登録される。)
$(MACRODEF target,
  プロジェクトのターゲット。
  コマンドライン引数のうち、拡張子が、`'.exe'`、`'.dll'` のものがここに登録
  される。)
$(MACRODEF dependencies,
  解決された依存関係が格納される。)
$(MACRODEF to_compile,
  コンパイルされるべきファイルが格納される。)
$(MACRODEF to_link,
  リンクされるべきファイルが格納される。)
$(MACRODEF rc_file,
  リソースファイル名。コマンドライン引数のうち、拡張子が、`'.rc'` のものが登録
  される。)
$(MACRODEF def,
  コマンドライン引数のうち、拡張子が、`'.def'` のものが登録される。)
$(MACRODEF ddoc,
  コマンドライン引数のうち、拡張子が、`'.ddoc'` のものが登録される。)
$(MACRODEF dd,
  DDOC ファイルの出力ディレクトリ)
$(MACRODEF libs,
  ライブラリファイル名が格納される。
  `'ext_lib_directory'` に登録されたディレクトリ下にある、`'lib_ext'` を持つ
  ファイルが格納される。)
$(MACRODEF3 imp, import,
  インポートファイルを含むルートディレクトリ。
  このフォルダに含まれているファイルはコンパイルされない。)
$(MACRODEF3 lib, lib,
  リンクするファイルを含むルートディレクトリ。)
$(MACRODEF i, imp_root ~ ';' ~ root
  dmd の `-I` オプションになる。)
$(MACRODEF is_dll,
  ターゲットが .dll だったとき、defined となる。)
$(MACRODEF is_lib,
  ターゲットが .lib だったとき、defined となる。)
$(MACRODEF verbose)
$(MACRODEF q,
  実行時の出力を調整する。)
$(MACRODEF3 footer, ## generated by amm.,
  Makefile 内でここに指定された文字列より後に書かれたものは、amm.exe を再度実行
  しても残る。)
$(MACRODEF3 style_file, make-style.xml,
  設定ファイルを指定する。
  コマンドライン引数のうち、拡張子が `'.xml'` のものが登録される。
  登録されたファイルは、以下の順で探される。
  $(OL
    $(OLI 実行時のカレントフォルダ)
    $(OLI 環境変数 HOME で指定したフォルダ)
    $(OLI amm.exe のあるフォルダ)
  ))
$(MACRODEF v)
$(MACRODEF authors)
$(MACRODEF license,
    プロジェクトのバージョン情報。)
$(MACRODEF date,
    amm が設定する。)
$(MACRODEF remake_command,
  amm を起動した時のコマンドが登録される。)
$(MACRODEF3 src, src,
  コマンドライン引数のうち、'-Ixxx;yyy;zzz' のような形で指定されたものが
  ここに登録される。
  ソースファイル探索のルートフォルダを決定する。)
$(MACRODEF is_vclinker,
  VCのリンカを参照する場合。)
$(MACRODEF4 dll_ext, .dll, .so,
  Dynamic Link Library ファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、amm によって生成
  される Makefile のターゲットファイルとして、マクロ名 'TARGET' の値にファイル
  が登録される。
  また、ターゲットファイルが DLL であることを示す、マクロ 'IS_DLL' が定義
  される。)
$(MACRODEF3 mak_ext, .mak,
  Makefile の拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'M'
  の値としてファイルが登録される。)
$(MACRODEF3 src_ext, .d,
  ソースファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'ROOT'
  の値としてファイルが登録され、プロジェクトの依存関係を解決するための
  ルートファイル として扱われる。
  また、マクロ名 'TARGET' が指定されなかった場合は、ROOT + EXE_EXT が
  マクロ名 'TARGET' に設定される。)
$(MACRODEF3 rc_ext, .rc,
  リソースファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'RC'
  の値としてファイルが登録される。)
$(MACRODEF rc,
  リソースファイル。
  コマンドライン引数のうち、マクロ名 'RC_EXT' に登録された拡張子を持つファイル
  がここに登録される。)
$(MACRODEF3 def_ext, .def,
  D言語の module definition file の拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'DEF'
  の値としてファイル登録される。)
$(MACRODEF3 ddoc_ext, .ddoc,
  DDOCファイルの拡張子
  このマクロの値として設定された拡張子を持つファイル名をコマンドライン引数
  として渡すと、マクロ名 'DDOC' の値としてファイルが登録される。)
$(MACRODEF3 xml_ext, .xml,
  amm の設定ファイルの持つ拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、
  マクロ名 'STYLE_FILE' の値としてファイルが登録される。)
$(MACRODEF3 style, make-style.xml,
  Makefile の出力を決定する設定ファイル。
  コマンドライン引数に拡張子が '.xml' のファイルを渡すとこのマクロに設定
  される。)
)

ライセンス:
$(LINK2 http://creativecommons.org/publicdomain/zero/1.0/, Creative Commons Zero License)

ToDo:
$(UL
$(LI $(DEL GNU make に対応する。)( 2012/10/25 ver. 0.163 にて対応))
$(LI $(DEL Linux に対応する。)( 2012/10/25 ver. 0.163 にて対応))
)

開発環境:
現在、
$(UL
$(LI Windows Vista(WoW64) x dmd$(DMD_VERSION) x (dmdに付属の)make)
$(LI Ubuntu 15.10(x64) x gcc 5.2.1 x dmd$(DMD_VERSION) x GNU Make)
)
の組み合わせで実行を確認しています。
付属の amm.exe は x64 Windows 用のバイナリです。

履歴:
$(UL
$(LI 2016/02/28 ver. 0.169(dmd2.070.0)
$(UL
    $(LI README.md を ddoc で生成するように。)
    $(LI 定義済みマクロとその初期値を ddoc で生成するように。)
))
$(LI 2015/12/22 ver. 0.168(dmd2.069.2)
$(UL
    $(LI 英語版README.md追加。)
    $(LI linux上でのバグフィクス)
))
$(LI 2015/12/06 ver. 0.167(dmd2.069.2)
  std.process がらみの deplication に対応。
  ソースのインデントをタブからスペースに。(dmdのソースに準拠すべく。))
$(LI 2014/06/28 ver. 0.166(dmd2.065)
  バグフィクス)
$(LI 2013/03/02 ver. 0.165(dmd2.064)
  linux 上で make-style.xml を探せないバグを修正。
  -inline で無限ループするバグは根気不足が原因だったかもしれん。)
$(LI 2012/10/28 ver. 0.164(dmd2.060)
  コンソールへの出力まわりを若干変更)
$(LI 2012/10/25 ver. 0.163(dmd2.060)
  linux になんとなく対応。)
$(LI 2012/10/11 ver. 0.162(dmd2.060)
  ディレクトリの評価まわりのバグフィクス。
  make-style.xml の修正。)
$(LI 2012/10/11 ver. 0.161(dmd2.060)
  いろいろ変更。
  $(OL
    $(LI ヘルプを日本語に。)
    $(LI help macro でマクロの一覧出せるように。)
    $(LI .lib のファイル渡すとリンクするライブラリという判断になりました。
      やっぱ不便やからね。)
    $(LI マクロ project なくなりました。不便。)
    $(LI マクロ install_directory なくなりました。いらん。)
    $(LI .mak のファイルを渡すと Makefile の名前となるように。)
    $(LI あとちょこちょこマクロの名前変わってます。)
  ))
$(LI 2012/10/10 ver. 0.160(dmd2.060)
  github デビュー。
  それにともなって、Doxygen 使うのやめに。
  あと、compo.lib にまとめるのはやめて、ソースコード展開しました。)
$(LI 2012/10/09 ver. 0.159(dmd2.060)
  dll 作成時の出力を変更)
$(LI 2012/06/07 ver. 0.158(dmd2.059)
  public import の依存を解決)
$(LI 2012/04/15 ver. 0.157(dmd2.059)
  compo.lib を若干修正
  コマンドラインからマクロを設定する際、後に書いたものが有効になるように変更。
  拡張子が ".lib" のファイルを渡した場合、これまではリンクすべき
  ライブラリファイルと判断されていましたが、
  出力ターゲットがライブラリファイルである。と認識されるようになりました。
  リンクすべきライブラリファイルをコマンドラインから指定する場合は、
  <span class="prompt">to_link+=hoge.lib</span>として下さい。)
$(LI 2012/04/11 ver. 0.156(dmd2.058)
  ほぼ全面刷新。
  $(UL
    $(LI いくつかのモジュールが、外部ライブラリ compo.lib にまとめられました。
      だからどうということもないんですが。)
    $(LI このドキュメントが $(LINK2 http://www.doxygen.jp, Doxygen)
      を使うようにかわりました。)
  ))
$(LI 2010/08/20 ver. 0.155 dmd2.048
  style-xml ファイルにコメント`<!-- -->`入れても落ちなくなりました。
  依存関係に .di ファイルがあっても大丈夫になりました。)
$(LI 2010/05/27 ver. 0.154 dmd2.046
  style-xmlの標準化にむけて。)
$(LI 2010/05/18 ver. 0.153 dmd2.045
  -style.xmlファイルの標準化にむけて。
  $(UL
    $(LI `<make>` タグが `<style>` に、)
    $(LI `<style>` タグが、`<environment>` に、)
    $(LI `<style>` マクロが、`<env>` に変更されました。)
  ))
$(LI 2010/05/11 ver. 0.152 dmd2.045
  ライセンスが修正BSDから $(LINK2 http://creativecommons.org/choose/zero, CreativeCommons Zero License) に変更されました。)
$(LI 2010/05/06 ver. 0.151 dmd2.045
  マクロの名前がいくつか変更されました。)
$(LI 2010/05/01 ver. 0.150 dmd2.043
  コマンドライン引数として複数のDソースファイルを渡せるようになりました。
  互いに依存関係が疎なファイルを一つのライブラリにまとめたい時に使えます。
  `<add>` タグが追加されました。)
$(LI 2010/04/21 ver. 0.149 dmd2.043
  `<set>` タグ内で `<get>`タグが使用可能になりました。
  この時、`<get>`タグは、そのマクロが展開される時に評価されます。)
$(LI 2010/04/09 ver. 0.148 dmd2.042
  dll作成になんとなく対応。
  `<set>` タグ内で `<br>`、`<tab>`、`<ws>` タグが使用可能に。)
$(LI 2010/04/07 ver. 0.147 dmd2.042
  Dのソースファイルにimport宣言がないとパースに失敗してたバグを修正。)
$(LI 2010/03/15 ver. 0.146
  dmd2.041対応版。)
$(LI 2009/10/20 ver. 0.145
  dmd2.035対応版。
  make-sytle.xml内で行頭および行末の空白文字のみ削除されるように変更されました。
  )
$(LI 2009/09/19 ver. 0.144
  `<footer>`マクロを導入。
  Makefile中で `<get id="footer" />`以降に書かれたものは
  Makefileを作りなおしても残るようになりました。
  ここに、まあインストールコマンドとかを書いてもらえばよいかと。)
$(LI 2009/09/17 ver. 0.143
  `<style>`タグの `'make'` 属性を `'id'` と変更。
  `<ifndef>`タグを追加。
  make-style.xml を刷新。)
$(LI 2009/09/15 ver. 0.14
  オプションの指定方法変更。
  `<switch>` タグのかわりに、`<ifdef>` タグができました。
  なんかコロコロ変わるよなあ。)
$(LI 2009/09/14 ver. 0.132
  色々修正。っていうかMakefileの書き方まちがってました。
  `<add>` タグがなくなりました。)
$(LI 2009/09/12 ver. 0.131
  マクロのidは大文字、小文字に関係なくなりました。
  その他ちょっとしたバグとか修正。)
$(LI 2009/09/04 ver. 0.13
  dmd2.032リリースにあたってのバージョンアップ
  std.xmlのバグがなおったので、altstd.xmlは消去。
  std.getoptつかうのやめに。それにともなってオプションのスタイルとか色々変り
  ました。
  make-style.xmlのバグ修正。)
$(LI 2009/09/01 ver. 0.12
  vwrite に対応。)
$(LI 2009/08/31 ver. 0.11
  改行コードが指定可能に。
  std.contractsを使うようにちょっとだけ変更。)
$(LI 2009/08/29 ver. 0.1
  ほんと $(B とりあえず) 公開。)
)

**/
module sworks.amm.main;

version (D_Ddoc){}
else:

import sworks.base.output;
import sworks.stylexml;
import sworks.amm.args_data;
import sworks.amm.ready_data;
import sworks.amm.deps_data;
debug import std.stdio : writeln;

enum _VERSION_ = "0.169(dmd2.070.0)";
enum _AUTHORS_ = "KUMA";


enum header =
    "Automatic Makefile Maker v" ~ _VERSION_ ~ ". Written by KUMA.\n";

/// 説明文の多言語化処理。
struct Lang { string en, jp; }
///
struct OS { string win, nix; }

enum string[string] helpdoc = mixin(import("help.d"));

// コマンドラインに表示するヘルプメッセージ
enum help = header ~ helpdoc[Lang("How to use:", "使い方:").sel];
enum string[][string] macrostore =
    mixin(helpdoc[Lang("Predefined macros:", "定義済みマクロ:").sel]);

struct PREDEF
{
static:
    mixin(
    {
        import std.array : Appender, join;
        Appender!(string[]) buf;
        foreach (key, val; macrostore)
        {
            if (0 == key.length) continue;
            buf.put(["enum ", key, " = \"", key, "\";"]);
        }
        return buf.data.join;
    }());
}

void main(string[] args)
{
    import std.conv : to;
    import std.exception : enforce;
    import std.file : read, exists, write;
    import std.string : lastIndexOf;

    // 引数がない場合はヘルプを出力して終了
    if (args.length <= 1) return help.outln;
    auto tempargs = args;
    args.length = 0;
    debug { Output.mode = Output.MODE.VERBOSE; }
    // ヘルプが必要か、と、出力の冗長性に関しては先に調べておく。
    foreach (i, one ; tempargs)
    {
        // ヘルプが要求されている場合
        if     (("h" == one) || ("help" == one) || ("?" == one) ||
                ("-h" == one) || ("-help" == one) || ("--help" == one) ||
                "/?" == one)
        {
            if (i+1 < tempargs.length && tempargs[i+1] == "macro")
                output_macro_help();
            else help.outln;
            return;
        }
        // 出力の冗長性の制御
        else if ("verbose" == one) Output.mode = Output.MODE.VERBOSE;
        else if ("q" == one || "quiet" == one) Output.mode = Output.MODE.QUIET;
        else if (0 < one.length) args ~= one;
    }

    StyleParser parser;
    // マクロに初期値を設定
    auto macros = default_macros;

    // コマンドライン引数の解析
    set_args_data!PREDEF(macros, args);

    header.logln;
    // -style.xml ファイルの読み込み。
    auto str = macros[PREDEF.style].read.to!string;
    logln("success to open ", macros[PREDEF.style]);
    parser = new StyleParser(str, macros);
    logln("parser is ready");

    // -style.xml ファイルのヘッダだけは読み込んでおく。
    parser.parseHead;
    logln("<head> is parsed successfully");

    // マクロを準備する。
    ready_data!PREDEF(macros);
    logln("macros are ready");

    // 依存関係を解決
    set_deps_data!PREDEF(macros);
    logln("dependencies are whole resolved.");

    //########## 準備完了 ##########
    // -style.xml ファイルのボディを処理する。
    logln("parse start.");
    auto makefile_cont = parser.parseBody();
    logln("parse success.");

    enforce(0 < makefile_cont.length, "failed to generate Makefile by " ~
            macros[PREDEF.style]);

    // Makefile が既存で、footer が見つかった場合、それ以降は残す。
    auto footer = macros[PREDEF.footer];
    if (macros[PREDEF.m].exists && 0 < footer.length)
    {
        logln("old makefile is detected.");
        auto old_makefile_cont = macros[PREDEF.m].read.to!string;
        auto i = old_makefile_cont.lastIndexOf(footer);
        if (0 < i)
        {
            string post_footer = old_makefile_cont[i+footer.length .. $];
            if (0 < post_footer.length)
            {
                logln("post-footers are detected.");
                makefile_cont ~= post_footer;
            }
        }
    }

    // Makefile を出力。
    macros[PREDEF.m].write(makefile_cont);
    logln("complete.");
}

private:

// マクロに初期値を設定します。
Macros default_macros()
{
    auto data = new Macros;
    import std.path :pathSeparator;

    foreach (name, val ; macrostore)
    {
        if      ("bracket" == name)
            data[name] = new BracketItem(val.sel);
        else if ("src" == name ||
                 "imp" == name ||
                 "lib" == name)
            data[name] = new MacroItem(val.sel, pathSeparator);
        else
            data[name] = new MacroItem(val.sel);

    }
    return data;
}

//
void output_macro_help()
{
    Lang("the list of pre defined macros.",
         "定義済みマクロ一覧").sel.outln;
    "--------------------".outln;

    foreach (name, val ; macrostore)
    {
        if (0 == name.length) continue;
        Lang("Name        : '", "マクロ名 : '").sel.outln(name, "'");
        Lang("Default     = '", "初期値   = '").sel.outln(val.sel, "'");
        Lang("Description    ", "説明        ").sel.outln;
        val[2].outln;
    }
}

string sel(Lang lang)
{
    version (InJapanese) return lang.jp;
    else return lang.en;
}

string sel(string[] os)
{
    version      (Windows) return os[0];
    else version (linux) return os[1];
    else static assert(0);
}


