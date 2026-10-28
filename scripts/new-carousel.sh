#!/usr/bin/env bash
# Create a carousel folder with one HyperFrames project per slide.
#
#   bash scripts/new-carousel.sh <carousel-dir> [slide-count] [--duration SECONDS]
#
# Slide 1 is copied from templates/cover-slide, slides 2 to N from
# templates/content-slide. Existing slide folders are never overwritten.
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 1 ] || die "usage: new-carousel.sh <carousel-dir> [slide-count] [--duration SECONDS]"
DIR="$1"
shift
COUNT=6
DURATION=6
while [ $# -gt 0 ]; do
  case "$1" in
    --duration) DURATION="$2"; shift 2 ;;
    *) COUNT="$1"; shift ;;
  esac
done

case "$COUNT" in ''|*[!0-9]*) die "slide-count must be a whole number" ;; esac
[ "$COUNT" -ge 2 ] && [ "$COUNT" -le 20 ] || die "slide-count must be 2 to 20 (5 to 7 recommended)"
awk "BEGIN { exit !($DURATION >= 3 && $DURATION <= 15) }" || die "--duration must be 3 to 15 seconds (5 to 7 recommended)"

mkdir -p "$DIR/slides"
i=1
while [ "$i" -le "$COUNT" ]; do
  NN="$(printf '%02d' "$i")"
  dest="$DIR/slides/slide-$NN"
  if [ -e "$dest" ]; then
    echo "keep   $dest (already exists, not touched)"
    i=$((i + 1))
    continue
  fi
  if [ "$i" -eq 1 ]; then tpl="cover-slide"; else tpl="content-slide"; fi
  cp -R "$SKILL_DIR/templates/$tpl" "$dest"
  rm -rf "$dest/.hyperframes"
  f="$dest/index.html"
  if [ "$i" -eq 1 ]; then
    replace_in_file "$f" '1 / 6' "1 / $COUNT"
  else
    replace_in_file "$f" '2 / 6' "$i / $COUNT"
    replace_in_file "$f" 'data-slide-index="2"' "data-slide-index=\"$i\""
    replace_in_file "$f" 'data-slide-total="6"' "data-slide-total=\"$COUNT\""
  fi
  replace_in_file "$f" 'data-duration="6"' "data-duration=\"$DURATION\""
  replace_in_file "$f" 'const DUR = 6;' "const DUR = $DURATION;"
  printf '{\n  "id": "slide-%s",\n  "name": "slide-%s"\n}\n' "$NN" "$NN" >"$dest/meta.json"
  echo "create $dest (from $tpl, ${DURATION}s)"
  i=$((i + 1))
done

if [ ! -f "$DIR/plan.md" ]; then
  cat >"$DIR/plan.md" <<EOF
# Carousel plan

Status: draft (needs user approval before building)

- Audience:
- Topic or offer:
- Goal: saves / shares / follows / DMs
- Comment keyword: THIS
- DM link: <YOUR_LINK>
- Look: (tokens at the top of each slide's index.html)

| Slide | Role | On-screen text | Primary motion technique |
| --- | --- | --- | --- |
EOF
  i=1
  while [ "$i" -le "$COUNT" ]; do
    if [ "$i" -eq 1 ]; then role="Cover hook (full hook visible at frame 0)"; tech="cover drift (cover-safe)";
    elif [ "$i" -eq "$COUNT" ]; then role="CTA: comment the keyword"; tech="";
    else role="Value point"; tech=""; fi
    echo "| $i | $role |  | $tech |" >>"$DIR/plan.md"
    i=$((i + 1))
  done
  cat >>"$DIR/plan.md" <<'EOF'

## Caption

(first line restates the hook; last line: Comment THIS and I will send you the link)

## Approvals

- [ ] Plan approved
- [ ] Grade stills reviewed
- [ ] QA PASS
- [ ] Carousel approved
- [ ] Publish dry run approved with an explicit yes
EOF
  echo "create $DIR/plan.md"
fi

echo
echo "Next: edit each slides/slide-NN/index.html, then run"
echo "  bash $SKILL_DIR/scripts/grade-stills.sh $DIR"
