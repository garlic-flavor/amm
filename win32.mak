## MACRO
TARGET = amm.exe
DC = dmd
MAKE = make
MAKEFILE = win32.mak
TO_COMPILE = src\sworks\compo\util\output.d src\sworks\compo\util\strutil.d src\sworks\amm\ready_data.d src\sworks\compo\stylexml\macro_item.d src\sworks\compo\stylexml\macros.d src\sworks\compo\stylexml\parser.d src\sworks\compo\stylexml\writer.d src\sworks\compo\util\array.d src\sworks\amm\default_data.d src\sworks\amm\args_data.d src\sworks\amm\main.d src\sworks\compo\util\search.d src\sworks\amm\deps_data.d
TO_LINK = src\sworks\compo\util\output.obj src\sworks\compo\util\strutil.obj src\sworks\amm\ready_data.obj src\sworks\compo\stylexml\macro_item.obj src\sworks\compo\stylexml\macros.obj src\sworks\compo\stylexml\parser.obj src\sworks\compo\stylexml\writer.obj src\sworks\compo\util\array.obj src\sworks\amm\default_data.obj src\sworks\amm\args_data.obj src\sworks\amm\main.obj src\sworks\compo\util\search.obj src\sworks\amm\deps_data.obj
COMPILE_FLAG = -Isrc
LINK_FLAG =
EXT_LIB =
DDOC_FILE =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g $(LINK_FLAG) $(FLAG) $(EXT_LIB) -of$@ $**

## COMPILE RULE
.d.obj :
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src\sworks\compo\util\output.obj : src\sworks\compo\util\output.d
src\sworks\compo\util\strutil.obj : src\sworks\compo\util\strutil.d
src\sworks\amm\ready_data.obj : src\sworks\amm\ready_data.d src\sworks\compo\util\output.d src\sworks\compo\stylexml\macros.d src\sworks\compo\util\search.d
src\sworks\compo\stylexml\macro_item.obj : src\sworks\compo\stylexml\macro_item.d
src\sworks\compo\stylexml\macros.obj : src\sworks\compo\stylexml\macro_item.d src\sworks\compo\stylexml\macros.d
src\sworks\compo\stylexml\parser.obj : src\sworks\compo\util\strutil.d src\sworks\compo\stylexml\parser.d src\sworks\compo\stylexml\macros.d src\sworks\compo\stylexml\writer.d
src\sworks\compo\stylexml\writer.obj : src\sworks\compo\stylexml\writer.d src\sworks\compo\util\array.d
src\sworks\compo\util\array.obj : src\sworks\compo\util\array.d
src\sworks\amm\default_data.obj : src\sworks\amm\default_data.d src\sworks\compo\stylexml\macros.d
src\sworks\amm\args_data.obj : src\sworks\compo\util\output.d src\sworks\amm\args_data.d src\sworks\compo\stylexml\macros.d src\sworks\compo\util\search.d
src\sworks\amm\main.obj : src\sworks\compo\util\output.d src\sworks\amm\ready_data.d src\sworks\compo\stylexml\macros.d src\sworks\compo\stylexml\parser.d src\sworks\amm\default_data.d src\sworks\amm\args_data.d src\sworks\amm\main.d src\sworks\amm\deps_data.d
src\sworks\compo\util\search.obj : src\sworks\compo\util\search.d
src\sworks\amm\deps_data.obj : src\sworks\compo\util\output.d src\sworks\compo\stylexml\macro_item.d src\sworks\compo\stylexml\macros.d src\sworks\amm\deps_data.d src\sworks\compo\util\search.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB)  $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB)  $(FLAG)
clean :
	del $(TARGET) $(TO_LINK)
clean_obj :
	del $(TO_LINK)
vwrite :
	vwrite -ver="0.163(dmd2.060)" -prj=$(TARGET) $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D -Dddoc $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
show :
	@echo ROOT = src\sworks\amm\main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.163(dmd2.060)
run :
	$(TARGET) $(FLAG)
edit :
	emacs $(TO_COMPILE)
remake :
	amm v=0.163(dmd2.060) amm.exe win32.mak src/sworks/amm/main.d $(FLAG)

debug :
	ddbg $(TARGET)

## generated by amm.

INSTALL =
install :
	copy amm.exe $(INSTALL)
	copy make-style.xml $(INSTALL)
