def P(x)
  puts "#{x} = #{eval(x, TOPLEVEL_BINDING)}"
end

def show_exprs *exprs
  exprs.each{|x| P(x)}
end
