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

-setup-targets() {
  :
}

-setup-vars() {
  # declare -p $(compgen -v EXAMPLE); # exit 9

  MAKE=${MAKE:-make}
  export UNAME_S="$(uname -s)"
  export ROOT_DIR="$(/bin/pwd)"
  export LOCAL_DIR="$ROOT_DIR/local"
  export LC_ALL=C

  DEBUG=''
  CC=''
  CFLAGS='' CFLAGS_SO=''
  INC_DIRS=''
  LDFLAGS='' LIB_DIRS='' LIBS=''
  SWIG_OPTS=''
  SWIG_CFLAGS=''
  SWIG_INC_DIRS=''
  SWIG_LDFLAGS='' SWIG_LIB_DIRS='' SWIG_LIBS=''
  SWIG_SO_SUFFIX='' SWIG_SO_PREFIX=''
  SWIG_EXTRA=''
  SWIG_GENERATED_FILES='' SWIG_GENERATED_FILES_MORE=''

  DEBUG+=' -g'

  ############################

  : "${SWIG_EXE:=$(which swig | head -1)}"

  ############################

  CFLAGS+=" ${DEBUG}"
  INC_DIRS+=' -Isrc'
  INC_DIRS+=' -Iinclude'
  INC_DIRS+=" -I${LOCAL_DIR}/include"
  LIB_DIRS+=" -L${LOCAL_DIR}/lib"

  ############################

  case "$EXAMPLE_SUFFIX"
  in
    .c)
      CC=clang
    ;;
    .cc)
      CC=clang++
      CFLAGS+=' -Wno-c++11-extensions' # -stdlib=libc++
      CFLAGS+=' -std=c++17'
      SWIG_OPTS+=' -c++'
    ;;
  esac
  [[ "${UNAME_S}" = Linux ]] && CC+=-13

  ############################

  SWIG_SO_SUFFIX=.so
  case "$EXAMPLE_NAME"
  in
    tommath)
      SWIG_CFLAGS+=' -Wno-sentinel'
      LIBS+=' -ltommath'
    ;;
    polynomial)
      SWIG_CFLAGS+=' -Wno-deprecated-declarations' # sprintf
      SWIG_CFLAGS+=' -Wno-deprecated-declarations' # sprintf
    ;;
  esac

  ############################

  SWIG_SO_SUFFIX=.so
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
    ;;
  esac

  case "$SWIG_TARGET"
  in
    ruby)
      SWIG_OPTS+=' -ruby'
      SWIG_CFLAGS+=" $(${RUBY_EXE} tool/ruby-cflags.rb) -Wno-unknown-attributes -Wno-ignored-attributes"
      SWIG_CFLAGS+="  -Wno-deprecated-declarations" # sprintf
      [[ "$UNAME_S" = Darwin ]] && SWIG_SO_SUFFIX=.bundle
    ;;
    python)
      PYTHON_VERSION=3.10
      PYTHON_MAJOR_VERSION="${PYTHON_VERSION%.*}"
      PYTHON_CONFIG=$(which python${PYTHON_VERSION}-config python${PYTHON_MAJOR_VERSION}-config python-config 2>/dev/null | head -1)
      PYTHON_EXE=$(which python${PYTHON_VERSION} python${PYTHON_MAJOR_VERSION} python 2>/dev/null | head -1)

      # SUFFIX_[python]=.py
      SWIG_OPTS+=' -python'
      # Has include options:
      SWIG_CFLAGS+=" $(${PYTHON_CONFIG} --cflags) -Wno-deprecated-declarations"
      # Has libs:
      SWIG_LDFLAGS+=" $(${PYTHON_CONFIG} --ldflags)"
      # SWIG_LIBS+=" $(${PYTHON_CONFIG} --libs)"
      SWIG_SO_PREFIX=_
      SWIG_GENERATED_FILES_MORE+=" target/${SWIG_TARGET}/${EXAMPLE_SWIG}.py"
    ;;
    tcl)
      # SUFFIX_[tcl]=.tcl
      SWIG_OPTS+=' -tcl'
      SWIG_CFLAGS+=" -I${TCL_HOME}/include"
      SWIG_CFLAGS+="  -Wno-deprecated-declarations" # sprintf
    ;;
    guile)
      GUILE_VERSION=3.0
      # SUFFIX_[guile]=.scm
      SWIG_OPTS+=' -guile'
      #MEH: error: ("/opt/homebrew/opt/pkg-config/bin/pkg-config" "--cflags" "guile-3.0") exited with non-zero error code 127
      SWIG_CFLAGS+=" $(pkg-config --cflags guile-$GUILE_VERSION)" #
      SWIG_LIBS+=" $(pkg-config --libs guile-$GUILE_VERSION)" #
      SWIG_SO_PREFIX=lib
    ;;
    clojure)
      SWIG_OPTS+=' -java'
      # SWIG_OPTS+=" -package ${EXAMPLE_NAME}"
      SWIG_CFLAGS+=" -I${JAVA_INC}"
      SWIG_SO_PREFIX=lib
      case "${UNAME_S}"
      in
        Darwin)
          SWIG_CFLAGS+=" -I${JAVA_INC}/darwin"
          SWIG_SO_SUFFIX=.jnilib
        ;;
        Linux)
          SWIG_CFLAGS+=" -I${JAVA_INC}/linux"
          SWIG_SO_SUFFIX=.so
        ;;
      esac
      SWIG_GENERATED_FILES_MORE="target/${SWIG_TARGET}/${EXAMPLE_NAME}*.java"
    ;;
    postgresql)
      SWIG_OPTS+=' -postgresql'
      # SWIG_OPTS+=' -debug-top 1,2,3,4'
      SWIG_OPTS+=' -extension-version 1.2.3'
      # SWIG_OPTS+=" -extension-schema $EXTENSION_NAME"
      SWIG_INC_DIRS+=" -I$(pg_config --includedir-server)" #
      # SWIG_LDFLAGS+=" $(pkg-config --libdir)" #
      SWIG_EXTRA+=' postgresql-make-extension'
      SWIG_GENERATED_FILES_MORE="target/${SWIG_TARGET}/${EXAMPLE_SWIG}-*.sql target/${SWIG_TARGET}/${EXAMPLE_SWIG}.control target/${SWIG_TARGET}/${EXAMPLE_SWIG}.make"
    ;;
    xml)
      SWIG_CFLAGS+= #-I${TCL_HOME}/include
      SWIG_CFLAGS+= #-I/usr/include/tcl # Linux: tcl-dev : #include <tcl.h>
    ;;
  esac

  ############################

  SWIG_OPTS+=" -addextern"
  SWIG_OPTS+=" -I-"
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
  SWIG_CFLAGS+=' -Wno-sentinel'
  SWIG_CFLAGS+=' -Wno-unused-command-line-argument'
  #SWIG_CFLAGS+='' -DSWIGRUNTIME_DEBUG=1'

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
	-run $CC $CFLAGS $INC_DIRS -c -o $lib_o $lib_c
	echo ""
	echo "# Compile and link native program:"
	-run $CC $CFLAGS $INC_DIRS -o $main_e $main_c $lib_o $LDFLAGS $LIB_DIRS $LIBS
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
  -run $SWIG_EXE $SWIG_OPTS $INC_DIRS $SWIG_INC_DIRS -outdir $TARGET_DIR/ -o $SWIG_C $EXAMPLE_I
	echo ""
  SWIG_GENERATED_FILES="$SWIG_C $SWIG_GENERATED_FILES_MORE"

	echo "# Source code statistics:"
	-run wc -l $EXAMPLE_H $EXAMPLE_I
	echo ''

	echo "# Generated code statistics:"
	-run wc -l "$SWIG_GENERATED_FILES"
	echo ''

	echo "# Compile ${SWIG_TARGET} bindings:"
	-run $CC $CFLAGS $INC_DIRS $SWIG_CFLAGS $SWIG_INC_DIRS -c -o $SWIG_O $SWIG_C
	echo ""

	echo "# Link $SWIG_TARGET dynamic library:"
	-run $CC $CFLAGS_SO -o $SWIG_SO target/native/${EXAMPLE_NAME}.o $SWIG_O $LIB_DIRS $LDFLAGS $SWIG_LDFLAGS  $SWIG_LIB_DIRS $SWIG_LIBS $LIBS

  local extra
  for extra in $SWIG_EXTRA :
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
  for EXAMPLE in $EXAMPLES
  do
    (
    -setup-example-vars
    -run-prog target/native/$EXAMPLE_NAME
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

declare -A SWIG_TARGET_SUFFIX_

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
