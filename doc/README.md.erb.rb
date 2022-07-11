# frozen_string_literal: true

# Prevent accidental Makefile recursion:
exit! if ENV['_SWIG_101_README_MD']
ENV['_SWIG_101_README_MD'] = '1'

require 'pp'

$verbose = false
$pe  = $verbose # || true
$msg = $verbose # || true
$context = nil

def msg *args
  if $msg # || true
    $stderr.puts "\n  !!! #{$$} : README.md.erb.rb : #{args * ' '}"
  end
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
  msg "cmd : #{cmd.inspect}"
  system "#{cmd} >tmp/cmd.out 2>&1"
  ok = $?.success?
  # puts File.read("tmp/cmd.out")
  out = File.read("tmp/cmd.out").gsub("\0", '')
  out = lines_to_string(string_to_lines(out))
  raise "#{cmd} : failed : #{$context.inspect} : #{out}" unless ok
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

def line_numbers! lines, lang
  com_beg, com_end = comment_for_lang(lang)
  max_width = [lines.map(&:size).max, 70].max
  fmt = "%%-%ds  %s %%2d %s" % [max_width, com_beg, com_end]
  lines.map!.with_index(1) {|line, i| fmt % [line, i] }
end

def comment_for_lang lang
  case lang.to_s.downcase
  when /^c/
    %w(//) # %w(/* */)
  when /lisp|scheme|scm|clojure|clj/i
    %w(;;)
  when /py|tcl|shell|sh|ruby|rb/i
    %w(#)
  else
    %w(#)
  end
end

def code_lines s, lang
  lines = string_to_lines(s)
  lines.map!{|s| remove_shebang(s)}
  trim_empty_lines!(lines)
  line_numbers!(lines, lang)
  lines_to_string(lines)
end

def wrap_line str, width = 78, newline =  " \\\n  "
  out, line = String.new, String.new
  str.strip.split(/\s+/).each do | word |
    if line.size + word.size > width
      out << line << newline
      line.clear
    end
    line << word << ' '
  end
  out << line
end

def markdeep str
  if ENV['MARKDEEP']
    str
  else
    markdeep_to_markdown(str)
  end
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
    gsub('/opt/local/bin/gmake',    'make').
    gsub('/opt/homebrew/bin/gmake', 'make').
    gsub('gmake',                   'make').
    gsub(%r{/\S*/swig}, 'swig').
    gsub(%r{/\S*/python}, 'python').
    # OSX:
    gsub(%r{/Library/Java/JavaVirtualMachines/jdk.+?jdk/Contents/Home}, '$JAVA_HOME').
    gsub(ENV['PYTHON_HOME'],  '$PYTHON_HOME').
    gsub(ENV['RUBY_HOME'],    '$RUBY_HOME').
    gsub(ENV['GUILE_HOME'],   '$GUILE_HOME').
    gsub(ENV['JAVA_HOME'],    '$JAVA_HOME').
    gsub(ENV['HOME'],         '$HOME').
    gsub(ENV['ROOT_DIR'],     '.').
    # brew:
    gsub(%r{\$PYTHON_HOME/Frameworks/Python\.framework/Versions/[^/]+}, '$PYTHON_HOME').
    gsub(%r{\$GUILE_HOME/Cellar/guile/[^/]+/(bin|include|lib)}, '$GUILE_HOME/\1')
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

example_names = %w(example1.c polynomial.cc polynomial_v2.cc tommath.c)

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
      t[:lang] ||= t[:type].split(/\s+/).first
      t[:code_style] ||= t[:lang].downcase
      t[:file] = "src/#{t[:file]}"
      t[:code] = File.exist?(t[:file]) && code_lines(File.read(t[:file]), t[:lang])
      case t[:cmd]
      when '-'
      when nil
        t[:run] = "bin/run #{t[:file]}"
      else
        t[:run] = t[:cmd]
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

