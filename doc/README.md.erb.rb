# frozen_string_literal: true

# Prevent accidental Makefile recursion:
exit! if ENV['_SWIG_101_README_MD']
ENV['_SWIG_101_README_MD'] = '1'

require 'pp'
require 'pry' if ENV['PRY']

$verbose = false
$pe  = $verbose # || true
$msg = $verbose # || true
$context = nil

def log *args
  $stderr.puts "  ### #{args * ' '}"
end

def msg *args
  log *args if $msg
end

def pe_ x
  PP.pp(x, $stderr)
  $stderr.flush
  x
end

def pe x
  pe_ x if $verbose or $pe
  x
end

def cmd cmd
  log "cmd : #{cmd} : ..."
  t0 = Time.now
  system "SWIG_101_VERBOSE=1 bin/run #{cmd} >tmp/cmd.out 2>&1"
  result = $?
  t1 = Time.now
  dt_ms = ((t1 - t0) * 1000).to_i
  out_raw = File.read("tmp/cmd.out").gsub("\0", '')
  out = lines_to_string(string_to_lines(out_raw))
  log "cmd : #{cmd} : DONE : #{dt_ms} ms : exit #{result.exitstatus} : #{out_raw.size} bytes"
  raise "#{cmd} : failed : #{$context.inspect} : #{out}" unless result.success?
  out
end

def remove_shebang s
  s.gsub(%r{(^#!.*$)|(!#)|(^.+ -\*- [a-z]+ -\*-.*$)|(^#pragma +once.*$)}, '')
end

def lines_to_string lines
  lines.join("\n") # + (lines.empty? ? "" : "\n")
end

def string_to_lines s
  s.split("\n", -1)
rescue => exc
  raise Exception, "string_to_lines: #{s.inspect} : #{exc.inspect}"
end

def trim_empty_lines!(lines)
  lines.each{|line| line.sub!(/\s+$/, '')}
  lines.shift while lines[ 0] && lines[ 0].empty?
  lines.pop   while lines[-1] && lines[-1].empty?
  lines
end

def dedup_empty_lines(lines)
  dedup_adjacent(lines, /^\s+$/)
end

def dedup_adjacent(enum, pat)
  result = [ ]
  emitted = nil
  enum.each do | elem |
    unless emitted && (pat === elem && pat === result[-1])
      result << elem
      emitted = true
    end
  end
  result
end

def line_numbers! lines, lang, swig_interface = nil
  comment_to_EOL, comment_line_rx = comment_for_lang(swig_interface || lang)
  # log("line_numbers! : #{lang.inspect} : #{swig_interface.inspect} : #{comment_to_EOL.inspect} : #{comment_line_rx.inspect}")
  pad_lines!(lines)
  lines.map!.with_index(1) do |line, i|
    # binding.pry if ENV['PRY'] && line =~ /Constructor:/
    case line
    when nil
    when %r{^\s*$}
      line
    when comment_line_rx
      # Markdeep trims whitespace in comments, thus
      # the line numbers are not right-justified.
      if ENV['MARKDEEP'] || true
        # line = $& + $'.gsub(' ', "\u00A0")
        line
      else
        ('%-s %-2s %2d ' % [line, comment_to_EOL, i])
      end
    else
      ('%-s %-2s %2d ' % [line, comment_to_EOL, i])
      #  .gsub(' ', "\u00A0")
    end
  end
end

def comment_for_lang lang
  case lang.to_s.downcase
  when /lisp|scheme|scm|clojure|clj/i
    [ ';;', %r{^\s*;;} ]
  when /py|tcl|shell|sh|ruby|rb/i
    [ '#' , %r{^\s*\#} ]
  when /sql|postgres/i
    [ '--' , %r{^\s*--} ]
  when /^c|java/i
    [ '//', %r{^\s*(//|/\*)} ]
  when /^swig/i
    [ '//', %r{^\s*//[^%]} ]
  else
    [ '#' , %r{^\s*\#} ]
  end
end

def code_lines s, lang, swig_interface = nil
  s = s.sub(%r{\A.*\n *-- *HEADER-END *-- *\n}m, '')
  s = s.gsub(/;;\s*$/, ';')
  lines = string_to_lines(s)
  lines.map!{|s| remove_shebang(s)}
  trim_empty_lines!(lines)
  line_numbers!(lines, lang, swig_interface)
  lines_to_string(lines)
end

def pad_lines! lines, min_width = 78
  lines.each{|line| line.sub!(/\s+$/, '')}
  max_length = [ lines.map(&:size).max, min_width ].max
  fmt = "%-#{max_length}s"
  lines.map!{|line| fmt % [ line ]}
end

def wrap_line str, width = 78, newline =  "  \\\n", indent = '  '
  lines, line = [ ], String.new
  str.strip.split(/\s+/).each do | word |
    if line.size + word.size > width
      lines << line
      line = indent.dup
    end
    line << word << ' '
  end
  lines << line
  lines.each{|line| line.sub!(/\s+$/, '')}
  pad_lines!(lines, width)
  lines * newline
end

def markdeep str
  ENV['MARKDEEP'] ? str : markdeep_to_markdown(str)
end

def markdeep_to_markdown str
  lines = string_to_lines(str)
  lines.map! do |s|
    s.gsub(/^\* /, '').
      gsub(/^\*\*\*+ *$/m, '```')
  end
  lines_to_string(lines)
end

def rx str
  Regexp.new(Regexp.escape(str))
end

def run_workflow e
  out = cmd "bin/build clean-example build-example EXAMPLE=#{e[:name]}"
  if ENV['SWIG_101_VERBOSE']
    log("run_workflow: #{e[:name]}")
    # log(out)
  end
  lines = string_to_lines(out)
  lines.map! do | line |
    idempotently(line) do | line |
      line.
  gsub(%r{//+}, '/').
  # OSX:
  gsub(%r{-isysroot */Library/Developer/CommandLineTools/SDKs/.+?.sdk}, ' ').
  # Linux:
  gsub(%r{-I /usr/include/tcl\S* *}, ' ').
  # Arbitrary compiler flags:
  gsub(%r{ +(-g|-O\d|-DNDEBUG|-fwrapv|-Wall|-Wno-c\+\+11-extensions|-Wno-sentinel|-Wno-unused-result|-Wsign-compare|-Wunreachable-code|-fno-common|-Wno-unused-command-line-argument|-Wno-unknown-attributes|-Wno-ignored-attributes|-Wno-deprecated-declarations|-Wl,-undefined,dynamic_lookup) +}, ' ').
  gsub(%r{  +}, ' ').
  # brew:
  gsub(%r{-I */opt/homebrew/include +}, ' ').
  gsub(%r{-L */opt/homebrew/lib +}, ' ').
  gsub(%r{-I */opt/homebrew/opt/\S+ +}, ' ').
  gsub(%r{-L */opt/homebrew/opt/\S+ +}, ' ').
  gsub(%r{ld: warning: -undefined dynamic_lookup may not work with chained fixups}, ' ').
  # macports:
  gsub(%r{-I */opt/local/include\S* +}, ' ').
  gsub(%r{-L */opt/local/lib\S* +}, ' ').
  # local/:
  gsub(%r{-I *include\S* +}, ' ').
  gsub(%r{-I *local/include\S* +}, ' ').
  gsub(%r{-L *local/lib\S* +}, ' ').
  gsub(%r{  +}, ' ')
  end
end
  lines = clean_up_lines(dedup_empty_lines(lines))
  lines_to_string(lines.map{|l| wrap_line(l.gsub(%r{  +}, ' '))})
end

def clean_up_lines lines
  lines.map! do | line |
    idempotently(line) do | line |
    line.
    gsub('\0', ''). # mp_fwrite adds NULL?!?
    # Abs paths:
    gsub(%r{//+}, '/').
    # Normalize tool names:
    gsub('gmake', 'make').
    gsub(%r{\bclang\b}, 'cc').
    gsub(%r{\bclang\+\+\b}, 'c++').
    # Compiler flags:
    gsub(%r{ -g }, ' ').
    gsub(%r{ -O\d }, ' ').
    gsub(%r{ -Wno-c++11-extensions }, ' ').
    # make options:
    gsub(%r{--no-print-directory}, ' ').
    # OSX:
    gsub(%r{-framework \S+ }, ' ').
    # HOME Paths:
    replace_env('LOCAL_DIR').
    replace_env('GUILE_HOME').
    replace_env('TCL_HOME').
    replace_env('PYTHON_HOME').
    replace_env('RUBY_HOME').
    replace_env('JAVA_HOME').
    replace_env('ROOT_DIR', '.').
    replace_env('POSTGRESQL_INC_DIR').
    replace_env('POSTGRESQL_LIB_DIR').
    replace_env('POSTGRESQL_SHARE_DIR').
    # Abs paths:
    gsub(%r{/usr/bin/install}, 'install').
    gsub(%r{^/bin/sh +}, '').
    gsub(%r{/\S*/bin/(make|gmake|swig|python|ruby|tcl|tclsh|guile)}, '\1').
    # brew:
    gsub(%r{\$PYTHON_HOME/Frameworks/Python\.framework/Versions/[^/]+}, '$PYTHON_HOME').
    gsub(%r{-L */opt/homebrew/lib +}, ' ').
    gsub(%r{-I */opt/homebrew/include +}, ' ').
    # gsub(%r{\$GUILE_HOME/Cellar/guile/[^/]+/(bin|include|lib)}, '$GUILE_HOME/\1').
    # Java:
    gsub(%r{-I *\$JAVA_HOME/include/\S+ +}, '-I $JAVA_HOME/include/$JAVA_ARCH ').
    gsub(%r{-L *\$JAVA_HOME/lib/\S+ +},     '-L $JAVA_HOME/lib/$JAVA_ARCH ').
    # local/:
    gsub(%r{-I *include\S* +}, ' ').
    gsub(%r{\$LOCAL_DIR/bin/}, ' ').
    gsub(%r{-I *\$LOCAL_DIR/include +}, ' ').
    gsub(%r{-L *\$LOCAL_DIR/lib +}, ' ').
    # Formatting:
    #gsub(%r{-I(\S+)}, %q{-I \1}).
    #gsub(%r{-L(\S+)}, %q{-L \1}).
    gsub(%r{-I\s+(\S+)}, %q{-I\1}).
    gsub(%r{-L\s+(\S+)}, %q{-L\1}).
    # WTF?:
    gsub(' /darwin ', ' ').
    gsub('/arm64-darwin21', '/$RUBY_ARCH'). # Apple Silicon
    gsub(%r{//+}, '/').
    sub(%r{  +$}, ' ')
    end
  end
  lines.reject!{|l| l =~ /Experimental target language.*postgresql/}
  lines.reject!{|l| l =~ /Deprecated command line option/} # swig 4.1.0+
  lines.reject!{|l| l =~ /Warning 801: Wrong class name/} # swig 4.1.0+
  lines.reject!{|l| l =~ /Document-method:/ } # ruby
  lines.reject!{|l| l =~ /WARNING: .*clojure\.main.*use -M/} # clojure
  lines.reject!{|l| l =~ /rootdir: .*swig-101/} # pytest
  lines.reject!{|l| l =~ /ld: warning: directory not found for option/} # ld
  lines
end

def idempotently x
  raise unless String === x
  # log("before: {{{{ #{x} }}}}")
  y = yield x
  until x == y
    x = y
    y = yield x
  end
  # log("after:  {{{{ #{x} }}}}")
  y
end

class ::String
  def replace_env name, rep = nil
    if e = ENV[name] and e != ''
      self.gsub(e, rep || "$#{name}")
    else
      self
    end
  end
end

#####################################

log "Start"

cmd "bin/build clean"

example_names = `bin/build EXAMPLES`.split(/\s+/)

$examples = [ ]

example_names.each do | name |
  src       = "src/#{name}"
  basename  = name.sub(/\.([^.]+)$/, '')
  suffix    = $1
  lang = suffix.upcase
  lang = 'C++' if lang == 'CC'
  $examples << (e = {
    name:     name,
    basename: basename,
    src:      src,
    suffix:   suffix,
    lang:     lang,
  })

  log "{{{ Example : #{e[:name]}"
  pe(e: e)

  log "  {{{ Workflow : #{e[:name]}"
  e[:workflow_output] = run_workflow(e)
  msg e[:workflow_output]
  log "  }}} Workflow : #{e[:name]}"

  targets = <<"END".split("\n").map{|l| l.split("|").map(&:strip).map{|f| f.empty? ? nil : f}}
#{lang} Header          | #{basename}.h        | - |
#{lang} Library         | #{name}              | - |
#{lang} Native          | #{basename}-native.#{suffix} | target/native/#{basename}-native
#{lang} SWIG Interface  | #{basename}.i        | - | #{lang}
Python                  | #{basename}.py       |   | Python
Clojure (Java)          | #{basename}.clj      |   | Clojure
Ruby                    | #{basename}.rb       |   | Ruby
Guile                   | #{basename}.scm      |   | Scheme
TCL                     | #{basename}.tcl      |   | TCL
PostgreSQL              | #{basename}.psql     |   | SQL
Python Tests            | #{basename}-test.py  | python3.10 -m pytest src/#{basename}-test.py |
END
  e[:targets] =
    targets.
    map do |l|
      t = [:type, :file, :cmd, :lang].zip(l).to_h
      $context = t
      t[:name] = t[:file]
      t[:swig_interface] = t[:type] =~ /SWIG/i && 'swig'
      t[:lang] ||= t[:type].split(/\s+/).first
      t[:code_style] ||= t[:lang].downcase
      t[:code_style] = 'c++' if t[:code_style] == 'cc'
      t[:suffix] = t[:file].sub(%r{^.*(\.[^./]+)$}, '\1')

      # Determine a list of files/commands for this target:
      files = case t[:cmd]
      when '-'
        # No command:
        [
          {
            file: "src/#{t[:file]}",
          }
        ]
      when nil
        # Files may be executables:
        ([ "src/#{t[:file]}" ] +
          Dir["src/#{e[:basename]}-*#{t[:suffix]}"].sort
        ).map do | f |
            {
              file: f,
              cmd: File.executable?(f) && "#{f}",
            }
          end
      else
        # Just a command:
        [
          {
            file: "src/#{t[:file]}",
            cmd: "#{t[:cmd]}",
          }
        ]
      end
      files.select!{|f| File.exist?(f[:file])}
      files.each do | f |
        f[:name] = File.basename(f[:file])
        f[:code] = code_lines(File.read(f[:file]), t[:lang], t[:swig_interface])
        f[:output] = f[:cmd] && lines_to_string(trim_empty_lines!(clean_up_lines(string_to_lines(cmd(f[:cmd])))))
      end
      t[:files] = files
      msg t[:files]
      t
    end
  pe(e: e)
  # PP.pp(targets: targets, $stderr)
  # pe(targets: targets)
  log "}}} Example : #{e[:name]}"
end

log 'DONE'
