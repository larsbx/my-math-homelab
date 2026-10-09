"""Print replayable counts for docs/representation-control-bpa-vs-overlap-2026-10-02.md.

Run from kernel/: pixi run mojo run -I . representation_control.mojo
Four fixed specimens only; no census, quotient, spectral margin, or theorem.
"""

from psc.corpus import STATE_CAP
from psc.representation_control import (
    MIN_PREFIX_LENGTH,
    TRANSLATION_PREFIX_LENGTH,
    RepresentationCounts,
    recompute_counts,
    specimen_keys,
)


def main() raises:
    var keys = specimen_keys()
    var rows = List[RepresentationCounts]()
    # Compute all rows before printing a table; a refusal is not a partial
    # completed evidence table.
    for i in range(len(keys)):
        rows.append(recompute_counts(keys[i]))
    print("# Four-specimen finite representation comparison; no theorem/status change")
    print("# cap:", STATE_CAP, "minimum fixed-point prefix:", MIN_PREFIX_LENGTH,
          "translation prefix k:", TRANSLATION_PREFIX_LENGTH)
    print("| substitution key | det | BPA types | swap-seed overlap types | finite-prefix OA types |")
    print("| --- | ---: | ---: | ---: | ---: |")
    for i in range(len(rows)):
        ref row = rows[i]
        print("| `" + keys[i] + "` | `+" + String(row.determinant)
              + "` | `" + String(row.bpa_types) + "` | `"
              + String(row.comparison.seed_types) + "` | `"
              + String(row.comparison.oa_types) + "` |")
    print("| substitution key | q | c | actual prefix length | window | OA minus seed | seed minus OA | BPA/seed/OA all productive |")
    print("| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |")
    for i in range(len(rows)):
        ref row = rows[i]
        ref report = row.comparison
        print("| `" + keys[i] + "` | " + String(report.power) + " | "
              + String(report.letter) + " | " + String(row.prefix_length)
              + " | " + String(row.window) + " | " + String(report.oa_minus_seed)
              + " | " + String(report.seed_minus_oa) + " | "
              + String(row.bpa_all_productive) + "/" + String(row.seed_all_productive)
              + "/" + String(report.oa_all_productive) + " |")
    print("# Differences omit coincidences; OA factors come from a finite uncertified prefix.")
    print("# All rows uncapped. Counts do not test a determinant law or a productivity margin.")
