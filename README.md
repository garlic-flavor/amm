Automatic Makefile Maker
========================
This is a program that makes a Makefile from the source code wirtten in
D programmming language, automatically.


ACKNOWLEDGEMENTS
----------------
amm is written by D.

[Digital Mars D Programming Language](http://dlang.org/ "D PROGRAMMING LANGUAGE")


!!! BUG !!!
-----------
- An error will occur when any Japanese are in a delimited string.(on windows)


HOW TO BUILD
------------
### ON WINDOWS.
Please build with make tool that is distributed with dmd.

32bit:

    >make -f win.mak release

64bit:

    >make -f win.mak release FLAG=-m64

### ON LINUX.

    >make -f linux64.mak release


HOW TO USE
----------
Invoke amm from terminal.

### Previous Notice.

- amm will invoke dmd, ensure that dmd is ready.

- Put make-style.xml to where amm can find.

    The searching priority is,

    1. Current directory.
    2. The directory of the environment variable 'HOME'.
    3. The directory where the amm is.
    4. On Linux, `../etc` (related with where the amm is).


### Example

    >amm root_file.d

With the above command, a Makefile will be generated in the current directory.

I assume that 'root_file.d' is a root file of the project, and that has `main()`
function.

If you want to make the target file name 'hoge.exe', do like this.

    >amm root_file.d hoge.exe

When the argument starts with '-', it will be passed through to dmd.

    >amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe

You can use macro for amm like this.

    > amm v=1.0 gui root_file.d

The macro named `'v'` is set as `'1.0'`, and the macro named `'gui'` is set as
`'defined'`.

Delete macro command is

    >amm gui= root_file.d


In the default situation, directories that consist your project are assumed like
below.

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


### COMMAND LINE ARGUMENTS
- '/?' '-h' '-help'

  show help messages.

- 'help macro'

  show pre-defined macros.

- starts with '-L'.

  is treated as link option.

- starts with '-'.

  is treated as comple option.

- has any extensions.

  is treated as some kind of file.

  + '.d'

    is treated as a root file of the project.

  + '.exe'

    is treated as a target file name of the project. (on Windows)

  + '.dll'

    is treated as a target file name of the project, and the project is
    assumed that its target is dynamic link library.

  + '.lib'

    is treated as a static link library to be linked with your project.
    (on Windows)

  + '.def'

    is treated as a module definition file for DLL. (on Windows)

  + '.rc'

    is treated as a resource file. (on Windows)

  + '.xml'

    is treated as a setting file for amm, described below.

  + '.mak'

    is treated as a file name of the target Makefile.


- other

  is treated as a definition of a macro.


  + `'macro_name=hogehoge'` sets the macro named `'macro_name'` as `'hogehoge'`.
  + `'macro_name+=hogehoge'` adds `'hogehoge'` to the macro named `'maco_name'`.
  + `'macro_name'` sets the macro named `'macro_name'` as `'defined'`.
  + `'macro_name='` removes the macro named `'macro_name'`.


### about make-style.xml
`make-style.xml` controls the generation of the Makefile.

In this file, you can

- output the string.
- set / add the string to the macro.
- retrieve the value from the macro, and do replacement.
- use ifdef / ifndef conditioning.

`make-style.xml` looks like below.

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
                
                $(TARGET) : $(TO_LINK)<br />
                <tab />dmd $(LINK_FLAG) -of$@ $**<br />
                
                .d.obj :<br />
                <tab />dmd -c -op $(COMPILE_FLAG) $&lt;<br />
                
                <get id="dependencies" /><br />
                <get id="footer" />
            </body>
        </environment>
    </style>

With above make-style.xml, and with the command below,

    >amm gui test.d

the Makefile that is going to be generated will be like below.

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


### VALID ELEMENTS in make-style.xml.

- `<style>`

    root element.

    `<environemnt>` is an essential element.


- `<head>`

    No outputting occur in this element.

    You can use `<set>`, `<and>` and, `<ifdef>`, `<ifndef>`.

    `<head>` will be followed by an `<environment>` or a `<body>` element.


- `<ifdef>` `<ifndef>`

    An `'id'` attribute of this element specify the condition.

    `'id'` is an essential attribute.


- `<set>`

    Its contents will be set to the macro named what is specified in the `'id'`
    attrubute.

    When the macro already exists, the value will be over written.

    You can use `<ws>`, `<br>`, `<tab>` and `<get>` in this element.

    `<get>` is evaluated lazily.

    `'id'` is an essential attribute.

- `<add>`

    The value will be added to the macro.

    `'id'` is an essential attribute.

- `<environment>`

    This element exists for backward compatibility.

- `<body>`

    Outputting may occur.
    Strings are outputted to the Makefile as usual.
    Starting/Trailing spaces are removed.

    You can use `<ws>`, `<tab>`, `<br>`, `<get>`, `<ifdef>` and `<ifndef>`.

    Character Entity References are resolved by std.xml.

- `<ws>`

    Output `' '`(space) to the Makefile. with `'length'` attrubute, you can
    output sequential spaces.

- `<tab>`

    Output `'\t'(tab)` to the Makefile.

- `<br>`

    Output `'\r\n'(on Windows)`/`'\n'(on linux)`.

    The Macro named `'bracket'` controls this behavior.

    * `bracket=rn`, then outputting is `'\r\n'`
    * `bracket=n`, then outputting is `'\n'`
    * `bracket=r`, then outputting is `'\r'`

- `<get>`

    Expand the macro specified by `'id'` attribute.

    With `'from'` and `'to'` attributes, a replacement will occur when the
    expansion.

    `'id'` is a essential attribute.

### PRE DEFINED MACROS.
The values specified by command line have highest priority.

The name of macro is case IN-sensitive.

- `'bracket'`

    specify newline characters.

    * `'rn'` => CR+LF.
    * `'n'` => LF.
    * `'r'` => CR.

    The default value is `'rn'` on Windows.

    The default value is `'n'` on linux.


- `'env'`

    This macro exists for backward compatibility.


- `'exe_ext'`

    specify a extension of an executable file name.

    The default value is `'.exe'` on Windows.

    The default value is `''` on linux.


- `'obj_ext'`

    specify a extension of a object file name.

    The default value is `'.obj'` on Windows.

    The default value is `'.o'` on linux.


- `'lib_ext'`

    specify a extension of a statically linked library file name.

    The default value is `'.lib'` on Windows.

    The default value is `'.a'` on linux.


- `'gen_deps_command'`

    specify the command that invokes dmd to resolve your project's dependencies.

    The default value is `'dmd -c -op -o- -deps=tempdeps -debug'`


- `'deps_file'`

    specify the file name of the target of `'gen_deps_command'`.

    The default value is `'tempdeps'`.


- `'m'`

    specify the name of the Makefile.

    The default value is `'Makefile'`.


- `'root'`

    specify the file name of root file of your project.

    When a file that has `'.d'` as its extension is passed as a command line
    argument, the file name will be set to this macro.


- `'compile_flag'`

    specify compile flags for dmd.

    When a command line argument for amm starts with `'-'`, the argument will be
    set to this macro.


- `'link_flag'`

    specify link flags for dmd

    When a command line argument for amm starts with `'-L'`, the argument will
    be set to this macro.


- `'target'`

    specify the target file name of your project.

    On Windows, when a file that has `'.exe'` or `'.dll'` as its extension is
    passed as a command line argument for amm, the file name will be set to this
    macro.


- `'dependencies'`

    Amm will set this value.


- `'to_compile'`

    Amm will set this value.


- `'to_link'`

    Amm will set this value.


- `'rc_file'`

    On Windows, when a file that has `'.rc'` as its extension is passed as a
    command line argument for amm, the file name will be set to this macro.


- `'def'`

    On Windows, when a file that has `'.def'` as its extension is passed as a
    command line argument for amm, the file name will be set to this macro.


- `'ddoc'`

    On Windows, when a file that has `'.ddoc'` as its extension is passed as a
    command line argument for amm, the file name will be set to this macro.


- `'dd'`

    specify the target directory of [DDOC](http://dlang.org/spec/ddoc.html).


- `'libs'`

    specify libraries names to link.

    Amm will gather names form the directory specified by the macro named
    `'lib'`.


- `'imp'`

    specify the directory that contains the files to be imported by your
    project.

    The default value is `'import'`.


- `'lib'`

    specify the directory that contains the file to be linked by your project.

    The default value is `'lib'`.


- `'i'`

    Amm will set this value.
    this is same as `-I` option for dmd.


- `'is_dll'`

    specify whether the target of your project is dynamic link library.


- `'is_lib'`

    specify whether the target of your project is static link library.


- `'verbose'`
- `'q'`

    controls the verboseness of amm.


- `'footer'`

    specify the 'footer mark' of the Makefile.

    Amm will overwrite the Makefile. but, the contents after this mark will
    remain.

    The default value is `'## generated by amm.'`


- `'style_file'`

    specify the setting file name.
    The default value is `'make-style.xml'`.


- `'v'`
- `'authors'`
- `'license'`

    specify the description about your project.

- `'date'`

    Amm will set this value as today.


LICENSE
-------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")

DEVELOPMENT ENVIRONMENT
-----------------------
- Windows Vista(x64) x dmd 2.069.2 x make (of Digital Mars)
- Ubuntu 15.10(x64) x gcc 5.2.1 x dmd 2.069.2 x GNU Make

HISTORY
-------
- 2015/12/22 ver. 0.168(dmd2.069.2)

    * add English README.md.
    * some bug fix on linux.


* * *




はじめにお読み下さい。 - AMM -
========================================
これはD言語で書かれたソースコードから Makefile を自動生成するプログラムです。


謝辞
----
amm は D言語で書かれています。

[Digital Mars D Programming Language](http://dlang.org/ "D PROGRAMMING LANGUAGE")


!!! BUG !!!
-----------
- <del>'-inline' オプションで amm をコンパイルすると dmd が無限ループ(?) ( win32 及び linux32 で確認 )</del>(2013/03/02 dmd2.062)
- ヒアドキュメント、q"DELIMITER hoge-hoge...  DELIMITER" である(不明)パターンになると、"Error: Outside Unicode code space"


ビルド方法
----------
### Windows
DMDに付属のmakeを使用して下さい。

32bit版

    >make -f win.mak release FLAG=-version=InJapanese

64bit版

    >make -f win.mak release FLAG="-version=InJapanese -m64"

### Linux

    >make -f linux64.mak release FLAG=-version=InJapanese


使い方
------
コマンドラインから使います。

### 事前に、

- dmd へパスを通し、使える状態にしておいて下さい。

- amm.exe へのパスを通して下さい。

- 同梱の make-style.xml を amm.exe が探せる位置において下さい。
  make-style.xml は

    1. amm.exe を実行するフォルダ
    2. 環境変数 HOME のフォルダ
    3. amm.exe と同じフォルダ
    4. linux上では amm のあるフォルダから見て `../etc`。

  の順に探されます。

### 簡単な使い方

    >amm root_file.d

でカレントフォルダに Makefile ができます。

ここで、`root_file.d` としているのは、プロジェクトのルートとなるファイル
(実行形式のファイルがターゲットとなる場合は、一般的に `main()` 関数を含むファイル) です。

初期状態では色々と変なことになると思うので、`make-style.xml` をいじって自分の環境に合わせてみて下さい。

実行ファイル名を hoge.exe とするには、

    >amm root_file.d hoge.exe

とします。

    >amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe

'-'(ハイフン)で初まる引数は、dmd へそのまま引き渡されます。

以降で説明する、make-style.xml 内で使用されるマクロを設定するには、

    >amm v=1.0 gui root_file.d

これで、マクロ名 `"v"` に、文字列 `"1.0"` が、マクロ名 `"gui"` に、文字列 `"defined"` が設定されます。

既存のマクロを削除するには、

    >amm gui= root_file.d

とします。

初期状態では、フォルダの構成が以下のような環境が想定されています。

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

### コマンドライン引数
- '-h' '-help' '/?'

  ヘルプメッセージを出力します。

- 'help macro'

  定義済みマクロ一覧を表示します。

- '-L' で始まるもの

  リンカへのオプションとみなされ、リンク時に dmd へと引き渡されます。

- それ以外で、'-'(ハイフン)で始まるもの

  コンパイル時に dmd へと引き渡されます。

- 拡張子があるもの。(std.path.extension にヒットするもの)

  ファイル名として解釈されます。

  + '.d'
    >ソースコードのルートとなるファイルとして扱われます。
    >複数のファイルを渡すこともできます。

  + '.exe'
    >ターゲットのファイル名として扱われます。

  + '.dll'
    >ターゲットのファイル名として扱われます。

  + '.lib'
    >ターゲットのファイル名として扱われます。
    >*リンクするライブラリとしては扱われない* ので注意が必要です。
    >
    >リンクするライブラリを指定する場合は、
    >`to_link+=hoge.lib`
    >とします。

  + '.def'
    >dll を作る際に参照されます。

  + '.rc'
    >Windows 用のリソースファイルとして認識されます。

  + '.xml'
    >後述する設定ファイルとして読み込まれます。

  + '.mak'
    >Makefile のファイル名


- それ以外

  後述の make-style.xml 内で参照されるマクロとして扱われます。

  `'macro_name=hogehoge'` でマクロに値を設定できます。

  `'macro_name+=hogehoge'` 複数設定可能なマクロには値を追加することができます。

  `'macro_name'` 値を指定しなかった場合は `'defined'` が格納されます。

  `'macro_name='` とすると、マクロを削除できます。


### 設定ファイル make-style.xml
設定ファイルは xml で記述されています。
Makefile の出力を制御します。

設定ファイル内では、

- 文字列をそのまま Makefile へ出力
- マクロへ文字を設定、追加
- マクロの文字を展開、置換して展開、して Makefile へ出力
- マクロの存在による分岐

が可能です。

ファイルはおよそ以下のような構造になっています。

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
                
                $(TARGET) : $(TO_LINK)<br />
                <tab />dmd $(LINK_FLAG) -of$@ $**<br />
                
                .d.obj :<br />
                <tab />dmd -c -op $(COMPILE_FLAG) $&lt;<br />
                
                <get id="dependencies" /><br />
                <get id="footer" />
            </body>
        </environment>
    </style>

この設定ファイルと、次のコマンドで amm.exe を実行した場合、

    >amm gui test.d

出力される Makefile は、

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

というようになります。

コマンドライン引数 `'gui'` を設定したことによって、コンパイルオプション、リンクオプションが追加されています。

最後の行の `## generated by amm.` はフッタとしてマクロに登録されたものです。
例えばインストールコマンド等、フッタ以降に手動で記入したものは、amm.exe を再度実行し、
Makefile を作り直しても残ります。

行頭、行末の空白文字は省かれます。
それ以外の空白文字はそのまま出力されます。

行頭にタブを出力する場合は、`<tab />` を使用して下さい。


#### 設定ファイルで利用可能なタグ
- `<style>`

  ルートタグ。

  `<environment>` が必須要素

- `<head>`

  マクロへの値の設定は、この中で行います。

  `<set>` タグ、`<add>` タグ及び、`<ifdef>`、`<ifndef>` タグが使用可能です。

  `<head>` タグは、`<style>` 要素の中で、`<environment>` 要素の前か、`<environment>` 要素の中で、
  `<body>` 要素の前に置くことができます。


- `<ifdef>`

  `'id'` 属性で指定した名前のマクロが登録されていた場合、要素の内容が反映されます。

  `'id'` 属性が必須属性です。


- `<ifndef>`

  `<ifdef>` の反対。


- `<set>`

  内容が `'id'` 属性で指定した名前で、マクロへ登録されます。

  マクロが既に存在する場合は、それを上書きします。

  この要素の内容には、`<ws>` タグ、`<br>` タグ、`<tab>` タグ及び、`<get>` タグを含めることができます。

  `<get>` タグは、現在のマクロが展開されるときに評価されます。

  `'id'` 属性が必須属性です。


- `<add>`

  `<set>` とはちがい、値を追加します。


- `<environment>`

  `<environment>` タグは複数書くことができます。

  事前に、`'env'` という名前でマクロが登録されていると、
  `<environment>` タグの `'id'` 属性の値とマッチしたものが評価されます。
  `'env'` マクロが存在しない場合は、最初の `<environment>` が評価されます。

  `'id'` 属性が必須属性です。

  `<body>` 要素が必須要素です。


- `<body>`

  この要素内の、タグ以外のテキストはそのまま Makefile へ出力されます。

  行頭、行末の空白文字は消去されます。それ以外の空白はそのまま残されます。

  この要素の内容には、`<ws>` タグ、`<tab>` タグ、`<br>` タグ、`<get>` タグ及び、`<ifdef>`、`<ifndef>`
  タグを含めることが出来ます。

  文字実体参照は std.xml によって変換されます。


- `<ws>`

  Makefileに ' '(スペース)を出力します。`'length'` 属性を指定すれば、連続した空白を出力できます。


- `<tab>`

  タブ文字を出力します。


- `<br>`

  改行を出力します。

  初期状態では、CR+LF を出力しますが、これは事前に、`'bracket'` という名前でマクロを登録しておくことで
  変更できます。

  `bracket=rn` で CR+LFに、
  `bracket=n` で LF に、
  `bracket=r` で CR に設定されます。


- `<get>`

  `'id'` 属性の名前で登録されているマクロの値を展開します。
  未登録のマクロを指定した場合はなにも出力されません。

  `'from'` 属性と `'to'` 属性を指定すると、std.array.replace による置換を適用できます。

  `'id'` 属性が必須属性です。



### 定義済みマクロ
マクロの値は、コマンドラインによる指定が最優先されます。

大文字と小文字は区別されません。

- `'bracket'`

  改行コードを指定する。

  `'rn'` で CR+LFに、

  `'n'` で LF に、

  `'r'` で CR に、設定されます。

  初期値は `'rn'`


- `'env'`

  `<environment>` 要素の `'id'` 属性の値と比較され、マッチした `<environment>` 要素の内容が反映される。

  初期値は `''`(なし)


- `'exe_ext'`

  実行形式ファイルの拡張子。拡張子には '.'(ドット) を含める。

  初期値は `'.exe'`


- `'obj_ext'`

  オブジェクトファイルの拡張子

  初期値は `'.obj'`


- `'lib_ext'`

  ライブラリファイルの拡張子

  初期値は `'.lib'`


- `'gen_deps_command'`

  dmd にファイルの依存関係を解決させる為のコマンド。

		>'gen_deps_command' ~ 'compile_flag' ~ 'root_file'

  で実行される。

  初期値は `'dmd -c -op -o- -deps=tempdeps -debug'`

  このコマンドの `'tempdeps'` の部分は、次項のマクロ `'deps_file'` の値と一致している必要がある。


- `'deps_file'`

  `'gen_deps_command'` により生成されるファイル名。

  amm.exe 終了時にこのファイルを消去する。

  初期値は `'tempdeps'`


- `'m'`

  生成される Makefile の名前

  初期値は `'Makefile'`


- `'root'`

  プロジェクトのルートになるファイル名。

  ターゲットがライブラリの場合など、互いに疎なソースファイルを扱えるように、複数のファイルを登録できる。

  コマンドラインから、拡張子が `'.d'` のファイルを指定すると、このマクロに追加される。


- `'compile_flag'`

  dmd に渡されるコンパイルオプション。

  コマンドライン引数のうち、'-'(ハイフン) で始まる引数がここに登録される。


- `'link_flag'`

  dmd に渡されるリンクオプション。

  コマンドライン引数のうち、'-L' で始まる引数がここに登録される。


- `'target'`

  プロジェクトのターゲット。

  コマンドライン引数のうち、拡張子が、`'.exe'`、`'.dll'` のものがここに登録される。


- `'dependencies'`

  解決された依存関係が格納される。


- `'to_compile'`

  コンパイルされるべきファイルが格納される。


- `'to_link'`

  リンクされるべきファイルが格納される。


- `'rc_file'`

  リソースファイル名。コマンドライン引数のうち、拡張子が、`'.rc'` のものが登録される。


- `'def'`

  コマンドライン引数のうち、拡張子が、`'.def'` のものが登録される。


- `'ddoc'`

  コマンドライン引数のうち、拡張子が、`'.ddoc'` のものが登録される。


- `'dd'`

  DDOC ファイルの出力ディレクトリ


- `'libs'`

  ライブラリファイル名が格納される。

  `'ext_lib_directory'` に登録されたディレクトリ下にある、`'lib_ext'` を持つファイルが格納される。


- `'imp'`

  インポートファイルを含むルートディレクトリ。

  このフォルダに含まれているファイルはコンパイルされない。

  初期値は `'import'`


- `'lib'`

  リンクするファイルを含むルートディレクトリ。

  初期値は、`'lib'`


- `'i'`

  dmd の `-I` オプションになる。

  初期値は `'imp_root'` ~ `";"` ~ `'root'`


- `'is_dll'`

  ターゲットが .dll だったとき、defined となる。


- `'is_lib'`

  ターゲットが .lib だったとき、defined となる。


- `'verbose'`
- `'q'`

  実行時の出力を調整する。


- `'footer'`

  Makefile 内でここに指定された文字列より後に書かれたものは、amm.exe を再度実行しても残る。

  初期値は、`'## generated by amm.'`


- `'style_file'`

  設定ファイルを指定する。

  コマンドライン引数のうち、拡張子が `'.xml'` のものが登録される。

  登録されたファイルは、

    1. 実行時のカレントフォルダ
    2. 環境変数 HOME で指定したフォルダ
    3. amm.exe のあるフォルダ

  の順に探索される。

  初期値は、`'make-style.xml'`


- `'v'`
- `'authors'`
- `'license'`

    プロジェクトのバージョン情報。

- `'date'`

    amm が設定する。

ライセンス
----------
[CC0](http://creativecommons.org/publicdomain/zero/1.0/ "Creative Commons Zero License")


ToDo
------------------------------
- <del>GNU make に対応する。</del>( 2012/10/25 ver. 0.163 にて対応)
- <del>Linux に対応する。</del>( 2012/10/25 ver. 0.163 にて対応)


開発環境
--------
現在、

- Windows Vista(WoW64) x dmd x (dmdに付属の)make
- Ubuntu 15.10(x64) x gcc 5.2.1 x dmd x GNU Make

の組み合わせで実行を確認しています。

付属の amm.exe は x64 Windows 用のバイナリです。



履歴
------------------------------
- 2015/12/22 ver. 0.168(dmd2.069.2)

    * 英語版README.md追加。
    * linux上でのバグフィクス

- 2015/12/06 ver. 0.167(dmd2.069.2)

    std.process がらみの deplication に対応。
    ソースのインデントをタブからスペースに。(dmdのソースに準拠すべく。)

- 2014/06/28 ver. 0.166(dmd2.065)

    バグフィクス


- 2013/03/02 ver. 0.165(dmd2.064)

    linux 上で make-style.xml を探せないバグを修正。
    -inline で無限ループするバグは根気不足が原因だったかもしれん。


- 2012/10/28 ver. 0.164(dmd2.060)

    コンソールへの出力まわりを若干変更


- 2012/10/25 ver. 0.163(dmd2.060)

    linux になんとなく対応。


- 2012/10/11 ver. 0.162(dmd2.060)

    ディレクトリの評価まわりのバグフィクス。
    make-style.xml の修正。


- 2012/10/11 ver. 0.161(dmd2.060)

    いろいろ変更。

    * ヘルプを日本語に。
    * help macro でマクロの一覧出せるように。
    * .lib のファイル渡すとリンクするライブラリという判断になりました。やっぱ不便やからね。
    * マクロ project なくなりました。不便。
    * マクロ install_directory なくなりました。いらん。
    * .mak のファイルを渡すと Makefile の名前となるように。
    * あとちょこちょこマクロの名前変わってます。


- 2012/10/10 ver. 0.160(dmd2.060)

    github デビュー。

    それにともなって、Doxygen 使うのやめに。

    あと、compo.lib にまとめるのはやめて、ソースコード展開しました。


- 2012/10/09 ver. 0.159(dmd2.060)

    dll 作成時の出力を変更


- 2012/06/07 ver. 0.158(dmd2.059)

    public import の依存を解決


- 2012/04/15 ver. 0.157(dmd2.059)

    compo.lib を若干修正
    コマンドラインからマクロを設定する際、後に書いたものが有効になるように変更。

    拡張子が ".lib" のファイルを渡した場合、これまではリンクすべきライブラリファイルと判断されていましたが、
    出力ターゲットがライブラリファイルである。と認識されるようになりました。

    リンクすべきライブラリファイルをコマンドラインから指定する場合は、
    <span class="prompt">to_link+=hoge.lib</span>として下さい。


- 2012/04/11 ver. 0.156(dmd2.058)

    ほぼ全面刷新。
    * いくつかのモジュールが、外部ライブラリ compo.lib にまとめられました。
      だからどうということもないんですが。
    * このドキュメントが <a href="http://www.doxygen.jp">Doxygen</a> を使うようにかわりました。


- 2010/08/20 ver. 0.155 dmd2.048

    style-xml ファイルにコメント`<!-- -->`入れても落ちなくなりました。
    依存関係に .di ファイルがあっても大丈夫になりました。


- 2010/05/27 ver. 0.154 dmd2.046

    style-xmlの標準化にむけて。


- 2010/05/18 ver. 0.153 dmd2.045

    -style.xmlファイルの標準化にむけて。
    `<make>` タグが `<style>` に、
    `<style>` タグが、`<environment>` に、
    `<style>` マクロが、`<env>` に変更されました。


- 2010/05/11 ver. 0.152 dmd2.045

    ライセンスが修正BSDから [CC0](http://creativecommons.org/choose/zero "CreativeCommons Zero License") に変更されました。


- 2010/05/06 ver. 0.151 dmd2.045

    マクロの名前がいくつか変更されました。


- 2010/05/01 ver. 0.150 dmd2.043

    コマンドライン引数として複数のDソースファイルを渡せるようになりました。
    互いに依存関係が疎なファイルを一つのライブラリにまとめたい時に使えます。
    `<add>` タグが追加されました。


- 2010/04/21 ver. 0.149 dmd2.043

    `<set>` タグ内で `<get>`タグが使用可能になりました。
    この時、`<get>`タグは、そのマクロが展開される時に評価されます。


- 2010/04/09 ver. 0.148 dmd2.042

    dll作成になんとなく対応。
    `<set>` タグ内で `<br>`、`<tab>`、`<ws>` タグが使用可能に。


- 2010/04/07 ver. 0.147 dmd2.042

    Dのソースファイルにimport宣言がないとパースに失敗してたバグを修正。


- 2010/03/15 ver. 0.146

    dmd2.041対応版。


- 2009/10/20 ver. 0.145

    dmd2.035対応版。
    make-sytle.xml内で行頭および行末の空白文字のみ削除されるように変更されました。


- 2009/09/19 ver. 0.144

    `<footer>`マクロを導入。
    Makefile中で `<get id="footer" />`以降に書かれたものは
    Makefileを作りなおしても残るようになりました。
    ここに、まあインストールコマンドとかを書いてもらえばよいかと。


- 2009/09/17 ver. 0.143

    `<style>`タグの `'make'` 属性を `'id'` と変更。
    `<ifndef>`タグを追加。
    make-style.xml を刷新。


- 2009/09/15 ver. 0.14

    オプションの指定方法変更。
    `<switch>` タグのかわりに、`<ifdef>` タグができました。
    なんかコロコロ変わるよなあ。


- 2009/09/14 ver. 0.132

    色々修正。っていうかMakefileの書き方まちがってました。
    `<add>` タグがなくなりました。


- 2009/09/12 ver. 0.131

    マクロのidは大文字、小文字に関係なくなりました。
    その他ちょっとしたバグとか修正。


- 2009/09/04 ver. 0.13

    dmd2.032リリースにあたってのバージョンアップ
    std.xmlのバグがなおったので、altstd.xmlは消去。
    std.getoptつかうのやめに。それにともなってオプションのスタイルとか色々変りました。
    make-style.xmlのバグ修正。


- 2009/09/01 ver. 0.12

    vwrite に対応。


- 2009/08/31 ver. 0.11

    改行コードが指定可能に。
    std.contractsを使うようにちょっとだけ変更。


- 2009/08/29 ver. 0.1

    ほんと *とりあえず* 公開。
