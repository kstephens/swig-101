import black_scholes_swig
import black_scholes_py

main():
  examples = random_examples()
  benchmark(black_scholes_py,    )
  benchmark(black_scholes_swig,  )
  
benchmark(bs, prepare_examples, example):

random_examples():
  N = 1000000
  examples = [
    random_example()
    for i in 1 .. n
  ]
  (_, dt_ms) = elapsed_ms(process_examples, bs, examples))
  print(f'{bs} {dt_ms} ms')

random_example():
  return [ random_offset(x, 0.10) for x in examples.sample() ]  
  
random_offset(x, relative):
  return x + (rand() - 0.5) * relative * 2 

elapsed_ms(fn, *args, **kwargs):
  t0 = time.now()
  result = fn(*args, **kwargs)
  t1 = time.now()
  return (result, (t1 - t0) * 1000
  
  
  
