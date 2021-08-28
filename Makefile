SWIG_TARGETS=ruby python
# SWIG_TARGET=ruby

SWIG_OPTS += \
	-addextern -I- \
	-debug-module 1,2,3,4
SWIG_OPTS_x += \
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

CFLAGS += -g -Iinclude
CFLAGS_SWIG=$(CFLAGS) $(CFLAGS_SWIG_$(SWIG_TARGET))
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
CFLAGS_SWIG_python=-I$(PYTHON_INCL)
SO_PREFIX_python=_
SO_SUFFIX_python=so # OSX

############################

SRCS=src/example1.c

############################

all: early all-targets

all-targets : Makefile
	@set -e; \
	for t in $(SWIG_TARGETS); \
	do \
	  $(MAKE) --no-print-directory build SWIG_TARGET=$$t; \
	done

TARGET_DEPS=                              \
$(foreach f, $(SRCS),                     \
	$(f:src/%.c=target/native/%.o)    \
	$(f:src/%.c=target/$(SWIG_TARGET)/%.c) \
	$(f:src/%.c=target/$(SWIG_TARGET)/%.o) \
	$(f:src/%.c=target/$(SWIG_TARGET)/$(SO_PREFIX)%.$(SO_SUFFIX)) \
	$(f:src/%.c=target/bin/%)    \
)

build: build-announce $(TARGET_DEPS)

build-announce:
	@echo "\n  ################################################"
	@echo "\n  ### Building SWIG wrapper for $(SWIG_TARGET):\n"

early:
	@mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

target/native/%.o : src/%.c
	@echo "\n  ### Compiling native example code:\n"
	$(CC) $(CFLAGS) -c -o $@ $<

target/bin/% : src/%-main.c
	@mkdir -p $(dir $@)
	@echo "\n  ### Compiling native example main program:\n"
	$(CC) $(CFLAGS) -o $@ $< $(<:src/%-main.c=target/native/%.o)

target/$(SWIG_TARGET)/%.c : include/%.h
	@mkdir -p $(dir $@)
	@echo "\n  ### Generating SWIG $(SWIG_TARGET) wrapper *.c:\n"
	swig $(SWIG_OPTS) -$(SWIG_TARGET) -o $@ $<

target/$(SWIG_TARGET)/%.o : target/$(SWIG_TARGET)/%.c
	@mkdir -p $(dir $@)
	@echo "\n  ### Compiling SWIG $(SWIG_TARGET) wrapper *.o:\n"
	$(CC) $(CFLAGS_SWIG) -c -o $@ $<

target/$(SWIG_TARGET)/$(SO_PREFIX)%.$(SO_SUFFIX) : target/$(SWIG_TARGET)/%.o
	@mkdir -p $(dir $@)
	@echo "\n  ### Linking SWIG $(SWIG_TARGET) wrapper dynamic library:\n"
	$(CC) $(CFLAGS_SWIG) $(CFLAGS_SO) -o $@ $(<:target/$(SWIG_TARGET)/%.o=target/native/%.o) $<

clean:
	rm -rf target/*

