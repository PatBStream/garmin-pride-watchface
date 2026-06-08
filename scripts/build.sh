#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_HOME="${CIQ_SDK_HOME:-/home/pat/.local/garmin-connectiq/sdk-9.1.0}"
KEY="${CIQ_DEVELOPER_KEY:-/home/pat/.Garmin/ConnectIQ/developer_key.der}"
DEVICE="${1:-}"

cd "$ROOT"
mkdir -p build

exec 9>"$ROOT/build/.build.lock"
flock 9

node scripts/generate_assets.js

if [[ ! -f "$KEY" ]]; then
  mkdir -p "$(dirname "$KEY")"
  openssl genrsa -out /home/pat/.Garmin/ConnectIQ/developer_key.pem 4096
  openssl pkcs8 \
    -topk8 \
    -inform PEM \
    -outform DER \
    -in /home/pat/.Garmin/ConnectIQ/developer_key.pem \
    -out "$KEY" \
    -nocrypt
  chmod 600 /home/pat/.Garmin/ConnectIQ/developer_key.pem "$KEY"
fi

OUTPUT="build/PrideDashboard.prg"
if [[ -n "$DEVICE" ]]; then
  OUTPUT="build/PrideDashboard-${DEVICE}.prg"
fi

args=(
  -f monkey.jungle
  -o "$OUTPUT"
  -y "$KEY"
  -w
  -l 1
)

if [[ -n "$DEVICE" ]]; then
  args=(-d "$DEVICE" "${args[@]}")
fi

"$SDK_HOME/bin/monkeyc" "${args[@]}"
echo "Built $OUTPUT"
