# Theorem C run logs — 2026-10-08

Output of `kernel/class_b_cone_certificate.mojo plus` and `... minus`, the
canonical certificate behind Theorem C of
`docs/p1b-symbolic-cone-2026-10-08.md`. Each line is one attempted symbolic
region (`undecided: …` names the read that failed at that shift; the next
shift is then tried), one certified region with its vertex count, or (in
`minus.out` only) one member decided by the exact kernel. `plus.out` was
produced before the driver logged exact members; its totals line is the same
format. Provenance, not a proof: rerun `pixi run class-b-cone-certificate` to
reproduce.
