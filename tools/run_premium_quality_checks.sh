#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

for verifier in \
  tools/verify_ba59.py \
  tools/verify_ba60.py \
  tools/verify_ba61.py \
  tools/verify_ba62.py \
  tools/verify_ba63.py \
  tools/verify_ba64.py
do
  python3 "$verifier"
done
