#!/usr/bin/env bash
# Retire source repositories consolidated into my-math-homelab.
#
#   tools/retire_sources.sh            dry run: report what each step would do
#   tools/retire_sources.sh --apply    preserve branches + transfer issues
#   tools/retire_sources.sh --apply --delete   ...then delete each source repo
#
# Run from a clean checkout of my-math-homelab main, after the consolidation PR
# is merged, with `gh auth refresh -s delete_repo`. Per source, fail closed:
#   1. source main must still equal its lock (else refresh the import first)
#   2. every branch not contained in main -> tag archive/<id>/<branch> here
#   3. every issue (open and closed) -> gh issue transfer to my-math-homelab
#   4. open PRs block deletion (merge or close them first)
#   5. --delete: gh repo delete
set -euo pipefail

HOME_REPO=larsbx/my-math-homelab
APPLY=false; DELETE=false
for arg in "$@"; do
  case $arg in --apply) APPLY=true ;; --delete) DELETE=true ;; *) echo "unknown $arg" >&2; exit 2 ;; esac
done
$DELETE && ! $APPLY && { echo "--delete requires --apply" >&2; exit 2; }

root=$(git rev-parse --show-toplevel)
python3 "$root/kernel/workspace.py" --root "$root" >/dev/null
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
run() { if $APPLY; then "$@"; else echo "  would: $*"; fi; }

python3 - "$root/policy/source-locks.toml" <<'EOF' > "$work/sources"
import sys, tomllib
for s in tomllib.load(open(sys.argv[1], "rb"))["source"]:
    print(s["id"], s["repository"], s["commit"])
EOF

while read -r id repo commit; do
  echo "== $repo ($id)"
  mirror="$work/$id.git"
  git clone -q --mirror "https://github.com/$repo.git" "$mirror"
  head=$(git -C "$mirror" rev-parse refs/heads/main)
  if [ "$head" != "$commit" ]; then
    echo "  BLOCKED: main moved from its lock ($commit -> $head); refresh the import first"; continue
  fi

  for ref in $(git -C "$mirror" for-each-ref --format='%(refname:short)' refs/heads); do
    [ "$ref" = main ] && continue
    [ "$(git -C "$mirror" rev-list --count "main..$ref")" -gt 0 ] || continue
    sha=$(git -C "$mirror" rev-parse "$ref")
    git -C "$root" fetch -q --no-tags "$mirror" "$sha"
    run git -C "$root" tag -f "archive/$id/$ref" "$sha"
  done
  run git -C "$root" push -q origin "refs/tags/archive/$id/*:refs/tags/archive/$id/*" || true

  for n in $(gh issue list -R "$repo" --state all --limit 1000 --json number -q '.[].number'); do
    run gh issue transfer "$n" "$HOME_REPO" -R "$repo"
  done

  open_prs=$(gh pr list -R "$repo" --state open --json number -q 'length')
  if [ "$open_prs" -gt 0 ]; then
    echo "  BLOCKED: $open_prs open PR(s); merge or close them first"; continue
  fi
  $DELETE && run gh repo delete "$repo" --yes
done < "$work/sources"
