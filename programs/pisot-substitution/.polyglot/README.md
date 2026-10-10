# Polyglot boundary metadata

`ESTATE.toml` declares the repository layout and authority. Mojo is the
canonical executable; Lean and TLA+ supply the proof layer, and Python supplies
reference oracles and repository tooling. `polyglot.manifest.toml` records the
`psc-bpa-census` boundary and its refusal rules.

The schema and conformance vectors in this directory are generated from the
pinned `tools/polyglot_envelope/` package. Regenerate them with:

```sh
python3 tools/polyglot_envelope/render.py
python3 tools/polyglot_envelope/render.py --check
```

CI checks template drift. A conformance runner is not wired, as the manifest's
`ci_wiring = false` records. These metadata files introduce no acceptance
authority or new language runtime. Add an oracle or experiment directory only
when it contains a reproducible implementation with a concrete research target.
