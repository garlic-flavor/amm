## for gnu make
## DOT DIRECTIVE
.PHONY : release clean show remake install run edit clean_obj vwrite debug-all ddoc
## MACRO
TARGET = amm
DC = dmd
MAKE = gmake
MAKEFILE = linux32.mak
TO_COMPILE = src/sworks/compo/util/output.d src/sworks/compo/util/strutil.d src/sworks/amm/deps_data.d src/sworks/compo/stylexml/macro_item.d src/sworks/amm/default_data.d src/sworks/amm/main.d src/sworks/compo/stylexml/macros.d src/sworks/compo/stylexml/parser.d src/sworks/compo/stylexml/writer.d src/sworks/compo/util/array.d src/sworks/amm/args_data.d src/sworks/compo/util/search.d src/sworks/amm/ready_data.d
TO_LINK = src/sworks/compo/util/output.o src/sworks/compo/util/strutil.o src/sworks/amm/deps_data.o src/sworks/compo/stylexml/macro_item.o src/sworks/amm/default_data.o src/sworks/amm/main.o src/sworks/compo/stylexml/macros.o src/sworks/compo/stylexml/parser.o src/sworks/compo/stylexml/writer.o src/sworks/compo/util/array.o src/sworks/amm/args_data.o src/sworks/compo/util/search.o src/sworks/amm/ready_data.o
COMPILE_FLAG = -Isrc
LINK_FLAG =
EXT_LIB =
DDOC_FILE =
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -of$@ $(LINK_FLAG) $(TO_LINK) $(EXT_LIB)

## COMPILE RULE
%.o : %.d
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src/sworks/compo/util/output.o : src/sworks/compo/util/output.d
src/sworks/compo/util/strutil.o : src/sworks/compo/util/strutil.d
src/sworks/amm/deps_data.o : src/sworks/amm/deps_data.d
src/sworks/compo/stylexml/macro_item.o : src/sworks/compo/stylexml/macro_item.d
src/sworks/amm/default_data.o : src/sworks/amm/default_data.d
src/sworks/amm/main.o : src/sworks/amm/main.d
src/sworks/compo/stylexml/macros.o : src/sworks/compo/stylexml/macro_item.d src/sworks/compo/stylexml/macros.d
src/sworks/compo/stylexml/parser.o : src/sworks/compo/stylexml/parser.d
src/sworks/compo/stylexml/writer.o : src/sworks/compo/stylexml/writer.d
src/sworks/compo/util/array.o : src/sworks/compo/util/array.d
src/sworks/amm/args_data.o : src/sworks/amm/args_data.d
src/sworks/compo/util/search.o : src/sworks/compo/util/search.d
src/sworks/amm/ready_data.o : src/sworks/amm/ready_data.d

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
	vwrite -ver="0.165(dmd2062)" -prj=$(TARGET) -target=$(TARGET) $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D -Dd $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
show :
	@echo ROOT = src/sworks/amm/main.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.165(dmd2062)
run :
	$(TARGET) $(FLAG)
edit :
	emacs $(TO_COMPILE)
remake :
	amm -ofamm "v=0.165(dmd2062)" linux32.mak src/sworks/amm/main.d $(FLAG)

debug :
	ddbg $(TARGET)

## generated by amm.

INSTALL =
install :
	cp ./amm $(INSTALL)
	cp ./make-style.xml $(INSTALL)
