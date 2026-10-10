"""Exact conjugacy classification of the finite endpoint maps.

Prints one replayable record per relabelling class of self-maps of the
alphabet, with its size, functional-cycle lengths, synchronization verdict and
recurrent off-diagonal core, then the summary lines. For three letters this is
the A..G table of docs/c4-endpoint-core-program.md, derived here rather than
transcribed: `psc.endpoint_core.classify_maps` builds the classes and
`endpoint_type` only names them.

The census also reports the worst number of steps a nonsynchronizing pair
takes to enter the recurrent core, the quantity the C4 locality argument uses.
This is a finite-map classification with no floating point and no
substitution-specific assumption; it is not a proof of C4.
"""

from psc.endpoint_core import (
    ENDPOINT_TYPE_COUNT,
    all_maps,
    classify_maps,
    endpoint_type,
    endpoint_type_name,
    pairs_key,
    steps_to_recurrent_core,
    synchronizes,
    synchronization_quotient_permutation,
)
from psc.histogram import Histogram
from psc.symmetry import word_key
from psc.words import ALPHABET


def class_name(size: Int, rank: Int) -> String:
    """The A..G name on three letters; the plain rank on any other alphabet."""
    return endpoint_type_name(rank) if size == ALPHABET else String(rank)


def main() raises:
    var size = ALPHABET
    var classes = classify_maps(size)
    var maps = all_maps(size)
    var members = 0
    var synchronizing_classes = 0
    var core_classes = 0
    var steps = Histogram(size * size + 2)

    for rank in range(len(classes)):
        ref item = classes[rank]
        members += item.size()
        synchronizing_classes += 1 if item.globally_synchronizing() else 0
        core_classes += 1 if len(item.recurrent_core) > 0 else 0
        print(
            "ENDPOINT_CLASS_JSON {\"class\":\"" + class_name(size, rank)
            + "\",\"representative\":\"" + word_key(item.representative)
            + "\",\"class_size\":" + String(item.size())
            + ",\"cycles\":\"" + word_key(item.cycle_lengths)
            + "\",\"quotient\":\"" + word_key(synchronization_quotient_permutation(item.representative))
            + "\",\"globally_synchronizing\":" + String(1 if item.globally_synchronizing() else 0)
            + ",\"nonsynchronizing\":\"" + pairs_key(item.nonsynchronizing)
            + "\",\"recurrent_core\":\"" + pairs_key(item.recurrent_core) + "\"}"
        )

    # Every nonsynchronizing pair of every map, not only of a representative:
    # the entry time is a conjugacy invariant, so a disagreement would be a
    # defect in the classification rather than a new phenomenon.
    for m in range(len(maps)):
        for a in range(size):
            for b in range(size):
                if a == b or synchronizes(maps[m], a, b):
                    continue
                steps.record(steps_to_recurrent_core(maps[m], a, b))

    if members != len(maps):
        raise Error("conjugacy classes do not partition the finite maps")

    print("endpoint-core conjugacy classification")
    print("alphabet size:", size)
    print("finite maps:", len(maps))
    print("conjugacy classes:", len(classes))
    print("globally synchronizing classes:", synchronizing_classes)
    print("classes with nonempty recurrent core:", core_classes)
    print("nonsynchronizing ordered pairs:", steps.total())
    print("maximum steps into the recurrent core:", steps.maximum())
    print(steps.line("pairs by steps into the recurrent core:"))
