# markov_transcript.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md, section 1.
#
# Print one line per parameter, as the Mojo kernel decides it. The transcript
# is consumed by tests/test_markov.py, which compares it against the Python
# reference oracle. Printing is all this driver does.

from finite_exact.rat_q import Q
from markov import transcript_line

comptime MARKOV_HORIZON = 64


def main():
    var parameters = List[Q]()
    parameters.append(Q(0, 1))
    parameters.append(Q(-1, 1))
    parameters.append(Q(-2, 1))
    parameters.append(Q(1, 4))
    parameters.append(Q(-3, 4))
    parameters.append(Q(1, 1))
    for index in range(len(parameters)):
        print(transcript_line(parameters[index], MARKOV_HORIZON))
