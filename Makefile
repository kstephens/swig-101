#!bin/build

############################

EXAMPLES         = libtommath.c # polynomial.cc polynomial_v2.cc example1.c
SWIG_TARGETS     = python  # clojure  ruby  tcl  guile
TARGET_SUFFIXES  = py      # clj      rb    tcl  scm
LIBS += -ltommath

SWIG_CFLAGS_libtommath.c+=-Wno-sentinel
SWIG_CFLAGS+=-Wno-sentinel

############################

MAKE+=--no-print-directory
MAKEFLAGS+=--no-print-directory
UNAME_S:=$(shell uname -s)
SILENT=@

############################

DEBUG     += -g
CFLAGS    += $(DEBUG) $(INC_DIRS)
CXXFLAGS  += $(DEBUG) $(INC_DIRS)
LDFLAGS   += $(LIB_DIRS) $(LIBS)

INC_DIRS      += -Isrc
INC_DIRS      += -Ilocal/include
LIB_DIRS      += -Llocal/lib

############################

SWIG_TARGET=UNDEFINED

SWIG_EXE?=$(shell which swig)
SWIG_SO_PREFIX_DEFAULT=
SWIG_SO_SUFFIX_DEFAULT=.so

SWIG_SO_SUFFIX_ruby=.so # Linux

ifeq "$(UNAME_S)" "CYGWIN_NT-10.0"
# https://cygwin.com/cygwin-ug-net/dll.html
  SWIG_SO_SUFFIX_DEFAULT=.dll
  CFLAGS_SO += -shared # GCC
endif
ifeq "$(UNAME_S)" "Linux"
  # Linux: GCC 7.5.0 ???	
  CFLAGS += -fPIC
  CFLAGS_SO += -shared
  # CFLAGS_SO += -fPIC -shared	
endif
ifeq "$(UNAME_S)" "Darwin"
  # OSX macports
  INC_DIRS      += -I/opt/local/include
  LIB_DIRS      += -L/opt/local/lib
  CFLAGS_SO += -dynamiclib -Wl,-undefined,dynamic_lookup
  SWIG_SO_SUFFIX_ruby:=.bundle
endif

############################

SWIG_OPTS += \
	-addextern \
	-I- $(INC_DIRS) \
	$(SWIG_OPTS_$(SWIG_TARGET))
SWIG_OPTS_x += \
     -debug-module 1,2,3,4 \
     -debug-symtabs  \
     -debug-symbols  \
     -debug-csymbols \
     -debug-symbols \
     -debug-tags     \
     -debug-template \
     -debug-top 1,2,3,4 \
     -debug-typedef  \
     -debug-typemap  \
     -debug-tmsearch \
     -debug-tmused

############################

SUFFIX_ruby=rb
SWIG_OPTS_ruby=-ruby
SWIG_CFLAGS_ruby:=$(shell ruby tool/ruby-cflags.rb)

############################

PYTHON_VERSION=3.10
PYTHON_MAJOR_VERSION=3
PYTHON_CONFIG:=$(shell which python$(PYTHON_VERSION)-config python$(PYTHON_MAJOR_VERSION)-config python-config 2>/dev/null | head -1)
PYTHON_EXE:=$(shell which python$(PYTHON_MAJOR_VERSION) python 2>/dev/null | head -1)

SUFFIX_python=py
SWIG_OPTS_python=-python
SWIG_CFLAGS_python:=$(shell $(PYTHON_CONFIG) --cflags) -Wno-deprecated-declarations
SWIG_LDFLAGS_python:=$(shell $(PYTHON_CONFIG) --ldflags)
SWIG_SO_PREFIX_python:=_
SWIG_GENERATED_FILES_python=target/$(SWIG_TARGET)/$(EXAMPLE_SWIG).py

############################

SUFFIX_tcl=tcl
SWIG_OPTS_tcl=-tcl
SWIG_CFLAGS_tcl:=-I$(TCL_HOME)/include
SWIG_CFLAGS_tcl:=-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>

############################

SUFFIX_guile=scm
SWIG_OPTS_guile=-guile
SWIG_CFLAGS_guile:=$(shell guile-config compile) #
SWIG_LDFLAGS_guile:=$(shell guile-config link) #
SWIG_SO_PREFIX_guile:=lib

############################

SUFFIX_clojure=clj
SWIG_OPTS_clojure=-java
# SWIG_OPTS_clojure=-package $(EXAMPLE_NAME)
SWIG_CFLAGS_clojure=-I$(JAVA_INC) -I$(JAVA_INC)/linux -I$(JAVA_INC)/darwin
SWIG_SO_PREFIX_clojure=lib
SWIG_SO_SUFFIX_clojure=.jnilib # OSX
SWIG_GENERATED_FILES_clojure=target/$(SWIG_TARGET)/$(EXAMPLE_NAME)*.java

############################

SWIG_CFLAGS_xml:= #-I$(TCL_HOME)/include
SWIG_CFLAGS_xml:= #-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>

############################

SWIG_CFLAGS+=$(SWIG_CFLAGS_$(SWIG_TARGET))
SWIG_CFLAGS+=$(SWIG_CFLAGS_$(EXAMPLE_NAME))
SWIG_LDFLAGS=$(SWIG_LDFLAGS_$(SWIG_TARGET))
SWIG_LDFLAGS+=$(SWIG_LDFLAGS_$(EXAMPLE_NAME))
#SWIG_CFLAGS += -DSWIGRUNTIME_DEBUG=1

############################

all: early build-examples

early: local-dirs
	$(SILENT)mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

#################################

EXAMPLE_NAME:=$(basename $(EXAMPLE))
EXAMPLE_SUFFIX:=$(suffix $(EXAMPLE))
EXAMPLE_SWIG:=$(EXAMPLE_NAME)_swig

############################

SWIG_SO_SUFFIX:=$(SWIG_SO_SUFFIX_$(SWIG_TARGET))
SWIG_SO_PREFIX:=$(SWIG_SO_PREFIX_$(SWIG_TARGET))

ifeq "$(SWIG_SO_PREFIX)" ""
SWIG_SO_PREFIX:=$(SWIG_SO_PREFIX_DEFAULT)
endif

ifeq "$(SWIG_SO_SUFFIX)" ""
SWIG_SO_SUFFIX:=$(SWIG_SO_SUFFIX_DEFAULT)
endif

############################

SWIG_OPTS+=$(SWIG_OPTS_SUFFIX$(EXAMPLE_SUFFIX))
SWIG_OPTS_SUFFIX.c=
SWIG_OPTS_SUFFIX.cc=-c++

CC=$(CC_SUFFIX$(EXAMPLE_SUFFIX))
CC_SUFFIX.c=clang
CC_SUFFIX.cc=clang++
ifeq "$(UNAME_S)" "Linux"
# WTF: wud: broken clang install??!?!?!
CC_SUFFIX.c=gcc
CC_SUFFIX.cc=g++
endif

CFLAGS+=$(CFLAGS_SUFFIX$(EXAMPLE_SUFFIX))
#LDFLAGS+= ???
CFLAGS_SUFFIX.c=
ifeq "$(UNAME_S)" "Linux"
# WTF: wud: broken clang install??!?!?!
else
CFLAGS_SUFFIX.cc=-Wno-c++11-extensions -stdlib=libc++
CFLAGS_SUFFIX.cc+= -std=c++17
endif

#################################

NATIVE_SRCS = \
  src/$(EXAMPLE) \
  src/$(EXAMPLE_NAME).h

NATIVE_DEPS = \
  target/native/$(EXAMPLE_NAME).o \
  target/native/$(EXAMPLE_NAME)

TARGET_SWIG=target/$(SWIG_TARGET)/$(EXAMPLE_SWIG)$(EXAMPLE_SUFFIX)
TARGET_SWIG_O=$(TARGET_SWIG).o
TARGET_SWIG_SO=$(dir $(TARGET_SWIG_O))/$(SWIG_SO_PREFIX)$(EXAMPLE_SWIG)$(SWIG_SO_SUFFIX)
TARGET_DEPS:= \
	$(TARGET_SWIG) \
	$(TARGET_SWIG_O) \
	$(TARGET_SWIG_SO)

#############################

ifeq "$(EXAMPLE_NAME)" "polynomial"
ifeq "$(UNAME_S)" "Linux"
# target/ruby/polynomial.cc: In function ‘void SWIG_RubyInitializeTrackings()’:
# target/ruby/polynomial.cc:1263:85: error: call of overloaded ‘rb_define_virtual_variable(const char [21], VALUE (&)(...), NULL)’ is ambiguous
#   rb_define_virtual_variable("SWIG_TRACKINGS_COUNT", swig_ruby_trackings_count, NULL);
SWIG_TARGETS:=$(filter-out ruby, $(SWIG_TARGETS))
TARGET_DEPS:=$(filter-out ruby, $(TARGET_DEPS))
# /usr/include/guile/2.2/libguile/deprecated.h:115:21: error: ‘scm_listify__GONE__REPLACE_WITH__scm_list_n’ was not declared in this scope
SWIG_TARGETS:=$(filter-out guile, $(SWIG_TARGETS))
TARGET_DEPS:=$(filter-out guile, $(TARGET_DEPS))
endif
endif

ifeq "$(EXAMPLE_NAME)" "libtommath"
# tcl.h forward declares struct mp_int!
# target/tcl/libtommath_swig.c:2330:19: error: incomplete definition of type 'struct mp_int'
SWIG_TARGETS:=$(filter-out tcl, $(SWIG_TARGETS))
TARGET_DEPS:=$(filter-out tcl, $(TARGET_DEPS))
endif

#################################

build-examples:
	$(SILENT)set -e; for e in $(EXAMPLES) ;\
	do \
	  $(MAKE) build-example EXAMPLE=$$e ;\
	done

build-example: early build-example-begin build-native build-targets build-example-end

build-example-begin:
	$(SILENT)echo "\n## Workflow - $(EXAMPLE) \n"

build-example-end:

#################################

build-native: early build-native-begin $(NATIVE_DEPS) build-native-end

build-native-begin:
	$(SILENT)echo "### Compile native code:\n"
	$(SILENT)echo "\`\`\`\n"

target/native/$(EXAMPLE_NAME).o : $(NATIVE_SRCS)
	$(SILENT)echo "# Compile native library:"
	$(CC) $(CFLAGS) -c -o $@ $<
	$(SILENT)echo ""

target/native/$(EXAMPLE_NAME) : src/$(EXAMPLE_NAME)-native$(suffix $(EXAMPLE)) target/native/$(EXAMPLE_NAME).o
	$(SILENT)mkdir -p $(dir $@)
	$(SILENT)echo "# Compile and link native program:"
	$(CC) $(CFLAGS) -o $@ $< $@.o $(LDFLAGS)
	$(SILENT)echo ""

build-native-end:
	$(SILENT)echo "\`\`\`\n"

#################################

build-targets:
	$(SILENT)set -e ;\
	for t in $(SWIG_TARGETS) ;\
	do \
	  $(MAKE) build-target EXAMPLE=$(EXAMPLE) SWIG_TARGET=$$t ;\
	done

build-target: early build-target-begin $(TARGET_DEPS) build-target-end

build-target-begin:
	$(SILENT)echo "### Build $(SWIG_TARGET) bindings\n\`\`\`\n"

build-target-end:
	$(SILENT)echo "\`\`\`\n"

$(TARGET_SWIG) : src/$(EXAMPLE_NAME).i $(NATIVE_SRCS)
	$(SILENT)mkdir -p $(dir $@)
	$(SILENT)echo "# Generate $(SWIG_TARGET) bindings:"
	$(SWIG_EXE) $(SWIG_OPTS) -outdir $(dir $@) -o $@ src/$(EXAMPLE_NAME).i
	$(SILENT)echo "# Code statistics:"
	wc -l src/$(EXAMPLE_NAME).h src/$(EXAMPLE_NAME).i
	$(SILENT)echo ''
	wc -l $@ $(SWIG_GENERATED_FILES_$(SWIG_TARGET))
	$(SILENT)echo ''
#	grep -siH $(EXAMPLE_NAME) $@ $(SWIG_GENERATED_FILES_$(SWIG_TARGET))
#	$(SILENT)echo ''
	-$(SILENT)$(SWIG_EXE) $(SWIG_OPTS) -xml -o $@ src/$(EXAMPLE_NAME).i 2>/dev/null || true

$(TARGET_SWIG_O) : $(TARGET_SWIG)
	$(SILENT)mkdir -p $(dir $@)
	$(SILENT)echo "\n# Compile $(SWIG_TARGET) bindings:"
	$(CC) $(CFLAGS) $(SWIG_CFLAGS) -c -o $@ $<
	$(SILENT)echo ""

$(TARGET_SWIG_SO) : $(TARGET_SWIG_O)
	$(SILENT)mkdir -p $(dir $@)
	$(SILENT)echo "\n# Link $(SWIG_TARGET) dynamic library:"
	$(CC) $(CFLAGS) $(CFLAGS_SO) -o $@ target/native/$(EXAMPLE_NAME).o $< $(SWIG_LDFLAGS) $(LDFLAGS)
	$(SILENT)echo ""

#################################

RUN="bin/run"

demo: clean all demo-run
demo-run:
	$(SILENT)set -e ;\
	for example in $(basename $(EXAMPLES)) ;\
	do \
	   (set -x; $(RUN) target/native/$$example) ;\
	   for suffix in $(TARGET_SUFFIXES) ;\
	   do \
	     [ -f src/$$example.$$suffix ] && (set -x; $(RUN) src/$$example.$$suffix) ;\
	   done \
	done

#################################

macports-prereq:
	sudo port    install automake libtool autoconf bison tcl     guile python310 py310-pip
	pip-3.10 install pytest

debian-prereq:
	sudo apt-get install automake libtool autoconf bison tcl-dev guile-2.2-dev

#################################

README.md : tmp/README.md 
	cp tmp/$@ $@
tmp/README.md: doc/README.md.erb doc/*.* src/*.* Makefile
	$(MAKE) clean
	mkdir -p tmp
	erb $< > $@

#################################

clean:
	rm -f ~/.cache/guile/**/swig-101/**/*-guile.go
	rm -rf target/*

clean-example:
	$(SILENT)rm -rf target/*/*$(EXAMPLE_NAME)*


#################################

local-tools: swig libtommath

local-dirs:
	mkdir -p local/src local/lib local/include local/bin

#################################

swig : local-dirs local/bin/swig

local/bin/swig : local/src/swig/pcre/README
	@set -xe ;\
	export PREFIX="$$(/bin/pwd)/local" ;\
	git clone https://github.com/swig/swig.git local/src/swig
	cd local/src/swig ;\
	git checkout 6939d91e4c6ea ;\
	cd local/src/swig ;\
	./autogen.sh ;\
	./configure --prefix="$$PREFIX" ;\
	make -j ;\
	make install

local/src/swig/pcre/README :
	@set -xe ;\
	mkdir -p local/src/swig ;\
	cd local/src/swig ;\
	pcre2_version='10.39' ;\
	curl -L -O https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$$pcre2_version/pcre2-$$pcre2_version.tar.gz ;\
	./Tools/pcre-build.sh

#################################

libtommath : local-dirs local/lib/libtommath.a

local/lib/libtommath.a :
	@set -xe ;\
	git clone https://github.com/libtom/libtommath.git local/src/libtommath ;\
	cd local/src/libtommath ;\
	git checkout 4b473685013 ;\
	mkdir -p local/lib local/include/libtommath
	(mkdir -p local/src/libtommath/build ;\
	cd local/src/libtommath/build ;\
	cmake .. ;\
	make clean ;\
	make -j ;\
	) ;\
	cp -p local/src/libtommath/build/libtommath.a $@ ;\
	cp -p local/src/libtommath/*.h local/include/libtommath/

