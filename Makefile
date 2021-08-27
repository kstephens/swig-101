CFLAGS+=-Iinclude

TARGET_LANGS=ruby
TARGET_LANG=ruby

SRCS=src/example1.c

all: early all-targets

all-targets :
	set -xe; for t in $(TARGET_LANGS); do $(MAKE) targets TARGET=$$t; done

TARGET_DEPS=$(foreach f,$(SRCS), \
	$(f:src/%.c=target/native/%.o) \
	$(f:src/%.c=target/native/%-main) \
	$(f:src/%.c=target/$(TARGET)/%.c))

targets: $(TARGET_DEPS)
	echo $(TARGET_DEPS)

early:
	mkdir -p target/native $(foreach t,$(TARGET_LANGS),target/$t)

target/native/%.o : src/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

target/native/% : src/%.c
	$(CC) $(CFLAGS) -DMAIN -o $@ $< target/native/*.o

target/$(TARGET_LANG)/%.o : target/$(TARGET_LANG)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

target/$(TARGET_LANG)/%.c : include/%.h
	mkdir -p $(dir $@)
	echo swig $(TARGET_LANG) -o $@
