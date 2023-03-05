#!/usr/bin/env python3.10
import sys ; sys.path.append('target/python')
import black_scholes_swig as bs

data = [
    # strike_price, asset_price, standard_deviation, risk_free_rate,  days_to_expiry:
    # vary expiry:
    [ 1.50, 2.00, 0.5,  2.25, 30.0 ],
    [ 1.50, 2.00, 0.5,  2.25, 15.0 ],
    [ 1.50, 2.00, 0.5,  2.25, 10.0 ],
    [ 1.50, 2.00, 0.5,  2.25,  5.0 ],
    [ 1.50, 2.00, 0.5,  2.25,  2.0 ],
    # vary strike:
    [ 0.50, 2.00, 0.25, 2.25, 15.0 ],
    [ 1.00, 2.00, 0.25, 2.25, 15.0 ],
    [ 1.50, 2.00, 0.25, 2.25, 15.0 ],
    [ 2.00, 2.00, 0.25, 2.25, 15.0 ],
    [ 2.50, 2.00, 0.25, 2.25, 15.0 ],
    [ 3.00, 2.00, 0.25, 2.25, 15.0 ],
    [ 3.50, 2.00, 0.25, 2.25, 15.0 ],
]
for r in data:
    c = bs.black_scholes_call (*r)
    p = bs.black_scholes_put  (*r)
    print("inputs: [ %5.2f, %5.2f, %5.2f, %5.2f, %5.2f ], call: %6.3f, put: %6.3f" %
            (*r, c, p))
