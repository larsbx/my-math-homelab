# T3 Finite Certificate — Prime Equality Below the Mod-3 Threshold

This file is the finite part of the proof that, for prime q,

J_2(q-1)=J_2(q+1)

holds exactly for q = 29, 41, 71.

The general theorem handles every prime q ≡ 1 (mod 3), and every prime q ≡ -1 (mod 3) with q >= 322. Therefore only the following 34 primes require direct evaluation.

| q | J_2(q-1) | J_2(q+1) | Delta(q) |
|---:|---:|---:|---:|
| 5 | 12 | 24 | 12 |
| 11 | 72 | 96 | 24 |
| 17 | 192 | 216 | 24 |
| 23 | 360 | 384 | 24 |
| 29 | 576 | 576 | 0 |
| 41 | 1152 | 1152 | 0 |
| 47 | 1584 | 1536 | -48 |
| 53 | 2016 | 1944 | -72 |
| 59 | 2520 | 2304 | -216 |
| 71 | 3456 | 3456 | 0 |
| 83 | 5040 | 4608 | -432 |
| 89 | 5760 | 5184 | -576 |
| 101 | 7200 | 6912 | -288 |
| 107 | 8424 | 7776 | -648 |
| 113 | 9216 | 8640 | -576 |
| 131 | 12096 | 11520 | -576 |
| 137 | 13824 | 12672 | -1152 |
| 149 | 16416 | 14400 | -2016 |
| 167 | 20664 | 18432 | -2232 |
| 173 | 22176 | 20160 | -2016 |
| 179 | 23760 | 20736 | -3024 |
| 191 | 25920 | 24576 | -1344 |
| 197 | 28224 | 25920 | -2304 |
| 227 | 38304 | 34560 | -3744 |
| 233 | 40320 | 36288 | -4032 |
| 239 | 41472 | 36864 | -4608 |
| 251 | 45000 | 41472 | -3528 |
| 257 | 49152 | 44352 | -4800 |
| 263 | 51480 | 46080 | -5400 |
| 269 | 53856 | 46656 | -7200 |
| 281 | 55296 | 52992 | -2304 |
| 293 | 63936 | 56448 | -7488 |
| 311 | 69120 | 64512 | -4608 |
| 317 | 74880 | 67392 | -7488 |

The zero rows are exactly q = 29, 41, 71.

## Proper odd prime powers below 322

For the prime-power reduction, the proper odd prime powers below 322 are:

| q | form | J_2(q-1) | J_2(q+1) | Delta(q) |
|---:|:---:|---:|---:|---:|
| 9 | 3^2 | 48 | 72 | 24 |
| 25 | 5^2 | 384 | 504 | 120 |
| 27 | 3^3 | 504 | 576 | 72 |
| 49 | 7^2 | 1536 | 1800 | 264 |
| 81 | 3^4 | 4608 | 5040 | 432 |
| 121 | 11^2 | 9216 | 11160 | 1944 |
| 125 | 5^3 | 11520 | 10368 | -1152 |
| 169 | 13^2 | 18432 | 20736 | 2304 |
| 243 | 3^5 | 43560 | 44640 | 1080 |
| 289 | 17^2 | 55296 | 60480 | 5184 |

None is an equality case.

All entries are exact integer evaluations using

J_2(n)=n^2 product_{p|n}(1-p^{-2}).

This certificate is finite and independently replayable; it is not an asymptotic computation.
