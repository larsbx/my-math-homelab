"""Regressions for the tuning, directive-prefix, and column-coincidence kernels
of the vendored substitution_dynamics package (larsbx/finite-math-kernels,
docs/tuning-substitutions-spec.md there, sections 1 to 3).

Every constant pinned here is also pinned upstream by the package's own Mojo
test and Python oracle; this file makes the consumer's CI compile the three
modules and check the contracts it relies on: the star product is composition
of tuning substitutions, the DGP parity is closed under it, the kneading prefix
is common to every image of the composite, and column coincidence reports the
least depth with negative calibrations. Nothing here is a claim about spectrum
or about any PSC gate: constant length is outside the irreducible Pisot regime
(docs/tuning-substitutions-stop-go-2026-09-16.md).
"""

from std.testing import assert_equal, assert_false, assert_true

from substitution_dynamics.coincidence import column_coincidence, constant_length, is_constant_length
from substitution_dynamics.sadic import apply_directive, compose, directive_composite
from substitution_dynamics.substitution import Substitution
from substitution_dynamics.tuning import TuningPattern, dgp_twist, kneading_prefix, star_product
from mojo_smoke.claims import require_contract


def period_doubling() raises -> TuningPattern:
    var prefix: List[Int] = [1]
    return TuningPattern.dgp(prefix)


def thue_morse() raises -> Substitution:
    var images: List[List[Int]] = [[0, 1], [1, 0]]
    return Substitution.checked(images)


def fibonacci() raises -> Substitution:
    var images: List[List[Int]] = [[0, 1], [0]]
    return Substitution.checked(images)


def same_images(s: Substitution, t: Substitution) -> Bool:
    if s.size != t.size:
        return False
    for a in range(s.size):
        if s.image(a) != t.image(a):
            return False
    return True


def test_boundaries_fail_closed() raises:
    var caught = False
    try:
        _ = TuningPattern.checked(List[Int](), False)
    except:
        caught = True
    assert_true(caught)
    var outside: List[Int] = [0, 2]
    caught = False
    try:
        _ = TuningPattern.checked(outside, True)
    except:
        caught = True
    assert_true(caught)
    var three: List[List[Int]] = [[0, 1, 2], [0], [1]]
    caught = False
    try:
        _ = compose(thue_morse(), Substitution.checked(three))
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = directive_composite(List[Substitution]())
    except:
        caught = True
    assert_true(caught)
    caught = False
    try:
        _ = kneading_prefix(List[TuningPattern]())
    except:
        caught = True
    assert_true(caught)
    assert_false(is_constant_length(fibonacci()))
    caught = False
    try:
        _ = column_coincidence(fibonacci())
    except:
        caught = True
    assert_true(caught)


def test_star_product_is_composition_and_dgp_parity_is_closed() raises:
    var p = period_doubling()
    assert_equal(p.substitution().image(0), [1, 1])
    assert_equal(p.substitution().image(1), [1, 0])
    var a2 = star_product(p, p)
    assert_equal(a2.prefix, [1, 0, 1])
    assert_false(a2.twist)
    assert_equal(dgp_twist(a2.prefix), a2.twist)
    assert_true(same_images(a2.substitution(), compose(p.substitution(), p.substitution())))
    var pa: List[Int] = [0, 1, 1]
    var pb: List[Int] = [1, 0]
    var a = TuningPattern.checked(pa, False)
    var b = TuningPattern.checked(pb, True)
    assert_true(same_images(star_product(a, b).substitution(), compose(a.substitution(), b.substitution())))
    assert_true(same_images(star_product(b, a).substitution(), compose(b.substitution(), a.substitution())))
    assert_equal(star_product(a, b).period(), a.period() * b.period())


def test_kneading_prefix_is_common_to_every_image_of_the_composite() raises:
    var p = period_doubling()
    var pats = List[TuningPattern]()
    var subs = List[Substitution]()
    for _ in range(3):
        pats.append(p.copy())
        subs.append(p.substitution())
    var prefix = kneading_prefix(pats)
    assert_equal(prefix, [1, 0, 1, 1, 1, 0, 1])
    var comp = directive_composite(subs)
    var w: List[Int] = [0, 1, 1]
    assert_equal(comp.apply(w), apply_directive(subs, w))
    for s in range(2):
        var img = comp.image(s)
        assert_equal(len(img), len(prefix) + 1)
        for i in range(len(prefix)):
            assert_equal(img[i], prefix[i])


def test_column_coincidence_reports_least_depth_with_calibrations() raises:
    var w = column_coincidence(period_doubling().substitution())
    assert_true(w.found)
    assert_equal(w.depth, 1)
    assert_equal(w.columns, [0])
    var tm = column_coincidence(thue_morse())
    assert_false(tm.found)
    assert_equal(tm.depth, -1)
    var three: List[List[Int]] = [[0, 1], [2, 0], [2, 1]]
    var depth_two = column_coincidence(Substitution.checked(three))
    assert_equal(constant_length(Substitution.checked(three)), 2)
    assert_true(depth_two.found)
    assert_equal(depth_two.depth, 2)
    assert_equal(depth_two.columns, [0, 1])
    var one: List[List[Int]] = [[0]]
    assert_equal(column_coincidence(Substitution.checked(one)).depth, 0)


def main() raises:
    test_boundaries_fail_closed()
    print("[PASS] test_boundaries_fail_closed")
    test_star_product_is_composition_and_dgp_parity_is_closed()
    print("[PASS] test_star_product_is_composition_and_dgp_parity_is_closed")
    test_kneading_prefix_is_common_to_every_image_of_the_composite()
    print("[PASS] test_kneading_prefix_is_common_to_every_image_of_the_composite")
    test_column_coincidence_reports_least_depth_with_calibrations()
    print("[PASS] test_column_coincidence_reports_least_depth_with_calibrations")
    print("4 tuning-kernel Mojo tests passed.")
    require_contract("the vendored substitution_dynamics tuning, directive-prefix, and column-coincidence kernels hold under the PSC toolchain")
