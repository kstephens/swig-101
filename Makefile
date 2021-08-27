SWIG_TARGETS=ruby
SWIG_TARGET=ruby

SWIG_OPTS += \
	-addextern -I- \
	-debug-module 1,2,3,4 

############################

CFLAGS += -g -Iinclude 
CFLAGS += $(CFLAGS_$(SWIG_TARGET))
CFLAGS_SO += -Wl,-undefined,dynamic_lookup -Wl,-multiply_defined,suppress
SO_SUFFIX=bundle # OSX

############################

RUBY_VERSION=2.3.0
RUBY_ROOT=$(HOME)/.rbenv/versions/$(RUBY_VERSION)
RUBY_INCL=$(RUBY_ROOT)/include/ruby-$(RUBY_VERSION)
RUBY_LIB=$(RUBY_ROOT)/lib
CFLAGS_ruby=-I$(RUBY_INCL) -I$(RUBY_INCL)/x86_64-darwin18

############################

SRCS=src/example1.c

############################

all: early all-targets

all-targets : Makefile
	@set -e; for t in $(SWIG_TARGETS); do $(MAKE) --no-print-directory targets TARGET=$$t; done

TARGET_DEPS=                              \
$(foreach f, $(SRCS),                     \
	$(f:src/%.c=target/native/%.o)    \
	$(f:src/%.c=target/$(SWIG_TARGET)/%.c) \
	$(f:src/%.c=target/$(SWIG_TARGET)/%.o) \
	$(f:src/%.c=target/$(SWIG_TARGET)/%.$(SO_SUFFIX)) \
	$(f:src/%.c=target/bin/%)    \
)

targets: $(TARGET_DEPS)

early:
	@mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)

target/native/%.o : src/%.c
	@echo "\n  ### Compiling native example code:\n"
	$(CC) $(CFLAGS) -c -o $@ $<

target/bin/% : src/%-main.c
	@mkdir -p $(dir $@)
	@echo "\n  ### Compiling native example main program:\n"
	$(CC) $(CFLAGS) -DMAIN -o $@ $< $(<:src/%-main.c=target/native/%.o)

target/$(SWIG_TARGET)/%.c : include/%.h
	@mkdir -p $(dir $@)
	@echo "\n  ### Generating SWIG $(SWIG_TARGET) wrapper *.c:\n"
	swig $(SWIG_OPTS) -$(SWIG_TARGET) -o $@ $<

target/$(SWIG_TARGET)/%.o : target/$(SWIG_TARGET)/%.c
	@mkdir -p $(dir $@)
	@echo "\n  ### Compiling SWIG $(SWIG_TARGET) wrapper *.o:\n"
	$(CC) $(CFLAGS) -c -o $@ $<

target/$(SWIG_TARGET)/%.$(SO_SUFFIX) : target/$(SWIG_TARGET)/%.o
	@mkdir -p $(dir $@)
	@echo "\n  ### Linking SWIG $(SWIG_TARGET) wrapper dynamic library:\n"
	$(CC) $(CFLAGS) $(CFLAGS_SO) -o $@ $< $(<:target/$(SWIG_TARGET)/%.o=target/native/%.o)

clean:
	rm -rf target/*

