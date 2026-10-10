#!/usr/bin/env bash
# sweep.sh BIN s delta floor r1 r2 budget plain_secs qlift_secs
# Covers each pattern of `zruns` in its own processes: the plain z_floor cover
# (`zruns ... at i plain`) under `timeout plain_secs`, then, if it leaves a
# region open or times out, the q-lift (`zruns ... at i qlift`) under
# `timeout qlift_secs`; one line per pattern, then a summary.
set -u
[ $# -eq 9 ] || { echo "usage: $0 BIN s delta floor r1 r2 budget plain_secs qlift_secs" >&2; exit 2; }
bin=$1; s=$2; d=$3; floor=$4; r1=$5; r2=$6; budget=$7; plain_secs=$8; qlift_secs=$9
n=$("$bin" "$s" "$d" "$floor" "$r1" "$r2" "$budget" count) || exit 1
declare -A tally=([closed-by-plain]=0 [closed-by-qlift]=0 [open]=0 [timeout]=0 [error]=0)
# stage i name secs: runs one stage; sets out, rc, verdict (plain|qlift|open|timeout|error)
# and line ("name: regions=R open=O budget=B secs=T", "name: killed" or "name: rc=..")
stage() {
    out=$(timeout "$3" "$bin" "$s" "$d" "$floor" "$r1" "$r2" "$budget" at "$1" "$2" 2>&1)
    rc=$?
    # the stage line of a finished cover: "<name> closed|OPEN <pattern> regions R open O budget B secs T"
    line=$(sed -n "s/^    $2 .* regions \([0-9]*\)  *open \([0-9]*\)  *budget \([A-Za-z]*\)  *secs \([0-9]*\)\$/$2: regions=\1 open=\2 budget=\3 secs=\4/p" <<<"$out")
    verdict=$(sed -n 's/^VERDICT //p' <<<"$out")
    if [ -z "$verdict" ]; then
        if [ $rc -eq 124 ]; then verdict=timeout; line="$2: killed"
        else verdict=error; line="$2: rc=$rc: $(tail -1 <<<"$out")"; fi
    fi
}
for ((i = 0; i < n; i++)); do
    t0=$SECONDS
    stage "$i" plain "$plain_secs"
    pat=$(sed -n 's/^PATTERN //p' <<<"$out")
    stages=$line
    case $verdict in
        plain) what=closed-by-plain ;;
        open | timeout)
            stage "$i" qlift "$qlift_secs"
            stages="$stages;$line"
            [ "$verdict" = qlift ] && what=closed-by-qlift || what=$verdict ;;
        *) what=error ;;
    esac
    tally[$what]=$((tally[$what] + 1))
    printf '%3d  %-16s %-24s %4ds  %s\n' "$i" "$what" "${pat:-?}" $((SECONDS - t0)) "$stages"
done
echo "summary s=$s delta=$d floor=$floor runs<=$r1,$r2 budget=$budget timeout=${plain_secs}s plain, ${qlift_secs}s q-lift: patterns $n, closed-by-plain ${tally[closed-by-plain]}, closed-by-qlift ${tally[closed-by-qlift]}, open ${tally[open]}, timeout ${tally[timeout]}, error ${tally[error]}"
