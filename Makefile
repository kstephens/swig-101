#!bin/build

############################

default: all

EXAMPLES:=$(shell bin/run bin/build.sh show var=EXAMPLES)
SWIG_TARGETS:=$(shell bin/run bin/build.sh show var=SWIG_TARGETS)
TARGET_SUFFIXES:=$(shell bin/run bin/build.sh show var=TARGET_SUFFIXES)

BUILD_SH=bin/run bin/build.sh

############################

MAKE+=--no-print-directory
MAKEFLAGS+=--no-print-directory
UNAME_S:=$(shell uname -s)
export ROOT_DIR?=$(shell /bin/pwd)
export LOCAL_DIR:=$(ROOT_DIR)/local
SILENT=@

############################

all: early build-examples

early: local-dirs
	$(SILENT)mkdir -p target/native $(foreach t,$(SWIG_TARGETS),target/$t)
EXAMPLES:
	$(SILENT)echo "$(EXAMPLES)"
.PHONY: early EXAMPLES

#################################

build-examples: early
	$(SILENT)$(BUILD_SH) all EXAMPLES='$(EXAMPLES)' SWIG_TARGETS='$(SWIG_TARGETS)'
build-example: early
	$(SILENT)$(BUILD_SH) all EXAMPLES='$(EXAMPLE)' SWIG_TARGETS='$(SWIG_TARGETS)'
build-native: early
	$(SILENT)$(BUILD_SH) build-native EXAMPLES='$(EXAMPLE)' SWIG_TARGETS='$(SWIG_TARGETS)'
build-targets: early
	$(SILENT)$(BUILD_SH) build-native EXAMPLES='$(EXAMPLES)' SWIG_TARGETS='$(SWIG_TARGETS)'
.PHONY: build-examples build-example build-native build-targets

#################################

demo: clean all demo-run
	$(SILENT)$(BUILD_SH) demo-run
demo-run:
	$(SILENT)$(BUILD_SH) demo-run EXAMPLES='$(EXAMPLES)' SWIG_TARGETS='$(SWIG_TARGETS)'
.PHONY: demo demo-run

#################################

brew-prereq:
	brew install          automake libtool autoconf cmake bison tcl-tk  guile python\@3.10 brew-pip openjdk postgresql\@14
	bin/run pip install   pytest
	-createdb $(USER)

debian-prereq:
	sudo apt-get install  automake libtool autoconf cmake bison byacc tcl-dev  guile-2.2-dev
	@echo "See https://apt.llvm.org/."
	sudo apt-get install clang-13 clang++-13 libc++-13-dev
	@echo "See: https://computingforgeeks.com/how-to-install-python-on-ubuntu-linux-system/ to install python 3.10."
	sudo apt-get install   python3.10-dev python3.10-venv
	curl -sS https://bootstrap.pypa.io/get-pip.py | bin/run python3.10
	bin/run python3.10 -m pip install pytest

#################################

README_MD_DEPS=doc/README.md.erb doc/README.md.erb.rb doc/*.* src/*.* include/*.* Makefile

README.md :
	$(BUILD_SH) build-readme-md EXAMPLES='$(EXAMPLES)' SWIG_TARGETS='$(SWIG_TARGETS)'
.PRECIOUS: README.md

README.md.html :
	$(BUILD_SH) build-readme-md-html EXAMPLES='$(EXAMPLES)' SWIG_TARGETS='$(SWIG_TARGETS)'

#################################

clean:
	@bin/run bin/build.sh clean

clean-example:
	@bin/run bin/build.sh clean-example EXAMPLES='$(EXAMPLE)'

pv:
	echo $(v)=$($(v))

#################################

local-tools: swig libtommath clojure # guile

local-tools-clean:
	rm -rf '$(LOCAL_DIR)'

local-dirs:
	@mkdir -p $(LOCAL_DIR)/src $(LOCAL_DIR)/lib $(LOCAL_DIR)/include $(LOCAL_DIR)/bin

#################################

swig : local-dirs $(LOCAL_DIR)/bin/swig

PCRE2_VERSION=pcre2-10.39

$(LOCAL_DIR)/bin/swig : $(LOCAL_DIR)/src/swig
	@set -xe ;\
	cd $(LOCAL_DIR)/src/swig ;\
	git fetch ;\
	git checkout postgresql ;\
	git pull ;\
	curl -L -O https://github.com/PhilipHazel/pcre2/releases/download/$(PCRE2_VERSION)/$(PCRE2_VERSION).tar.gz ;\
	./Tools/pcre-build.sh ;\
	./autogen.sh ;\
	./configure --prefix='$(LOCAL_DIR)' ;\
	make -j ;\
	make install

$(LOCAL_DIR)/src/swig :
	git clone https://github.com/kstephens/swig.git $@

#################################

libtommath : local-dirs $(LOCAL_DIR)/lib/libtommath.a

$(LOCAL_DIR)/lib/libtommath.a : $(LOCAL_DIR)/src/libtommath
	@set -xe ;\
	cd $(LOCAL_DIR)/src/libtommath ;\
	git checkout 4b473685013 ;\
	mkdir -p $(LOCAL_DIR)/src/libtommath/build $(LOCAL_DIR)/include/libtommath ;\
	cd $(LOCAL_DIR)/src/libtommath ;\
	make -f makefile.unix clean ;\
	make -f makefile.unix -j CC='$(CC_SUFFIX.c) -fPIC' ;\
	cp -p $(LOCAL_DIR)/src/libtommath/libtommath.a $@ ;\
	cp -p $(LOCAL_DIR)/src/libtommath/*.h $(LOCAL_DIR)/include/libtommath/

$(LOCAL_DIR)/src/libtommath:
	git clone https://github.com/libtom/libtommath.git $@

#################################

clojure : local-dirs $(LOCAL_DIR)/bin/clojure

$(LOCAL_DIR)/bin/clojure :
	curl -Lk https://download.clojure.org/install/linux-install-1.11.1.1149.sh > tmp/clojure-install.sh
	bash tmp/clojure-install.sh --prefix $(LOCAL_DIR)

#################################

include lib/Makefile.bdwgc

#################################

guile : local-dirs bdwgc $(LOCAL_DIR)/bin/guile

$(LOCAL_DIR)/bin/guile : $(LOCAL_DIR)/src/guile
	@set -xe ;\
	cd $(LOCAL_DIR)/src/guile ;\
	git checkout v3.0.9 ;\
	export CFLAGS='$(CFLAGS)' ;\
	export LDFLAGS='$(LDFLAGS)' ;\
	./autogen.sh ;\
	./configure --prefix='$(LOCAL_DIR)' --enable-mini-gmp ;\
	make -j ;\
	make install

$(LOCAL_DIR)/src/guile:
	git clone https://git.savannah.gnu.org/git/guile.git $@
