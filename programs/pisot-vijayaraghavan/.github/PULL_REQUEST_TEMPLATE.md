## What changed

## Why

## Evidence

| Check | Command | Result |
| --- | --- | --- |
| exact identity tests | python -m pytest | not run |
| claim-state consistency | python tools/check_claims.py | not run |
| estate layout | CI policy job | not run |

## What this does *not* establish

Required. State the remaining bound or open dependency. A finite computation is
not a general theorem; a reduction to an open case does not solve that case.

## Risk and reversibility

## Checklist

- [ ] Evidence table is honest.
- [ ] Claim status and dossier were updated together.
- [ ] New exact behavior has a regression.
- [ ] No WITHDRAWN argument is reintroduced.
- [ ] No secret or credential is in the diff.
