## for gnu make
## DOT DIRECTIVE
.PHONY : release clean show remake install run edit clean_obj vwrite debug-all ddoc debug l10n-init l10n-init-po l10n-update l10n
## MACRO
TARGET = amm
PROJECT = amm
VERSION = 0.173

MAKEFILE = linux.mak
DC = dmd
MAKE = make
TO_COMPILE = src/sworks/amm/main.d src/sworks/amm/args_data.d submodule/mofile/source/mofile.d src/sworks/amm/deps_data.d src/sworks/amm/ready_data.d src/sworks/base/array.d src/sworks/base/getopt.d src/sworks/base/mo.d src/sworks/base/output.d src/sworks/base/search.d src/sworks/base/strutil.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/macros.d src/sworks/stylexml/package.d src/sworks/stylexml/parser.d src/sworks/stylexml/writer.d
TO_LINK = src/sworks/amm/main.o src/sworks/amm/args_data.o submodule/mofile/source/mofile.o src/sworks/amm/deps_data.o src/sworks/amm/ready_data.o src/sworks/base/array.o src/sworks/base/getopt.o src/sworks/base/mo.o src/sworks/base/output.o src/sworks/base/search.o src/sworks/base/strutil.o src/sworks/stylexml/macro_item.o src/sworks/stylexml/macros.o src/sworks/stylexml/package.o src/sworks/stylexml/parser.o src/sworks/stylexml/writer.o
COMPILE_FLAG = -Isrc:submodule/mofile/source
LINK_FLAG =
EXT_LIB =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g -of$@ $(LINK_FLAG) $(TO_LINK) $(FLAG)

## COMPILE RULE
%.o : %.d
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src/sworks/amm/main.o : src/sworks/base/output.d src/sworks/amm/main.d src/sworks/stylexml/writer.d src/sworks/base/mo.d submodule/mofile/source/mofile.d src/sworks/stylexml/package.d src/sworks/amm/ready_data.d src/sworks/base/getopt.d src/sworks/amm/args_data.d src/sworks/base/array.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/parser.d src/sworks/base/strutil.d src/sworks/amm/deps_data.d src/sworks/stylexml/macros.d src/sworks/base/search.d
src/sworks/amm/args_data.o : src/sworks/base/output.d src/sworks/base/mo.d submodule/mofile/source/mofile.d src/sworks/base/getopt.d src/sworks/amm/args_data.d src/sworks/stylexml/macro_item.d src/sworks/base/strutil.d src/sworks/base/search.d src/sworks/stylexml/macros.d
submodule/mofile/source/mofile.o : submodule/mofile/source/mofile.d
src/sworks/amm/deps_data.o : src/sworks/base/output.d submodule/mofile/source/mofile.d src/sworks/base/mo.d src/sworks/amm/deps_data.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/macros.d src/sworks/base/search.d
src/sworks/amm/ready_data.o : src/sworks/base/output.d submodule/mofile/source/mofile.d src/sworks/base/mo.d src/sworks/amm/ready_data.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/macros.d src/sworks/base/search.d
src/sworks/base/array.o : src/sworks/base/array.d
src/sworks/base/getopt.o : submodule/mofile/source/mofile.d src/sworks/base/strutil.d src/sworks/base/mo.d src/sworks/base/getopt.d
src/sworks/base/mo.o : src/sworks/base/mo.d submodule/mofile/source/mofile.d
src/sworks/base/output.o : src/sworks/base/output.d
src/sworks/base/search.o : src/sworks/base/search.d
src/sworks/base/strutil.o : src/sworks/base/strutil.d
src/sworks/stylexml/macro_item.o : src/sworks/stylexml/macro_item.d src/sworks/base/mo.d submodule/mofile/source/mofile.d
src/sworks/stylexml/macros.o : submodule/mofile/source/mofile.d src/sworks/stylexml/macro_item.d src/sworks/base/mo.d src/sworks/stylexml/macros.d
src/sworks/stylexml/package.o : src/sworks/stylexml/writer.d src/sworks/base/mo.d submodule/mofile/source/mofile.d src/sworks/stylexml/package.d src/sworks/base/array.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/parser.d src/sworks/stylexml/macros.d
src/sworks/stylexml/parser.o : src/sworks/stylexml/writer.d src/sworks/base/mo.d submodule/mofile/source/mofile.d src/sworks/base/array.d src/sworks/stylexml/macro_item.d src/sworks/stylexml/parser.d src/sworks/stylexml/macros.d
src/sworks/stylexml/writer.o : src/sworks/base/array.d src/sworks/stylexml/writer.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
clean :
	rm $(TARGET) $(TO_LINK)
clean_obj :
	rm $(TO_LINK)
vwrite :
	vwrite --setversion "$(VERSION)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
	@type $(DOC_HEADER) $(DOC_FILES) $(DOC_FOOTER) > $(DOC_TARGET) 2>nul
	@del $(DOC_FILES)
show :
	@echo ROOT = src/sworks/amm/main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.173
run :
	$(TARGET) $(FLAG)
remake :
	amm -Isubmodule/mofile/source linux.mak target=amm v=0.173 ./src/sworks/amm/main.d $(FLAG)

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

install:
	cp ./amm /usr/local/bin
	if [ ! -d "/usr/local/etc/amm" ]; then mkdir /usr/local/etc/amm; fi
	cp ./make-style.xml /usr/local/etc/amm/
	if [ ! -d "/usr/local/etc/amm/l10n" ]; then mkdir /usr/local/etc/amm/l10n; fi
	cp ./l10n/amm/ja.mo /usr/local/etc/amm/l10n
