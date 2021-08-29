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
CFLAGS_SWIG=$(CFLAGS_SWIG_$(SWIG_TARGET))
#CFLAGS_SWIG += -DSWIGRUNTIME_DEBUG=1
#CFLAGS_SO += -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
CFLAGS_SO += -dynamiclib -Wl,-undefined,dynamic_lookup # OSX
SO_SUFFIX=$(SO_SUFFIX_$(SWIG_TARGET))
SO_PREFIX=$(SO_PREFIX_$(SWIG_TARGET))

############################

RUBY_VERSION=2.3.0
RUBY_ROOT=$(HOME)/.rbenv/versions/$(RUBY_VERSION)
RUBY_INCL=$(RUBY_ROOT)/include/ruby-$(RUBY_VERSION)
RUBY_LIB=$(RUBY_ROOT)/lib
RUBY_EXE=$(RUBY_ROOT)/bin/ruby
CFLAGS_SWIG_ruby=-I$(RUBY_INCL) -I$(RUBY_INCL)/x86_64-darwin18
SO_SUFFIX_ruby=bundle # OSX

############################

PYTHON_VERSION=3.8
PYTHON_ROOT=/opt/local/Library/Frameworks/Python.framework/Versions/$(PYTHON_VERSION)
PYTHON_INCL=$(PYTHON_ROOT)/include/python$(PYTHON_VERSION)
PYTHON_LIB=$(PYTHON_ROOT)/lib
PYTHON_EXE=python$(PYTHON_VERSION)
CFLAGS_SWIG_python=-I$(PYTHON_INCL) -Wno-deprecated-declarations
SO_PREFIX_python=_
SO_SUFFIX_python=so # OSX

############################

TCL_VERSION=2.2
TCL_HOME=/opt/local
TCL_INCL=$(TCL_HOME)/include/guile/$(TCL_VERSION)
TCL_LIB=$(TCL_HOME)/lib
TCL_EXE=$(TCL_HOME)/bin/tclsh
CFLAGS_SWIG_guile=-I$(TCL_INCL)
#SO_PREFIX_tcl=lib
#SO_SUFFIX_tcl=dylib # OSX
SO_SUFFIX_tcl=so # OSX
SWIG_OPTS_tcl=

############################

GUILE_VERSION=2.2
GUILE_HOME=/opt/local
GUILE_INCL=$(GUILE_HOME)/include/guile/$(GUILE_VERSION)
GUILE_LIB=$(GUILE_HOME)/lib
GUILE_EXE=$(GUILE_HOME)/bin/guile
CFLAGS_SWIG_guile=-I$(GUILE_HOME)/include -I$(GUILE_INCL) -I$(GUILE_INCL)/libguile
SO_PREFIX_guile=lib
SO_SUFFIX_guile=so # OSX
SWIG_OPTS_guile=-scmstub

############################

JAVA_VERSION=11.0.2
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-$(JAVA_VERSION).jdk/Contents/Home
JAVA_INCL=$(JAVA_HOME)/include
JAVA_LIB=$(JAVA_HOME)/lib
JAVA_EXE=$(JAVA_HOME)/bin/java
CFLAGS_SWIG_java=-I$(JAVA_INCL) -I$(JAVA_INCL)/darwin
SO_PREFIX_java=lib
SO_SUFFIX_java=jnilib # OSX

############################

EXAMPLES=example1

############################

all: early build-examples

early:
	@mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

#################################

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
  target/native/$(EXAMPLE).o \
  target/native/$(EXAMPLE) \

build-native: early $(NATIVE_DEPS)

target/native/$(EXAMPLE).o : src/$(EXAMPLE).c
	@echo "\n### Compile native code\n\n\`\`\`"
	$(CC) $(CFLAGS) -c -o $@ $<
	@echo "\`\`\`"

target/native/$(EXAMPLE) : src/$(EXAMPLE)-native.c
	@mkdir -p $(dir $@)
	@echo "\n### Compile native program\n\n\`\`\`"
	$(CC) $(CFLAGS) -o $@ $< target/native/$(EXAMPLE).o
	@echo "\`\`\`"

#################################

build-targets : Makefile
	@set -e ;\
	for t in $(SWIG_TARGETS) ;\
	do \
	  $(MAKE) --no-print-directory build-target EXAMPLE=$(EXAMPLE) SWIG_TARGET=$$t ;\
	done

TARGET_DEPS = \
	target/$(SWIG_TARGET)/$(EXAMPLE).c \
	target/$(SWIG_TARGET)/$(EXAMPLE).o \
	target/$(SWIG_TARGET)/$(SO_PREFIX)$(EXAMPLE).$(SO_SUFFIX)

build-target: early build-target-announce $(TARGET_DEPS)

build-target-announce:
	@echo "\n## Build $(SWIG_TARGET) SWIG wrapper\n"

target/$(SWIG_TARGET)/$(EXAMPLE).c : src/$(EXAMPLE).h
	@mkdir -p $(dir $@)
	@echo "\n### Generate $(SWIG_TARGET) SWIG wrapper\n\n\`\`\`"
	swig $(SWIG_OPTS) -$(SWIG_TARGET) -o $@ $<
	wc -l $@
	@echo "\`\`\`"

target/$(SWIG_TARGET)/$(EXAMPLE).o : target/$(SWIG_TARGET)/$(EXAMPLE).c
	@mkdir -p $(dir $@)
	@echo "\n### Compile $(SWIG_TARGET) SWIG wrapper\n\n\`\`\`"
	$(CC) $(CFLAGS) $(CFLAGS_SWIG) -c -o $@ $<
	@echo "\`\`\`"

target/$(SWIG_TARGET)/$(SO_PREFIX)$(EXAMPLE).$(SO_SUFFIX) : target/$(SWIG_TARGET)/$(EXAMPLE).o
	@mkdir -p $(dir $@)
	@echo "\n### Link $(SWIG_TARGET) SWIG wrapper dynamic library\n\n\`\`\`"
	$(CC) $(CFLAGS) $(CFLAGS_SO) -o $@ target/native/$(EXAMPLE).o $<
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

