
# Automatic Makefile Maker

__Version:__0.172(dmd2.085.0)
__Date:__ 2019-Apr-1
__Authors:__ KUMA
__License:__ CC0

## Description
This is a program that makes a Makefile from source codes written in D programming language, automatically.

## Acknowledgements
AMM is written with D.
[Digital Mars D Programming Language](http://dlang.org/)

AMM depends on Mofile as a submodule.
[Mofile](https://github.com/FreeSlave/mofile.git)

## BUGS
- An error will occur when any Japanese are in a delimited string. (on windows)

## How to build

### on Windows
Please build with the make tool distributed with dmd.

#### 32bit

    >make -f win.mak release

#### 64bit

    >make -f win.mak release FLAG=-m64

### on linux

    >make -f linux64.mak release

## How to use

    >amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d

option        | description
--------------|-----------
-lang **      | Specify the language. The default value is taken from an environment variable named 'LANG'.
-verbose      | Set output policy as 'VERBOSE'.
-quiet -q     | Set output policy as 'quiet'.
other options | are passed to dmd.
name+=value   | Append 'value' to the macro named 'name'.
name=value    | Set 'value' to the macro named 'name'.
name          | Set the macro named 'name' as 'defined'.


### How files in command line arguments are treated as,
- `.d` is treated as a root file of the project.
- `.exe` is treated as a target file name of the project. (on Windows)
- `.dll` is treated as a target file name of the project, and the project is assumed that its target is a dynamic link library.
- `.lib` is treated as a static link library to be linked with your project. (on Windows)
- `.def` is treated as a module definition file for DLL. (on Windows)
- `.rc` is treated as a resource file. (on Windows)
- `.xml` is treated as a setting file for amm, described below.
- `.mak` is treated as a file name of the target Makefile.

## Previous Notice
- amm will invoke dmd. Ensure that dmd is ready.
- Put make-style.xml where amm can find. The searching priority is,
    1. Current directory.
    1. The directory of environment variable 'HOME'.
    1. The directory where amm is.
    1. On Linux, `../etc/amm` (relative path from where amm is).

## Example

    >amm root_file.d
With the above command, a Makefile will be generated in the current directory.
I assumed that 'root_file.d' is a root file of the project, and that has `main()`function.
If you want to make the target file name 'hoge.exe', do like this.

    >amm root_file.d hoge.exe
When the argument starts with '-', it will be passed to dmd.

    >amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe
You can set a macro for amm like this.

    >amm v=1.0 gui root_file.d
Now, the macro named `'v'` is set as `'1.0'`, and the macro named `'gui'` is set as `'defined'`.
To Delete a macro command, do

    >amm gui= root_file.d
By the default setting, directories that consist your project are assumed like below.

    -- project --+                             <-where amm.exe will be invoked in.
                 |
                 |- target.exe                 <-where the target file will be generated to.
                 |- Makefile                   <-
                 |
                 |-- src    --+
                 |            |- source files  <-files that will be compiled.
                 |            |- ...
                 |
                 |-- import --+
                 |            |- import files  <-files that will be imported.
                 |            |- ...
                 |
                 |-- lib    --+
                 |            |- libraries     <-file that will be linked.
                 |            |- ...
                 |
                 |-- lib64  --+
                 |            |- libraries     <-file that will be linked.
                 |            |- ...

## About make-style.xml
`make-style.xml` controls the generation of Makefile. In this file, you can
- output strings.
- set / add a string to a macro.
- retrieve a value from a macro, and do a simple replacement.
- use ifdef / ifndef conditioning.

`make-style.xml` looks like below.
```xml
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

```
With above make-style.xml, and with the command below,

    >amm gui test.d
the Makefile that is going to be generated will be like below.
```
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

```

### Valid elements in make-style.xml
- `<style>` is a root element. `<body>` is an essential element in this.
- `<head>` is an element for preparation. Nothing is output. You can use `<set>`, `<add>` and, `<ifdef>`, `<ifndef>`. `<head>` will be followed by a `<body>` element.
- `<ifdef>` or `<ifndef>` has an `'id'` attribute. `'id'` specify its condition. `'id'` is an essential attribute.
- `<set>`'s contents are set to the macro specified by the `'id'` attribute. When the macro already exists, the value will be over written. You can use `<ws>`, `<br>`, `<tab>` and `<get>` in this element. `'id'` is an essential attribute.
- `<add>` adds its contents to the macro. `'id'` is an essential attribute.
- `<body>` is an element for output. Strings are simply outputted. Starting/Trailing spaces of each line are removed. You can use `<ws>`, `<tab>`, `<br>`, `<get>`, `<ifdef>` and `<ifndef>`. any Character Entity References are resolved by std.xml.
- `<ws>` outputs `' '`(space) to the Makefile. With `'length'` attribute, you can output sequential spaces.
- `<tab>` outputs `'\t'(tab)` to the Makefile.
- `<br>` outputs `'\r\n'(on Windows)`/`'\n'(on linux)`. The Macro named `'bracket'` controls this behavior.
    - `bracket=rn` is `'\r\n'`
    - `bracket=n` is `'\n'`
    - `bracket=r` is `'\r'`
- `<get>` expands the macro specified by `'id'` attribute. With `'from'` and `'to'` attributes, a replacement will occur when expanding. `<get>` is evaluated lazily. `'id'` is an essential attribute.

## Predefined macros
The values specified by command line have highest priority. The name of macro is case IN-sensitive.

name             | default value         | description
-----------------|-----------------------|-----------
bracket          | rn                    | consists of newline characters. `'rn'` means CR+LF. `'n'` means LF. `'r'` means CR.
env              |                       | This macro exists for backward compatibility.
exe_ext          | .exe                  | consists of an extension of an executable file name.
obj_ext          | .obj                  | consists of an extension of a object file name.
lib_ext          | .lib                  | consists of an extension of a statically linked library file name.
gen_deps_command | dmd -c -op -o- -debug | consists of the command that invokes dmd to resolve your project's dependencies.
deps_file        | tempdeps              | consists of the file name of the target of `'gen_deps_command'`.
m                | Makefile              | consists of the name of the Makefile.
root             |                       | consists of the file name of a root file of your project. When a file name having `'.d'` as its extension is passed as a command line argument, the file name will be set to this macro.
compile_flag     |                       | consists of compile flags for dmd. When a command line argument starts with `'-'`, the argument will be set to this macro.
link_flag        |                       | consists of link flags for dmd. When a command line argument for amm starts with `'-L'`, the argument will be set to this macro.
target           |                       | consists of the target file name of your project. On Windows, when a file name having `'.exe'` or `'.dll'` as its extension is passed as a command line argument, the file name will be set to this macro.
dependencies     |                       | Amm will set this value.
to_compile       |                       | Amm will set this value.
to_link          |                       | Amm will set this value.
rc_file          |                       | On Windows, when a file that has `'.rc'` as its extension is passed as a command line argument, the file name will be set to this macro.
def              |                       | On Windows, when a file that has `'.def'` as its extension is passed as a command line argument, the file name will be set to this macro.
ddoc             |                       | when a file that has `'.ddoc'` as its extension is passed as a command line argument, the file name will be set to this macro.
dd               | doc                   | consists of the target directory of DDOC.
libs             |                       | consists of libraries names to link. Amm will gather files form the directory specified by the macro named `'lib'`.
imp              | import                | consists of the directory that contains files to be imported by your project.
lib              | lib                   | consists of the directory that contains the file to be linked by your project.
i                | imp_root ~ ';' ~ root | Amm will set this value. This is same as `-I` option for dmd.
is_dll           |                       | mark whether the target of your project is dynamic link library.
is_lib           |                       | mark whether the target of your project is static link library.
verbose          |                       | controls the verboseness of amm.
q                |                       | controls the verboseness of amm.
footer           | ## generated by amm.  | consists of the 'footer mark' of the Makefile. Amm will overwrite the Makefile but, contents after this mark will remain.
style_file       | make-style.xml        | consists of the setting file name.
v                |                       | specify the description about your project.
authors          |                       | specify the description about your project.
license          |                       | specify the description about your project.
date             |                       | Amm will set this value as today.
remake_command   | amm.exe               | consists of the command line arguments that invoked amm.
src              | src                   | command line arguments that starts with '-I' is set to this value. This value is used to decide that the root directory of source files to be compiled.
is_vclinker      |                       | If 'defined', dmd will invoke the linker of Microsoft.
dll_ext          | .dll                  | consists of the extension of a Dynamic Linked Library. when a file with this extension is in the arguments, the file will be regarded as TARGET, and the macro 'IS_DLL' is defined.
mak_ext          | .mak                  | consists of the extension of Makefile. when a file with this extension is in the arguments, the file will be regarded as Makefile.
src_ext          | .d                    | consists of the extension of source file. When a file with this extension is in the arguments, the file will be regarded the root file of the project. and the file will be set to the value of the macro 'ROOT'. When the value of macro 'TARGET' is undefined, the value of the macro will be set as 'ROOT' + 'EXE_EXT'.
rc_ext           | .rc                   | consists of the extension of a resource file. When a file with this extension is in the arguments, the file will be set to the value of the macro 'RC'. Windows only.
rc               |                       | consists of resource files. Windows only.
def_ext          | .def                  | consists of the extension of a module definition file of D. when a file with this extension is in the arguments, the file will be regarded as module definition file.
ddoc_ext         | .ddoc                 | consists of the extension of a file for ddoc. when a file with this extension is in the arguments, the file will be regarded as for ddoc.
xml_ext          | .xml                  | consists of the extension of STYLE_FILE. when a file with this extension is in the arguments, the file will be regarded STYLE_FILE.
style            | make-style.xml        | STYLE_FILE controls output.


## Licensed under
[Creative Commons Zero License](http://creativecommons.org/publicdomain/zero/1.0/)

## Development environment
- Windows Vista(x64) x dmd 2.084.0 x make (of Digital Mars)
- Ubuntu 15.10(x64) x gcc 5.2.1 x dmd 2.084.0 x GNU Make

## History
- 2018/04/01 ver. 0.172(dmd2.085.0)
    - Implement japanese l10n.
- 2018/03/21 ver. 0.171(dmd2.085.0)
    - Implement i18n.
    - add mofile(https://github.com/FreeSlave/mofile.git) as submodule.
    - add sworks.base.mo
    - add sworks.base.getopt
    - add sworks.base.readmegen
    - add readme.d
- 2016/04/11 ver. 0.170(dmd2.071.0)
    - bug fix about string import.
- 2016/02/28 ver. 0.169(dmd2.070.0)
    - README.md is generated by ddoc.
    - Pre-defined macros and its default values are generated by ddoc.
- 2015/12/22 ver. 0.168(dmd2.069.2)
    - English README.md is added.
    - some bug fix on linux.
- 2015/12/06 ver. 0.167(dmd2.069.2)
    - fix deprecated about std.process.
    - replace a tab with 4-spaces.
- 2014/06/28 ver. 0.166(dmd2.065)
    - some bug fix.
- 2013/03/02 ver. 0.165(dmd2.064)
    - fix a bug that amm can't find a make-style.xml on linux.
- 2012/10/28 ver. 0.164(dmd2.060)
    - refine the style of output.
- 2012/10/25 ver. 0.163(dmd2.060)
    - Now, amm can build on linux.
- 2012/10/11 ver. 0.162(dmd2.060)
    - fix a bug about directory evaluation.
    - rewrite make-style.xml.
- 2012/10/11 ver. 0.161(dmd2.060)
    - Add japanese help messages.
    - `help macro` command line option shows the list of macros.
    - A `.lib` file is treated as a library to be linked with the project.
    - `project` macro removed.
    - `install_directory` macro removed.
    - A `.mak` file is treated as a name of Makefile.
    - Some macros are renamed.
- 2012/10/10 ver. 0.160(dmd2.060)
    - Amm is on github.
    - Doxygen were purged.
    - `compo.lib` was expanded.
- 2012/10/09 ver. 0.159(dmd2.060)
    - fix a bug when the target is a dll.
- 2012/06/07 ver. 0.158(dmd2.059)
    - fix a bug about `public import`
- 2012/04/15 ver. 0.157(dmd2.059)
    - fix some bugs about compo.lib
    - more latter arguments have higher priority.
    - A `.lib` file is treated as the target name of the project. To add libraries to be linked, use `to_link+=hoge.lib`.
- 2012/04/11 ver. 0.156(dmd2.058)
    - whole brushing up.
    - some modules were integrated as `compo.lib`.
    - Now, amm depends on Doxygen http://www.doxygen.jp.
- 2010/08/20 ver. 0.155 dmd2.048
    - fix a bug halting when `<!-- -->` is inside style-xml file.
    - fix a bug when some modules depend on `.di`.
- 2010/05/27 ver. 0.154 dmd2.046
    - Standardize style-xml.
- 2010/05/18 ver. 0.153 dmd2.045
    - Standardize style-xml.
    - `<make>` element was renamed to `<style>`.
    - `<style>` element was renamed to `<environment>`.
    - `style` macro was renamed to `env`.
- 2010/05/11 ver. 0.152 dmd2.045
    - Amm is licensed under CC0(http://creativecommons.org/choose/zero).
- 2010/05/06 ver. 0.151 dmd2.045
    - Some macros name were renamed.
- 2010/05/01 ver. 0.150 dmd2.043
    - Amm can treat two or more `.d` files.
    - Add `<add>` element.
- 2010/04/21 ver. 0.149 dmd2.043
    - `<get>` element can be in a `<set>` element. `<get>` element is evaluated lazily.
- 2010/04/09 ver. 0.148 dmd2.042
    - Add an implementation about building a dll.
    - `<br>`, `<tab>` and `<ws>` element can be in a `<set>` element.
- 2010/04/07 ver. 0.147 dmd2.042
    - fix a bug halting with absence of `import` declaration.
- 2010/03/15 ver. 0.146
    - for dmd2.041.
- 2009/10/20 ver. 0.145
    - for dmd2.035.
    - In make-style.xml, starting and trailing spaces are removed.
- 2009/09/19 ver. 0.144
    - Add `<footer>` macro.
- 2009/09/17 ver. 0.143
    - `make` attribute of `<style>` element was renamed to `id`.
    - `<ifndef>` element was added.
    - make-style.xml were brushed up.
- 2009/09/15 ver. 0.14
    - the way of specifying options was changed.
    - `<switch>` element was removed.
    - `<ifdef>` element was added.
- 2009/09/14 ver. 0.132
    - fix a bug of my knowledge about Makefile.
    - `<add>` element was remove.
- 2009/09/12 ver. 0.131
    - now, `id` attribute of macro is case insensitive.
    - fix some tiny bugs.
- 2009/09/04 ver. 0.13
    - for dmd2.032
    - `altstd.xml` was removed.
    - amm doesn't depend on std.getopt.
    - fix a bug about make-style.xml
- 2009/09/01 ver. 0.12
    - vwrite was introduced.
- 2009/08/31 ver. 0.11
    - now, end of line characters can be selected.
    - use std.contracts.
- 2009/08/29 ver. 0.1
    - first release.


* * *

# Automatic Makefile Maker

__Version:__0.172(dmd2.085.0)
__Date:__ 2019-Apr-1
__Authors:__ KUMA
__License:__ CC0

## 詳細
このプログラムはD言語で書かれたソースコードからMakefileを自動生成する為のものです。

## 謝辞
AMMはD言語で記述されています。
[D言語(Digital Mars)](http://dlang.org/)

AMMは Mofile を利用しています。
[Mofile](https://github.com/FreeSlave/mofile.git)

## バグ
- q"..."文字列内に日本語があった場合にエラーが発生します。

## ビルド方法

### Windowsの場合
DMDに付属のmakeツールを使用して下さい。

#### 32bit

    >make -f win.mak release

#### 64bit

    >make -f win.mak release FLAG=-m64

### linuxの場合

    >make -f linux64.mak release

## 実行方法

    >amm [target.exe] [make-style.xml] [option for dmd] [options] rootfile.d

オプション    | 説明
--------------|-----------
-lang **      | 言語を指定します。初期値は環境変数`'LANG'`から取られます。
-verbose      | AMMの標準出力を'冗長'に設定します。
-quiet -q     | AMMの標準出力を'静か'に設定します。
other options | dmdへと渡されます。
name+=value   | マクロ名'name'に'value'を追加します。
name=value    | マクロ名'name'に'value'を設定します。
name          | マクロ名'name'を'defined'(定義済)に設定します。


### コマンドライン引数のうち、ファイル名(=拡張子があるもの)の扱い。
- `.d`はプロジェクトのルート(=main()関数を持つ)ファイルであるとみなされます。
- `.exe`はプロジェクトのビルドターゲット名として扱われます(Windowsの場合)。
- `.dll`はプロジェクトのビルドターゲット名として扱われます。また、ターゲットはDLLであるとみなされます(Windowsの場合)。
- `.lib`は、ビルド時にリンクされるライブラリ名として扱われます(Windowsの場合)。
- `.def`はDLL用の定義ファイルとして扱われます(Windowsの場合)。
- `.rc`はリソースファイルとして扱われます(Windowsの場合)。
- `.xml`はAMM用の設定ファイルとして扱われます。
- `.mak`はMakefileの名前として扱われます。

## 準備
- AMMはDMDを呼び出します。DMD.EXEが利用可能な(=パスが通っている)状態にして下さい。
- `make-style.xml`をAMMが探せる位置に置いてください。探索の優先順位は、
    1. 現在のディレクトリ。
    1. 環境変数'HOME'のディレクトリ。
    1. AMM.EXEがあるディレクトリ。
    1. linuxでは、`../etc/amm`(AMMのあるディレクトリからの"相対パス)。

## 例

    >amm root_file.d
上の例では、Makefileが現在のディレクトリに作られます。
'root_file.d'はプロジェクトのルートとなるファイルであり、通常は`main()`関数を持つとみなされます。
プロジェクトのターゲットを'hoge.exe'とするには、次のようにします。

    >amm root_file.d hoge.exe
引数が'-'で始まる場合は、dmdへの引数だと解釈されます。

    >amm -version=Unicode -L/exet:nt/su:windows:4.0 root_file.d hoge.exe
AMMのマクロを次のように設定できます。

    >amm v=1.0 gui root_file.d
これで、マクロ`'v'`は`'1.0'`に。マクロ`'gui'`は`'defined'`に設定されます。
マクロを削除するには次のようにします。

    >amm gui= root_file.d
初期設定では、下記のようなフォルダ構成が想定されています。

    -- project --+                             <-AMM.EXEが実行されるフォルダ。
                 |
                 |- target.exe                 <-ターゲットが出力される場所。
                 |- Makefile                   <-
                 |
                 |-- src    --+
                 |            |- source files  <-コンパイルされるファイル。
                 |            |- ...
                 |
                 |-- import --+
                 |            |- import files  <-インポートされるファイル。
                 |            |- ...
                 |
                 |-- lib    --+
                 |            |- libraries     <-静的リンクされるファイル。
                 |            |- ...
                 |
                 |-- lib64  --+
                 |            |- libraries     <-静的リンクされるファイル。
                 |            |- ...

## make-style.xml
make-style.xmlはMakefileへの出力を制御します。このファイルでは以下のことを行えます。
- 文字列を出力する。
- 「マクロ」への値の代入、追加。
- 「マクロ」からの値の取得。及び置換。
- `ifdef`、`ifndef`による条件分岐。

`make-style.xml`の例を次に示します。
```xml
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

```
上記のmake-style.xmlと、次のコマンドで、

    >amm gui test.d
下記のMakefileが出力されます。
```
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

```

### make-style.xmlで使えるタグ。
- `<style>`は最も外側の要素です。`<body>`要素が必須要素です。
- `<head>`要素は事前準備用です。Makefileへの出力はされません。`<set>`、`<add>`、`<ifdef>`、`<ifndef>`要素を含めることができます。`<body>`要素の前に書きます。
- `<ifdef>`と`<ifndef>`は`'id'`属性持ちます。`'id'`属性で指定されたマクロ名が定義済であるかどうかで条件分岐が発生します。
- `<set>`要素の中身は`'id'`属性で指定されたマクロに登録されます。マクロが既に定義済の場合、値は上書きされます。この要素内では、`<ws>`、`<br>`、`<tab>`、`<get>`要素を使うことができます。`'id'`属性は必須属性です。
- `<add>`要素は中身を`'id'`属性で指定されたマクロへと追加します。
- `<body>`要素内ではMakefileへの出力が行われます。文字列は単に出力されます。行頭/
行末のスペースは取り除かれます。`<ws>`、`<tab>`、`<br>`、`<get>`、`<ifdef>`、`<ifndef>`要素を含めることができます。文字実体参照はPhobosによって解決されます。
- `<ws>`要素は`' '`(半角スペース)を出力します。`'length'`属性で連続した半角スペースを出力できます。
- `<tab>`は`'\\t'`(タブ文字)を出力します。
- `<br>`要素は改行文字を出力します。Windowsでは、`'\\r\\n'`で、linuxでは、`'\n'`です。後述の`'bracket'`マクロでこの値を変更することができます。
    - `'breacket'`マクロの中身が`'rn'`の場合は`'\\r\\n'`が出力されます。
    - `'bracket'`マクロの中身が`'n'`の場合は`'\\n'`が出力されます。
    - `'bracket'`マクロの中身が`'r'`の場合は`'\\r'`が出力されます。
- `<get>`要素は`'id'`属性で指定したマクロの中身を展開します。`'from'`属性と`'to'`属性を使って置換を行うことができます。展開は遅延評価されます。`'id'`が必須属性です。

## 定義済マクロ一覧
コマンドライン引数で指定したマクロが最も優先されます。マクロ名は大文字小文字を区別しません。

名前             | 初期値                | 説明
-----------------|-----------------------|-----------
bracket          | rn                    | 改行文字を指定します。`'rn'`はCR+LFを、`'n'`はLFを、`'r'`はCRを意味します。
env              |                       | このマクロは後方互換性の為に残されています。
exe_ext          | .exe                  | 実行形式ファイルの拡張子を指定します。
obj_ext          | .obj                  | オブジェクトファイルの拡張子を指定します。
lib_ext          | .lib                  | 静的リンクライブラリファイルの拡張子を指定します。
gen_deps_command | dmd -c -op -o- -debug | 依存関係解決の為に実行される際のコマンドが格納されます。
deps_file        | tempdeps              | `'gen_deps_command'`で生成される一時ファイルのファイル名を指定します。
m                | Makefile              | 生成されるMakefileの名前を指定します。
root             |                       | プロジェクトのルートファイルパスを指定します。拡張子が`.d`のパスをコマンドライン引数から指定するとこのマクロに設定されます。
compile_flag     |                       | dmdのコンパイルフラグを指定します。コマンドライン引数のうち、`-`で始まるものがここに格納されます。
link_flag        |                       | dmdのリンクフラグを指定します。コマンドライン引数のうち、'-L'で始まるものがここに格納されます。
target           |                       | プロジェクトのビルドターゲット名が格納されます。Windowsでは、`.exe`あるいは`.dll'の拡張子を持つパスをコマンドライン引数から指定すると、ここに格納されます。
dependencies     |                       | AMMが自動で値を設定します。ソースファイルの依存関係が格納されます。
to_compile       |                       | AMMが自動で値を設定します。ソースファイルの依存関係が格納されます。
to_link          |                       | AMMが自動で値を設定します。ソースファイルの依存関係が格納されます。
rc_file          |                       | Windows上で、リソースファイルを指定します。拡張子が`.rc`のファイルをコマンドライン引数から指定するとここに格納されます。
def              |                       | Windowsで、モジュール定義ファイルを指定します。コマンドライン引数から`.def`の拡張子のファイルを指定するとここに格納されます。
ddoc             |                       | DDOC用ファイルを指定します。コマンドライン引数から`.ddoc`の拡張子を持つファイルを指定するとここに格納されます。
dd               | doc                   | DDOCの出力用ディレクトリを指定します。
libs             |                       | 静的リンクされるライブラリファイルパスが格納されます。マクロ名`'lib'`で指定されたディレクトリ内にあるファイルがここに格納されます。
imp              | import                | importされるファイルが含まれているディレクトリを指定します。このディレクトリ下にあるファイルはコンパイルされないものとみなされます。
lib              | lib                   | 静的リンクされるライブラリファイルが入っているディレクトリを指定します。
i                | imp_root ~ ';' ~ root | AMMが値を設定します。dmdの`-I`オプションの内容と同じです。
is_dll           |                       | プロジェクトのターゲットがDLLの場合に定義します。
is_lib           |                       | プロジェクトのターゲットが静的ライブラリの場合に定義します。
verbose          |                       | AMMの標準出力の冗長性を指定します。
q                |                       | AMMの標準出力の冗長性を指定します。
footer           | ## generated by amm.  | Makefile末尾に追加される「フッターマーク」を格納します。Makefile内でこのマークより後に手動で追加された部分は、AMMでMakefileを更新した場合でも残ります。
style_file       | make-style.xml        | オブジェクトファイルの拡張子を指定します。
v                |                       | プロジェクトの情報を指定します。
authors          |                       | プロジェクトの情報を指定します。
license          |                       | プロジェクトの情報を指定します。
date             |                       | AMMが現在時刻を格納します。
remake_command   | amm.exe               | AMMが起動された時のコマンドが格納されます。
src              | src                   | コマンドライン引数から`-I`で指定されたディレクトリがここに格納されます。
is_vclinker      |                       | dmdに、マイクロソフトのリンカを使うように設定します。
dll_ext          | .dll                  | DLLライブラリの拡張子を指定します。この拡張子を持つファイルがコマンドライン引数から指定された場合、プロジェクトのビルドターゲットとしてみなされ、`'IS_DLL'`マクロが定義済とされます。
mak_ext          | .mak                  | Makefileの拡張子を指定します。コマンドライン引数でこの拡張子を持つファイル名が指定された場合、AMMが出力するMakefileの名前として使われます。
src_ext          | .d                    | ソースファイルの拡張子を指定します。コマンドライン引数からこの拡張子を持つファイル名が指定された場合、プロジェクトのルートファイルとみなされ、`'ROOT'`マクロへと設定されます。また、`'TARGET'`マクロが未定義の場合、``ROOT'+'EXE_EXT'`がプロジェクトターゲット名として設定されます。
rc_ext           | .rc                   | リソースファイルの拡張子を設定します。コマンドライン引数からこの拡張子を持つファイルが指定された場合、`'RC'`マクロに設定されます。
rc               |                       | リソースファイル名が格納されます。
def_ext          | .def                  | モジュール定義ファイルの拡張子を指定します。コマンドライン引数からこの拡張子を持つファイルを指定した場合、モジュール定義ファイルとみなされます。
ddoc_ext         | .ddoc                 | DDOCファイルの拡張子を指定します。コマンドライン引数からこの拡張子を持つファイルを指定した場合、DDOC用のファイルとみなされます。
xml_ext          | .xml                  | AMMが使う設定ファイルに用いられるファイルの拡張子を設定します。
style            | make-style.xml        | STYLE_FILEはAMMの出力を制御します。


## ライセンス
[クリエイティブ・コモンズ・ゼロ ライセンス](http://creativecommons.org/publicdomain/zero/1.0/)

## 開発環境
- Windows Vista(x64) x dmd 2.084.0 x make (of Digital Mars)
- Ubuntu 15.10(x64) x gcc 5.2.1 x dmd 2.084.0 x GNU Make

## 履歴
- 2018/04/01 ver. 0.172(dmd2.085.0)
    - gettext用、ja.poの実装。
- 2018/03/21 ver. 0.171(dmd2.085.0)
    - gettext用の_("hogehoge")の実装
    - サブモジュールとして、mofile(https://github.com/FreeSlave/mofile.git)を追加しました。
    - sworks.base.moを追加しました。
    - sworks.base.getoptを追加しました。
    - sworks.base.readmegenを追加しました。
    - readme.dを追加しました。
- 2016/04/11 ver. 0.170(dmd2.071.0)
    - 文字列インポートに関するバグフィクス
- 2016/02/28 ver. 0.169(dmd2.070.0)
    - README.md を ddoc で生成するように。
    - 定義済みマクロとその初期値を ddoc で生成するように。
- 2015/12/22 ver. 0.168(dmd2.069.2)
    - 英語版README.md追加。
    - linux上でのバグフィクス
- 2015/12/06 ver. 0.167(dmd2.069.2)
    - std.process がらみの deprecation に対応。
    - ソースのインデントをタブからスペースに。(dmdのソースに準拠すべく。)
- 2014/06/28 ver. 0.166(dmd2.065)
    - バグフィクス
- 2013/03/02 ver. 0.165(dmd2.064)
    - linux 上で make-style.xml を探せないバグを修正。-inline で無限ループするバグは根気不足が原因だったかもしれん。
- 2012/10/28 ver. 0.164(dmd2.060)
    - コンソールへの出力まわりを若干変更
- 2012/10/25 ver. 0.163(dmd2.060)
    - linux になんとなく対応。
- 2012/10/11 ver. 0.162(dmd2.060)
    - ディレクトリの評価まわりのバグフィクス。
    - make-style.xml の修正。
- 2012/10/11 ver. 0.161(dmd2.060)
    - ヘルプを日本語に。
    - help macro でマクロの一覧出せるように。
    - .lib のファイル渡すとリンクするライブラリという判断になりました。やっぱ不便やからね。
    - マクロ project なくなりました。不便。
    - マクロ install_directory なくなりました。いらん。
    - .mak のファイルを渡すと Makefile の名前となるように。
    - あとちょこちょこマクロの名前変わってます。
- 2012/10/10 ver. 0.160(dmd2.060)
    - github デビュー。
    - それにともなって、Doxygen 使うのやめに。
    - あと、compo.lib にまとめるのはやめて、ソースコード展開しました。
- 2012/10/09 ver. 0.159(dmd2.060)
    - dll 作成時の出力を変更
- 2012/06/07 ver. 0.158(dmd2.059)
    - public import の依存を解決
- 2012/04/15 ver. 0.157(dmd2.059)
    - compo.lib を若干修正
    - コマンドラインからマクロを設定する際、後に書いたものが有効になるように変更。
    - 拡張子が ".lib" のファイルを渡した場合、これまではリンクすべきライブラリファイルと判断されていましたが、出力ターゲットがライブラリファイルである。と認識されるようになりました。リンクすべきライブラリファイルをコマンドラインから指定する場合は、`to_link+=hoge.lib`として下さい。
- 2012/04/11 ver. 0.156(dmd2.058)
    - ほぼ全面刷新。
    - いくつかのモジュールが、外部ライブラリ compo.lib にまとめられました。だからどうということもないんですが。
    - このドキュメントが [Doxygen(http://www.doxygen.jp)](http://www.doxygen.jp)を使うようにかわりました。
- 2010/08/20 ver. 0.155 dmd2.048
    - style-xml ファイルにコメント`<!-- -->`入れても落ちなくなりました。
    - 依存関係に .di ファイルがあっても大丈夫になりました。
- 2010/05/27 ver. 0.154 dmd2.046
    - style-xmlの標準化にむけて。
- 2010/05/18 ver. 0.153 dmd2.045
    - style-xmlの標準化にむけて。
    - `<make>` タグが `<style>` に、
    - `<style>` タグが、`<environment>` に、
    - `<style>` マクロが、`<env>` に変更されました。
- 2010/05/11 ver. 0.152 dmd2.045
    - ライセンスが修正BSDから [CreativeCommons Zero License(http://creativecommons.org/choose/zero)](http://creativecommons.org/choose/zero) に変更されました。
- 2010/05/06 ver. 0.151 dmd2.045
    - マクロの名前がいくつか変更されました。
- 2010/05/01 ver. 0.150 dmd2.043
    - コマンドライン引数として複数のDソースファイルを渡せるようになりました。互いに依存関係が疎なファイルを一つのライブラリにまとめたい時に使えます。
    - `<add>` タグが追加されました。
- 2010/04/21 ver. 0.149 dmd2.043
    - `<set>` タグ内で `<get>`タグが使用可能になりました。この時、`<get>`タグは、そのマクロが展開される時に評価されます。
- 2010/04/09 ver. 0.148 dmd2.042
    - dll作成になんとなく対応。
    - `<set>` タグ内で `<br>`、`<tab>`、`<ws>` タグが使用可能に。
- 2010/04/07 ver. 0.147 dmd2.042
    - Dのソースファイルにimport宣言がないとパースに失敗してたバグを修正。
- 2010/03/15 ver. 0.146
    - dmd2.041対応版。
- 2009/10/20 ver. 0.145
    - dmd2.035対応版。
    - make-sytle.xml内で行頭および行末の空白文字のみ削除されるように変更されました。
- 2009/09/19 ver. 0.144
    - `<footer>`マクロを導入。Makefile中で `<get id="footer" />`以降に書かれたものはMakefileを作りなおしても残るようになりました。ここに、まあインストールコマンドとかを書いてもらえばよいかと。
- 2009/09/17 ver. 0.143
    - `<style>`タグの `'make'` 属性を `'id'` と変更。
    - `<ifndef>`タグを追加。
    - make-style.xml を刷新。
- 2009/09/15 ver. 0.14
    - オプションの指定方法変更。
    - `<switch>` タグのかわりに、`<ifdef>` タグができました。
    - なんかコロコロ変わるよなあ。
- 2009/09/14 ver. 0.132
    - 色々修正。っていうかMakefileの書き方まちがってました。
    - `<add>` タグがなくなりました。
- 2009/09/12 ver. 0.131
    - マクロのidは大文字、小文字に関係なくなりました。
    - その他ちょっとしたバグとか修正。
- 2009/09/04 ver. 0.13
    - dmd2.032リリースにあたってのバージョンアップ
    - std.xmlのバグがなおったので、altstd.xmlは消去。
    - std.getoptつかうのやめに。それにともなってオプションのスタイルとか色々変りました。
    - make-style.xmlのバグ修正。
- 2009/09/01 ver. 0.12
    - vwrite に対応。
- 2009/08/31 ver. 0.11
    - 改行コードが指定可能に。
    - std.contractsを使うようにちょっとだけ変更。
- 2009/08/29 ver. 0.1
    - ほんと __とりあえず__ 公開。
