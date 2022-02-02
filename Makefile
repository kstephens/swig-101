#!bin/build

MAKE+=--no-print-directory
MAKEFLAGS+=--no-print-directory
UNAME_S:=$(shell uname -s)

############################

SWIG_EXE?=$(shell which swig)
SWIG_TARGETS=ruby python tcl guile java
SWIG_TARGET=UNDEFINED

SWIG_SO_PREFIX_DEFAULT=

ifeq "$(UNAME_S)" "CYGWIN_NT-10.0"
# https://cygwin.com/cygwin-ug-net/dll.html
  SWIG_SO_SUFFIX_DEFAULT=.dll
  CFLAGS_SO += -shared # GCC
else
  SWIG_SO_SUFFIX_DEFAULT=.so
  #CFLAGS_SO += -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
  CFLAGS_SO += -dynamiclib -Wl,-undefined,dynamic_lookup # OSX, Linux
endif

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

CFLAGS += -g -O3
CFLAGS += -Isrc
CFLAGS += -I/opt/local/include # OSX macports
SWIG_CFLAGS=$(SWIG_CFLAGS_$(SWIG_TARGET))
SWIG_LDFLAGS=$(SWIG_LDFLAGS_$(SWIG_TARGET))
#SWIG_CFLAGS += -DSWIGRUNTIME_DEBUG=1

############################

SWIG_CFLAGS_ruby:=$(shell ruby tool/ruby-cflags.rb)
SWIG_SO_SUFFIX_ruby:=.bundle # OSX

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
SWIG_CFLAGS_java:=-I$(JAVA_INCL) -I$(JAVA_INCL)/darwin
SWIG_SO_PREFIX_java:=lib
SWIG_SO_SUFFIX_java:=.jnilib # OSX

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

CFLAGS+=$(CFLAGS_SUFFIX$(EXAMPLE_SUFFIX))
#LDFLAGS+= ???
CFLAGS_SUFFIX.c=
CFLAGS_SUFFIX.cc=-Wno-c++11-extensions -stdlib=libc++

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
	@set -x; time src/example1-ruby
	@set -x; time src/example1-python
	@set -x; time src/example1-guile
	@set -x; time src/example1-tcl
	@set -x; time bin/run-clj src/example1-clojure

	@set -x; time target/native/example2

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

