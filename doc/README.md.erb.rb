
# Prevent accidental Makefile recursion:
exit! if ENV['_SWIG_101_README_MD']
ENV['_SWIG_101_README_MD'] = '1'

require 'pp'

$verbose = false
$pe  = $verbose # || true
$msg = $verbose # || true
$context = nil

def msg *args
  if $msg
    $stderr.puts "\n  !!! #{$$} : README.md.erb : #{args * ' '}"
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
  out = File.read("tmp/cmd.out")
  raise "#{cmd} : failed : #{$context.inspect} : #{out}" unless ok
  out
end

def remove_shebang s
  s.gsub(%r{(^#!.*$)|(!#)|(^.+ -\*- [a-z]+ -\*-.*$)|(^#pragma +once.*$)}, '')
end

def lines_to_string lines
  lines.join("\n")
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

def line_numbers! lines
  lines.map!.with_index(1) {|line, i| "%3d   %s" % [i, line] }
end

def code_lines s
  lines = string_to_lines(s)
  lines.map!{|s| remove_shebang(s)}
  trim_empty_lines!(lines)
  line_numbers!(lines)
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

def run_workflow e
  out = cmd "bin/build clean-example build-example EXAMPLE=#{e[:name]}"
  out = out.
  gsub('/opt/local/bin/gmake', 'make').
  gsub(%r{^/.*/swig}, 'swig').
  gsub(%r{/Library/Java/JavaVirtualMachines/jdk.+?jdk/Contents/Home}, '$JAVA_HOME').
  gsub(%r{/opt/local/Library/Frameworks/Python.framework/Versions/[^/]+}, '$PYTHON_HOME').
  gsub(%r{-isysroot/Library/Developer/CommandLineTools/SDKs/.+?.sdk}, ' ').
  gsub(%r{^/.*/python}, 'python').
  gsub(%r{ *-I */opt/local/include[^ ]* *}, ' ').
  gsub(%r{ *-L */opt/local/lib[^ ]* *}, ' ').
  gsub(%r{#{ENV['PYTHON_HOME']}},  '$PYTHON_HOME').
  gsub(%r{#{ENV['RUBY_HOME']}},    '$RUBY_HOME').
  gsub(%r{#{ENV['GUILE_HOME']}},   '$GUILE_HOME').
  gsub(%r{#{ENV['JAVA_HOME']}},    '$JAVA_HOME').
  gsub(%r{#{ENV['HOME']}},         '$HOME').
  gsub(%r{  +}, ' ')
  lines = out.split("\n", 999999)
  lines.reject!{|l| l =~ /Deprecated command line option/} # swig 4.1.0+
  lines.reject!{|l| l =~ /Document-method:/ } # ruby
  lines.map{|l| wrap_line(l.gsub(%r{  +}, ' '))}.join("\n")
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
TCL                     | #{basename}.tcl      |   | Bash
Python Tests            | #{basename}-test.py  | python3.10 -m pytest src/#{basename}-test.py |
END
  e[:targets] =
    targets.
    map do |l|
      t = [:type, :file, :cmd, :lang].zip(l).to_h
      $context = t
      t[:name] = t[:file]
      t[:lang] ||= t[:type].split(/\s+/).first
      t[:file] = "src/#{t[:file]}"
      t[:code] = File.exist?(t[:file]) && code_lines(File.read(t[:file]))
      case t[:cmd]
      when '-'
      when nil
        t[:run] = "bin/run #{t[:file]}"
      else
        t[:run] = t[:cmd]
      end if t[:code]
      t[:run_output] = t[:run] && lines_to_string(trim_empty_lines!(string_to_lines(cmd(t[:run]))))
      msg t[:run_output]
      t
    end
  pe(e: e)
  # PP.pp(targets: targets, $stderr)
  # pe(targets: targets)
  msg "}}} Example : #{e[:name]}"
end

msg 'DONE'

