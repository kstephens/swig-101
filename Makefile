#!bin/build

MAKE+=--no-print-directory
MAKEFLAGS+=--no-print-directory
UNAME_S:=$(shell uname -s)

############################

SWIG_EXE?=$(shell which swig)
SWIG_TARGETS:=python ruby tcl guile java
SWIG_TARGET=UNDEFINED

############################

SWIG_SO_PREFIX_DEFAULT=
SWIG_SO_SUFFIX_DEFAULT=.so

SWIG_SO_SUFFIX_ruby:=.so # Linux

ifeq "$(UNAME_S)" "CYGWIN_NT-10.0"
# https://cygwin.com/cygwin-ug-net/dll.html
  SWIG_SO_SUFFIX_DEFAULT=.dll
  CFLAGS_SO += -shared # GCC
endif
ifeq "$(UNAME_S)" "Linux"
  # Linux: GCC 7.5.0 ???	
  CFLAGS += -fPIC -shared
  # CFLAGS_SO += -fPIC -shared	

# target/ruby/example2.cc: In function ‘void SWIG_RubyInitializeTrackings()’:
# target/ruby/example2.cc:1263:85: error: call of overloaded ‘rb_define_virtual_variable(const char [21], VALUE (&)(...), NULL)’ is ambiguous
#   rb_define_virtual_variable("SWIG_TRACKINGS_COUNT", swig_ruby_trackings_count, NULL);
SWIG_TARGETS:=$(filter-out ruby, $(SWIG_TARGETS))

# /usr/include/guile/2.2/libguile/deprecated.h:115:21: error: ‘scm_listify__GONE__REPLACE_WITH__scm_list_n’ was not declared in this scope
SWIG_TARGETS:=$(filter-out guile, $(SWIG_TARGETS))

  ifeq "$(EXAMPLE)" "example2"
    SWIG_TARGETS:=$(filter-out ruby, $(SWIG_TARGETS))
  endif
endif
ifeq "$(UNAME_S)" "Darwin"
  #CFLAGS_SO += -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
  CFLAGS_SO += -dynamiclib -Wl,-undefined,dynamic_lookup
  SWIG_SO_SUFFIX_ruby:=.bundle
endif

############################

SWIG_OPTS += \
	-addextern -I- \
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

CFLAGS += -g
CFLAGS += -Isrc
CFLAGS += -I/opt/local/include # OSX macports
SWIG_CFLAGS=$(SWIG_CFLAGS_$(SWIG_TARGET))
SWIG_LDFLAGS=$(SWIG_LDFLAGS_$(SWIG_TARGET))
#SWIG_CFLAGS += -DSWIGRUNTIME_DEBUG=1
CXXFLAGS += -g
CXXFLAGS += -Isrc

############################

SWIG_CFLAGS_ruby:=$(shell ruby tool/ruby-cflags.rb)

############################

PYTHON_VERSION=3.10
PYTHON_MAJOR_VERSION=3
PYTHON_CONFIG:=$(shell which python$(PYTHON_VERSION)-config python$(PYTHON_MAJOR_VERSION)-config python-config 2>/dev/null | head -1)
PYTHON_EXE:=$(shell which python$(PYTHON_MAJOR_VERSION) python 2>/dev/null | head -1)
SWIG_CFLAGS_python:=$(shell $(PYTHON_CONFIG) --cflags) -Wno-deprecated-declarations
SWIG_LDFLAGS_python:=$(shell $(PYTHON_CONFIG) --ldflags)
SWIG_OPTS_python:=-py3
SWIG_SO_PREFIX_python:=_

############################

TCL_HOME:=$(abspath $(shell which tclsh)/../..)
SWIG_CFLAGS_tcl:=-I$(TCL_HOME)/include
SWIG_CFLAGS_tcl:=-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>

############################

GUILE_VERSION:=2.2
GUILE_HOME:=$(abspath $(shell which guile)/../..)
GUILE_EXE:=$(GUILE_HOME)/bin/guile
SWIG_OPTS_guile=-scmstub
SWIG_CFLAGS_guile:=$(shell guile-config compile) #
SWIG_LDFLAGS_guile:=$(shell guile-config link) #
SWIG_SO_PREFIX_guile:=lib

############################

# JAVA_VERSION=11.0.2
JAVA_HOME:=$(abspath $(shell which java)/../..)
JAVA_INCL:=$(JAVA_HOME)/include
JAVA_LIB:=$(JAVA_HOME)/lib
JAVA_EXE:=$(JAVA_HOME)/bin/java
SWIG_CFLAGS_java:=-I$(JAVA_INCL) -I$(JAVA_INCL)/linux -I$(JAVA_INCL)/darwin
SWIG_SO_PREFIX_java:=lib
SWIG_SO_SUFFIX_java:=.jnilib # OSX
# debian prereq: openjdk-11-jdk-headless

############################

EXAMPLES = \
  example1.c \
  example2.cc

############################

all: early build-examples

early:
	@mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

#################################

EXAMPLE_NAME:=$(basename $(EXAMPLE))
EXAMPLE_SUFFIX:=$(suffix $(EXAMPLE))

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

build-examples:
	@echo "\n# Examples \n"
	@for e in $(EXAMPLES) ;\
	do \
	  $(MAKE) --no-print-directory build-example EXAMPLE=$$e ;\
	done

build-example: early build-example-begin build-native build-targets build-example-end

build-example-begin:
	@echo "\n# Build $(EXAMPLE) \n"

build-example-end:

#################################

NATIVE_DEPS = \
  target/native/$(EXAMPLE_NAME).o \
  target/native/$(EXAMPLE_NAME) \

build-native: early build-native-begin $(NATIVE_DEPS) build-native-end

build-native-begin:
	@echo "\n## Build $(EXAMPLE) Native Code\n\`\`\`"

build-native-end:
	@echo "\`\`\`\n"

target/native/$(EXAMPLE_NAME).o : src/$(EXAMPLE)
	@echo "\n# Compile native library:"
	$(CC) $(CFLAGS) -c -o $@ $<

target/native/$(EXAMPLE_NAME) : src/$(EXAMPLE_NAME)-native$(suffix $(EXAMPLE))
	@mkdir -p $(dir $@)
	@echo "\n# Compile and link native program:"
	$(CC) $(CFLAGS) -o $@ $< target/native/$(EXAMPLE_NAME).o

#################################

build-targets : Makefile
	@set -e ;\
	for t in $(SWIG_TARGETS) ;\
	do \
	  $(MAKE) --no-print-directory build-target EXAMPLE=$(EXAMPLE) SWIG_TARGET=$$t ;\
	done

TARGET_DEPS = \
	target/$(SWIG_TARGET)/$(EXAMPLE) \
	target/$(SWIG_TARGET)/$(EXAMPLE_NAME).o \
	target/$(SWIG_TARGET)/$(SWIG_SO_PREFIX)$(EXAMPLE_NAME)$(SWIG_SO_SUFFIX)

build-target: early build-target-begin $(TARGET_DEPS) build-target-end

build-target-begin:
	@echo "\n## Build $(SWIG_TARGET) SWIG wrapper\n\`\`\`"

build-target-end:
	@echo "\`\`\`\n"

target/$(SWIG_TARGET)/$(EXAMPLE) : src/$(EXAMPLE_NAME).h
	@mkdir -p $(dir $@)
	@echo "\n# Generate $(SWIG_TARGET) SWIG wrapper:"
	$(SWIG_EXE) $(SWIG_OPTS) -$(SWIG_TARGET) -o $@ $<
	@echo ''
	wc -l $@

target/$(SWIG_TARGET)/$(EXAMPLE_NAME).o : target/$(SWIG_TARGET)/$(EXAMPLE)
	@mkdir -p $(dir $@)
	@echo "\n# Compile $(SWIG_TARGET) SWIG wrapper:"
	$(CC) $(CFLAGS) $(SWIG_CFLAGS) -c -o $@ $<

target/$(SWIG_TARGET)/$(SWIG_SO_PREFIX)$(EXAMPLE_NAME)$(SWIG_SO_SUFFIX) : target/$(SWIG_TARGET)/$(EXAMPLE_NAME).o
	@mkdir -p $(dir $@)
	@echo "\n# Link $(SWIG_TARGET) SWIG wrapper dynamic library:"
	$(CC) $(CFLAGS) $(CFLAGS_SO) -o $@ target/native/$(EXAMPLE_NAME).o $< $(SWIG_LDFLAGS)

#################################

%.md : all %.md.erb src/* Makefile
	erb -T 2 $@.erb | sed -E -e 's@$(HOME)@$$HOME@g' > $@

#################################

demo:
	$(MAKE) clean all
	@set -x; time target/native/example1
	@set -x; time src/example1-python
	@set -x; time src/example1-ruby
	@set -x; time src/example1-tcl
	@set -x; time src/example1-guile
	@set -x; time bin/run-clj src/example1-clojure

	@set -x; time target/native/example2
	@set -x; time src/example2-python
	@set -x; time src/example2-ruby
	@set -x; time src/example2-tcl
#	@set -x; time src/example2-guile
	@set -x; time bin/run-clj src/example2-clojure

#################################

macports-prereq:
	sudo port install $(SWIG_TARGETS:%=swig-%)

#################################

README.md : README.md.erb clean
	erb $< > $@.tmp
	mv $@.tmp $@

#################################

clean:
	rm -rf target/*

clean-example:
	rm -rfv target/*/$(EXAMPLE_NAME)*

