# -*- Mode: makefile -*-

# Makefile for the cil wrapper
# @do_not_edit@ Makefile.in
#
# authors: George Necula, Gabriel Kerneis

CILLY			  = cilly
CIL_VERSION = 1.7.3

# Avoid using CIL_FEATURES when building doc or tests
unexport CIL_FEATURES

.PHONY: all
all: install-local

# look out for outdated Makefile; if it's out of date, this will automatically
# re-run ./config.status, then re-exec make with the same arguments
Makefile: config.status Makefile.in
	./$<

config.status: configure
	./$@ --recheck

$(srcdir)/configure: configure.ac aclocal.m4
	cd '$(srcdir)' && autoconf

# autoheader might not change config.h.in, so touch a stamp file.
$(srcdir)/config.h.in: stamp-h.in
$(srcdir)/stamp-h.in: configure.ac aclocal.m4
	cd '$(srcdir)' && autoheader
	echo timestamp > '$(srcdir)/stamp-h.in'

config.h: stamp-h
stamp-h: config.h.in config.status
	./config.status

CC=gcc
_GNUCC=1

# We have to use _build because of OCaml's bug #0004502
OBJDIR    = _build
BINDIR    = bin
CILLYDIR  = lib/perl5

# Ocaml tools
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLFIND = ocamlfind
OCAMLBUILD = ocamlbuild
OCAMLNATDYNLINK = yes

PERL = perl

# Build the list of files for cillib
CILLIB_TARGETS=
CILLY_EXE_FILES=

CIL_PLUGINS_DIR = src/ext
CIL_EXCLUDE_PLUGINS =
CIL_PLUGINS = $(addprefix $(OBJDIR)/,$(filter-out $(addprefix $(CIL_PLUGINS_DIR)/, $(CIL_EXCLUDE_PLUGINS)),$(wildcard $(CIL_PLUGINS_DIR)/*)))

CIL_DEFAULT_PLUGINS = $(patsubst $(CIL_PLUGINS_DIR)/%/default,cil.%,$(wildcard $(CIL_PLUGINS_DIR)/*/default))

ifneq ($(OCAMLC),no)
  CILLIB_TARGETS  += $(OBJDIR)/src/cil.cma
  CILLIB_TARGETS  += $(addsuffix .cma,$(CIL_PLUGINS))
  CILLY_EXE_FILES += $(OBJDIR)/src/main.byte
endif
ifneq ($(OCAMLOPT),no)
# build native version only if natdynlink is available
ifeq ($(OCAMLNATDYNLINK),yes)
  CILLIB_TARGETS  += $(OBJDIR)/src/cil.cmxa $(OBJDIR)/src/cil.a
  CILLIB_TARGETS  += $(addsuffix .cmxa,$(CIL_PLUGINS))
  CILLIB_TARGETS  += $(addsuffix .cmxs,$(CIL_PLUGINS))
  CILLIB_TARGETS  += $(addsuffix .a,$(CIL_PLUGINS))
  CILLY_EXE_FILES += $(OBJDIR)/src/main.native
endif
endif

CILLIB_FILES = $(OBJDIR)/src/cil.libfiles $(addsuffix .libfiles,$(CIL_PLUGINS))
CILDOC_INDEX = $(OBJDIR)/cil.docdir/index.html
CILLY_EXE_BIN = $(patsubst $(OBJDIR)/src/main.%,bin/$(CILLY).%,$(CILLY_EXE_FILES))

# Force a single invocation of ocamlbuild per make execution

override OCAMLBUILD += -build-dir $(OBJDIR) -use-ocamlfind -no-links

OCAMLBUILD_TARGETS = \
	$(CILLIB_TARGETS)  \
	$(CILLIB_FILES)	   \
	$(CILLY_EXE_FILES) \
	$(CILDOC_INDEX)

# Trick: this no-op rule is executed for each target, but
# its PHONY dependency is built exactly once.
$(OCAMLBUILD_TARGETS): ocamlbuild
	@:

.PHONY: ocamlbuild
ocamlbuild:
	export CIL_VERSION
	MAKE=$(MAKE) $(OCAMLBUILD) $(patsubst $(OBJDIR)/%,%,$(OCAMLBUILD_TARGETS))

.PHONY: META
META:
	@rm -f $@
	@printf "description = \"C Intermediate Language\"\n" >>$@
	@printf "requires = \"unix str num dynlink findlib\"\n" >>$@
	@printf "version = \"$(CIL_VERSION)\"\n\n" >>$@
	@printf "archive(byte) = \"cil.cma\"\n" >>$@
	@printf "archive(native) = \"cil.cmxa\"\n\n" >>$@
	@printf "package \"default-features\" (\n" >>$@
	@printf "requires=\"$(CIL_DEFAULT_PLUGINS)\"\n" >>$@
	@printf "version = \"$(CIL_VERSION)\"\n" >>$@
	@printf ")\n\n" >>$@
	@printf "package \"all-features\" (\n" >>$@
	@printf "requires=\"$(patsubst $(OBJDIR)/$(CIL_PLUGINS_DIR)/%,cil.%,$(CIL_PLUGINS))\"\n" >>$@
	@printf "version = \"$(CIL_VERSION)\"\n" >>$@
	@printf ")\n\n" >>$@
	@$(foreach plugin,$(patsubst $(OBJDIR)/$(CIL_PLUGINS_DIR)/%,%,$(CIL_PLUGINS)),\
	  printf "package \"$(plugin)\" (\n" >> $@;\
	  cat $(CIL_PLUGINS_DIR)/$(plugin)/META >> $@;\
	  printf "version = \"$(CIL_VERSION)\"\n" >>$@;\
	  printf "archive(byte) = \"$(plugin).cma\"\n" >> $@;\
	  printf "archive(byte,plugin) = \"$(plugin).cma\"\n" >> $@;\
	  printf "archive(native) = \"$(plugin).cmxa\"\n" >> $@;\
	  printf "archive(native,plugin) = \"$(plugin).cmxs\"\n" >> $@;\
	  printf ")\n\n" >> $@;\
	)

# cilly perl wrapper
prefix = /usr/local
INSTALL_BASE = $(prefix)

CILLYMOD := Cilly

$(CILLYDIR)/Makefile: $(CILLYDIR)/Makefile.PL $(CILLYDIR)/App/$(CILLYMOD).pm
	cd $(CILLYDIR); $(PERL) Makefile.PL INSTALL_BASE="$(INSTALL_BASE)"

bin/$(CILLY).%: $(OBJDIR)/src/main.%
	cp $< $@

.PHONY: $(CILLY)
$(CILLY): $(CILLY_EXE_BIN) $(CILLYDIR)/Makefile
	$(MAKE) -C $(CILLYDIR)

# Create the machine dependency module
# If the cl command cannot be run then the MSVC part will be identical to GCC
.PHONY : machdep
machdep: $(OBJDIR)/machdep.ml
$(OBJDIR)/machdep.ml : src/machdep-ml.c configure.ac Makefile.in
	@rm -f $@
	@mkdir -p $(OBJDIR)
	@echo "(* This module was generated automatically by code in Makefile and $(<F) *)" >$@
	@echo "type mach = {" >> $@
	@echo "  version_major: int;     (* Major version number *)"    >> $@
	@echo "  version_minor: int;     (* Minor version number *)"    >> $@
	@echo "  version: string;        (* gcc version string *)"      >> $@
	@echo "  underscore_name: bool;  (* If assembly names have leading underscore *)" >> $@
	@echo "  sizeof_short: int;      (* Size of \"short\" *)"       >> $@
	@echo "  sizeof_int: int;        (* Size of \"int\" *)"         >> $@
	@echo "  sizeof_bool: int;       (* Size of \"_Bool\" *)"       >> $@
	@echo "  sizeof_long: int ;      (* Size of \"long\" *)"        >> $@
	@echo "  sizeof_longlong: int;   (* Size of \"long long\" *)"   >> $@
	@echo "  sizeof_ptr: int;        (* Size of pointers *)"        >> $@
	@echo "  sizeof_float: int;      (* Size of \"float\" *)"       >> $@
	@echo "  sizeof_double: int;     (* Size of \"double\" *)"      >> $@
	@echo "  sizeof_longdouble: int; (* Size of \"long double\" *)" >> $@
	@echo "  sizeof_void: int;       (* Size of \"void\" *)"        >> $@
	@echo "  sizeof_fun: int;        (* Size of function *)"        >> $@
	@echo "  size_t: string;         (* Type of \"sizeof(T)\" *)"   >> $@
	@echo "  wchar_t: string;        (* Type of \"wchar_t\" *)"     >> $@
	@echo "  alignof_short: int;     (* Alignment of \"short\" *)"  >> $@
	@echo "  alignof_int: int;       (* Alignment of \"int\" *)"    >> $@
	@echo "  alignof_bool: int;      (* Alignment of \"_Bool\" *)"    >> $@
	@echo "  alignof_long: int;      (* Alignment of \"long\" *)"   >> $@
	@echo "  alignof_longlong: int;  (* Alignment of \"long long\" *)" >> $@
	@echo "  alignof_ptr: int;       (* Alignment of pointers *)"   >> $@
	@echo "  alignof_enum: int;      (* Alignment of enum types *)" >> $@
	@echo "  alignof_float: int;     (* Alignment of \"float\" *)"  >> $@
	@echo "  alignof_double: int;    (* Alignment of \"double\" *)" >> $@
	@echo "  alignof_longdouble: int;  (* Alignment of \"long double\" *)" >> $@
	@echo "  alignof_str: int;       (* Alignment of strings *)" >> $@
	@echo "  alignof_fun: int;       (* Alignment of function *)" >> $@
	@echo "  alignof_aligned: int;   (* Alignment of anything with the \"aligned\" attribute *)" >> $@
	@echo "  char_is_unsigned: bool; (* Whether \"char\" is unsigned *)">> $@
	@echo "  const_string_literals: bool; (* Whether string literals have const chars *)">> $@
	@echo "  little_endian: bool; (* whether the machine is little endian *)">>$@
	@echo "  __thread_is_keyword: bool; (* whether __thread is a keyword *)">>$@
	@echo "  __builtin_va_list: bool; (* whether __builtin_va_list is builtin (gccism) *)">>$@
	@echo "}" >> $@
	@if $(CC) -D_GNUCC $< -o $(OBJDIR)/machdep-ml.exe ;then \
	    echo "machdep-ml.exe created succesfully." \
	;else \
            rm -f $@; exit 1 \
        ;fi
	@echo "let gcc = {" >>$@
	@$(OBJDIR)/machdep-ml.exe >>$@
	@echo "}"          >>$@
	@if cl -D_MSVC $< -Fe$(OBJDIR)/machdep-ml.exe -Fo$(OBJDIR)/machdep-ml.obj ;then \
           echo "let hasMSVC = true" >>$@ ;\
	         echo "let msvc = {" >>$@ ;\
	           $(OBJDIR)/machdep-ml.exe >>$@ ;\
	         echo "}"          >>$@ \
        ;else \
           echo "let hasMSVC = false" >>$@ ;\
					 echo "let msvc = gcc" >> $@ \
			  ;fi
	@echo "let theMachine : mach ref = ref gcc" >>$@

$(CILLYDIR)/App/$(CILLYMOD).pm: $(CILLYDIR)/App/$(CILLYMOD).pm.in src/machdep-ml.c configure.ac Makefile.in
	cp $(CILLYDIR)/App/$(CILLYMOD).pm.in $(CILLYDIR)/App/$(CILLYMOD).pm
	sed -e "s|CIL_VERSION|$(CIL_VERSION)|" $(CILLYDIR)/App/$(CILLYMOD).pm > $(CILLYDIR)/App/$(CILLYMOD).pm.tmp; \
	mv $(CILLYDIR)/App/$(CILLYMOD).pm.tmp $(CILLYDIR)/App/$(CILLYMOD).pm; \
	if $(CC) -D_GNUCC -m32 src/machdep-ml.c -o $(OBJDIR)/machdep-ml32.exe ;then \
	  sed -e "s|nogcc32model|`$(OBJDIR)/machdep-ml32.exe --env`|" $(CILLYDIR)/App/$(CILLYMOD).pm > $(CILLYDIR)/App/$(CILLYMOD).pm.tmp; \
	  mv $(CILLYDIR)/App/$(CILLYMOD).pm.tmp $(CILLYDIR)/App/$(CILLYMOD).pm; \
	fi
	if $(CC) -D_GNUCC -m64 src/machdep-ml.c -o $(OBJDIR)/machdep-ml64.exe ;then \
	  sed -e "s|nogcc64model|`$(OBJDIR)/machdep-ml64.exe --env`|" $(CILLYDIR)/App/$(CILLYMOD).pm > $(CILLYDIR)/App/$(CILLYMOD).pm.tmp; \
	  mv $(CILLYDIR)/App/$(CILLYMOD).pm.tmp $(CILLYDIR)/App/$(CILLYMOD).pm; \
	fi

### DOCUMENTATION

# You should usually run this twice to get all of the references linked
# correctly.
.PHONY: doc
doc: texdoc odoc

.PHONY: odoc texdoc pdfdoc

# Documentation generated by "ocamldoc"
odoc: $(CILDOC_INDEX)
	-rm -rf doc/html/cil/api
	-mkdir -p doc/html/cil/
	-cp -r $(dir $<) doc/html/cil/api

doc/cilpp.tex: doc/cilcode.pl doc/cil.tex $(CILLY)
	-rm -rf doc/html/cil
	-mkdir -p doc/html/cil
	-mkdir -p doc/html/cil/examples
	cd doc; $(PERL) cilcode.pl cil.tex >cilpp.tex.tmp
	mv doc/cilpp.tex.tmp $@

# Documentation generated from latex files using "hevea"
texdoc: doc/cilpp.tex
	cd doc/html/cil; printf '\\def\\cilversion{$(CIL_VERSION)}\n' >cil.version.tex
	cd doc/html/cil; hevea -exec xxdate.exe ../../cilpp
	cd doc/html/cil; hevea -exec xxdate.exe ../../cilpp
	cd doc/html/cil; mv cilpp.html cil.html
	cd doc/html/cil; hacha -o ciltoc.html cil.html
	cp -f doc/index.html doc/html/cil/index.html
	cp -f doc/header.html doc/html/cil

pdfdoc: doc/cilpp.tex
	cd doc; printf '\\def\\cilversion{$(CIL_VERSION)}\n' >cil.version.tex
	cd doc; pdflatex cilpp.tex; pdflatex cilpp.tex
	cd doc; mv cilpp.pdf html/cil/CIL.pdf

.PHONY: distclean clean
distclean: clean
	$(MAKE) -C test distclean
	rm -rf autom4te.cache/
	rm -f Makefile
	rm -f $(CILLYDIR)/App/$(CILLYMOD)/CilConfig.pm
	rm -f config.h
	rm -f config.log
	rm -f config.mk
	rm -f config.status
	rm -f doc/header.html
	rm -f doc/index.html
	rm -f src/machdep-ml.c src/cilversion.ml
	rm -f stamp-h

clean: $(CILLYDIR)/Makefile
	rm -rf $(OBJDIR)
	rm -f $(BINDIR)/$(CILLY).*
	rm -rf lib/cil share/
	rm -f META
	rm -rf doc/html/
	rm -rf doc/cilcode.tmp/
	rm -f doc/cil.version.*
	rm -f doc/cilpp.*
	$(MAKE) -C $(CILLYDIR) clean
	rm -f $(CILLYDIR)/App/$(CILLYMOD).pm
	rm -f $(CILLYDIR)/Makefile.old
	$(MAKE) -C test clean

.PHONY: test
test:
ifneq ($(VERBOSE),)
	cd test; CC=gcc ./testcil -r --regrtest || { cat cil.log; exit 1; }
else
	cd test; CC=gcc ./testcil -r --regrtest
endif

########################################################################

INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644

exec_prefix = ${prefix}
datarootdir = ${prefix}/share
datadir = $(datarootdir)/cil
bindir = ${exec_prefix}/bin

CYGPATH=

# Make DESTDIR absolute (necessary for perl installation), and add trailing
# backspace.
ifneq ($(DESTDIR),)
  ifneq ($(CYGPATH),)
    override DESTDIR := $(shell $(CYGPATH) -ua $(DESTDIR)/)
  else
    override DESTDIR := $(abspath $(DESTDIR)/)
  endif
endif

MAKE_CILLY = $(MAKE) -C $(CILLYDIR) DESTDIR=$(DESTDIR) INSTALL_BASE=$(INSTALL_BASE)

install: $(CILLY) install-findlib install-data
	$(MAKE_CILLY) pure_install
	$(INSTALL) -m 0755 $(BINDIR)/$(CILLY).* $(DESTDIR)$(bindir)

uninstall: $(CILLYDIR)/Makefile uninstall-findlib uninstall-data
	-rm -f $(DESTDIR)$(bindir)/$(CILLY).*
	$(MAKE_CILLY) force_uninstall

.PHONY: install-findlib uninstall-findlib

# Get the default OCAMLFIND_DESTDIR
OCAMLFIND_DESTDIR=$(shell ocamlfind printconf destdir)

# Add DESTDIR in front of OCAMLFIND_DESTDIR. Do the necessary conversions on
# cygwin, since the former is in unix format whereas the later and the result
# are in windows (mixed) format.
ifneq ($(CYGPATH),)
  OCAMLFIND_UNIXDIR=$(shell $(CYGPATH) -ua "$(OCAMLFIND_DESTDIR)")
  OCAMLFIND_INSTALLDIR=$(shell $(CYGPATH) -ma "$(DESTDIR)$(OCAMLFIND_UNIXDIR)")
else
  OCAMLFIND_INSTALLDIR=$(DESTDIR)$(OCAMLFIND_DESTDIR)
endif

install-findlib: META $(CILLIB_FILES) $(CILLIB_TARGETS) uninstall-findlib
	mkdir -p $(OCAMLFIND_INSTALLDIR)
	OCAMLFIND_DESTDIR=$(OCAMLFIND_INSTALLDIR) \
	  $(OCAMLFIND) install cil META $(CILLIB_TARGETS) `cat $(CILLIB_FILES)`

uninstall-findlib:
	OCAMLFIND_DESTDIR=$(OCAMLFIND_INSTALLDIR) $(OCAMLFIND) remove cil

.PHONY: install-data uninstall-data
install-data:
	mkdir -p $(DESTDIR)$(datadir)
ifneq ($(CYGPATH),)
	printf $(shell $(CYGPATH) -ma "$(OCAMLFIND_DESTDIR)") > ocamlpath
else
	printf $(abspath $(OCAMLFIND_DESTDIR)) > ocamlpath
endif
	$(INSTALL_DATA) ocamlpath $(DESTDIR)$(datadir)
	rm -f ocamlpath

uninstall-data:
	rm -rf $(DESTDIR)$(datadir)

.PHONY: install-local
# Recursive call to install-findlib builds $(CILLIB_TARGETS)
install-local:
	$(MAKE) $(CILLY) install-findlib install-data PREFIX=. datarootdir=share DESTDIR= OCAMLFIND_DESTDIR=lib
