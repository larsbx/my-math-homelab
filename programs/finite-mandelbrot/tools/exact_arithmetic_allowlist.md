# Exact Arithmetic Allowlist

Files that may contain floating-point types or literals. Each entry must have a
matching `QUARANTINED` row in section 6.2 of
`docs/rational-interval-arithmetic-spec.md`, and none of them may be imported
by a module that constructs, evaluates, or accepts certificate data.

- `kernel/mojo/dynamics/complex_box.mojo` — `Float64` demo substrate; replacement target is
  dyadic-rational endpoints per `docs/interval-orbit-native-target.md`.
- `kernel/mojo/dynamics/finite_mandelbrot.mojo` — legacy demo iteration over `Float64`.
- `kernel/mojo/entrypoints/run_examples.mojo` — demo driver over the `C64` substrate.

Removing a file from this list requires removing its floating-point use, or
deleting the file, in the same change.
