# atlas_dataset.mojo
#
# Every exact object this repository catalogues, printed once as JSON.
#
# The page that reads this file draws two things: numbers, which are exact and
# come from here, and positions in the parameter plane, which are conventional
# floating-point work and cannot come from here. This module is the first half,
# and it holds the policy: integers, rationals and finite incidence vertices
# only, no float, no trigonometry, no analytic point.
#
# Each section is the module that owns the object, asked for its own answer:
#
#   counts, catalogues  misiurewicz_catalogue
#   kneading            C1_residual_directive_carrier (internal addresses: the
#                       vendored substitution_dynamics.tuning)
#   tunings             angle_tuning
#   graphs              C1_misiurewicz_prefix_graph
#   density             C1_separated_density
#   incidence           bigq_certificate_incidence and the gate beneath it
#
# Usage: pixi run atlas-dataset > dataset.json

from dynamics.angle_tuning import address_period, angle_period, binary_block, tuned_angle
from entrypoints.json_text import arr, field, flag, ints, joined, obj, pair, quoted
from certificates.c_minus_2.bigq_certificate_incidence import bigq_c_minus_2_certificate_incidence
from c1.wake.misiurewicz_prefix_graph import (
    RATIONAL_RAY_LANDING,
    extract_catalogue,
    forward_closure,
    period_orbit,
)
from c1.residual.residual_directive_carrier import (
    checked_kneading_prefix,
    continuation_last_letter,
)
from c1.separator.separated_density import separated_pair_density
from finite_exact.exact_decimal import bigz_decimal, q_decimal
from substitution_dynamics.internal_address import internal_address
from certificates.misiurewicz_catalogue import (
    catalogue,
    catalogue_count,
    catalogue_denominator,
)

comptime MAX_PERIOD = 5
comptime MAX_PREPERIOD = 3


# --- the catalogue: the identity against the enumeration ------------------------


def counts_section() -> String:
    var rows = List[String]()
    for l in range(1, 8):
        for k in range(1, 8):
            var den = catalogue_denominator(l, k)
            if den < 0:
                continue
            var row = List[String]()
            row.append(field("l", String(l)))
            row.append(field("k", String(k)))
            row.append(field("den", String(den)))
            row.append(field("count", String(catalogue_count(l, k))))
            row.append(field("enumerated", String(len(catalogue(l, k)))))
            rows.append(obj(row))
    return arr(rows)


def catalogues_section() -> String:
    var rows = List[String]()
    for l in range(1, MAX_PREPERIOD + 1):
        for k in range(1, MAX_PERIOD + 1):
            var den = catalogue_denominator(l, k)
            if den < 0:
                continue
            var row = List[String]()
            row.append(field("l", String(l)))
            row.append(field("k", String(k)))
            row.append(field("den", String(den)))
            row.append(field("addresses", ints(catalogue(l, k))))
            rows.append(obj(row))
    return arr(rows)


# --- kneading sequences, internal addresses, tuning patterns --------------------


def kneading_section() -> String:
    var rows = List[String]()
    for n in range(1, MAX_PERIOD + 1):
        var den = (1 << n) - 1
        for num in range(1, den):
            if angle_period(Int64(num), Int64(den)) != n:
                continue
            var kneading = checked_kneading_prefix(Int64(num), Int64(den))
            if not kneading.accepted():
                continue
            # nu stops at its star; the internal address that contains the
            # period belongs to the continuation the letter below picks out.
            var letter = continuation_last_letter(kneading.prefix)
            var continued = kneading.prefix.copy()
            var twist = String("null")
            if not letter.rejected:
                continued.append(letter.last_letter)
                twist = flag(letter.last_letter == 0)
            var nu = String("")
            for i in range(len(kneading.prefix)):
                nu += String(kneading.prefix[i])
            var block = binary_block(Int64(num), Int64(den), 12 if 2 * n > 12 else 2 * n)
            var digits = String("")
            if not block.rejected:
                for i in range(len(block.digits)):
                    digits += String(block.digits[i])
            var address = String("null")
            try:
                address = ints(internal_address(continued))
            except:
                pass
            var row = List[String]()
            row.append(field("theta", pair(num, den)))
            row.append(field("period", String(kneading.period)))
            row.append(field("nu", quoted(nu + "*")))
            row.append(field("address", address))
            row.append(field("twist", twist))
            row.append(field("block", quoted(digits)))
            rows.append(obj(row))
    return arr(rows)


# --- Douady tuning --------------------------------------------------------------


def tuning_row(name: String, lo_num: Int, lo_den: Int, hi_num: Int, hi_den: Int,
               num: Int, den: Int) -> String:
    var tuned = tuned_angle(Int64(lo_num), Int64(lo_den), Int64(hi_num), Int64(hi_den),
                            Int64(num), Int64(den))
    var row = List[String]()
    row.append(field("component", quoted(name)))
    row.append(field("lo", pair(lo_num, lo_den)))
    row.append(field("hi", pair(hi_num, hi_den)))
    row.append(field("theta", pair(num, den)))
    if tuned.rejected:
        row.append(field("tuned", "null"))
        row.append(field("period", "null"))
    else:
        row.append(field("tuned", "[" + bigz_decimal(tuned.num) + "," + bigz_decimal(tuned.den) + "]"))
        row.append(field("period", String(address_period(tuned))))
    return obj(row)


def tunings_section() -> String:
    var names: List[String] = ["doubling", "rabbit", "airplane", "primitive period 4",
                               "satellite period 4"]
    var lo_n: List[Int] = [1, 1, 3, 7, 2]
    var lo_d: List[Int] = [3, 7, 7, 15, 5]
    var hi_n: List[Int] = [2, 2, 4, 8, 3]
    var hi_d: List[Int] = [3, 7, 7, 15, 5]
    var th_n: List[Int] = [1, 3, 2]
    var th_d: List[Int] = [3, 7, 5]
    var rows = List[String]()
    for c in range(len(names)):
        for t in range(len(th_n)):
            rows.append(tuning_row(names[c], lo_n[c], lo_d[c], hi_n[c], hi_d[c],
                                   th_n[t], th_d[t]))
    return arr(rows)


# --- the obstruction extractor over declared separator prefixes -----------------


def pairs_of(codes: List[Int], den: Int) -> String:
    var out = List[String]()
    for i in range(len(codes)):
        out.append(pair(codes[i] // den, codes[i] % den))
    return arr(out)


def graph_row(l: Int, k: Int, prefix_period: Int) -> String:
    var den = catalogue_denominator(l, k)
    var orbit = period_orbit(prefix_period, den)
    if den < 0 or len(orbit) < 2:
        return String("")
    var lows = List[Int]()
    var highs = List[Int]()
    var tags = List[Int]()
    var seps = List[String]()
    for i in range(len(orbit)):
        lows.append(orbit[i])
        highs.append(orbit[(i + 1) % len(orbit)])
        tags.append(RATIONAL_RAY_LANDING)
        seps.append(pair(lows[i], highs[i]))
    var found = extract_catalogue(l, k, lows, highs, tags)
    if not found.accepted():
        return String("")
    var row = List[String]()
    row.append(field("l", String(l)))
    row.append(field("k", String(k)))
    row.append(field("den", String(den)))
    row.append(field("prefix_period", String(prefix_period)))
    row.append(field("separators", arr(seps)))
    row.append(field("catalogue", ints(catalogue(l, k))))
    row.append(field("vertices", ints(forward_closure(catalogue(l, k), den))))
    row.append(field("n_vertices", String(found.vertices)))
    row.append(field("undecided", String(found.undecided)))
    row.append(field("nonproductive", String(found.nonproductive)))
    row.append(field("merging", String(found.merging)))
    row.append(field("boundary", String(found.boundary)))
    row.append(field("interior", String(found.interior)))
    row.append(field("obstruction_free", flag(found.obstruction_free())))
    row.append(field("nonproductive_pairs", pairs_of(found.nonproductive_codes, den)))
    row.append(field("cycle_pairs", pairs_of(found.cycle_codes, den)))
    return obj(row)


def graphs_section() -> String:
    var ls: List[Int] = [1, 1, 2, 1, 2, 3]
    var ks: List[Int] = [2, 3, 3, 4, 2, 3]
    var ps: List[Int] = [2, 3, 3, 4, 2, 3]
    var rows = List[String]()
    for i in range(len(ls)):
        var row = graph_row(ls[i], ks[i], ps[i])
        if row.byte_length() > 0:
            rows.append(row)
    return arr(rows)


# --- the measure a separator prefix decides -------------------------------------


def density_row(ln: List[Int64], ld: List[Int64], rn: List[Int64], rd: List[Int64]) -> String:
    var result = separated_pair_density(ln, ld, rn, rd)
    var seps = List[String]()
    for i in range(len(ln)):
        seps.append("[" + pair(Int(ln[i]), Int(ld[i])) + "," + pair(Int(rn[i]), Int(rd[i])) + "]")
    var row = List[String]()
    row.append(field("separators", arr(seps)))
    if result.rejected:
        row.append(field("density", "null"))
        return obj(row)
    row.append(field("density", quoted(q_decimal(result.density))))
    row.append(field("residue", quoted(q_decimal(result.residue))))
    row.append(field("classes", String(result.classes)))
    row.append(field("atoms", String(result.atoms)))
    return obj(row)


def density_section() -> String:
    var rows = List[String]()
    var a_ln: List[Int64] = [1]
    var a_ld: List[Int64] = [3]
    var a_rn: List[Int64] = [2]
    var a_rd: List[Int64] = [3]
    rows.append(density_row(a_ln, a_ld, a_rn, a_rd))
    var b_ln: List[Int64] = [0, 1]
    var b_ld: List[Int64] = [1, 2]
    var b_rn: List[Int64] = [1, 3]
    var b_rd: List[Int64] = [4, 4]
    rows.append(density_row(b_ln, b_ld, b_rn, b_rd))
    var c_ln: List[Int64] = [1, 2]
    var c_ld: List[Int64] = [7, 7]
    var c_rn: List[Int64] = [2, 4]
    var c_rd: List[Int64] = [7, 7]
    rows.append(density_row(c_ln, c_ld, c_rn, c_rd))
    var d_ln: List[Int64] = [1, 0]
    var d_ld: List[Int64] = [3, 1]
    var d_rn: List[Int64] = [2, 1]
    var d_rd: List[Int64] = [3, 3]
    rows.append(density_row(d_ln, d_ld, d_rn, d_rd))
    var e_ln: List[Int64] = [1, 1]
    var e_ld: List[Int64] = [3, 3]
    var e_rn: List[Int64] = [2, 2]
    var e_rd: List[Int64] = [3, 3]
    rows.append(density_row(e_ln, e_ld, e_rn, e_rd))
    return arr(rows)


# --- the incidence package ------------------------------------------------------


def incidence_row(half_width_den_power: Int) -> String:
    var packaged = bigq_c_minus_2_certificate_incidence(half_width_den_power)
    var status = packaged.status.copy()
    var association = status.association.copy()
    var vertex = packaged.packaged_vertex.copy()
    var carrier = List[String]()
    var roles: List[String] = [vertex.carrier.root_handle.role,
                               vertex.carrier.ray_address_set.role,
                               vertex.carrier.rational_box.role]
    var ids: List[String] = [vertex.carrier.root_handle.identifier,
                             vertex.carrier.ray_address_set.identifier,
                             vertex.carrier.rational_box.identifier]
    for i in range(3):
        var member = List[String]()
        member.append(field("role", quoted(roles[i])))
        member.append(field("id", quoted(ids[i])))
        carrier.append(obj(member))
    var row = List[String]()
    row.append(field("half_width_den_power", String(half_width_den_power)))
    row.append(field("box_name", quoted(association.box_name)))
    row.append(field("ell", String(association.ell)))
    row.append(field("period", String(association.period)))
    row.append(field("ray_preperiod", String(association.rays.preperiod)))
    row.append(field("ray_period", String(association.rays.period)))
    row.append(field("citation", quoted(association.correspondence.source_citation_key)))
    row.append(field("preperiod_offset",
                     String(association.correspondence.critical_orbit_preperiod_offset)))
    row.append(field("krawczyk", flag(association.localization.arithmetic_replay_accepted())))
    row.append(field("excluded", String(association.exclusions.excluded_count)))
    row.append(field("required", String(association.exclusions.required_count)))
    row.append(field("ambiguous", flag(association.exclusions.ambiguous())))
    row.append(field("finite_replay", flag(association.finite_replay_associated())))
    row.append(field("theorem_import", flag(status.theorem_tags_accepted())))
    row.append(field("vertex", quoted(vertex.identifier)))
    row.append(field("carrier", arr(carrier)))
    row.append(field("carrier_size", String(vertex.carrier.size())))
    row.append(field("incidence_only", flag(vertex.incidence_only)))
    row.append(field("vertex_valid", flag(vertex.valid())))
    row.append(field("packaged", flag(packaged.finite_incidence_packaged())))
    row.append(field("certificate_emitted", flag(packaged.certificate_emitted())))
    row.append(field("proves_c1", flag(packaged.proves_c1())))
    return obj(row)


def incidence_section() -> String:
    var powers: List[Int] = [8, 25, 80, 0]
    var rows = List[String]()
    for i in range(len(powers)):
        rows.append(incidence_row(powers[i]))
    return arr(rows)


def main():
    var sections = List[String]()
    sections.append(field("counts", counts_section()))
    sections.append(field("catalogues", catalogues_section()))
    sections.append(field("kneading", kneading_section()))
    sections.append(field("tunings", tunings_section()))
    sections.append(field("graphs", graphs_section()))
    sections.append(field("density", density_section()))
    sections.append(field("incidence", incidence_section()))
    print(obj(sections))
