#!/usr/bin/env python3.10
import sys ; sys.path.append('target/python')
import black_scholes_swig as bs
import json
data = [
    # strike_price, asset_price, standard_deviation, risk_free_rate,  days_to_expiry:
    # vary expiry:
    [ 1.50, 2.00, 0.5,  2.25, 30 ],
    [ 1.50, 2.00, 0.5,  2.25, 15 ],
    [ 1.50, 2.00, 0.5,  2.25, 10 ],
    [ 1.50, 2.00, 0.5,  2.25,  5 ],
    [ 1.50, 2.00, 0.5,  2.25,  2 ],
    # vary strike:
    [ 0.50, 2.00, 0.25, 2.25, 15 ],
    [ 1.00, 2.00, 0.25, 2.25, 15 ],
    [ 1.50, 2.00, 0.25, 2.25, 15 ],
    [ 2.00, 2.00, 0.25, 2.25, 15 ],
    [ 2.50, 2.00, 0.25, 2.25, 15 ],
    [ 3.00, 2.00, 0.25, 2.25, 15 ],
    [ 3.50, 2.00, 0.25, 2.25, 15 ],
]
for r in data:
   c = bs.black_scholes_call (r[0], r[1], r[2], r[3], r[4])
   p = bs.black_scholes_put  (r[0], r[1], r[2], r[3], r[4])
   print(json.dumps({'input': r, "call": round(c, 3), "put": round(p, 3)}))
