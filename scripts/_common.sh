#!/usr/bin/env bash
# Shared helpers for the carousel scripts. Sourced, not run directly.
# Works with bash 3.2 (macOS default) and newer bash on Linux.

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Split words on newlines and tabs only, so paths with spaces survive loops.
IFS=$'\n\t'

die() {
  echo "error: $*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "$1 not found. $2"
}

# HyperFrames CLI: use the global install if present, else npx.
hf() {
  if command -v hyperframes >/dev/null 2>&1; then
    hyperframes "$@"
  else
    npx --yes hyperframes "$@"
  fi
}

# Never send frames to a third-party vision service from these scripts.
# (hyperframes snapshot can call one automatically when GEMINI_API_KEY is set.)
hf_private() {
  env -u GEMINI_API_KEY bash -c 'if command -v hyperframes >/dev/null 2>&1; then hyperframes "$@"; else npx --yes hyperframes "$@"; fi' _ "$@"
}

# Root data-duration of a slide project (first data-duration in index.html).
slide_duration() {
  local d
  d="$(grep -o 'data-duration="[0-9.]*"' "$1/index.html" | head -n 1 | sed -E 's/[^0-9.]//g')"
  [ -n "$d" ] || die "no data-duration found in $1/index.html"
  echo "$d"
}

# Float math without bc: calc "6 / 2"
calc() {
  awk "BEGIN { printf \"%.3f\", $1 }"
}

# List slide project folders in order (slides/slide-01, slides/slide-02, ...)
list_slides() {
  local dir="$1"
  [ -d "$dir/slides" ] || die "$dir/slides not found. Run scripts/new-carousel.sh first."
  find "$dir/slides" -mindepth 1 -maxdepth 1 -type d -name 'slide-*' | sort
}

# In-place text replace that works on both BSD and GNU sed.
replace_in_file() {
  local file="$1" from="$2" to="$3" tmp
  tmp="$(mktemp)"
  sed "s|$from|$to|g" "$file" >"$tmp" && cat "$tmp" >"$file"
  rm -f "$tmp"
}
