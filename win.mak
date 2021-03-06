## MACRO
TARGET = amm.exe
PROJECT = amm
VERSION = 0.173

MAKEFILE = win.mak
DC = dmd
MAKE = make
TO_COMPILE = src\sworks\amm\main.d src\sworks\amm\args_data.d submodule\mofile\source\mofile.d src\sworks\amm\deps_data.d src\sworks\amm\ready_data.d src\sworks\base\array.d src\sworks\base\getopt.d src\sworks\base\mo.d src\sworks\base\output.d src\sworks\base\search.d src\sworks\base\strutil.d src\sworks\stylexml\macro_item.d src\sworks\stylexml\macros.d src\sworks\stylexml\package.d src\sworks\stylexml\parser.d src\sworks\stylexml\writer.d src\sworks\win32\sjis.d
TO_LINK = src\sworks\amm\main.obj src\sworks\amm\args_data.obj submodule\mofile\source\mofile.obj src\sworks\amm\deps_data.obj src\sworks\amm\ready_data.obj src\sworks\base\array.obj src\sworks\base\getopt.obj src\sworks\base\mo.obj src\sworks\base\output.obj src\sworks\base\search.obj src\sworks\base\strutil.obj src\sworks\stylexml\macro_item.obj src\sworks\stylexml\macros.obj src\sworks\stylexml\package.obj src\sworks\stylexml\parser.obj src\sworks\stylexml\writer.obj src\sworks\win32\sjis.obj
COMPILE_FLAG = -Isrc;src;submodule\mofile\source
LINK_FLAG =
EXT_LIB =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g $(LINK_FLAG) $(FLAG) -of$@ $**

## COMPILE RULE
.d.obj :
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src\sworks\amm\main.obj : src\sworks\base\search.d src\sworks\stylexml\package.d src\sworks\base\array.d src\sworks\amm\ready_data.d src\sworks\stylexml\macros.d src\sworks\stylexml\writer.d src\sworks\base\output.d src\sworks\base\strutil.d src\sworks\win32\sjis.d src\sworks\amm\main.d src\sworks\stylexml\parser.d src\sworks\amm\deps_data.d src\sworks\amm\args_data.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d src\sworks\base\getopt.d
src\sworks\amm\args_data.obj : src\sworks\stylexml\macros.d src\sworks\base\strutil.d src\sworks\base\search.d src\sworks\amm\args_data.d src\sworks\win32\sjis.d src\sworks\base\output.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d src\sworks\base\getopt.d
submodule\mofile\source\mofile.obj : submodule\mofile\source\mofile.d
src\sworks\amm\deps_data.obj : src\sworks\stylexml\macros.d src\sworks\base\search.d src\sworks\base\output.d src\sworks\win32\sjis.d src\sworks\base\strutil.d src\sworks\amm\deps_data.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d
src\sworks\amm\ready_data.obj : src\sworks\amm\ready_data.d src\sworks\stylexml\macros.d src\sworks\base\strutil.d src\sworks\base\search.d src\sworks\win32\sjis.d src\sworks\base\output.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d
src\sworks\base\array.obj : src\sworks\base\array.d
src\sworks\base\getopt.obj : submodule\mofile\source\mofile.d src\sworks\base\strutil.d src\sworks\base\getopt.d src\sworks\base\mo.d
src\sworks\base\mo.obj : submodule\mofile\source\mofile.d src\sworks\base\mo.d
src\sworks\base\output.obj : src\sworks\base\output.d src\sworks\base\strutil.d src\sworks\win32\sjis.d
src\sworks\base\search.obj : src\sworks\base\search.d
src\sworks\base\strutil.obj : src\sworks\base\strutil.d
src\sworks\stylexml\macro_item.obj : src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d src\sworks\base\mo.d
src\sworks\stylexml\macros.obj : src\sworks\stylexml\macros.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d src\sworks\base\mo.d
src\sworks\stylexml\package.obj : src\sworks\stylexml\package.d src\sworks\base\array.d src\sworks\stylexml\macros.d src\sworks\stylexml\writer.d src\sworks\stylexml\parser.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d
src\sworks\stylexml\parser.obj : src\sworks\base\array.d src\sworks\stylexml\macros.d src\sworks\stylexml\writer.d src\sworks\stylexml\parser.d src\sworks\base\mo.d src\sworks\stylexml\macro_item.d submodule\mofile\source\mofile.d
src\sworks\stylexml\writer.obj : src\sworks\stylexml\writer.d src\sworks\base\array.d
src\sworks\win32\sjis.obj : src\sworks\base\strutil.d src\sworks\win32\sjis.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
clean :
	del $(TARGET) $(TO_LINK)
clean_obj :
	del $(TO_LINK)
vwrite :
	vwrite --setversion "$(VERSION)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
	@type $(DOC_HEADER) $(DOC_FILES) $(DOC_FOOTER) > $(DOC_TARGET) 2>nul
	@del $(DOC_FILES)
show :
	@echo ROOT = src\sworks\amm\main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.173
run :
	$(TARGET) $(FLAG)
remake :
	amm.exe amm.exe v=0.173 win.mak -Isrc;submodule\mofile\source .\src\sworks\amm\main.d $(FLAG)

debug :
	ddbg $(TARGET)


l10n-init:
	xgettext -k_ --from-code=UTF-8 --language=C $(TO_COMPILE) -o l10n\$(PROJECT)\message.pot

l10n-init-po:
	msginit --locale=ja_JP.UTF-8 -i l10n\$(PROJECT)\message.pot -o l10n\$(PROJECT)\ja.po --no-translator

l10n-update:
	xgettext -k_ --from-code=UTF-8 --language=C $(TO_COMPILE) -o l10n\$(PROJECT)\message.pot
	msgmerge --update l10n\$(PROJECT)\ja.po l10n\$(PROJECT)\message.pot

l10n:
	msgcat --no-location --output l10n\$(PROJECT)\ja.nolocation.po l10n\$(PROJECT)\ja.po
	msgfmt l10n\$(PROJECT)\ja.nolocation.po -o l10n\$(PROJECT)\ja.mo

## generated by amm.
