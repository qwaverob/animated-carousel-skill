#!/usr/bin/env bash
# One PNG grid of every slide, for a fast visual review.
#
#   bash scripts/contact-sheet.sh <carousel-dir> [--stills|--renders]
#
# Slide 1 shows its frame 0 (the Instagram cover); every other slide shows its
# settled last frame. --renders (default when renders/ has MP4s) reads the MP4s,
# --stills reads stills/slide-NN/*.png from grade-stills.sh.
# Output: <carousel-dir>/qa/contact-sheet.png (renders) or stills/contact-sheet.png (stills)
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 1 ] || die "usage: contact-sheet.sh <carousel-dir> [--stills|--renders]"
DIR="${1%/}"
MODE="${2:-auto}"
need ffmpeg "Install ffmpeg (macOS: brew install ffmpeg, Linux: apt install ffmpeg)."

if [ "$MODE" = "auto" ]; then
  if ls "$DIR"/renders/slide-*.mp4 >/dev/null 2>&1; then MODE="--renders"; else MODE="--stills"; fi
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
n=0

if [ "$MODE" = "--renders" ]; then
  OUT="$DIR/qa/contact-sheet.png"
  for mp4 in $(ls "$DIR"/renders/slide-*.mp4 | sort); do
    n=$((n + 1))
    frame="$TMP/$(printf '%03d' "$n").png"
    if [ "$n" -eq 1 ]; then
      ffmpeg -nostdin -v error -y -i "$mp4" -frames:v 1 "$frame"
    else
      dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")"
      ffmpeg -nostdin -v error -y -ss "$(calc "$dur - 0.1")" -i "$mp4" -frames:v 1 "$frame"
    fi
  done
else
  OUT="$DIR/stills/contact-sheet.png"
  for slide in $(list_slides "$DIR"); do
    name="$(basename "$slide")"
    n=$((n + 1))
    if [ "$n" -eq 1 ]; then src="$DIR/stills/$name/frame0.png"; else src="$DIR/stills/$name/last.png"; fi
    [ -f "$src" ] || die "$src not found. Run grade-stills.sh first."
    cp "$src" "$TMP/$(printf '%03d' "$n").png"
  done
fi

[ "$n" -gt 0 ] || die "no slides found in $DIR"
mkdir -p "$(dirname "$OUT")"
COLS=$n
[ "$COLS" -gt 4 ] && COLS=4
ROWS=$(((n + COLS - 1) / COLS))

# Each cell 360x450 (a third of 1080x1350) with an 8 px gutter.
ffmpeg -nostdin -v error -y -framerate 1 -i "$TMP/%03d.png" \
  -vf "scale=360:450:flags=lanczos,pad=376:466:8:8:color=0x202020,tile=${COLS}x${ROWS}:color=0x202020" \
  -frames:v 1 -update 1 "$OUT"
echo "contact sheet: $OUT ($n slides, ${COLS}x${ROWS})"
