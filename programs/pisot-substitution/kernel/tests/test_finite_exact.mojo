"""Executes the vendored finite_exact arithmetic and interval checks under the PSC toolchain.

The byte-level identity of the vendored files with their pinned upstream
commits is checked separately by tools/vendoring/check_vendored_sync.py.
"""

from finite_exact.bigint_z import bigint_z_phase_one_smoke, bigint_z_phase_two_smoke, bigint_z_phase_three_smoke, bigz_long_division_smoke
from finite_exact.rat_q import bigq_storage_smoke, demo_q_normalization, demo_q_order, q_cancellation_smoke
from finite_exact.closed_interval import bigq_interval_conformance_smoke, demo_complex_quadrance_point, demo_interval_mul
from mojo_smoke.claims import require_contract


def main() raises:
    if not bigint_z_phase_one_smoke() or not bigint_z_phase_two_smoke() or not bigint_z_phase_three_smoke():
        raise Error("finite_exact BigZ smoke failed")
    if not bigz_long_division_smoke():
        raise Error("finite_exact long division smoke failed")
    if not bigq_storage_smoke() or not q_cancellation_smoke() or not demo_q_normalization() or not demo_q_order():
        raise Error("finite_exact Q smoke failed")
    if not bigq_interval_conformance_smoke() or not demo_interval_mul() or not demo_complex_quadrance_point():
        raise Error("finite_exact closed-interval smoke failed")
    print("finite_exact vendored smoke checks passed.")
    require_contract("the vendored finite_exact arithmetic and closed-interval kernels compile and hold under the PSC toolchain")
