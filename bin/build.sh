#!/usr/bin/env bash

declare -A SWIG_TARGET_SUFFIX_

-defaults() {
  MAKE=${MAKE:-make}
  export UNAME_S="$(uname -s)"
  export ROOT_DIR="$(/bin/pwd)"
  export LOCAL_DIR="$ROOT_DIR/local"
  export LC_ALL=C

  EXAMPLES='mathlib.c polynomial.cc polynomial_v2.cc tommath.c rational.cc black_scholes.c'
  SWIG_TARGETS='native python clojure ruby tcl guile postgresql'
  SWIG_TARGET_SUFFIX_=([native]=-main [python]=.py [clojure]=.clj [ruby]=.rb [tcl]=.tcl [guile]=.scm [postgresql]=.psql)
}

-initialize() {
  EXAMPLES="${EXAMPLES//src\//}"
}

-setup-example-vars() {
  EXAMPLE_NAME=${EXAMPLE%.*}
  EXAMPLE_SUFFIX=".${EXAMPLE##*.}"
  EXAMPLE_SWIG=${EXAMPLE_NAME}_swig

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
      SWIG_TARGETS="${SWIG_TARGETS//tcl/}"
    ;;
  esac

  case "$EXAMPLE_NAME"
  in
    mathlib|black_scholes) ;;
    *)
      SWIG_TARGETS="${SWIG_TARGETS//postgresql/}"
    ;;
  esac
}

-setup-vars() {
  : "${SWIG_EXE:=$(which swig | head -1)}"
  CC=''              CFLAGS=''
  INC_DIRS=''        LDFLAGS=''        LIB_DIRS=''      LIBS=''
  CFLAGS_SO=''
  SWIG_OPTS=''       SWIG_CFLAGS=''
  SWIG_INC_DIRS=''   SWIG_LDFLAGS=''   SWIG_LIB_DIRS='' SWIG_LIBS=''
  SWIG_SO_SUFFIX=''  SWIG_SO_PREFIX=''
  SWIG_EXTRA=''
  SWIG_GENERATED_FILES='' SWIG_GENERATED_FILES_MORE=''

  DEBUG+=' -g'

  ############################

  : "${SWIG_EXE:=$(which swig | head -1)}"

  ############################

  CFLAGS+=" -g -O3"
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

  #################################

  SWIG_C="target/${SWIG_TARGET}/${EXAMPLE_SWIG}${EXAMPLE_SUFFIX}"
  SWIG_O="$SWIG_C.o"
  SWIG_SO="$(dirname ${SWIG_O})/${SWIG_SO_PREFIX}${EXAMPLE_SWIG}${SWIG_SO_SUFFIX}"

  EXAMPLE_I=src/${EXAMPLE_NAME}.i
  EXAMPLE_H=$(ls src/${EXAMPLE_NAME}.h include/${EXAMPLE_NAME}.h 2>/dev/null)
  EXAMPLE_C=src/${EXAMPLE_NAME}.c

  NATIVE_LIB_C=src/${EXAMPLE_NAME}${EXAMPLE_SUFFIX}
  NATIVE_LIB_O=target/native/${EXAMPLE_NAME}.o
  NATIVE_MAIN_C=src/${EXAMPLE_NAME}-main${EXAMPLE_SUFFIX}
  NATIVE_MAIN_E=target/native/${EXAMPLE_NAME}-main
}


####################################

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

# TODO:
postgresql-make-extension() {
  echo ""
  echo "# Compile and install ${SWIG_TARGET} extension:"
  ${MAKE} -C target/postgresql -f ${EXAMPLE_SWIG}.make install
}

############################

-cmd-build-examples() {
  for EXAMPLE in $EXAMPLES
  do
    (
      set -e
      -setup-example-vars
      echo "## Workflow - ${EXAMPLE}"
      echo ""
      -cmd-build-native |& tee $NATIVE_LIB_O.log
      echo ""
      -cmd-build-example-targets
      echo ""
    ) || return $?
  done
}

-cmd-build-example-targets() {
  (
  for SWIG_TARGET in $SWIG_TARGETS
  do
    -cmd-build-example-target || return $?
    echo ""
  done
  ) || return $?
}

-cmd-build-native() {
  (
  set -e -o pipefail
  SWIG_TARGET=native
  -setup-vars
  mkdir -p $(dirname $NATIVE_MAIN_E)

	echo "### Compile Native Code"
	echo ""
	echo '```'
	echo "# Compile native library:"
	-run $CC $CFLAGS $INC_DIRS -c -o $NATIVE_LIB_O $NATIVE_LIB_C
	echo ""
	echo "# Compile and link main program:"
	-run $CC $CFLAGS $INC_DIRS -o $NATIVE_MAIN_E $NATIVE_MAIN_C $NATIVE_LIB_O $LDFLAGS $LIB_DIRS $LIBS
	echo '```'
  ) || return $?
}

-cmd-build-example-target() {
(
  set -e
  -setup-vars
  TARGET_DIR=$(dirname $SWIG_C)
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
	echo ""

	echo "# Generated code statistics:"
	-run wc -l "$SWIG_GENERATED_FILES"
	echo ""

	echo "# Compile ${SWIG_TARGET} bindings:"
	-run $CC $CFLAGS $INC_DIRS $SWIG_CFLAGS $SWIG_INC_DIRS -c -o $SWIG_O $SWIG_C
	echo ""

	echo "# Link $SWIG_TARGET dynamic library:"
	-run $CC $CFLAGS_SO -o $SWIG_SO target/native/${EXAMPLE_NAME}.o $SWIG_O $LIB_DIRS $LDFLAGS $SWIG_LDFLAGS  $SWIG_LIB_DIRS $SWIG_LIBS $LIBS

  local extra
  for extra in $SWIG_EXTRA ''
  do
    [[ -n "$extra" ]] && $extra && echo ""
  done

  echo '```'
) || return $?
}

-cmd-demo() {
  (
    set -e
    -cmd-clean
    -cmd-all
    -cmd-demo-run
  ) || return $?
}

-cmd-demo-run() {
  for EXAMPLE in $EXAMPLES
  do
    (
    export SWIG_101_VERBOSE=1
    -setup-example-vars
    -run-prog target/native/$EXAMPLE_NAME-main
    echo ""
    for SWIG_TARGET in $SWIG_TARGETS
    do
      suffix=${SWIG_TARGET_SUFFIX_[$SWIG_TARGET]}
      for prog in src/"$EXAMPLE_NAME$suffix" src/"$EXAMPLE_NAME"-*"$suffix"
      do
        if [[ -x "$prog" ]]
        then
          -run-prog "$prog" || exit $?
          echo ""
        fi
      done
    done
    ) || return $?
  done
}

############################

-cmd-build-readme-md() {
  (
    set -e
	-cmd-clean
  : "${readme_md:=README.md}"
	erb doc/README.md.erb | doc/normalize-object-ids | tee $readme_md.tmp |
  wc -l
	mv $readme_md.tmp $readme_md
	ls -l $readme_md
  ) || return $?
}

-cmd-build-readme-md-html() {
  (
    set -x
    readme_html=README.md.html
    readme_md=tmp/$readme_html.md
    mkdir -p tmp
    MARKDEEP=1 -cmd-build-readme-md
	  df-markdown -v -s dark -o $readme_html $readme_md
  	ls -l $readme_html
  )
}

############################

-cmd-clean() {
	rm -f ~/.cache/guile/**/swig-101/**/*-guile.go
	rm -rf target/*
  rm -rf {bin,src}/__pycache__/
}

-cmd-clean-example() {
  for EXAMPLE in $EXAMPLES
  do
    (
      -setup-example-vars
      rm -rf target/*/*${EXAMPLE_NAME}*
    ) || return $?
  done
}

############################

-run-prog() {
  [[ "$1" != "${1%-test.py}" ]] && set -- pytest --no-header -v "$@"
  (
    set -e
    echo '```'
    echo "\$ $*"
    bin/run "$@" || exit $?
    echo '```'
  ) || exit $?
}

-run() {
  echo "$*"
  if ! $*
  then
    echo "ERROR: $? : $*" >&2
    exit 9
  fi
}

############################

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
    "-cmd-$cmd" || return $?
  done
}

-main "$@"
