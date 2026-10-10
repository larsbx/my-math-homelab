"""The evidence archive refuses incomplete or altered receipts."""
import importlib.util
from pathlib import Path
from zipfile import ZipFile
import pytest

spec = importlib.util.spec_from_file_location('separation_receipts', Path(__file__).parents[1] / 'tools/check_separation_receipts.py')
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)

@pytest.fixture(scope='module')
def log():
    with ZipFile(checker.ARCHIVE / 'evidence.zip') as zipped:
        return zipped.read('separation-radius.log').decode()


def test_archived_receipts_match_independent_exact_corpus():
    result = checker.check_archive()
    assert result['specimens'] == 24486
    assert result['radii']['9'] == 12
    assert result['exceptional_orbits'] == {'012001/2/0': 12}


@pytest.mark.parametrize('mutation', ['truncated', 'omitted', 'inconclusive', 'histogram'])
def test_incomplete_or_corrupted_receipts_refuse_completion(log, mutation):
    if mutation == 'truncated':
        log = log.replace('COMPLETE separation sweep: 24486 classified; 0 inconclusive', '')
    elif mutation == 'omitted':
        rows = log.splitlines()
        at = next(i for i, row in enumerate(rows) if row.startswith('SEPARATED '))
        del rows[at]
        log = '\n'.join(rows)
    elif mutation == 'inconclusive':
        log += '\nINCONCLUSIVE 0 1 2 0/1/2 capped\n'
    else:
        log = log.replace('1:2264', '1:2263')
    with pytest.raises(ValueError):
        checker.check_log(log)
