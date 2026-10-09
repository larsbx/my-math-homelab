from psc_research.bpa import apply_substitution
from psc_research.examples import EXAMPLES
from psc_research.legal_ancestry_tower import descent_margin
from psc_research.prefix_difference import locate_inflated_cut


def _distance_to_word_end(cut: int, length: int) -> int:
    return min(cut, length - cut)


def test_one_step_margin_contraposition_on_named_substitutions():
    # Structural regression for the inequality behind descent_margin.
    # If an output cut is at least (R+1)L from both ends of sigma(w), then its
    # canonical source cut must be at least R letters from both ends of w.
    # Exhaust all cuts of several short words for every named substitution.
    words = (
        (1,),
        (2,),
        (3,),
        (1, 2),
        (2, 1),
        (1, 2, 3),
        (3, 2, 1),
        (1, 3, 2, 1),
    )
    for sigma in EXAMPLES.values():
        max_image_length = max(len(image) for image in sigma.values())
        for radius in range(4):
            required = descent_margin(radius, 1, max_image_length)
            for word in words:
                image = apply_substitution(sigma, word)
                for output_cut in range(len(image) + 1):
                    if _distance_to_word_end(output_cut, len(image)) < required:
                        continue
                    source_cut, _offset = locate_inflated_cut(sigma, word, output_cut)
                    assert _distance_to_word_end(source_cut, len(word)) >= radius


def test_margin_recurrence_composes_monotonically():
    for max_image_length in range(1, 5):
        for radius in range(4):
            previous = radius
            for descent_levels in range(1, 6):
                current = descent_margin(radius, descent_levels, max_image_length)
                assert current == (previous + 1) * max_image_length
                assert current >= previous
                previous = current
