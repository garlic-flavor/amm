["summary": `Automatic Makefile Maker.
`,
"Version": `0.170(dmd2.071.0)
`,
"Date": "2016-Apr-11 21:08:01
",
"Authors": `KUMA
`,
"License": `CC0

`,
"Description:":`
This is a program that makes a Makefile from the source code wirtten in
D programmming language, automatically.



`,
"Acknowledgements:":`
amm is written by D.
Digital Mars D Programming Language(http://dlang.org/)

`,
"BUGS": `o An error will occur when any Japanese are in a delimited string.
  (on windows)


`,
"How to build:":`











`,
"How to use:":`
>amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d
options             | description
--------------------|--------------------
h help ?            | show this message.
macro_name          | define the macro named macro_name.
macro_name=value    | define the macro named macro_name as value.
m=Makefile          | set outputting Makefile's name.
                    | passing a file of '.mak' extension as argument is same.
root=path           | set the root file of this project.
                    | passing a file of '.d' extension as argument is same.
v=0.001             | set version description.
                    | for my vwrite.
help macro          | show pre-defined macros.


`,
"Previous Notice:":`
o amm will invoke dmd, ensure that dmd is ready.
o Put make-style.xml to where amm can find.
    The searching priority is,
    * Current directory.
    * The directory of the environment variable 'HOME'.
    * The directory where the amm is.
    * On Linux, ../etc/amm (related with where the amm is).



`,
"Example:":`
>amm root_file.d


With the above command, a Makefile will be generated in the current directory.
I assume that 'root_file.d' is a root file of the project, and that has main()
function.
If you want to make the target file name 'hoge.exe', do like this.
>amm root_file.d hoge.exe
When the argument starts with '-', it will be passed through to dmd.
>amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe
You can use macro for amm like this.
>amm v=1.0 gui root_file.d
The macro named 'v' is set as '1.0', and the macro named 'gui' is set as
'defined'.


Delete macro command is
>amm gui= root_file.d


In the default situation, directories that consist your project are assumed like
below.




`,
"COMMAND LINE ARGUMENTS:":`
o '/?' '-h' '-help'
  show help messages.
o 'help macro'
  show pre-defined macros.
o starts with '-L'.
  is treated as link option.
o starts with '-'.
  is treated as comple option.
o has any extensions.
  is treated as some kind of file.
    o '.d'
      is treated as a root file of the project.
    o '.exe'
      is treated as a target file name of the project. (on Windows)
    o '.dll'
      is treated as a target file name of the project, and the project is
      assumed that its target is dynamic link library.
    o '.lib'
      is treated as a static link library to be linked with your project.
      (on Windows)
    o '.def'
      is treated as a module definition file for DLL. (on Windows)
    o '.rc'
      is treated as a resource file. (on Windows)
    o '.xml'
      is treated as a setting file for amm, described below.
    o '.mak'
      is treated as a file name of the target Makefile.

o other
  is treated as a definition of a macro.
    o 'macro_name=hogehoge' sets the macro named 'macro_name' as
      'hogehoge'.
    o 'macro_name+=hogehoge' adds 'hogehoge' to the macro named
      'maco_name'.
    o 'macro_name' sets the macro named 'macro_name' as 'defined'.
    o 'macro_name=' removes the macro named 'macro_name'.




about_make-style.xml:
make-style.xml controls the generation of the Makefile.
In this file, you can
o output the string.
o set / add the string to the macro.
o retrieve the value from the macro, and do replacement.
o use ifdef / ifndef conditioning.



make-style.xml looks like below.


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
                <tab />dmd  -of$@ $**<br />

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



Valid_elements_in_make-style.xml:
o <style>
    root element.
    <environemnt> is an essential element.
o <head>
    No outputting occur in this element.
    You can use <set>, <and> and, <ifdef>, <ifndef>.
    <head> will be followed by an <environment> or a <body> element.
o <ifdef> <ifndef>
    An 'id' attribute of this element specify the condition.
    'id' is an essential attribute.
o <set>
    Its contents will be set to the macro named what is specified in the 'id'
    attrubute.
    When the macro already exists, the value will be over written.
    You can use <ws>, <br>, <tab> and <get> in this element.
    <get> is evaluated lazily.
    'id' is an essential attribute.
o <add>
    The value will be added to the macro.
    'id' is an essential attribute.
o <environment>
    This element exists for backward compatibility.
o <body>
    Outputting may occur.
    Strings are outputted to the Makefile as usual.
    Starting/Trailing spaces are removed.
    You can use <ws>, <tab>, <br>, <get>, <ifdef> and <ifndef>.
    Character Entity References are resolved by std.xml.
o <ws>
    Output ' '(space) to the Makefile. with 'length' attrubute, you can
    output sequential spaces.
o <tab>
    Output '\t'(tab) to the Makefile.
o <br>
    Output '\r\n'(on Windows)/'\n'(on linux).
    The Macro named 'bracket' controls this behavior.
    o bracket=rn, then outputting is '\r\n'
    o bracket=n, then outputting is '\n'
    o bracket=r, then outputting is '\r'

o <get>
    Expand the macro specified by 'id' attribute.
    With 'from' and 'to' attributes, a replacement will occur when the
    expansion.
    'id' is a essential attribute.


`,
"Predefined macros:":`



["bracket": ["rn", "n", "  specify newline characters.
    o 'rn' => CR+LF.
    o 'n' => LF.
    o 'r' => CR.
"],
"env": ["", "", "  This macro exists for backward compatibility."],
"exe_ext": [".exe", "", "  specify a extension of an executable file name."],
"obj_ext": [".obj", ".o", "  specify a extension of a object file name."],
"lib_ext": [".lib", ".a", "  specify a extension of a statically linked library file name."],
"gen_deps_command": ["dmd -c -op -o- -debug", "dmd -c -op -o- -debug", "  specify the command that invokes dmd to resolve your project's dependencies."],
"deps_file": ["tempdeps", "tempdeps", "  specify the file name of the target of 'gen_deps_command'."],
"m": ["Makefile", "Makefile", "  specify the name of the Makefile."],
"root": ["", "", "  specify the file name of root file of your project.
  When a file that has '.d' as its extension is passed as a command line
  argument"],
"compile_flag": ["", "", "  specify compile flags for dmd.
  When a command line argument for amm starts with '-'"],
"link_flag": ["", "", "  specify link flags for dmd
  When a command line argument for amm starts with '-L'"],
"target": ["", "", "  specify the target file name of your project.
  On Windows"],
"dependencies": ["", "", "  Amm will set this value."],
"to_compile": ["", "", "  Amm will set this value."],
"to_link": ["", "", "  Amm will set this value."],
"rc_file": ["", "", "  On Windows"],
"def": ["", "", "  On Windows"],
"ddoc": ["", "", "  On Windows"],
"dd": ["doc", "doc", "  specify the target directory of DDOC(http://dlang.org/spec/ddoc.html)."],
"libs": ["", "", "  specify libraries names to link.
  Amm will gather names form the directory specified by the macro named
  'lib'."],
"imp": ["", "", "  specify the directory that contains the files to be imported by your project.
  The default value is 'import'."],
"lib": ["", "", "  specify the directory that contains the file to be linked by your project.
  The default value is 'lib'."],
"i": ["", "", "  Amm will set this value.
  this is same as -I option for dmd."],
"is_dll": ["", "", "  specify whether the target of your project is dynamic link library."],
"is_lib": ["", "", "  specify whether the target of your project is static link library."],
"verbose": ["", "", "verbose"],
"q": ["", "", "  controls the verboseness of amm."],
"footer": ["## generated by amm.", "## generated by amm.", "  specify the 'footer mark' of the Makefile.
  Amm will overwrite the Makefile. but"],
"style_file": ["", "", "  specify the setting file name.
  The default value is 'make-style.xml'."],
"v": ["", "", "v"],
"authors": ["", "", "authors"],
"license": ["", "", "  specify the description about your project."],
"date": ["", "", "  Amm will set this value as today."],
"remake_command": ["", "", "  The command line arguments that invoked amm is set to the value."],
"src": ["src", "src", "  Amm set command line argument that starts with '-I' to this value.
  This value is used to decide that the root directory of source files
  to be compiled."],
"is_vclinker": ["", "", "  If true"],
"dll_ext": [".dll", ".so", "  the extension of a Dynamic Linked Library.
  when a file with this extension is in the arguments"],
"mak_ext": [".mak", ".mak", "  the extension of Makefile.
  when a file with this extension is in the arguments"],
"src_ext": [".d", ".d", "  The extension of a source file.
  When a file with this extension is in the arguments"],
"rc_ext": [".rc", ".rc", "  The extension of a resource file.
  When a file with this extension is in the arguments"],
"rc": ["", "", "  Resource files are set to this value.
  Windows only."],
"def_ext": [".def", ".def", "  the extension of a module definition file of D.
  when a file with this extension is in the arguments"],
"ddoc_ext": [".ddoc", ".ddoc", "  The extension of a file for ddoc.
  when a file with this extension is in the arguments"],
"xml_ext": [".xml", ".xml", "  the extension of STYLE_FILE.
  when a file with this extension is in the arguments"],
"style": ["make-style.xml", "make-style.xml", "  STYLE_FILE controls the output.
  when a file with '.xml' extension is in the arguments"],




 "":[""]]

`,
"Licensed under:":`
Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)

`,
"Development environment:":`
o Windows Vista(x64) x dmd 2.071.0 x make (of Digital Mars)
o Ubuntu 15.10(x64) x gcc 5.2.1 x dmd 2.071.0 x GNU Make


`,
"History": `
o 2016/04/11 ver. 0.170(dmd2.071.0)
    o bug fix about string import.

o 2016/02/28 ver. 0.169(dmd2.070.0)
    o README.md is generated by ddoc.
    o Pre-defined macros and its default values are generated by ddoc.

o 2015/12/22 ver. 0.168(dmd2.069.2)
    o add English README.md.
    o some bug fix on linux.








これはD言語で書かれたソースコードから Makefile を自動生成するプログラムです。


`,
"謝辞:":`
amm は D言語で書かれています。
Digital Mars D Programming Language(http://dlang.org/)

`,
"BUGS": `o 
o ヒアドキュメント、q"DELIMITER hoge-hoge...  DELIMITER" である(不明)パターンになると、"Error: Outside Unicode code space"


`,
"ビルド方法:":`











`,
"使い方:":`
>amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d


options             | description
--------------------|--------------------
h help ?            | ヘルプを表示します。
macro_name          | マクロを定義済みとします。
macro_name=value    | マクロに値を設定します。
m=Makefile          | 出力される Makefile のファイル名を指定します。
                    | 拡張子、'.mak' のファイルを渡しても可
root=path           | ルートとなるソースファイルを指定します。
                    | 拡張子、'.d' のファイルを渡しても可
v=0.001             | ヴァージョン文字列を指定します。数字以外も指定できます。
                    | 拙著の vwrite.exe 向けです。
help macro          | 定義済みマクロを一覧表示します。


`,
"事前に:":`
o dmd へパスを通し、使える状態にしておいて下さい。
o amm.exe へのパスを通して下さい。
o 同梱の make-style.xml を amm.exe が探せる位置において下さい。
  make-style.xml は以下の順に探されます。
    * amm.exe を実行するフォルダ
    * 環境変数 HOME のフォルダ
    * amm.exe と同じフォルダ
    * linux上では amm のあるフォルダから見て ../etc/amm。



`,
"簡単な使い方:":`
>amm root_file.d


でカレントフォルダに Makefile ができます。


ここで、root_file.d としているのは、プロジェクトのルートとなるファイル
(実行形式のファイルがターゲットとなる場合は、一般的に main() 関数を含むファイル) です。


初期状態では色々と変なことになると思うので、make-style.xml をいじって自分の環境に合わせてみて下さい。


実行ファイル名を hoge.exe とするには、
>amm root_file.d hoge.exe


とします。
>amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe


'-'(ハイフン)で初まる引数は、dmd へそのまま引き渡されます。


以降で説明する、make-style.xml 内で使用されるマクロを設定するには、
>amm v=1.0 gui root_file.d


これで、マクロ名 "v" に、文字列 "1.0" が、マクロ名 "gui" に、文字列 "defined" が設定されます。


既存のマクロを削除するには、
>amm gui= root_file.d


とします。


初期状態では、フォルダの構成が以下のような環境が想定されています。




`,
"コマンドライン引数:":`
o '-h' '-help' '/?'
  ヘルプメッセージを出力します。
o 'help macro'
  定義済みマクロ一覧を表示します。
o '-L' で始まるもの
  リンカへのオプションとみなされ、リンク時に dmd へと引き渡されます。
o それ以外で、'-'(ハイフン)で始まるもの
  コンパイル時に dmd へと引き渡されます。
o 拡張子があるもの。(std.path.extension にヒットするもの)
  ファイル名として解釈されます。
    o '.d'
      ソースコードのルートとなるファイルとして扱われます。
      複数のファイルを渡すこともできます。
    o '.exe'
      ターゲットのファイル名として扱われます。
    o '.dll'
      ターゲットのファイル名として扱われます。
    o '.lib'
      ターゲットのファイル名として扱われます。
リンクするライブラリとしては扱われない* ので注意が必要です。


      リンクするライブラリを指定する場合は、
      to_link+=hoge.lib
      とします。
    o '.def'
      dll を作る際に参照されます。
    o '.rc'
      Windows 用のリソースファイルとして認識されます。
    o '.xml'
      後述する設定ファイルとして読み込まれます。
    o '.mak'
      Makefile のファイル名

o それ以外
  後述の make-style.xml 内で参照されるマクロとして扱われます。
    o 'macro_name=hogehoge' でマクロに値を設定できます。
    o 'macro_name+=hogehoge' 複数設定可能なマクロには値を追加することができ
         ます。
    o 'macro_name' 値を指定しなかった場合は 'defined' が格納されます。
    o 'macro_name=' とすると、マクロを削除できます。



設定ファイル_make-style.xml:
設定ファイルは xml で記述されています。
Makefile の出力を制御します。


設定ファイル内では、
o 文字列をそのまま Makefile へ出力
o マクロへ文字を設定、追加
o マクロの文字を展開、置換して展開、して Makefile へ出力
o マクロの存在による分岐



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
                <tab />dmd  -of$@ $**<br />

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


コマンドライン引数 'gui' を設定したことによって、コンパイルオプション、リンクオプションが追加されています。


最後の行の ## generated by amm. はフッタとしてマクロに登録されたものです。
例えばインストールコマンド等、フッタ以降に手動で記入したものは、amm.exe を再度実行し、
Makefile を作り直しても残ります。


行頭、行末の空白文字は省かれます。
それ以外の空白文字はそのまま出力されます。


行頭にタブを出力する場合は、<tab /> を使用して下さい。



`,
"設定ファイルで利用可能なタグ:":`
o <style>
  ルートタグ。
  <environment> が必須要素
o <head>
  マクロへの値の設定は、この中で行います。
  <set> タグ、<add> タグ及び、<ifdef>、<ifndef> タグが使用可能です。
  <head> タグは、<style> 要素の中で、<environment> 要素の前か、
  <environment> 要素の中で、 <body> 要素の前に置くことができます。
o <ifdef>
  'id' 属性で指定した名前のマクロが登録されていた場合、要素の内容が反映されま
  す。
  'id' 属性が必須属性です。
o <ifndef>
  <ifdef> の反対。
o <set>
  内容が 'id' 属性で指定した名前で、マクロへ登録されます。
  マクロが既に存在する場合は、それを上書きします。
  この要素の内容には、<ws> タグ、<br> タグ、<tab> タグ及び、<get> タグを
  含めることができます。
  <get> タグは、現在のマクロが展開されるときに評価されます。
  'id' 属性が必須属性です。
o <add>
  <set> とはちがい、値を追加します。
o <environment>
  <environment> タグは複数書くことができます。
  事前に、'env' という名前でマクロが登録されていると、
  <environment> タグの 'id' 属性の値とマッチしたものが評価されます。
  'env' マクロが存在しない場合は、最初の <environment> が評価されます。
  'id' 属性が必須属性です。
  <body> 要素が必須要素です。
o <body>
  この要素内の、タグ以外のテキストはそのまま Makefile へ出力されます。
  行頭、行末の空白文字は消去されます。それ以外の空白はそのまま残されます。
  この要素の内容には、<ws> タグ、<tab> タグ、<br> タグ、<get> タグ及び、
  <ifdef>、<ifndef>
  タグを含めることが出来ます。
  文字実体参照は std.xml によって変換されます。
o <ws>
  Makefileに ' '(スペース)を出力します。'length' 属性を指定すれば、連続した
  空白を出力できます。
o <tab>
  タブ文字を出力します。
o <br>
  改行を出力します。
  初期状態では、CR+LF を出力しますが、これは事前に、'bracket' という名前で
  マクロを登録しておくことで
  変更できます。
  bracket=rn で CR+LFに、
  bracket=n で LF に、
  bracket=r で CR に設定されます。
o <get>
  'id' 属性の名前で登録されているマクロの値を展開します。
  未登録のマクロを指定した場合はなにも出力されません。
  'from' 属性と 'to' 属性を指定すると、std.array.replace による置換を適用
  できます。
  'id' 属性が必須属性です。


`,
"定義済みマクロ:":`



["bracket": ["rn", "n", "  改行コードを指定する。
    o 'rn' で CR+LFに、
    o 'n' で LF に、
    o 'r' で CR に、設定されます。
"],
"env": ["", "", "  現在は使用していません。"],
"exe_ext": [".exe", "", "  実行形式ファイルの拡張子。拡張子には '.'(ドット) を含める。"],
"obj_ext": [".obj", ".o", "  オブジェクトファイルの拡張子"],
"lib_ext": [".lib", ".a", "  ライブラリファイルの拡張子"],
"gen_deps_command": ["dmd -c -op -o- -debug", "dmd -c -op -o- -debug", "  dmd にファイルの依存関係を解決させる為のコマンド。
  'gen_deps_command' ~ 'compile_flag' ~ 'root_file'
  で実行される。
  このコマンドの 'tempdeps' の部分は、次項のマクロ 'deps_file' の値と一致
  している必要がある。"],
"deps_file": ["tempdeps", "tempdeps", "  'gen_deps_command' により生成されるファイル名。
  amm.exe 終了時にこのファイルを消去する。"],
"m": ["Makefile", "Makefile", "  生成される Makefile の名前"],
"root": ["", "", "  プロジェクトのルートになるファイル名。
  ターゲットがライブラリの場合など、互いに疎なソースファイルを扱えるように、複数
  のファイルを登録できる。
  コマンドラインから、拡張子が '.d' のファイルを指定すると、このマクロに追加
  される。"],
"compile_flag": ["", "", "  dmd に渡されるコンパイルオプション。
  コマンドライン引数のうち、'-'(ハイフン) で始まる引数がここに登録される。"],
"link_flag": ["", "", "  dmd に渡されるリンクオプション。
  コマンドライン引数のうち、'-L' で始まる引数がここに登録される。"],
"target": ["", "", "  プロジェクトのターゲット。
  コマンドライン引数のうち、拡張子が、'.exe'、'.dll' のものがここに登録
  される。"],
"dependencies": ["", "", "  解決された依存関係が格納される。"],
"to_compile": ["", "", "  コンパイルされるべきファイルが格納される。"],
"to_link": ["", "", "  リンクされるべきファイルが格納される。"],
"rc_file": ["", "", "  リソースファイル名。コマンドライン引数のうち、拡張子が、'.rc' のものが登録
  される。"],
"def": ["", "", "  コマンドライン引数のうち、拡張子が、'.def' のものが登録される。"],
"ddoc": ["", "", "  コマンドライン引数のうち、拡張子が、'.ddoc' のものが登録される。"],
"dd": ["doc", "doc", "  DDOC ファイルの出力ディレクトリ"],
"libs": ["", "", "  ライブラリファイル名が格納される。
  'ext_lib_directory' に登録されたディレクトリ下にある、'lib_ext' を持つ
  ファイルが格納される。"],
"imp": ["import", "import", "  インポートファイルを含むルートディレクトリ。
  このフォルダに含まれているファイルはコンパイルされない。"],
"lib": ["lib", "lib", "  リンクするファイルを含むルートディレクトリ。"],
"i": ["", "", "imp_root ~ ';' ~ root
  dmd の -I オプションになる。"],
"is_dll": ["", "", "  ターゲットが .dll だったとき、defined となる。"],
"is_lib": ["", "", "  ターゲットが .lib だったとき、defined となる。"],
"verbose": ["", "", "verbose"],
"q": ["", "", "  実行時の出力を調整する。"],
"footer": ["## generated by amm.", "## generated by amm.", "  Makefile 内でここに指定された文字列より後に書かれたものは、amm.exe を再度実行
  しても残る。"],
"style_file": ["make-style.xml", "make-style.xml", "  設定ファイルを指定する。
  コマンドライン引数のうち、拡張子が '.xml' のものが登録される。
  登録されたファイルは、以下の順で探される。
      * 実行時のカレントフォルダ
    * 環境変数 HOME で指定したフォルダ
    * amm.exe のあるフォルダ
  "],
"v": ["", "", "v"],
"authors": ["", "", "authors"],
"license": ["", "", "    プロジェクトのバージョン情報。"],
"date": ["", "", "    amm が設定する。"],
"remake_command": ["", "", "  amm を起動した時のコマンドが登録される。"],
"src": ["src", "src", "  コマンドライン引数のうち、'-Ixxx;yyy;zzz' のような形で指定されたものが
  ここに登録される。
  ソースファイル探索のルートフォルダを決定する。"],
"is_vclinker": ["", "", "  VCのリンカを参照する場合。"],
"dll_ext": [".dll", ".so", "  Dynamic Link Library ファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、amm によって生成
  される Makefile のターゲットファイルとして、マクロ名 'TARGET' の値にファイル
  が登録される。
  また、ターゲットファイルが DLL であることを示す、マクロ 'IS_DLL' が定義
  される。"],
"mak_ext": [".mak", ".mak", "  Makefile の拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'M'
  の値としてファイルが登録される。"],
"src_ext": [".d", ".d", "  ソースファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'ROOT'
  の値としてファイルが登録され、プロジェクトの依存関係を解決するための
  ルートファイル として扱われる。
  また、マクロ名 'TARGET' が指定されなかった場合は、ROOT + EXE_EXT が
  マクロ名 'TARGET' に設定される。"],
"rc_ext": [".rc", ".rc", "  リソースファイルの拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'RC'
  の値としてファイルが登録される。"],
"rc": ["", "", "  リソースファイル。
  コマンドライン引数のうち、マクロ名 'RC_EXT' に登録された拡張子を持つファイル
  がここに登録される。"],
"def_ext": [".def", ".def", "  D言語の module definition file の拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、マクロ名 'DEF'
  の値としてファイル登録される。"],
"ddoc_ext": [".ddoc", ".ddoc", "  DDOCファイルの拡張子
  このマクロの値として設定された拡張子を持つファイル名をコマンドライン引数
  として渡すと、マクロ名 'DDOC' の値としてファイルが登録される。"],
"xml_ext": [".xml", ".xml", "  amm の設定ファイルの持つ拡張子。
  この拡張子を持つファイル名をコマンドライン引数として渡すと、
  マクロ名 'STYLE_FILE' の値としてファイルが登録される。"],
"style": ["make-style.xml", "make-style.xml", "  Makefile の出力を決定する設定ファイル。
  コマンドライン引数に拡張子が '.xml' のファイルを渡すとこのマクロに設定
  される。"],
 "":[""]]

`,
"ライセンス:":`
Creative Commons Zero License(http://creativecommons.org/publicdomain/zero/1.0/)

`,
"ToDo:":`
o ( 2012/10/25 ver. 0.163 にて対応)
o ( 2012/10/25 ver. 0.163 にて対応)


`,
"開発環境:":`
現在、
o Windows Vista(WoW64) x dmd2.071.0 x (dmdに付属の)make
o Ubuntu 15.10(x64) x gcc 5.2.1 x dmd2.071.0 x GNU Make

の組み合わせで実行を確認しています。
付属の amm.exe は x64 Windows 用のバイナリです。

`,
"履歴:":`
o 2016/04/11 ver. 0.170(dmd2.071.0)
    o 文字列インポートに関するバグフィクス

o 2016/02/28 ver. 0.169(dmd2.070.0)
    o README.md を ddoc で生成するように。
    o 定義済みマクロとその初期値を ddoc で生成するように。

o 2015/12/22 ver. 0.168(dmd2.069.2)
    o 英語版README.md追加。
    o linux上でのバグフィクス

o 2015/12/06 ver. 0.167(dmd2.069.2)
  std.process がらみの deplication に対応。
  ソースのインデントをタブからスペースに。(dmdのソースに準拠すべく。)
o 2014/06/28 ver. 0.166(dmd2.065)
  バグフィクス
o 2013/03/02 ver. 0.165(dmd2.064)
  linux 上で make-style.xml を探せないバグを修正。
  -inline で無限ループするバグは根気不足が原因だったかもしれん。
o 2012/10/28 ver. 0.164(dmd2.060)
  コンソールへの出力まわりを若干変更
o 2012/10/25 ver. 0.163(dmd2.060)
  linux になんとなく対応。
o 2012/10/11 ver. 0.162(dmd2.060)
  ディレクトリの評価まわりのバグフィクス。
  make-style.xml の修正。
o 2012/10/11 ver. 0.161(dmd2.060)
  いろいろ変更。
      o ヘルプを日本語に。
    o help macro でマクロの一覧出せるように。
    o .lib のファイル渡すとリンクするライブラリという判断になりました。
      やっぱ不便やからね。
    o マクロ project なくなりました。不便。
    o マクロ install_directory なくなりました。いらん。
    o .mak のファイルを渡すと Makefile の名前となるように。
    o あとちょこちょこマクロの名前変わってます。
  
o 2012/10/10 ver. 0.160(dmd2.060)
  github デビュー。
  それにともなって、Doxygen 使うのやめに。
  あと、compo.lib にまとめるのはやめて、ソースコード展開しました。
o 2012/10/09 ver. 0.159(dmd2.060)
  dll 作成時の出力を変更
o 2012/06/07 ver. 0.158(dmd2.059)
  public import の依存を解決
o 2012/04/15 ver. 0.157(dmd2.059)
  compo.lib を若干修正
  コマンドラインからマクロを設定する際、後に書いたものが有効になるように変更。
  拡張子が ".lib" のファイルを渡した場合、これまではリンクすべき
  ライブラリファイルと判断されていましたが、
  出力ターゲットがライブラリファイルである。と認識されるようになりました。
  リンクすべきライブラリファイルをコマンドラインから指定する場合は、
  <span class="prompt">to_link+=hoge.lib</span>として下さい。
o 2012/04/11 ver. 0.156(dmd2.058)
  ほぼ全面刷新。
      o いくつかのモジュールが、外部ライブラリ compo.lib にまとめられました。
      だからどうということもないんですが。
    o このドキュメントが Doxygen(http://www.doxygen.jp)
      を使うようにかわりました。
  
o 2010/08/20 ver. 0.155 dmd2.048
  style-xml ファイルにコメント<!-- -->入れても落ちなくなりました。
  依存関係に .di ファイルがあっても大丈夫になりました。
o 2010/05/27 ver. 0.154 dmd2.046
  style-xmlの標準化にむけて。
o 2010/05/18 ver. 0.153 dmd2.045
  -style.xmlファイルの標準化にむけて。
      o <make> タグが <style> に、
    o <style> タグが、<environment> に、
    o <style> マクロが、<env> に変更されました。
  
o 2010/05/11 ver. 0.152 dmd2.045
  ライセンスが修正BSDから CreativeCommons Zero License(http://creativecommons.org/choose/zero) に変更されました。
o 2010/05/06 ver. 0.151 dmd2.045
  マクロの名前がいくつか変更されました。
o 2010/05/01 ver. 0.150 dmd2.043
  コマンドライン引数として複数のDソースファイルを渡せるようになりました。
  互いに依存関係が疎なファイルを一つのライブラリにまとめたい時に使えます。
  <add> タグが追加されました。
o 2010/04/21 ver. 0.149 dmd2.043
  <set> タグ内で <get>タグが使用可能になりました。
  この時、<get>タグは、そのマクロが展開される時に評価されます。
o 2010/04/09 ver. 0.148 dmd2.042
  dll作成になんとなく対応。
  <set> タグ内で <br>、<tab>、<ws> タグが使用可能に。
o 2010/04/07 ver. 0.147 dmd2.042
  Dのソースファイルにimport宣言がないとパースに失敗してたバグを修正。
o 2010/03/15 ver. 0.146
  dmd2.041対応版。
o 2009/10/20 ver. 0.145
  dmd2.035対応版。
  make-sytle.xml内で行頭および行末の空白文字のみ削除されるように変更されました。
  
o 2009/09/19 ver. 0.144
  <footer>マクロを導入。
  Makefile中で <get id="footer" />以降に書かれたものは
  Makefileを作りなおしても残るようになりました。
  ここに、まあインストールコマンドとかを書いてもらえばよいかと。
o 2009/09/17 ver. 0.143
  <style>タグの 'make' 属性を 'id' と変更。
  <ifndef>タグを追加。
  make-style.xml を刷新。
o 2009/09/15 ver. 0.14
  オプションの指定方法変更。
  <switch> タグのかわりに、<ifdef> タグができました。
  なんかコロコロ変わるよなあ。
o 2009/09/14 ver. 0.132
  色々修正。っていうかMakefileの書き方まちがってました。
  <add> タグがなくなりました。
o 2009/09/12 ver. 0.131
  マクロのidは大文字、小文字に関係なくなりました。
  その他ちょっとしたバグとか修正。
o 2009/09/04 ver. 0.13
  dmd2.032リリースにあたってのバージョンアップ
  std.xmlのバグがなおったので、altstd.xmlは消去。
  std.getoptつかうのやめに。それにともなってオプションのスタイルとか色々変り
  ました。
  make-style.xmlのバグ修正。
o 2009/09/01 ver. 0.12
  vwrite に対応。
o 2009/08/31 ver. 0.11
  改行コードが指定可能に。
  std.contractsを使うようにちょっとだけ変更。
o 2009/08/29 ver. 0.1
  ほんと とりあえず 公開。
`,

"": ""]
