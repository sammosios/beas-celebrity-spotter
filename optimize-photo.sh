#!/usr/bin/env bash
# Usage: ./optimize-photo.sh photo.jpg [photo2.webp ...]
# Resizes and compresses images into assets/optimized/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/assets/optimized"
MAX_PX=400  # max width or height — circles are 112px, 400px gives plenty of detail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <image file(s)>"
  echo "Example: $0 assets/taylor.jpg assets/drake.webp"
  exit 1
fi

for input in "$@"; do
  if [[ ! -f "$input" ]]; then
    echo "Skipping: $input (file not found)"
    continue
  fi

  filename="$(basename "$input")"
  ext="${filename##*.}"
  ext_lower="${ext,,}"
  out="$OUT_DIR/$filename"

  case "$ext_lower" in
    jpg|jpeg|png|tiff|tif|gif|bmp)
      echo "Optimizing: $filename"
      sips --resampleHeightWidthMax $MAX_PX \
           --setProperty formatOptions 85 \
           "$input" --out "$out" > /dev/null
      ;;
    webp|avif|heic|heif)
      # sips can't compress these formats — copy as-is (they're usually small already)
      echo "Copying (unsupported for resize): $filename"
      cp "$input" "$out"
      ;;
    *)
      echo "Skipping: $filename (unknown format)"
      continue
      ;;
  esac

  orig_size=$(du -sh "$input" | cut -f1)
  new_size=$(du -sh "$out" | cut -f1)
  echo "  $orig_size -> $new_size  =>  $out"
done
