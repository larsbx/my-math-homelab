# No-Trig Scan Scope

The audit guard is intentionally simple and lexical.

Current intended enforcement path:

- core Mojo source under `kernel/` and the vendored `vendor/mojo/`
- executable tokens only; comments and strings are masked so policy documents,
  diagnostics, and rejection messages may name forbidden concepts

The scanner rejects analytic circular functions, inverse and hyperbolic
trigonometric functions, `exp`, `log`, `sqrt`, angle measurement,
radians/degrees, polar-angle APIs, and unit-circle machinery.
