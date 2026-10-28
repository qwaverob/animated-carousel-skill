#!/usr/bin/env bash
# Grade stills: frame 0, middle and last frame of every slide as PNGs, BEFORE the
# full render. Look at them, fix the slides, repeat, then run render-slides.sh.
#
#   bash scripts/grade-stills.sh <carousel-dir> [--from-renders]
#
# Default: captures from the HyperFrames projects (no MP4 needed).
# --from-renders: extracts the same three frames from renders/slide-NN.mp4 with ffmpeg.
#
# Output: <carousel-dir>/stills/slide-NN/{frame0,mid,last}.png and stills/contact-sheet.png
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 1 ] || die "usage: grade-stills.sh <carousel-dir> [--from-renders]"
DIR="${1%/}"
FROM_RENDERS=0
[ "${2:-}" = "--from-renders" ] && FROM_RENDERS=1
need ffmpeg "Install ffmpeg (macOS: brew install ffmpeg, Linux: apt install ffmpeg)."
mkdir -p "$DIR/stills" "$DIR/logs"

for slide in $(list_slides "$DIR"); do
  name="$(basename "$slide")"
  out="$DIR/stills/$name"
  rm -rf "$out"
  mkdir -p "$out"

  if [ "$FROM_RENDERS" -eq 1 ]; then
    mp4="$DIR/renders/$name.mp4"
    [ -f "$mp4" ] || die "$mp4 not found. Run render-slides.sh first or drop --from-renders."
    dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")"
    mid="$(calc "$dur / 2")"
    last="$(calc "$dur - 0.1")"
    ffmpeg -nostdin -v error -y -i "$mp4" -frames:v 1 "$out/frame0.png"
    ffmpeg -nostdin -v error -y -ss "$mid" -i "$mp4" -frames:v 1 "$out/mid.png"
    ffmpeg -nostdin -v error -y -ss "$last" -i "$mp4" -frames:v 1 "$out/last.png"
  else
    dur="$(slide_duration "$slide")"
    mid="$(calc "$dur / 2")"
    last="$(calc "$dur - 0.05")"
    hf_private snapshot "$slide" --at "0,$mid,$last" --no-end -o "$out" >"$DIR/logs/stills-$name.log" 2>&1 \
      || die "snapshot failed for $name, see $DIR/logs/stills-$name.log"
    mv "$out"/frame-00-*.png "$out/frame0.png"
    mv "$out"/frame-01-*.png "$out/mid.png"
    mv "$out"/frame-02-*.png "$out/last.png"
    rm -f "$out"/contact-sheet.* "$out"/*.json
  fi
  echo "stills $name: frame0.png mid.png last.png (duration ${dur}s)"
done

bash "$(dirname "$0")/contact-sheet.sh" "$DIR" --stills
echo
echo "Now LOOK at the stills. Slide 1 frame0.png must show the whole hook."
