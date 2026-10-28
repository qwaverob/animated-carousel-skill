#!/usr/bin/env bash
# Render every slide project to renders/slide-NN.mp4 (H.264, yuv420p, 30 fps).
# Run grade-stills.sh and fix the slides first.
#
#   bash scripts/render-slides.sh <carousel-dir> [--quality draft|looks|delivery] [--only 01,03]
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 1 ] || die "usage: render-slides.sh <carousel-dir> [--quality draft|looks|delivery] [--only 01,03]"
DIR="${1%/}"
shift
QUALITY="delivery"
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --quality) QUALITY="$2"; shift 2 ;;
    --only) ONLY=",$2,"; shift 2 ;;
    *) die "unknown option $1" ;;
  esac
done
case "$QUALITY" in draft|looks|delivery) ;; *) die "--quality must be draft, looks or delivery" ;; esac
need ffmpeg "Install ffmpeg (macOS: brew install ffmpeg, Linux: apt install ffmpeg)."
need ffprobe "ffprobe ships with ffmpeg."

mkdir -p "$DIR/renders" "$DIR/logs"
OUT_ABS="$(cd "$DIR/renders" && pwd)"

for slide in $(list_slides "$DIR"); do
  name="$(basename "$slide")"
  num="${name#slide-}"
  if [ -n "$ONLY" ]; then
    case "$ONLY" in *",$num,"*) ;; *) continue ;; esac
  fi
  mp4="$OUT_ABS/$name.mp4"
  log="$DIR/logs/render-$name.log"
  echo "render $name ($QUALITY) ..."
  if ! hf render "$slide" --quality "$QUALITY" --fps 30 -o "$mp4" >"$log" 2>&1; then
    tail -n 20 "$log" >&2
    die "render failed for $name, full log: $log"
  fi

  # Make sure the file is H.264 yuv420p (what Instagram expects). Re-encode only if not.
  codec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$mp4")"
  pix="$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$mp4")"
  if [ "$codec" != "h264" ] || [ "$pix" != "yuv420p" ]; then
    echo "  converting $codec/$pix to h264/yuv420p"
    tmp="$OUT_ABS/.$name.tmp.mp4"
    ffmpeg -nostdin -v error -y -i "$mp4" -c:v libx264 -pix_fmt yuv420p -crf 16 -preset slow -r 30 -movflags +faststart -c:a copy "$tmp"
    mv "$tmp" "$mp4"
  fi
  dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")"
  size="$(wc -c <"$mp4" | tr -d ' ')"
  echo "  ok $DIR/renders/$name.mp4 ($(calc "$dur")s, $(calc "$size / 1048576") MB)"
done

echo
echo "Next: bash $SKILL_DIR/scripts/qa.sh $DIR"
