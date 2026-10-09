#!/usr/bin/env bash
# Re-run every archived probe from this directory; each writes ../outputs/rerun_<name>.out.
# Python probes are the session's float/prototype oracles (not certificates); Mojo
# probes are exact and are superseded by mojo/one_tile_anatomy.mojo.
# Usage: ./rerun.sh [name ...]   (default: all, quick ones first)
set -u
cd "$(dirname "$0")"
MOJO_DIR=../../../../kernel
PIXI=${PIXI:-pixi}
quick_py="a1 a2 a3 a4 col lv box2 mine mine2 plastic radii uhan"
sample_py="mine3 climb birth3 onetile_s outlier"
full_py="oracle_total box_corpus"
mojo="vc_try probe closure_probe diag_probe direct_probe"
r_search="r_search"
r_len="r_all r_irr r_prim r_prim4"
names=${*:-"$quick_py $mojo $r_search $sample_py $full_py $r_len"}
for n in $names; do
    out=../outputs/rerun_$n.out
    echo "== $n" >&2
    case " $mojo " in
        *" $n "*) ( time "$PIXI" run --manifest-path $MOJO_DIR/pixi.toml mojo run -I $MOJO_DIR $n.mojo ) > "$out" 2>&1 ;;
        *)
            case " $r_len " in
                *" $n "*) ( time python3 $n.py 3 ) > "$out" 2>&1 ;;
                *) ( time python3 $n.py ) > "$out" 2>&1 ;;
            esac ;;
    esac
    echo "exit $?" >> "$out"
done
