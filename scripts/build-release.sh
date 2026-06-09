#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=(venusq2 venusq2m venux1)

cd "$ROOT"

for target in "${TARGETS[@]}"; do
  scripts/build.sh "$target"
done

echo
echo "Release artifacts:"
for target in "${TARGETS[@]}"; do
  artifact="build/PrideDashboard-${target}.prg"
  if [[ -f "$artifact" ]]; then
    size="$(du -h "$artifact" | awk '{print $1}')"
    echo "  $artifact ($size)"
  fi
done
