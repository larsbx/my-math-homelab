"""Entry point: run the Spectral module certificate and report."""

from psc.certificate import run_all, Check


def main() raises:
    print("PSC Spectral module -- exact certificate (alphabet 3, length-7 seeds)")
    print("------------------------------------------------------------------------------")
    var checks = run_all(2)
    var failed = 0
    for i in range(len(checks)):
        print(checks[i])
        if not checks[i].passed:
            failed += 1
    print("------------------------------------------------------------------------------")
    if failed == 0:
        print(String(len(checks)), "checks passed.")
    else:
        print(String(failed), "of", String(len(checks)), "checks FAILED.")
        raise Error("certificate verification failed")
