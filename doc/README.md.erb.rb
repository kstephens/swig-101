#####################################

exit! if ENV['README_MD']
ENV['README_MD'] = '1'

require 'pp'

$verbose = false
$pe  = $verbose # || true
$msg = $verbose # || true

def msg *args
  if $msg
    $stderr.puts "\n  !!! #{$$} : README.md.erb : #{args * ' '}"
  end
end

def pe x
  if $verbose or $pe
    PP.pp(x, $stderr)
    $stderr.flush
  end
  x
end

def cmd cmd
  msg "cmd : #{cmd.inspect}"
  system "bin/run #{cmd} >tmp/cmd.out 2>&1"
  File.read("tmp/cmd.out")
end

def lines_to_string lines
  lines.join("\n")
end

def string_to_lines s
  s.split("\n", -1)
end

def trim_empty_lines!(lines)
  lines.each{|line| line.sub!(/\s+$/, '')}
  lines.shift while lines[ 0].empty?
  lines.pop   while lines[-1].empty?
  lines
end

def line_numbers! lines
  lines.map!.with_index(1) {|line, i| "%3d   %s" % [i, line] }
end

def string_lines s
  lines = string_to_lines(s)
  trim_empty_lines!(lines)
  line_numbers!(lines)
  lines_to_string(lines)
end

def wrap_line line, width = 78
  words = line.strip.split(/\s+/)
  out = String.new
  line = String.new
  words.each do | word |
    if line.size + word.size > width
      out += line + " \\\n  "
      line = String.new
    end
    line += word + ' '
  end
  out << line
end

def run_workflow e
  cmd "#{make} clean"
  out = cmd "#{make} build-example EXAMPLE=#{e[:name]}"
  out = out.
  gsub('/opt/local/bin/gmake', 'make').
  gsub(%r{^/.*/swig}, 'swig').
  gsub(%r{/Library/Java/JavaVirtualMachines/jdk.+?jdk/Contents/Home}, '$JAVA_HOME').
  gsub(%r{/opt/local/Library/Frameworks/Python.framework/Versions/[^/]+}, '$PYTHON_HOME').
  gsub(%r{-isysroot/Library/Developer/CommandLineTools/SDKs/.+?.sdk}, ' ').
  gsub(%r{^/.*/python}, 'python').
  gsub(%r{ *-I */opt/local/include[^ ]* *}, ' ').
  gsub(%r{ *-L */opt/local/lib[^ ]* *}, ' ').
  gsub(%r{#{ENV['PYTHON_HOME']}}, '$PYTHON_HOME').
  gsub(%r{#{ENV['RUBY_HOME']}}, '$RUBY_HOME').
  gsub(%r{#{ENV['GUILE_HOME']}}, '$GUILE_HOME').
  gsub(%r{#{ENV['JAVA_HOME']}}, '$JAVA_HOME').
  gsub(%r{#{ENV['HOME']}}, '$HOME').
  gsub(%r{  +}, ' ')
  lines = out.split("\n", 999999)
  lines.reject!{|l| l =~ /Deprecated command line option/} # swig 4.1.0+
  lines.reject!{|l| l =~ /Document-method:/ } # ruby
  lines.map{|l| wrap_line(l.gsub(%r{  +}, ' '))}.join("\n")
end

def make
  'bin/build'
end

#####################################

msg "Start"

example_names = %w(polynomial.cc example1.c)

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

  targets = <<"END".split("\n").map{|l| l.split("|").map(&:strip).map{|f| f.empty? ? nil : f}}
#{lang} Header          | src/#{basename}.h        | - |
#{lang} Library         | src/#{name}              | - |
#{lang} Main            | src/#{basename}-native.#{suffix} | target/native/#{basename}
#{lang} SWIG Interface  | src/#{basename}.i        | - | #{lang}
Python                  | src/#{basename}-python   |   |
Clojure (Java)          | src/#{basename}-clojure  |   | Lisp
Ruby                    | src/#{basename}-ruby     |   |
Guile                   | src/#{basename}-guile    |   | Scheme
TCL                     | src/#{basename}-tcl      |   |
END
  e[:targets] =
    targets.
    map do |l|
      t = [:type, :file, :cmd, :lang].zip(l).to_h
      t[:name] ||= t[:file]
      if t[:cmd] == '-'
        t[:cmd] = nil
      else 
        t[:cmd] ||= t[:file]
      end
      t[:lang] ||= t[:type].split(/\s+/).first
      t
    end
  # PP.pp(targets: targets, $stderr)
  pe(targets: targets)
end

