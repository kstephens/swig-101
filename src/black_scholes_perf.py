import black_scholes_swig
import black_scholes_py
import postgresql as pg

main():
  examples = random_examples()
  pg_conn = connnect_pg(()
  pg_insert_examples(pg_conn, examples)
  benchmark(examples, compute_local, black_scholes_py,   )
  benchmark(examples, compute_local, black_scholes_swig,  )
  
benchmark(examples, bs, fetch_examples):
  examples = fetch_examples(examples)
  (_, dt_ms) = elapsed_ms(compute, bs, examples)
  print(f'{bs} {dt_ms} ms')

compute_local(bs, examples):
  
compute_postgres(bs, example):
  profitable_short

pg_insert_examples(pg_conn, examples):
  pg.execute('DROP TABLE IF EXISTS bs_examples')
  pg.execute('CREATE TABLE bs_examples(...)')
                        
random_examples():
  N = 1000000
  examples = [
    random_example()
    for i in 1 .. n
  ]

random_example():
  return [ random_offset(x, 0.10) for x in examples.sample() ]  
  
random_offset(x, relative):
  return x + (rand() - 0.5) * relative * 2 

elapsed_ms(fn, *args, **kwargs):
  t0 = time.now()
  result = fn(*args, **kwargs)
  t1 = time.now()
  return (result, (t1 - t0) * 1000
  
  
  
