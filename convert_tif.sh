#!/bin/bash -x
# Converts single-page tif scans into a multi-page pdf file
# Scans need to be in tif format
set -e
[[ ! "$1" ]] && { echo "Usage: $0 <pdf_name>"; exit 1; }
fn="$1"
[[ "$fn" != *.pdf ]] && fn="${fn}.pdf"
for file in *.tif; do convert -quality 60 "$file" "${file%.tif}.jpg"; done
convert *.jpg "${fn}"
