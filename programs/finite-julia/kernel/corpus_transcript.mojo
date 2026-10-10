# corpus_transcript.mojo
#
# Print one line per corpus row, as the Mojo kernel decides it. The transcript
# is consumed by tests/test_mojo_replay.py, which compares it against the
# Python reference oracle. Printing is all this driver does: it decides
# nothing and asserts nothing.

from corpus_replay import transcript_line
from parameter_corpus import CORPUS_SIZE, corpus_row


def main():
    for index in range(CORPUS_SIZE):
        print(transcript_line(corpus_row(index)))
