# structure_streams.mojo
#
# The atlas's valleys and the golden-mean convergents as finite streams of
# limbs, printed as JSON. A valley names where one looks; what fills it is the
# sequence of limbs whose rotation numbers tend to a target along its Farey
# parents, each with exact root angles. The golden-mean Siegel parameter has no
# finite key; the limbs at its continued-fraction convergents do.
#
# The valley table mirrors schemas/structure_names.toml (each region's
# accumulation parent and rotation); tests/test_structure_streams.py binds the
# two in both directions and checks every term against the Python oracles.
# This is a separate emitter from atlas_dataset: that one's seven sections are
# a contract its consumers check.
#
# Usage: pixi run structure-streams > streams.json

from dynamics.limb_streams import FareyTerm, LimbRoots, farey_stream, limb_of
from entrypoints.json_text import arr, field, flag, obj, pair, quoted
from finite_exact.exact_decimal import bigz_decimal
from rational_dynamics.rational import ReducedFraction

#: The atlas reference's bounds: six Farey steps, denominators up to 14.
comptime STREAM_DEPTH = 6
comptime STREAM_MAX_DENOMINATOR = 14
#: Golden-mean convergents F_n / F_{n+1} up to this denominator.
comptime CONVERGENT_MAX_DENOMINATOR = 34


def angle(a: ReducedFraction) -> String:
    return "[" + bigz_decimal(a.num) + "," + bigz_decimal(a.den) + "]"


def term(t: FareyTerm, limb: LimbRoots, parent_period: Int) -> String:
    var row = List[String]()
    row.append(field("side", quoted("below" if t.below else "above")))
    row.append(field("limb", pair(t.num, t.den)))
    row.append(field("lo", angle(limb.lo)))
    row.append(field("hi", angle(limb.hi)))
    row.append(field("width", angle(limb.width())))
    row.append(field("period", String(parent_period * t.den)))
    return obj(row)


def valley(id: String, parent: String, parent_period: Int,
           lo_num: Int64, lo_den: Int64, hi_num: Int64, hi_den: Int64, a: Int, b: Int) raises -> String:
    var terms = List[String]()
    for t in farey_stream(a, b, STREAM_DEPTH, STREAM_MAX_DENOMINATOR):
        var limb = limb_of(lo_num, lo_den, hi_num, hi_den, t.num, t.den)
        if not limb.accepted():
            raise Error("limb refused in " + id)
        terms.append(term(t, limb, parent_period))
    var row = List[String]()
    row.append(field("id", quoted(id)))
    row.append(field("parent", quoted(parent)))
    row.append(field("rotation", pair(a, b)))
    row.append(field("terms", arr(terms)))
    return obj(row)


def valleys_section() raises -> String:
    var rows = List[String]()
    rows.append(valley("elephant-valley", "main-cardioid", 1, 0, 1, 0, 1, 0, 1))
    rows.append(valley("seahorse-valley", "main-cardioid", 1, 0, 1, 0, 1, 1, 2))
    rows.append(valley("triple-spiral-valley", "main-cardioid", 1, 0, 1, 0, 1, 1, 3))
    rows.append(valley("quad-spiral-valley", "main-cardioid", 1, 0, 1, 0, 1, 1, 4))
    rows.append(valley("double-spiral-valley", "bulb-1/2", 2, 1, 3, 2, 3, 0, 1))
    rows.append(valley("scepter-valley", "bulb-1/2", 2, 1, 3, 2, 3, 1, 2))
    return arr(rows)


def convergents_section() raises -> String:
    var terms = List[String]()
    var prev_a = 1
    var prev_b = 1
    var a = 1
    var b = 2
    while b <= CONVERGENT_MAX_DENOMINATOR:
        var limb = limb_of(0, 1, 0, 1, a, b)
        if not limb.accepted():
            raise Error("convergent limb refused")
        var row = List[String]()
        row.append(field("limb", pair(a, b)))
        row.append(field("lo", angle(limb.lo)))
        row.append(field("hi", angle(limb.hi)))
        row.append(field("period", String(b)))
        var det = a * prev_b - prev_a * b
        row.append(field("farey_adjacent_to_previous", flag(len(terms) > 0 and (det == 1 or det == -1))))
        terms.append(obj(row))
        prev_a = a
        prev_b = b
        var next = a + b
        a = b
        b = next
    var stream = List[String]()
    stream.append(field("id", quoted("golden-mean-siegel")))
    stream.append(field("terms", arr(terms)))
    return arr([obj(stream)])


def main() raises:
    var sections = List[String]()
    sections.append(field("valleys", valleys_section()))
    sections.append(field("convergents", convergents_section()))
    print(obj(sections))
