MAKE+=--no-print-directory
MAKEFLAGS+=--no-print-directory

############################

SWIG_TARGETS=ruby python tcl guile java
SWIG_TARGET=UNDEFINED

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
#SWIG_CFLAGS += -DSWIGRUNTIME_DEBUG=1
#CFLAGS_SO += -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
CFLAGS_SO += -dynamiclib -Wl,-undefined,dynamic_lookup # OSX
SWIG_SO_SUFFIX=$(SWIG_SO_SUFFIX_$(SWIG_TARGET))
SWIG_SO_PREFIX=$(SWIG_SO_PREFIX_$(SWIG_TARGET))

############################

SWIG_CFLAGS_ruby:=$(shell ruby -rrbconfig -e 'include RbConfig; puts "-I#{CONFIG["rubyhdrdir"]} -I#{CONFIG["rubyarchhdrdir"]}"')
SWIG_SO_SUFFIX_ruby=bundle # OSX

############################

PYTHON_VERSION=3.8
PYTHON_ROOT=/opt/local/Library/Frameworks/Python.framework/Versions/$(PYTHON_VERSION)
SWIG_CFLAGS_python=-I$(PYTHON_ROOT)/include/python$(PYTHON_VERSION) -Wno-deprecated-declarations
SWIG_SO_PREFIX_python=_
SWIG_SO_SUFFIX_python=so # OSX

############################

TCL_HOME:=$(abspath $(shell which tclsh)/../..)
SWIG_CFLAGS_tcl=-I$(TCL_HOME)/include
#SWIG_SO_PREFIX_tcl=lib
SWIG_SO_SUFFIX_tcl=so # OSX

############################

GUILE_VERSION=2.2
GUILE_HOME:=$(abspath $(shell which guile)/../..)
GUILE_EXE=$(GUILE_HOME)/bin/guile
GUILE_INCL=$(GUILE_HOME)/include/guile/$(GUILE_VERSION)
SWIG_OPTS_guile=-scmstub
SWIG_CFLAGS_guile=-I$(GUILE_INCL) -I$(GUILE_INCL)/libguile
SWIG_SO_PREFIX_guile=lib
SWIG_SO_SUFFIX_guile=so # OSX

############################

# JAVA_VERSION=11.0.2
JAVA_HOME:=$(abspath $(shell which java)/../..)
JAVA_INCL=$(JAVA_HOME)/include
JAVA_LIB=$(JAVA_HOME)/lib
JAVA_EXE=$(JAVA_HOME)/bin/java
SWIG_CFLAGS_java=-I$(JAVA_INCL) -I$(JAVA_INCL)/darwin
SWIG_SO_PREFIX_java=lib
SWIG_SO_SUFFIX_java=jnilib # OSX

############################

EXAMPLES=example1.c

############################

all: early build-examples

early:
	@mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

#################################

EXAMPLE_NAME:=$(basename $(EXAMPLE))

build-examples:
	@echo "\n# Examples \n"
	@for e in $(EXAMPLES) ;\
	do \
	  $(MAKE) --no-print-directory build-example EXAMPLE=$$e ;\
	done

build-example: early build-example-announce build-native build-targets

build-example-announce:
	@echo "\n## $(EXAMPLE) \n"

#################################

NATIVE_DEPS = \
  target/native/$(EXAMPLE_NAME).o \
  target/native/$(EXAMPLE_NAME) \

build-native: early $(NATIVE_DEPS)

target/native/$(EXAMPLE_NAME).o : src/$(EXAMPLE)
	@echo "\n### Compile native code\n\n\`\`\`"
	$(CC) $(CFLAGS) -c -o $@ $<
	@echo "\`\`\`"

target/native/$(EXAMPLE_NAME) : src/$(EXAMPLE_NAME)-native$(suffix $(EXAMPLE))
	@mkdir -p $(dir $@)
	@echo "\n### Compile native program\n\n\`\`\`"
	$(CC) $(CFLAGS) -o $@ $< target/native/$(EXAMPLE_NAME).o
	@echo "\`\`\`"

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
	target/$(SWIG_TARGET)/$(SWIG_SO_PREFIX)$(EXAMPLE_NAME).$(SWIG_SO_SUFFIX)

build-target: early build-target-announce $(TARGET_DEPS)

build-target-announce:
	@echo "\n## Build $(SWIG_TARGET) SWIG wrapper\n"

target/$(SWIG_TARGET)/$(EXAMPLE) : src/$(EXAMPLE_NAME).h
	@mkdir -p $(dir $@)
	@echo "\n### Generate $(SWIG_TARGET) SWIG wrapper\n\n\`\`\`"
	swig $(SWIG_OPTS) -$(SWIG_TARGET) -o $@ $<
	wc -l $@
	@echo "\`\`\`"

target/$(SWIG_TARGET)/$(EXAMPLE_NAME).o : target/$(SWIG_TARGET)/$(EXAMPLE)
	@mkdir -p $(dir $@)
	@echo "\n### Compile $(SWIG_TARGET) SWIG wrapper\n\n\`\`\`"
	$(CC) $(CFLAGS) $(SWIG_CFLAGS) -c -o $@ $<
	@echo "\`\`\`"

target/$(SWIG_TARGET)/$(SWIG_SO_PREFIX)$(EXAMPLE_NAME).$(SWIG_SO_SUFFIX) : target/$(SWIG_TARGET)/$(EXAMPLE_NAME).o
	@mkdir -p $(dir $@)
	@echo "\n### Link $(SWIG_TARGET) SWIG wrapper dynamic library\n\n\`\`\`"
	$(CC) $(CFLAGS) $(CFLAGS_SO) -o $@ target/native/$(EXAMPLE_NAME).o $<
	@echo "\`\`\`"

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

#################################

clean:
	rm -rf target/*

