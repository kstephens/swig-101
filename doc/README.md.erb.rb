# frozen_string_literal: true

# Prevent accidental Makefile recursion:
exit! if ENV['_SWIG_101_README_MD']
ENV['_SWIG_101_README_MD'] = '1'

require 'pp'

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
  system "#{cmd} >tmp/cmd.out 2>&1"
  result = $?
  out = File.read("tmp/cmd.out").gsub("\0", '')
  out = lines_to_string(string_to_lines(out))
  log "cmd : #{cmd} : DONE #{result.exitstatus}"
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
end

def trim_empty_lines!(lines)
  lines.each{|line| line.sub!(/\s+$/, '')}
  lines.shift while lines[ 0] && lines[ 0].empty?
  lines.pop   while lines[-1] && lines[-1].empty?
  lines
end

def dedup_empty_lines(lines)
  result = [ ]
  last = nil
  while line = lines.shift
    unless last == "" && line == ""
      result << line
    end
    last = line
  end
  result
end

def line_numbers! lines, lang, swig_interface = nil
  comment_to_EOL, comment_line_rx = comment_for_lang(swig_interface || lang)
  pad_lines!(lines)
  lines.map!.with_index(1) do |line, i|
    case line
    when %r{^\s*$}
      line
    when comment_line_rx
      line
    else
      ('%-s %-2s %2d ' % [line, comment_to_EOL, i])
      #  .gsub(' ', "\u00A0")
    end
  end
end

def comment_for_lang lang
  case lang.to_s.downcase
  when /^c|java/i
    [ '//', %r{^\s*(//|/\*)} ]
  when /^swig/i
    [ '//', %r{^\s*//[^%]} ]
  when /lisp|scheme|scm|clojure|clj/i
    [ ';;', %r{^\s*;;} ]
  when /py|tcl|shell|sh|ruby|rb/i
    [ '#' , %r{^\s*\#} ]
  else
    [ '#' , %r{^\s*\#} ]
  end
end

def code_lines s, lang, swig_interface = nil
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
  out = out.
  gsub(%r{//+}, '/').
  gsub(%r{-isysroot */Library/Developer/CommandLineTools/SDKs/.+?.sdk}, ' ').
  # Linux:
  gsub(%r{-I /usr/include/tcl[^ ]* *}, ' ').
  # macports:
  gsub(%r{-I */opt/local/include[^ ]* *}, ' ').
  gsub(%r{-L */opt/local/lib[^ ]* *}, ' ').
  # brew:
  gsub(%r{-I */opt/homebrew/include[^ ]* *}, ' ').
  gsub(%r{-L */opt/homebrew/lib[^ ]* *}, ' ').
  gsub(%r{-I *\S+/opt/\S*include[^ ]* *}, ' ').
  gsub(%r{-L *\S+/opt/\S*lib[^ ]* *}, ' ').
  gsub(%r{-I *\S+/opt/\S+ *}, ' ').
  gsub(%r{-L *\S+/opt/\S+ *}, ' ').
  # local/:
  gsub(%r{-I *include[^ ]* *}, ' ').
  gsub(%r{-I *local/include[^ ]* *}, ' ').
  gsub(%r{-L *local/lib[^ ]* *}, ' ').
  gsub(%r{  +}, ' ')
  lines = clean_up_lines(dedup_empty_lines(string_to_lines(out)))
  lines_to_string(lines.map{|l| wrap_line(l.gsub(%r{  +}, ' '))})
end

def clean_up_lines lines
  lines.map! do | line |
    line.
    gsub('\0', ''). # mp_fwrite adds NULL?!?
    # Abs paths:
    gsub(%r{//+}, ' ').
    gsub('gmake', 'make').
    # OSX:
    gsub(%r{/Library/Java/JavaVirtualMachines/jdk.+?jdk/Contents/Home}, '$JAVA_HOME').
    gsub(%r{-framework \S+ }, ' ').
    # HOME Paths:
    gsub(ENV['PYTHON_HOME'],  '$PYTHON_HOME').
    gsub(ENV['RUBY_HOME'],    '$RUBY_HOME').
    gsub(ENV['GUILE_HOME'],   '$GUILE_HOME').
    gsub(ENV['JAVA_HOME'],    '$JAVA_HOME').
    gsub(ENV['HOME'],         '$HOME').
    gsub(ENV['ROOT_DIR'],     '.').
    # Abs paths:
    gsub(%r{/\S*/(make|gmake|swig|python|ruby|tcl|guile)}, '\1').
    # brew:
    gsub(%r{\$PYTHON_HOME/Frameworks/Python\.framework/Versions/[^/]+}, '$PYTHON_HOME').
    gsub(%r{\$GUILE_HOME/Cellar/guile/[^/]+/(bin|include|lib)}, '$GUILE_HOME/\1').
    # Duplicates:
    gsub(%r{\s+(-[IL]\S*)\s+\1}, ' ').
    gsub(%r{//+}, '/').
    sub(%r{\s+$}, '')
  end
  lines.reject!{|l| l =~ /Deprecated command line option/} # swig 4.1.0+
  lines.reject!{|l| l =~ /Document-method:/ } # ruby
  lines.reject!{|l| l =~ /WARNING: .*clojure\.main.*use -M/} # clojure
  lines.reject!{|l| l =~ /rootdir: .*swig-101/} # pytest
  lines.reject!{|l| l =~ /ld: warning: directory not found for option/} # ld
  lines
end

#####################################

msg "Start"

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

  msg "{{{ Example : #{e[:name]}"
  pe(e: e)

  msg "  {{{ Workflow : #{e[:name]}"
  e[:workflow_output] = run_workflow(e)
  msg e[:workflow_output]
  msg "  }}} Workflow : #{e[:name]}"

  targets = <<"END".split("\n").map{|l| l.split("|").map(&:strip).map{|f| f.empty? ? nil : f}}
#{lang} Header          | #{basename}.h        | - |
#{lang} Library         | #{name}              | - |
#{lang} Main            | #{basename}-native.#{suffix} | target/native/#{basename}
#{lang} SWIG Interface  | #{basename}.i        | - | #{lang}
Python                  | #{basename}.py       |   |
Clojure (Java)          | #{basename}.clj      |   | Lisp
Ruby                    | #{basename}.rb       |   |
Guile                   | #{basename}.scm      |   | Scheme
TCL                     | #{basename}.tcl      |   | Shell
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
      t[:file] = "src/#{t[:file]}"
      t[:code] = File.exist?(t[:file]) && code_lines(File.read(t[:file]), t[:lang], t[:swig_interface])
      case t[:cmd]
      when '-'
      when nil
        t[:run] = "bin/run #{t[:file]}"
      else
        t[:run] = "bin/run #{t[:cmd]}"
      end if t[:code]
      t[:run_output] = t[:run] && lines_to_string(trim_empty_lines!(clean_up_lines(string_to_lines(cmd(t[:run])))))
      msg t[:run_output]
      t
    end
  pe(e: e)
  # PP.pp(targets: targets, $stderr)
  # pe(targets: targets)
  msg "}}} Example : #{e[:name]}"
end

msg 'DONE'
