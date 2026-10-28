#!/usr/bin/env bash
# Frame QA on the rendered slides. Must print "QA PASS" before anything is uploaded.
#
#   bash scripts/qa.sh <carousel-dir>
#
# Checks per renders/slide-NN.mp4:
#   - 1080x1350, H.264, yuv420p, 30 fps
#   - duration 3 to 15 s (warns outside the 5 to 7 s target)
#   - no black stretches (ffmpeg blackdetect) and no blank, single-color frames
#   - file size sane (fails under 20 KB or over 100 MB, warns over 30 MB)
# Carousel checks:
#   - 2 or more slides (warns above 10: check your account's current carousel limit)
#   - exports qa/cover-frame0.png (slide 1, frame 0, the Instagram cover)
#   - warns if slide 1 frame 0 looks very different from its settled frame
# Writes qa/report.txt. Exit code 0 on pass, 1 on fail.
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ $# -ge 1 ] || die "usage: qa.sh <carousel-dir>"
DIR="${1%/}"
need ffmpeg "Install ffmpeg (macOS: brew install ffmpeg, Linux: apt install ffmpeg)."
need ffprobe "ffprobe ships with ffmpeg."
ls "$DIR"/renders/slide-*.mp4 >/dev/null 2>&1 || die "no renders/slide-*.mp4 in $DIR. Run render-slides.sh first."

mkdir -p "$DIR/qa"
REPORT="$DIR/qa/report.txt"
: >"$REPORT"
FAILS=0
WARNS=0
COUNT=0

say() { echo "$*" | tee -a "$REPORT"; }
fail() { say "  FAIL $*"; FAILS=$((FAILS + 1)); }
warn() { say "  WARN $*"; WARNS=$((WARNS + 1)); }
ok() { say "  ok   $*"; }

say "QA report for $DIR"
say ""

for mp4 in $(ls "$DIR"/renders/slide-*.mp4 | sort); do
  COUNT=$((COUNT + 1))
  name="$(basename "$mp4" .mp4)"
  say "$name"

  w="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$mp4")"
  h="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$mp4")"
  codec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$mp4")"
  pix="$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$mp4")"
  fps="$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of csv=p=0 "$mp4")"
  dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$mp4")"
  size="$(wc -c <"$mp4" | tr -d ' ')"

  if [ "$w" = "1080" ] && [ "$h" = "1350" ]; then ok "size ${w}x${h}"; else fail "size ${w}x${h}, expected 1080x1350"; fi
  if [ "$codec" = "h264" ]; then ok "codec h264"; else fail "codec $codec, expected h264"; fi
  if [ "$pix" = "yuv420p" ]; then ok "pixel format yuv420p"; else fail "pixel format $pix, expected yuv420p"; fi
  fpsn="$(awk -v f="$fps" 'BEGIN { split(f, a, "/"); if (a[2] == "" || a[2] == 0) a[2] = 1; printf "%.2f", a[1] / a[2] }')"
  if awk "BEGIN { exit !($fpsn > 29.9 && $fpsn < 30.1) }"; then ok "fps $fpsn"; else fail "fps $fpsn, expected 30"; fi

  if awk "BEGIN { exit !($dur >= 3 && $dur <= 15) }"; then
    if awk "BEGIN { exit !($dur >= 4.9 && $dur <= 7.1) }"; then ok "duration $(calc "$dur")s"; else warn "duration $(calc "$dur")s is outside the 5 to 7 s target"; fi
  else
    fail "duration $(calc "$dur")s, must be 3 to 15 s"
  fi

  mb="$(calc "$size / 1048576")"
  if [ "$size" -lt 20480 ]; then fail "file is only $size bytes, probably empty"
  elif [ "$size" -gt 104857600 ]; then fail "file is ${mb} MB, too large"
  elif [ "$size" -gt 31457280 ]; then warn "file is ${mb} MB, large for one slide"
  else ok "file ${mb} MB"; fi

  # Black stretches: 0.1 s or longer where 98 percent of pixels are near black.
  black="$(ffmpeg -nostdin -v info -i "$mp4" -vf "blackdetect=d=0.1:pic_th=0.98:pix_th=0.05" -an -f null - 2>&1 | grep -o 'black_start:[0-9.]* black_end:[0-9.]*' || true)"
  if [ -z "$black" ]; then ok "no black frames"; else fail "black frames: $(echo "$black" | tr '\n' ' ')"; fi

  # Blank frames: sample 4 frames per second; a frame whose brightest and darkest
  # pixels are within 24 levels is a single flat color (nothing on screen).
  blank="$(ffmpeg -nostdin -v error -i "$mp4" -vf "fps=4,signalstats,metadata=mode=print:file=-" -an -f null - 2>/dev/null \
    | awk '/pts_time/ { split($0, p, "pts_time:"); t = p[2] + 0 }
           /lavfi.signalstats.YMIN=/ { split($0, a, "="); ymin = a[2] + 0 }
           /lavfi.signalstats.YMAX=/ { split($0, b, "="); if (b[2] - ymin < 24) printf "%.2fs ", t }')"
  if [ -z "$blank" ]; then ok "no blank frames"; else fail "blank single-color frames at: $blank"; fi
done

say ""
say "carousel"
if [ "$COUNT" -lt 2 ]; then fail "$COUNT slide(s); a carousel needs at least 2"
elif [ "$COUNT" -gt 10 ]; then warn "$COUNT slides; check your account's current carousel limit in the app"
else ok "$COUNT slides"; fi

first="$(ls "$DIR"/renders/slide-*.mp4 | sort | head -n 1)"
ffmpeg -nostdin -v error -y -i "$first" -frames:v 1 "$DIR/qa/cover-frame0.png"
ok "cover exported: $DIR/qa/cover-frame0.png (check the whole hook is readable)"

# Cover rule: frame 0 must already carry the whole hook. Compare how much text and
# detail (edge density) is on screen at frame 0 versus the settled frame at 60 percent.
# Subtle drift keeps the ratio near 1; a hook that fades or types in drops it sharply.
edges() {
  ffmpeg -nostdin -v error -i "$1" -vf "format=gray,edgedetect=low=0.1:high=0.3,signalstats,metadata=mode=print:file=-" -f null - 2>/dev/null \
    | awk -F= '/lavfi.signalstats.YAVG=/ { print $2 + 0; exit }'
}
fdur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$first")"
ffmpeg -nostdin -v error -y -ss "$(calc "$fdur * 0.6")" -i "$first" -frames:v 1 "$DIR/qa/.cover-settled.png"
e0="$(edges "$DIR/qa/cover-frame0.png")"
es="$(edges "$DIR/qa/.cover-settled.png")"
rm -f "$DIR/qa/.cover-settled.png"
if [ -n "$e0" ] && [ -n "$es" ] && awk "BEGIN { exit !($es > 0) }"; then
  ratio="$(calc "$e0 / $es")"
  if awk "BEGIN { exit !($ratio >= 0.85) }"; then ok "cover frame 0 shows as much text as the settled cover (ratio $ratio)"
  else fail "cover frame 0 has much less on screen than the settled cover (ratio $ratio). The hook must be fully visible at frame 0"; fi
else
  warn "could not measure the cover; open qa/cover-frame0.png and check the hook by eye"
fi

say ""
if [ "$FAILS" -eq 0 ]; then
  say "QA PASS ($COUNT slides, $WARNS warning(s))"
  exit 0
else
  say "QA FAIL ($FAILS failure(s), $WARNS warning(s))"
  exit 1
fi
