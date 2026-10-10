# Executable negative-path probe for the smoke-test CI gate.

from smoke.smoke_tests import require_smoke_success


def main() raises:
    require_smoke_success(False)
