#!/usr/bin/env bash

-cmd-build() {
  targets=("$@")
  build-things
}

-cmd-show() {
  local v
  for v in $var
  do
    echo "${!v}"
  done
}

-cmd-() {
  -cmd-all
}

-cmd-all() {
  -cmd-build-examples
}
####################################

declare -g -A SWIG_OPTS_ SWIG_CFLAGS_ SWIG_INC_DIRS_ SWIG_LDFLAGS_ SWIG_LIB_DIRS_ SWIG_LIBS_ SWIG_SO_SUFFIX_ SWIG_SO_PREFIX_
declare -g -A SWIG_GENERATED_FILES_ SWIG_EXTRA_
declare -g -A CC_ CFLAGS_ INC_DIRS_ LDFLAGS_ LIB_DIRS_ LIBS_ SUFFIX_

-setup-targets() {
  :
}

-setup-vars() {
  # declare -p $(compgen -v EXAMPLE); # exit 9

  MAKE=${MAKE:-make}
  export UNAME_S="$(uname -s)"
  export ROOT_DIR="$(/bin/pwd)"
  export LOCAL_DIR="${ROOT_DIR}/local"
  export LC_ALL=C

  DEBUG=''
  CC='' CC_=()
  CFLAGS='' CFLAGS_=() CFLAGS_SO=''
  CXXFLAGS=''
  INC_DIRS=''
  LIB_DIRS=''        LIB_DIRS_=()
  LIBS=''            LIBS_=()
  LDFLAGS=''         LDFLAGS_=()
  SWIG_OPTS=''       SWIG_OPTS_=()
  SWIG_CFLAGS=''     SWIG_CFLAGS_=()
  SWIG_LDFLAGS=''    SWIG_LDFLAGS_=()
  SWIG_LIB_DIRS=''   SWIG_LIB_DIRS_=()
  SWIG_LIBS=''       SWIG_LIBS_=()
  SWIG_SO_SUFFIX=''  SWIG_SO_SUFFIX_=()
  SWIG_SO_PREFIX=''  SWIG_SO_PREFIX_=()
  SWIG_EXTRA=''      SWIG_EXTRA_=()
  SWIG_GENERATED_FILES='' SWIG_GENERATED_FILES_=()

  SWIG_CFLAGS+=' -Wno-sentinel'
  SWIG_CFLAGS+=' -Wno-unused-command-line-argument'

  DEBUG+=' -g'

  ############################

  SWIG_CFLAGS_[tommath]='-Wno-sentinel'
  LIBS_[tommath]='-ltommath'

  SWIG_CFLAGS_[polynomial]+=' -Wno-deprecated-declarations' # sprintf
  SWIG_CFLAGS_[polynomial_v2]+=' -Wno-deprecated-declarations' # sprintf

  ############################

  : "${SWIG_EXE:=$(which swig | head -1)}"
  SWIG_SO_SUFFIX_DEFAULT=.so
  SWIG_SO_SUFFIX_+=(
    [ruby]=.so [guile]=.so [postgresql]=.so
  )

  ############################

  # SUFFIX_ruby=rb
  SWIG_OPTS_[ruby]=-ruby
  SWIG_CFLAGS_[ruby]="$(${RUBY_EXE} tool/ruby-cflags.rb) -Wno-unknown-attributes -Wno-ignored-attributes"

  ############################

  PYTHON_VERSION=3.10
  PYTHON_MAJOR_VERSION="${PYTHON_VERSION%.*}"
  PYTHON_CONFIG=$(which python${PYTHON_VERSION}-config python${PYTHON_MAJOR_VERSION}-config python-config 2>/dev/null | head -1)
  PYTHON_EXE=$(which python${PYTHON_VERSION} python${PYTHON_MAJOR_VERSION} python 2>/dev/null | head -1)

  # SUFFIX_[python]=.py
  SWIG_OPTS_[python]=-python
  # Has include options:
  SWIG_CFLAGS_[python]="$(${PYTHON_CONFIG} --cflags) -Wno-deprecated-declarations"
  # Has libs:
  SWIG_LDFLAGS_[python]="$(${PYTHON_CONFIG} --ldflags)"
  # SWIG_LIBS_[python]="$(${PYTHON_CONFIG} --libs)"
  SWIG_SO_PREFIX_[python]=_
  SWIG_GENERATED_FILES_[python]=target/${SWIG_TARGET}/${EXAMPLE_SWIG}.py

  ############################

  # SUFFIX_[tcl]=.tcl
  SWIG_OPTS_[tcl]=-tcl
  SWIG_CFLAGS_[tcl]="-I${TCL_HOME}/include"
  #SWIG_CFLAGS_[tcl]=-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>

  ############################

  GUILE_VERSION=3.0
  # SUFFIX_[guile]=.scm
  SWIG_OPTS_[guile]=-guile
  #MEH: error: ("/opt/homebrew/opt/pkg-config/bin/pkg-config" "--cflags" "guile-3.0") exited with non-zero error code 127
  #SWIG_CFLAGS_guile:=$(shell guile-config compile) #
  #SWIG_LDFLAGS_guile:=$(shell guile-config link) #
  SWIG_CFLAGS_[guile]="$(pkg-config --cflags guile-$GUILE_VERSION)" #
  SWIG_LIBS_[guile]="$(pkg-config --libs guile-$GUILE_VERSION)" #
  SWIG_SO_PREFIX_[guile]=lib

  ############################

  # SUFFIX_[clojure]=.clj
  SWIG_OPTS_[clojure]=-java
  # SWIG_OPTS_[clojure]="-package ${EXAMPLE_NAME}"
  SWIG_CFLAGS_[clojure]="-I${JAVA_INC}"
  SWIG_SO_PREFIX_[clojure]=lib
  case "${UNAME_S}"
  in
    Darwin)
      SWIG_CFLAGS_[clojure]+=" -I${JAVA_INC}/darwin"
      SWIG_SO_SUFFIX_[clojure]=.jnilib
    ;;
    Linux)
      SWIG_CFLAGS_[clojure]+=" -I${JAVA_INC}/linux"
      SWIG_SO_SUFFIX_[clojure]=.so
    ;;
  esac
  SWIG_GENERATED_FILES_[clojure]="target/${SWIG_TARGET}/${EXAMPLE_NAME}*.java"

  ############################

  # SUFFIX_[postgresql]=.psql
  SWIG_OPTS_[postgresql]=-postgresql
  # SWIG_OPTS_[postgresql]+='' -debug-top 1,2,3,4'
  SWIG_OPTS_[postgresql]+=' -extension-version 1.2.3'
  # SWIG_OPTS_[postgresql]+="" -extension-schema  $EXTENSION_NAME"
  SWIG_INC_DIRS_[postgresql]="-I$(pg_config --includedir-server)" #
  # SWIG_CXXFLAGS_postgresql="$(pg_config --includedir-server)" #
  # SWIG_LDFLAGS_postgresql="$(pkg-config --libdir)" #
  SWIG_EXTRA_[postgresql]=postgresql-make-extension
  SWIG_GENERATED_FILES_[postgresql]="target/${SWIG_TARGET}/${EXAMPLE_SWIG}-*.sql target/${SWIG_TARGET}/${EXAMPLE_SWIG}.control target/${SWIG_TARGET}/${EXAMPLE_SWIG}.make"

  ############################

  SWIG_CFLAGS_[xml]= #-I${TCL_HOME}/include
  SWIG_CFLAGS_[xml]= #-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>

  ############################

  CC_[.c]=clang
  CC_[.cc]=clang++
  case "${UNAME_S}"
  in
    Linux)
      CC_[.c]=clang-13
      CC_[.cc]=clang++-13
    ;;
  esac

  #LDFLAGS+= ???
  CFLAGS_[.c]=
  CFLAGS_[.cc]=-Wno-c++11-extensions # -stdlib=libc++
  CFLAGS_[.cc]+=' -std=c++17'

  CC="${CC_[$EXAMPLE_SUFFIX]}"
  CFLAGS+=" ${CFLAGS_[$EXAMPLE_SUFFIX]}"
  CFLAGS+=" ${CFLAGS_[$EXAMPLE_NAME]}"
  CFLAGS+=" ${DEBUG}"
  CXXFLAGS+=" ${DEBUG}"
  INC_DIRS+=' -Isrc'
  INC_DIRS+=' -Iinclude'
  INC_DIRS+=" -I${LOCAL_DIR}/include"
  LIB_DIRS+=" -L${LOCAL_DIR}/lib"
  LIBS+=" ${LIBS_[$EXAMPLE_NAME]}"
  LIBS+=" ${LIBS_[$SWIG_TARGET]}"
  # declare -p INC_DIRS LIB_DIRS LIBS LDFLAGS
  # declare -p CFLAGS_ CC CFLAGS CXXFLAGS

  ############################

  case "$UNAME_S"
  in
    CYGWIN_NT*)
      SWIG_SO_SUFFIX_DEFAULT=.dll
      CFLAGS_SO+=' -shared' # GCC
    ;;
    Linux)
      # Linux: GCC 7.5.0 ???
      CFLAGS+=' -fPIC'
      CFLAGS_SO+=' -shared'
      # CFLAGS_SO += -fPIC -shared
    ;;
    Darwin)
      # OSX brew
      INC_DIRS+=' -I/opt/homebrew/include'
      LIB_DIRS+=' -L/opt/homebrew/lib'
      CFLAGS_SO+=' -dynamiclib -Wl,-undefined,dynamic_lookup'
      SWIG_SO_SUFFIX_[ruby]=.bundle
    ;;
  esac
  # declare -p UNAME_S CFLAGS CFLAGS_SO; exit 9

  ############################
  # set -x

  SWIG_OPTS_[.cc]=-c++
  SWIG_OPTS+=" ${SWIG_OPTS_[$SWIG_TARGET]}"
  SWIG_OPTS+=" -I-"
  SWIG_OPTS+=" ${SWIG_OPTS_[$EXAMPLE_SUFFIX]}"
  SWIG_OPTS+=" ${SWIG_OPTS_[$EXAMPLE_NAME]}"
  SWIG_OPTS+=" -addextern"
  SWIG_OPTS_x+=' \
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
  '
  SWIG_CFLAGS+=" ${SWIG_CFLAGS_[$SWIG_TARGET]}"
  SWIG_CFLAGS+=" ${SWIG_CFLAGS_[$EXAMPLE_NAME]}"
  SWIG_CFLAGS+=" ${SWIG_CFLAGS_[$EXAMPLE_SUFFIX]}"
  #SWIG_CFLAGS+='' -DSWIGRUNTIME_DEBUG=1'
  SWIG_INC_DIRS+=" ${SWIG_INC_DIRS_[$EXAMPLE_NAME]}"
  SWIG_INC_DIRS+=" ${SWIG_INC_DIRS_[$SWIG_TARGET]}"
  SWIG_LDFLAGS+=" ${SWIG_LDFLAGS_[$SWIG_TARGET]}"
  SWIG_LDFLAGS+=" ${SWIG_LDFLAGS_[$EXAMPLE_NAME]}"
  SWIG_LIB_DIRS+=" ${SWIG_LIB_DIRS_[$SWIG_TARGET]}"
  SWIG_LIB_DIRS+=" ${SWIG_LIB_DIRS_[$EXAMPLE_NAME]}"
  SWIG_LIBS+=" ${SWIG_LIBS_[$EXAMPLE_NAME]}"
  SWIG_LIBS+=" ${SWIG_LIBS_[$SWIG_TARGET]}"
  SWIG_SO_SUFFIX="${SWIG_SO_SUFFIX_[$SWIG_TARGET]}"
  SWIG_SO_PREFIX="${SWIG_SO_PREFIX_[$SWIG_TARGET]}"
  : "${SWIG_SO_PREFIX:=$SWIG_SO_PREFIX_DEFAULT}"
  : "${SWIG_SO_SUFFIX:=$SWIG_SO_SUFFIX_DEFAULT}"
  SWIG_EXTRA+=" ${SWIG_EXTRA_[$SWIG_TARGET]}"

  # declare -p EXAMPLE EXAMPLE_NAME EXAMPLE_SUFFIX
  # declare -p $(compgen -v SWIG)

  #################################

  SWIG_C="target/${SWIG_TARGET}/${EXAMPLE_SWIG}${EXAMPLE_SUFFIX}"
  SWIG_O="$SWIG_C.o"
  SWIG_SO="$(dirname ${SWIG_O})/${SWIG_SO_PREFIX}${EXAMPLE_SWIG}${SWIG_SO_SUFFIX}"

  # (set +x; declare -p $(compgen -v | grep -E -e '[A-Z]' | sort))
  # exit 9
}

# TODO:
postgresql-make-extension() {
  echo ""
  echo "# Compile and install ${SWIG_TARGET} extension:"
  ${MAKE} -C target/postgresql -f ${EXAMPLE_SWIG}.make install
}

-filter-example-targets() {
  case "${EXAMPLE_NAME}-${UNAME_S}"
  in
    polynomial-Linux)
      # /usr/include/guile/2.2/libguile/deprecated.h:115:21: error: ‘scm_listify__GONE__REPLACE_WITH__scm_list_n’ was not declared in this scope
      # SWIG_TARGETS:=$(filter-out guile, $(SWIG_TARGETS))
      # TARGET_DEPS:=$(filter-out guile, $(TARGET_DEPS))
      #
    ;;
    tommath-*)
      # tcl.h forward declares struct mp_int!
      # target/tcl/libtommath_swig.c:2330:19: error: incomplete definition of type 'struct mp_int'
      SWIG_TARGETS="${SWIG_TARGETS//tcl/ }"
    ;;
  esac
  SWIG_TARGET_SUFFIXES=
  local target
  for target in $SWIG_TARGETS
  do
    SWIG_TARGET_SUFFIXES+=" ${SWIG_TARGET_SUFFIX_[$target]}"
  done
}

-setup-example-vars() {
  EXAMPLE_NAME=${EXAMPLE%.*}
  EXAMPLE_SUFFIX=".${EXAMPLE##*.}"
  EXAMPLE_SWIG=${EXAMPLE_NAME}_swig
}

############################

-cmd-build-examples() {
  for EXAMPLE in $EXAMPLES
  do
    (
      -setup-example-vars
      echo -e "\n## Workflow - ${EXAMPLE} \n"
    	echo ""
      set -e
      -cmd-build-native
      -cmd-build-example-targets
    )
  done
}

-cmd-build-example-targets() {
  (
  -filter-example-targets
  for SWIG_TARGET in $SWIG_TARGETS
  do
    (
      -setup-vars
      set -e
      -cmd-build-example-target
    ) || exit $?
  done
	echo ""
  )
}

-cmd-build-native() {
      (
        SWIG_TARGET=native
        -setup-vars
        set -e
  mkdir -p target/native
  lib_c=src/${EXAMPLE_NAME}${EXAMPLE_SUFFIX}
  lib_o=target/native/${EXAMPLE_NAME}.o
  main_c=src/${EXAMPLE_NAME}-native${EXAMPLE_SUFFIX}
  main_e=target/native/${EXAMPLE_NAME}

	echo "### Compile Native Code"
	echo ""
	echo '```'
	echo "# Compile native library:"
	-run ${CC} ${CFLAGS} $INC_DIRS -c -o $lib_o $lib_c
	echo ""
	echo "# Compile and link native program:"
	-run ${CC} ${CFLAGS} $INC_DIRS -o $main_e $main_c $lib_o $LDFLAGS $LIB_DIRS $LIBS
	echo ""
	echo '```'
      ) || exit $?
}

-cmd-build-example-target() {
  TARGET_DIR=$(dirname $SWIG_C)
  EXAMPLE_I=src/${EXAMPLE_NAME}.i
  EXAMPLE_H=src/${EXAMPLE_NAME}.h
  EXAMPLE_C=src/${EXAMPLE_NAME}.c

  mkdir -p $TARGET_DIR

	echo "### Build ${SWIG_TARGET} Bindings"
	echo ""
	echo '```'

	echo "# Generate ${SWIG_TARGET} bindings:"
  -run ${SWIG_EXE} ${SWIG_OPTS} $INC_DIRS $SWIG_INC_DIRS -outdir $TARGET_DIR/ -o $SWIG_C $EXAMPLE_I
	echo ""
  SWIG_GENERATED_FILES="$SWIG_C ${SWIG_GENERATED_FILES_[$SWIG_TARGET]}"

	echo "# Source code statistics:"
	-run wc -l $EXAMPLE_H $EXAMPLE_I
	echo ''

	echo "# Generated code statistics:"
	-run wc -l "$SWIG_GENERATED_FILES"
	echo ''

	# -run ${SWIG_EXE} ${SWIG_OPTS} -xml -o $SWIG_C $EXAMPLE_I 2>/dev/null || true

	echo "# Compile ${SWIG_TARGET} bindings:"
	-run $CC $CFLAGS $INC_DIRS $SWIG_CFLAGS $SWIG_INC_DIRS -c -o $SWIG_O $SWIG_C
	echo ""

	echo "# Link $SWIG_TARGET dynamic library:"
	-run $CC $CFLAGS_SO -o $SWIG_SO target/native/${EXAMPLE_NAME}.o $SWIG_O $LIB_DIRS $LDFLAGS $SWIG_LDFLAGS  $SWIG_LIB_DIRS $SWIG_LIBS $LIBS

  local extra
  for extra in ${SWIG_EXTRA_[$SWIG_TARGET]} :
  do
    $extra
  done

  echo '```'
	echo ""
}

-cmd-demo() {
  -cmd-clean
  -cmd-all
  -cmd-demo-run
}

-cmd-demo-run() {
  -filter-example-targets
  for EXAMPLE in ${EXAMPLES}
  do
    (
    -setup-example-vars
    -run-prog target/native/${EXAMPLE_NAME}
    for suffix in $SWIG_TARGET_SUFFIXES
    do
      for prog in src/"$EXAMPLE_NAME"*"$suffix"
      do
        if [[ -x "$prog" ]]
        then
          -run-prog "$prog"
        fi
      done
    done
    ) || exit $?
  done
}

-run-prog() {
  (
    set -e
    echo '```'
    echo -n '$ '
    -run bin/run "$@"
    echo '```'
    echo ''
  ) || exit $?
}

############################

-cmd-clean() {
	rm -f ~/.cache/guile/**/swig-101/**/*-guile.go
	rm -rf target/*
}

-cmd-clean-example() {
  for EXAMPLE in $EXAMPLES
  do
    (
      -setup-example-vars
      rm -rf target/*/*${EXAMPLE_NAME}*
    )
  done
}

############################

-built() {
  local file
  local done=1
  for file in "$@"
  do
   [[ " $targets " =~ " $file " ]] || done=
  done
  [[ -n "$done" ]] && exit 0
}

-run() {
  echo "$*"
  $*
}

############################

declare -A SWIG_TARGET_SUFFIX_=( [py]=.py [clj]=.clj [rb]=.rb [tcl]=.tcl [scm]=.scm [psql]=.sql )

-defaults() {
  SWIG_TARGET_SUFFIX_=([python]=.py [clojure]=.clj [ruby]=.rb [tcl]=.tcl [guile]=.scm [postgresql]=.psql)
  SWIG_TARGETS='python clojure ruby tcl guile postgresql'
  EXAMPLES='example1.c polynomial.cc polynomial_v2.cc tommath.c black_scholes.c'
  # OVERRIDE:
  # SWIG_TARGETS=python
  # EXAMPLES='example1.c'
}

-initialize() {
  EXAMPLE_NAMES="${EXAMPLES//.*/}"
}

-main() {
  # set -x
  cd "$(dirname "$0")/.." || exit $?
  -defaults
  cmds=()
  local arg
  for arg in "$@"
  do
    case "$arg"
    in
    *=*)
      declare -g "$arg"
    ;;
    *)
      cmds+=("$arg")
    ;;
    esac
  done
  -initialize
  for cmd in "${cmds[@]}"
  do
    "-cmd-$cmd"
  done
}

-main "$@"
